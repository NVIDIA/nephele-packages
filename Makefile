# Copyright (c) 2020, NVIDIA CORPORATION. All rights reserved.
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

.PHONY: all slurm pyxis gdrcopy gpudirect mostlyclean clean

CONTAINER_NAME        ?= ubuntu
UBUNTU_VERSION        ?= 20.04
SLURM_VERSION         ?= 20.11.4.1
PYXIS_VERSION         ?= 0.9.1
GDRCOPY_VERSION       ?= f203d7510aa3cec9f0d8238be18e1efa77494fa1
GPUDIRECT_VERSION     ?= 1.1-0
NVIDIA_DRIVER_VERSION ?= 460.32.03-0ubuntu1
KERNEL_VERSION        ?= generic

export

all: slurm pyxis gdrcopy gpudirect

slurm: .slurm.stamp
pyxis: .pyxis.stamp | slurm
gdrcopy: .gdrcopy.stamp
gpudirect: .gpudirect.stamp

.%.stamp: .$(CONTAINER_NAME).stamp
	$*/build
	touch $@

.$(CONTAINER_NAME).stamp: ubuntu.sqsh
	enroot create -n $(CONTAINER_NAME) $<
	touch $@

ubuntu.sqsh:
	enroot import -o $@ docker://ubuntu:$(UBUNTU_VERSION)

mostlyclean:
	-enroot remove -f $(CONTAINER_NAME)
	rm -f *.sqsh .*.stamp

clean: mostlyclean
	rm -f *.orig.tar.* *.debian.tar.* *.dsc *.deb
