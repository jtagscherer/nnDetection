#Copyright 2020 Division of Medical Image Computing, German Cancer Research Center (DKFZ), Heidelberg, Germany
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

# Contains pytorch, torchvision, cuda, cudnn
FROM doduo1.umcn.nl/uokbaseimage/diag:tf2.12-pt2.0-v1

ARG env_det_num_threads=6
ARG env_det_verbose=1

# Setup environment variables
ENV det_data=/opt/data det_models=/opt/models det_num_threads=$env_det_num_threads det_verbose=$env_det_verbose OMP_NUM_THREADS=1

# Install some tools
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && apt-get install -y \
 git \
 cmake \
 make \
 wget \
 gnupg \
 build-essential \
 software-properties-common \
 gdb \
 ninja-build \
 openssh-server

# Enable password-based login via SSH
RUN mkdir /var/run/sshd
RUN echo 'root:passforroot' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# updating requests and urllib3 fixed compatibility with my docker version
RUN pip3 install --upgrade pip \
  && pip3 install numpy \
  && pip3 install --upgrade requests \
  && pip3 install --upgrade urllib3 \
  && pip3 install setuptools

# Install own code
COPY ./requirements.txt .
RUN mkdir ${det_data} \
  && mkdir ${det_models} \
  && mkdir -p /opt/code/nndet \
  && pip3 install -r requirements.txt  \
  && pip3 install hydra-core --upgrade --pre \
  && pip3 install git+https://github.com/mibaumgartner/pytorch_model_summary.git

WORKDIR /opt/code/nndet
COPY . .
# RUN FORCE_CUDA=1 pip3 install -v -e .
