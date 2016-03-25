#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2015, Alcatel-Lucent Inc
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the copyright holder nor the names of its contributors
#       may be used to endorse or promote products derived from this software without
#       specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import os
import re
from optparse import OptionParser


def generate_file(output_file, subfolder, classprefix):

    if not output_file:
        output_file = os.getcwd().split("/")[-1]
        if not output_file.startswith(classprefix):
            output_file = "%s%s" % (classprefix, output_file)

    files = list()

    for (dirpath, dirnames, filenames) in os.walk("."):
        for filename in filenames:
            path = dirpath
            tmp_output_file = filename

            if (path == "."):
                path = ""

            if (path[:2] == "./"):
                if not subfolder:
                    continue
                else:
                    path = path[2:len(path)] + "/"

            name = path + tmp_output_file

            objective_j_file = re.search('(\w*.j)', tmp_output_file)

            if objective_j_file and name != "%s.j" % output_file:
                files.append(name)

    destination_file = open(output_file + ".j", 'w')
    destination_file.write("\n\n")

    for f in files:
        import_string = "@import \"%s\"\n" % f
        destination_file.write(import_string)

    destination_file.close()

if __name__ == "__main__":
    parser = OptionParser()
    parser.add_option("-o", "--output",
                      dest="output",
                      help="Name of the file to generate")
    parser.add_option("-r", "--recursive",
                      action="store_true",
                      dest="recursive",
                      help="Import the files find in the subfolder")
    parser.add_option("-p", "--class-prefix",
                      dest="classprefix",
                      help="Set the class prefix to use")

    options, args = parser.parse_args()

    generate_file(options.output, options.recursive, options.classprefix)
