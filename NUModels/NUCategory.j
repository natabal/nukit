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


@implementation NUCategory : CPObject
{
    BOOL            _dataSourceFilterShouldIgnore   @accessors(getter=dataSourceFilterShouldIgnore);
    CPArray         _children                       @accessors(property=children);
    CPString        _name                           @accessors(property=name);
    CPString        _contextIdentifier              @accessors(property=contextIdentifier);
    CPPredicate     _filter                         @accessors(property=filter);
    CPNumber        _currentPage                    @accessors(property=currentPage);
    CPNumber        _currentTotalCount              @accessors(property=currentTotalCount);
}

+ (id)categoryWithName:(CPString)aName
{
    return [[NUCategory alloc] initWithName:aName];
}

+ (id)categoryWithName:(CPString)aName contextIdentifier:(CPString)aContext
{
    return [[NUCategory alloc] initWithName:aName
                          contextIdentifier:aContext];
}


+ (id)categoryWithName:(CPString)aName contextIdentifier:(CPString)aContext filter:(id)aFilter
{
    return [[NUCategory alloc] initWithName:aName
                          contextIdentifier:aContext
                                     filter:aFilter];
}

- (id)initWithName:(CPString)aName
{
    return [self initWithName:aName contextIdentifier:nil filter:nil];
}

- (id)initWithName:(CPString)aName contextIdentifier:(CPString)aContext
{
    return [self initWithName:aName contextIdentifier:aContext filter:nil];
}

- (id)initWithName:(CPString)aName contextIdentifier:(CPString)aContext filter:(id)aFilter
{
    if (self = [super init])
    {
        _children                     = [];
        _contextIdentifier            = aContext;
        _dataSourceFilterShouldIgnore = YES;
        _filter                       = aFilter;
        _name                         = aName;
        _currentPage                  = -1;
        _currentTotalCount            = -1;
    }

    return self;
}

- (CPString)description
{
    return _name;
}

- (id)valueForUndefinedKey:(CPString)aKey
{
    return nil;
}

- (void)sortUsingDescriptors:(CPArray)someDescriptors
{
    [_children sortUsingDescriptors:someDescriptors];
}

@end
