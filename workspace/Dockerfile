ARG TAG
FROM wn1980/nvidia-ros${TAG}

LABEL maintainer="Waipot Ngamsaad <waipotn@hotmail.com>"

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND noninteractive

#RUN  apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

#RUN sed -i -e 's/http:\/\/archive/mirror:\/\/mirrors/' -e 's/http:\/\/security/mirror:\/\/mirrors/' -e 's/\/ubuntu\//\/mirrors.txt/' /etc/apt/sources.list

RUN apt-get update && apt-get upgrade -y 
RUN apt-get install -y \
    apt-transport-https \
    build-essential \
    curl \
    git \
    wget \
    nano && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' && \
    curl -L http://packages.osrfoundation.org/gazebo.key | apt-key add -

RUN apt-get update && apt-get upgrade -y 
RUN apt-get install -y \
    #ros-${ROS_DISTRO}-desktop-full \
    #ros-${ROS_DISTRO}-linux-peripheral-interfaces \
    #ros-${ROS_DISTRO}-diagnostics \
    #ros-${ROS_DISTRO}-navigation \
    #ros-${ROS_DISTRO}-hector-slam \
    #ros-${ROS_DISTRO}-octomap-server \
    #ros-${ROS_DISTRO}-octomap-rviz-plugins \
    ros-${ROS_DISTRO}-rviz \
    ros-${ROS_DISTRO}-vision-opencv \
    ros-${ROS_DISTRO}-nodelet \
    ros-${ROS_DISTRO}-usb-cam \
    ros-${ROS_DISTRO}-image-view \
    libboost-all-dev \
    python-rosdep && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get upgrade -y 
RUN apt-get install -y \
    bash-completion \
    #less \
    htop \
    tmux \
    terminator \
    xfe \
    #fluxbox \
    jwm \
    xfonts-base \
    xauth \
    x11-xkb-utils \
    xkb-data \
    dbus-x11 \
    net-tools \
    usbutils \
    sudo \
    tigervnc-standalone-server \
    #tigervnc-xorg-extension \
    #python-is-python3 \
    python-pip && \
    pip install -U --no-cache-dir supervisor supervisor_twiddler && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install noVNC
ENV NO_VNC_HOME=/app/noVNC

RUN rm -Rf $NO_VNC_HOME && \
    mkdir -p $NO_VNC_HOME/utils/websockify && \
    wget -qO- https://github.com/novnc/noVNC/archive/v1.2.0.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME && \
    wget -qO- https://github.com/novnc/websockify/archive/v0.10.0.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME/utils/websockify

COPY ./index.html $NO_VNC_HOME

RUN rm /etc/apt/apt.conf.d/docker-clean
    
# install code-server
ENV VERSION=3.11.1
RUN wget https://github.com/cdr/code-server/releases/download/v${VERSION}/code-server_${VERSION}_$(dpkg --print-architecture).deb && \
    dpkg -i code-server_${VERSION}_$(dpkg --print-architecture).deb && \
    rm -f code-server_${VERSION}_$(dpkg --print-architecture).deb

RUN rosdep init

RUN mkdir -p /workspace

# setup user
RUN useradd -m developer && \
    usermod -aG sudo developer && \
    usermod --shell /bin/bash developer && \
    chown -R developer:developer /workspace && \
    ln -sfn /workspace /home/developer/workspace && \
    echo developer ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer

ENV USER=developer

ENV HOME /home/developer

ENV SHELL /bin/bash

USER $USER

WORKDIR /home/developer

# init rosdep
RUN rosdep fix-permissions && rosdep update

# colorize less
#RUN echo "export LESS='-R'" >> ~/.bash_profile && \
#    echo "export LESSOPEN='|pygmentize -g %s'" >> ~/.bash_profile

# enable bash completion
RUN echo "source /usr/share/bash-completion/bash_completion" >> ~/.bashrc && \
    #git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it && \
    #~/.bash_it/install.sh --silent && \
    #rm ~/.bashrc.bak && \
    #bash -i -c "bash-it enable completion git" && \
    echo "source ~/.bashrc" >> ~/.bash_profile 

RUN mkdir -p ~/catkin_ws/src && \
    cd ~/catkin_ws/src && \
    git clone --recursive https://github.com/leggedrobotics/darknet_ros.git

RUN cd ~/catkin_ws && \
    source /opt/ros/$ROS_DISTRO/setup.bash && \
    catkin_make -DCMAKE_BUILD_TYPE=Release

RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc && \
    echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc 

COPY ./usb-cam.launch /

COPY ./app /app

VOLUME /tmp/.X11-unix

ENV DISPLAY ":1"

EXPOSE 8008 9901

CMD ["sudo", "-E", "/usr/local/bin/supervisord", "-c", "/app/supervisord.conf"]