# Copyright (c) 2022, NVIDIA CORPORATION. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

.PHONY: all slurm pyxis gdrcopy mostlyclean clean

SHELL := /bin/bash

CONTAINER_NAME        ?= ubuntu
UBUNTU_VERSION        ?= 20.04
SLURM_VERSION         ?= 21.08.5.1
PYXIS_VERSION         ?= 0.11.1
GDRCOPY_VERSION       ?= v2.3
NVIDIA_DRIVER_VERSION ?= 470.161.03-0ubuntu1
KERNEL_VERSION        ?= generic

export

all: slurm pyxis gdrcopy

slurm: .slurm.stamp
pyxis: .pyxis.stamp | slurm
gdrcopy: .gdrcopy.stamp

ifdef CONTAINERIZED_BUILD

.%.stamp: .$(CONTAINER_NAME).stamp
	$*/build
	touch $@

.$(CONTAINER_NAME).stamp: ubuntu.sqsh
	enroot create -n $(CONTAINER_NAME) $<
	touch $@

ubuntu.sqsh:
	enroot import -o $@ dockerd://ubuntu:$(UBUNTU_VERSION)

mostlyclean:
	-enroot remove -f $(CONTAINER_NAME)
	rm -f *.sqsh .*.stamp

else

.%.stamp:
	source $*/build && source <(environ) && rc
	touch $@

mostlyclean:
	rm -f *.sqsh .*.stamp

endif

clean: mostlyclean
	rm -f *.orig.tar.* *.debian.tar.* *.dsc *.deb
