/*
* Copyright (c) 2016, Alcatel-Lucent Inc
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the copyright holder nor the names of its contributors
*       may be used to endorse or promote products derived from this software without
*       specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

@import <Foundation/Foundation.j>
@import <AppKit/CPSearchField.j>
@import <AppKit/CPViewAnimation.j>

@class _CPPopoverWindow

@global CPApp


/*! NUExpandableSearchField is the field you can use in NUModule interfaces.
    When double clicking on the little magnifier of this text field,
    the NUAdvancedFilteringView of the NUModule owning this field will be shown.
*/
@implementation NUExpandableSearchField : CPSearchField
{
    BOOL                _isExpanded         @accessors(property=isExpanded);
    CPViewAnimation     _animation;
    int                 _contractedWidth;
    int                 _expandedWidth;

    id                  _timeout;
}

- (void)awakeFromCib
{
    _expandedWidth = [self _widthFromSuperView];
    _contractedWidth = 22;
    _timeout = nil;

    _animation = [[CPViewAnimation alloc] initWithDuration:0.2 animationCurve:CPAnimationEaseInOut];
    [_animation setDelegate:self];

    [self _contractWithAnimation:NO];
}


#pragma mark -
#pragma mark Overrides

- (BOOL)resignFirstResponder
{
    if ([self isExpanded] && [[self stringValue] length] == 0)
        [self _contractWithAnimation:![self isHidden]]; // Animation will reset isHidden to YES

    return [super resignFirstResponder];
}

- (BOOL)acceptsFirstResponder
{
    return ![self isHidden];
}

- (BOOL)becomeFirstResponder
{
    if (![self isExpanded])
    {
        [self _expandWithAnimation:YES];
        return; // Will be first responder after expansion
    }

    return [super becomeFirstResponder];
}

- (CPView)hitTest:(CGPoint)aPoint
{
    var keyWindow = [CPApp keyWindow];

    if ([keyWindow isKindOfClass:_CPPopoverWindow] && keyWindow != [self window])
        return nil;

    return [super hitTest:aPoint];
}


#pragma mark -
#pragma mark Mouse and Keyboard events

- (void)mouseDown:(CPEvent)anEvent
{
    if ([self isHidden])
        return;

    if (_timeout || [_animation isAnimating])
        return;

    if (![self isExpanded])
    {
        _timeout = setTimeout(function()
        {
            if ([[CPApp currentEvent] clickCount] === 1)
                [self _expandWithAnimation:YES];

            else if ([[CPApp currentEvent] clickCount] === 2 && [[self searchButton] target] && [[self searchButton] action])
                [super mouseDown:anEvent];

            _timeout = nil;
        }, 300);
    }
    else
    {
        [super mouseDown:anEvent];
    }
}

- (BOOL)performKeyEquivalent:(CPEvent)anEvent
{
    var key = [anEvent charactersIgnoringModifiers];

    if (key === CPEscapeFunctionKey && [[self window] firstResponder] == self)
    {
        [self _simulateCancelOperation];
    }

    return [super performKeyEquivalent:anEvent];
}

- (void)setStringValue:(CPString)aString
{
    if ([aString length] > 0 && ![self isExpanded])
        [self _expandWithAnimation:YES];

    if ([aString length] == 0 && [self isExpanded])
    {
        [self _simulateCancelOperation];
        [self _contractWithAnimation:YES];
    }

    [super setStringValue:aString];
}

- (void)_simulateCancelOperation
{
    if ([[self stringValue] length] > 0)
        [self cancelOperation:[self cancelButton]];

    [[self window] makeFirstResponder:nil];
}


#pragma mark -
#pragma mark Animations

- (void)_contractWithAnimation:(bool)shouldAnimate
{
    var frame   = [self frame],
        mask    = [self autoresizingMask];

    _expandedWidth = [self _widthFromSuperView];

    if (!(mask & CPViewMaxXMargin))
    {
        var marginRight = [[self superview] frameSize].width - frame.origin.x - frame.size.width;
        frame.origin.x = marginRight + _expandedWidth - _contractedWidth;
    }

    frame.size.width = _contractedWidth;

    if (shouldAnimate)
    {
        var animationInfo = @{
                CPViewAnimationTargetKey: self,
                CPViewAnimationStartFrameKey: [self frame],
                CPViewAnimationEndFrameKey: frame,
                CPViewAnimationEffectKey: CPAnimationEaseInOut
            };

        [_animation setViewAnimations:[animationInfo]];
        [_animation startAnimation];
    }
    else
        [self setFrame:frame];

    [self setIsExpanded:NO];
}

- (void)_expandWithAnimation:(bool)shouldAnimate
{
    var frame = [self frame],
        mask = [self autoresizingMask];

    _expandedWidth = [self _widthFromSuperView];
    frame.size.width = _expandedWidth;

    if (!(mask & CPViewMinXMargin))
        frame.size.width = _expandedWidth - frame.origin.x;

    if (!(mask & CPViewMaxXMargin))
        frame.origin.x = frame.origin.x - _expandedWidth + _contractedWidth;

    if (shouldAnimate)
    {
        var animationInfo = @{
                CPViewAnimationTargetKey: self,
                CPViewAnimationStartFrameKey: [self frame],
                CPViewAnimationEndFrameKey: frame,
                CPViewAnimationEffectKey: CPAnimationEaseInOut
            };

        [_animation setViewAnimations:[animationInfo]];
        [_animation startAnimation];
    }
    else
    {
        [self setFrame:frame];
        [super becomeFirstResponder];
    }

    [self setIsExpanded:YES];
}

- (void)animationDidEnd:(CPAnimation)anAnimation
{
    var mask = [self autoresizingMask];

    if ([self isExpanded])
    {
        [[self window] makeFirstResponder:self];
        [self setAutoresizingMask: mask | CPViewMinXMargin | CPViewWidthSizable];
    }
    else
        [self setAutoresizingMask: mask & ~CPViewWidthSizable];
}


#pragma mark -
#pragma mark Private methods

- (int)_widthFromSuperView
{
    var parentWidth = [[self superview] frameSize].width,
        margin = [self frameOrigin].x,
        mask = [self autoresizingMask];

    if (!(mask & CPViewMaxXMargin))
    {
        margin = parentWidth - [self frameOrigin].x - [self frameSize].width
    }

    return parentWidth - (2 * margin);
}

@end
