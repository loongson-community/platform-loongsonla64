# Copyright 2014-present PlatformIO <contact@platformio.org>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
Lafk

https://www.loongson.com
"""

import sys
from os.path import join, isfile

from SCons.Script import DefaultEnvironment, SConscript

env = DefaultEnvironment()
mcu = env.BoardConfig().get("build.mcu")
core = env.BoardConfig().get("build.core", "")

#SConscript(build_script)
