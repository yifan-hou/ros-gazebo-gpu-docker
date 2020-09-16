# ROS Melodic + NVIDIA + ROS Control in Docker

## How to build the image
```bash
cd docker/nvidia
./build.sh
```
You can find the docker file and config files under `docker/nvidia`.

You'll be user `ros` with password `ros` and `sudo` powers. The current directory will be mounted to `/workspace` in the container.

## How to run the container
```
./run-nvidia.sh
```

## A script to make your life easier
`scripts/docker_run.sh` is a script for create/start/attach to the same container from multiple terminals. Use it to quickly get in your container without worrying about duplicating your container.

The behavior of the script is as follows. If the container is:
* **Running**, then connect to it in a new terminal.
* **Stopped**, then start it and connect to it.
* **Not yet created**, then create it (you must have already built the image).

Suggested use of the script:
``` bash
# in your host machine
cp docker_run.sh ~/bin # copy it to ~/bin
echo "export PATH="~/bin:$PATH"" >> ~/.bashrc # add ~/bin to your path
source ~/.bashrc
cd ~/bin
mv docker_run.sh rosstart # give it a convenient name, remove the '.sh' postfix
chmod -x rosstart # give it executable access

# from anywhere
rosstart # run the container
# from another terminal
rosstart # run another terminal on this container
```

## todo
add to dockerfile:
``` bash
sudo apt-get install ros-melodic-catkin python-catkin-tools
rosdep install kdl_parser
rosmake kdl_parser
```



---
## Sourced documentation
- [Ubuntu install of ROS Melodic](http://wiki.ros.org/melodic/Installation/Ubuntu)
- [Hardware Acceleration](http://wiki.ros.org/docker/Tutorials/Hardware%20Acceleration)
- [nvidia/cudagl](https://hub.docker.com/r/nvidia/cudagl/tags?page=1&name=16.04) Docker image

Modified based on https://github.com/sunsided/ros-gazebo-gpu-docker