FROM nvidia/cudagl:10.2-base-ubuntu18.04
# FROM nvidia/cudagl:9.0-base-ubuntu16.04
#FROM osrf/ros:kinetic-desktop-full-xenial

ARG DEBIAN_FRONTEND=noninteractive

# Run a full upgrade and install utilities for development.
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    mesa-utils \
    vim \
    build-essential gdb \
    cmake cmake-curses-gui \
    git \
    ssh \
    terminator \
    gnome-terminal \
    software-properties-common \
 && rm -rf /var/lib/apt/lists/*

# Register the ROS package sources.
ENV UBUNTU_RELEASE=bionic
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $UBUNTU_RELEASE main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# Install ROS.
RUN apt-get update && apt-get install -y \
    ros-melodic-desktop-full \
    python-rosdep python-rosinstall python-rosinstall-generator \
    python-wstool build-essential

# Install Gazebo and ROS control
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
RUN wget https://packages.osrfoundation.org/gazebo.key -O - | apt-key add -
RUN apt-get update && apt-get install -y \
    ros-melodic-gazebo11-ros-pkgs ros-melodic-gazebo11-ros-control \
    ros-melodic-ros-control ros-melodic-ros-controllers

RUN apt-get install ros-melodic-catkin python-catkin-tools

# clean up source lists after installation
RUN rm -rf /var/lib/apt/lists/*

# Only for nvidia-docker 1.0
LABEL com.nvidia.volumes.needed="nvidia_driver"
# ENV PATH /usr/local/nvidia/bin:${PATH}
# ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

# nvidia-container-runtime (nvidia-docker2)
ENV NVIDIA_VISIBLE_DEVICES \
   ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
   ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

# Some QT-Apps/Gazebo don't show controls without this
ENV QT_X11_NO_MITSHM 1

# Create users and groups.
ARG ROS_USER_ID=1000
ARG ROS_GROUP_ID=1000

RUN addgroup --gid $ROS_GROUP_ID ros \
 && useradd --gid $ROS_GROUP_ID --uid $ROS_USER_ID -ms /bin/bash -p "$(openssl passwd -1 ros)" -G root,sudo ros \
 && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
 && mkdir -p /workspace \
 && ln -s /workspace /home/workspace \
 && chown -R ros:ros /home/ros /workspace

USER ros

# Initialize rosdep
RUN sudo rosdep init
RUN rosdep update
RUN rosdep install kdl_parser
RUN rosmake kdl_parser

# Setup terminator
RUN mkdir -p /home/ros/.config/terminator/
COPY configs/terminator_config /home/ros/.config/terminator/config

RUN sh -c "$(wget -O- https://raw.githubusercontent.com/deluan/zsh-in-docker/master/zsh-in-docker.sh)"


##
## config bash
##
COPY configs/bash_aliases /home/ros/.bash_aliases
COPY configs/bashrc /home/ros/bashrc
RUN cat /home/ros/bashrc >> /home/ros/.bashrc
RUN rm /home/ros/bashrc

# ROS
RUN echo "source /opt/ros/melodic/setup.bash" >> /home/ros/.bashrc
# If the script is started from a Catkin workspace,
# source its configuration as well.
RUN echo "test -f /workspace/catkin_ws/devel/setup.bash && echo \"Found Catkin workspace.\" && source /workspace/catkin_ws/devel/setup.bash" >> /home/ros/.bashrc

WORKDIR /workspace

VOLUME /workspace/catkin_ws
VOLUME /workspace/Git
