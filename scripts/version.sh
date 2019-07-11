#!/bin/bash
################################################################################
#
# Copyright (c) 2017 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

CURRENT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

set -e

. "${CURRENT_DIR}"/product.sh

######################################
# get the package version information
######################################
get_package_version() {
  echo "The packages version information list"

  local package_dir
  local package_size
  local package_size_git
  local package_size_src
  local package_version
  local package_name
  local version_file

  package_dir=$(get_rdk_ws_dir)
  version_file=$(get_config_dir)/version_package.ini
  echo -e "$(date)" > "$version_file"

  cd "$package_dir" ||exit
  read -r -a array <<< "$(find "$package_dir" -name ".git" |tr "\n" " ")"
  for package in "${array[@]}"
  do
    package=${package%/.git*}
    cd "$package" || exit
    package_size=$(du -s |awk '{print $1}')
    package_size_git=$(du -s .git |awk '{print $1}')
    package_size_src=$((package_size-package_size_git))
    package_version=$(git rev-parse HEAD)
    package_name=${package##*/}
    echo "[$package_name]" |tee -a "$version_file"
    echo "size=$package_size_src kB" |tee -a "$version_file"
    echo "version=$package_version" |tee -a "$version_file"
    echo "" |tee -a "$version_file"
  done
  echo "Save the package version information to $version_file"
}


#######################################
# Print thirdparty version
#######################################
print_thirdparty_version()
{
  # sdk_ws=
  # ros2-linux
  echo "ros2-linux: ros2-dashing-20190531-linux-bionic-amd64.tar.bz2"

  # librealsense
  echo "third_party:"
  echo "  librealsense: master-commitID"

}


#######################################
# Print package version
#######################################
print_pkg_version()
{
  echo "perception_ws:"
  echo "  ros2_object_analytics: version"
  get_package_version

}

print_sdk_version()
{
  commit=$(git rev-parse --short HEAD)
  branch=$(git rev-parse --abbrev-ref HEAD)
  echo "robot_devkit(rdk) version ${branch}-${commit}"
}

######################################
# Print version of this repository
######################################
version() {
  print_sdk_version
  print_pkg_version
  print_thirdparty_version
}

unset CURRENT_DIR
