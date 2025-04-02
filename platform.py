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

import os
import sys
import subprocess

from platformio.managers.platform import PlatformBase
from platformio.project.helpers import get_project_dir


IS_WINDOWS = sys.platform.startswith("win")


class Loongsonla64Platform(PlatformBase):

    def configure_default_packages(self, variables, targets):
        board = variables.get("board")
        board_config = self.board_config(board)
        build_core = variables.get(
            "board_build.core", board_config.get("build.core", "allinone"))

        frameworks = variables.get("pioframework", [])
        if "allinone" in frameworks:
            print("[DEBUG] Found all-in-one framework")
            self.packages["toolchain-loongarch64"]["version"] = "1.0.0"
            self.packages["framework-allinone"]["optional"] = False

        return PlatformBase.configure_default_packages(self, variables,
                                                       targets)

    def install_package(self, name, *args, **kwargs):
        pkg = super().install_package(name, *args, **kwargs)

        return pkg

    def get_boards(self, id_=None):
        result = PlatformBase.get_boards(self, id_)
        if not result:
            return result
        return result
