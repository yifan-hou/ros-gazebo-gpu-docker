##
## This script creates or starts or connects to the mlab_ros container.
## Copy this file to ~/bin and change its access by
##      chmod +x mlab_docker_run.sh
##
##

# See README.md for building this image.
CONTAINER_NAME=mlab_ros
DOCKER_IMAGE=yifan/ros-gpu:melodic-nvidia
GIT_PATH=~/Git
CATKIN_WS_PATH=~/Dockers/mlab/catkin_ws
PKG_PATH=~/Dockers/mlab/ros-gazebo-gpu-docker

set -euo pipefail
if [ "$(docker ps -q -f name="$CONTAINER_NAME")" ]; then
    # the container is already running.
    echo "The container is already running. Now connect to it."
    docker exec -it "$CONTAINER_NAME" bash
    exit
fi

if [ "$(docker ps -aq -f status=exited -f name="$CONTAINER_NAME")" ]; then
    # the container exists but is stopped. start and connect to it
    echo "The container exists but is stopped. Now start and connect to it."
    docker start "$CONTAINER_NAME"
    docker exec -it "$CONTAINER_NAME" bash
    exit
fi

if [ "$(docker ps -aq -f status=created -f name="$CONTAINER_NAME")" ]; then
    # the container is just created. start and connect to it
    echo "The container is just created. Now start and connect to it."
    docker start "$CONTAINER_NAME"
    docker exec -it "$CONTAINER_NAME" bash
    exit
fi

if [ "$(docker ps -aq -f name="$CONTAINER_NAME")" ]; then
    # the container exists but is in an unknown status
    echo "The container exists but is in an unknown status. Please update how to handle this status in this script."
    exit
fi

echo "The container does not exist. Creating it:"

# Which GPUs to use; see https://github.com/NVIDIA/nvidia-docker
GPUS="all"

XSOCK=/tmp/.X11-unix

XAUTH=$PKG_PATH/.tmp/docker.xauth
XAUTH_DOCKER=/tmp/.docker.xauth

if [ ! -f $XAUTH ]
then
    xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
    if [ ! -z "$xauth_list" ]
    then
        echo "$xauth_list" | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi

docker run -it \
    --name "$CONTAINER_NAME" \
    --gpus "$GPUS" \
    --env="DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --env="XAUTHORITY=$XAUTH_DOCKER" \
    --volume="$XSOCK:$XSOCK:rw" \
    --volume="$XAUTH:$XAUTH_DOCKER:rw" \
    -v "$GIT_PATH:/workspace/Git" \
    -v "$CATKIN_WS_PATH:/workspace/catkin_ws" \
    $DOCKER_IMAGE \
    bash