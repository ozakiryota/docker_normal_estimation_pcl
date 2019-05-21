FROM ros:kinetic
# FROM osrf/ros:kinetic-desktop-full

########## basis ##########
RUN apt-get update && apt-get install -y \
	vim \
	wget \
	unzip \
	git
########## ROS setup ##########
RUN mkdir -p /home/ros_catkin_ws/src && \
	cd /home/ros_catkin_ws/src && \
	/bin/bash -c "source /opt/ros/kinetic/setup.bash; catkin_init_workspace" && \
	cd /home/ros_catkin_ws && \
	/bin/bash -c "source /opt/ros/kinetic/setup.bash; catkin_make" && \
	echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc && \
	echo "source /home/ros_catkin_ws/devel/setup.bash" >> ~/.bashrc && \
	echo "export ROS_PACKAGE_PATH=\${ROS_PACKAGE_PATH}:/home/ros_catkin_ws" >> ~/.bashrc && \
	echo "export ROS_WORKSPACE=/home/ros_catkin_ws" >> ~/.bashrc && \
	echo "function cmk(){\n	lastpwd=\$OLDPWD \n	cpath=\$(pwd) \n	cd /home/ros_catkin_ws \n	catkin_make \$@ \n	cd \$cpath \n	OLDPWD=\$lastpwd \n}" >> ~/.bashrc
########## CUDA 8.0 nvidia-docker ##########
## runtime ver.
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates apt-transport-https gnupg-curl && \
	rm -rf /var/lib/apt/lists/* && \
	NVIDIA_GPGKEY_SUM=d1be581509378368edeec8c1eb2958702feedf3bc3d17011adbf24efacce4ab5 && \
	NVIDIA_GPGKEY_FPR=ae09fe4bbd223a84b2ccfce3f60f4b3d7fa2af80 && \
	apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub && \
	apt-key adv --export --no-emit-version -a $NVIDIA_GPGKEY_FPR | tail -n +5 > cudasign.pub && \
	echo "$NVIDIA_GPGKEY_SUM  cudasign.pub" | sha256sum -c --strict - && rm cudasign.pub && \
	echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/cuda.list
	
	ENV CUDA_VERSION 8.0.61

	ENV CUDA_PKG_VERSION 8-0=$CUDA_VERSION-1
	RUN apt-get update && apt-get install -y --no-install-recommends \
			cuda-nvrtc-$CUDA_PKG_VERSION \
			cuda-nvgraph-$CUDA_PKG_VERSION \
			cuda-cusolver-$CUDA_PKG_VERSION \
			cuda-cublas-8-0=8.0.61.2-1 \
			cuda-cufft-$CUDA_PKG_VERSION \
			cuda-curand-$CUDA_PKG_VERSION \
			cuda-cusparse-$CUDA_PKG_VERSION \
			cuda-npp-$CUDA_PKG_VERSION \
			cuda-cudart-$CUDA_PKG_VERSION && \
		ln -s cuda-8.0 /usr/local/cuda && \
		rm -rf /var/lib/apt/lists/*

# nvidia-docker 1.0
LABEL com.nvidia.volumes.needed="nvidia_driver"
LABEL com.nvidia.cuda.version="${CUDA_VERSION}"

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=8.0"

## devel ver.
RUN apt-get update && apt-get install -y --no-install-recommends \
		cuda-core-$CUDA_PKG_VERSION \
		cuda-misc-headers-$CUDA_PKG_VERSION \
		cuda-command-line-tools-$CUDA_PKG_VERSION \
		cuda-nvrtc-dev-$CUDA_PKG_VERSION \
		cuda-nvml-dev-$CUDA_PKG_VERSION \
		cuda-nvgraph-dev-$CUDA_PKG_VERSION \
		cuda-cusolver-dev-$CUDA_PKG_VERSION \
		cuda-cublas-dev-8-0=8.0.61.2-1 \
		cuda-cufft-dev-$CUDA_PKG_VERSION \
		cuda-curand-dev-$CUDA_PKG_VERSION \
		cuda-cusparse-dev-$CUDA_PKG_VERSION \
		cuda-npp-dev-$CUDA_PKG_VERSION \
		cuda-cudart-dev-$CUDA_PKG_VERSION \
		cuda-driver-dev-$CUDA_PKG_VERSION && \
		rm -rf /var/lib/apt/lists/*
ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs
########## Eigen 3.3.7 ##########
RUN	mkdir /home/eigen_ws && \
	cd /home/eigen_ws && \
	wget http://bitbucket.org/eigen/eigen/get/3.3.7.tar.gz && \
	tar -zxvf 3.3.7.tar.gz && \
	cd eigen-eigen-323c052e1731 && \
	mkdir build && \
	cd build && \
	cmake .. && \
	make install
########## FLANN 1.8.4 ##########
RUN	mkdir /home/flann_ws && \
	cd /home/flann_ws && \
	wget http://www.cs.ubc.ca/research/flann/uploads/FLANN/flann-1.8.4-src.zip && \
	unzip flann-1.8.4-src.zip && \
	cd flann-1.8.4-src && \
	mkdir build && \
	cd build && \
	cmake .. && \
	make install
########## Open GL ##########
RUN	apt-get update && apt-get install -y freeglut3-dev
########## VTK 8.2.0 ##########
RUN	mkdir /home/vtk_ws && \
	cd /home/flann_ws && \
	wget https://www.vtk.org/files/release/8.2/VTK-8.2.0.zip && \
	unzip VTK-8.2.0.zip && \
	cd VTK-8.2.0 && \
	mkdir build && \
	cd build && \
	cmake .. && \
	make install
########## PCL 1.9.1 ##########
RUN	mkdir /home/pcl_ws && \
	cd /home/pcl_ws && \
	wget https://github.com/PointCloudLibrary/pcl/archive/pcl-1.9.1.tar.gz && \
	tar -zxvf pcl-1.9.1.tar.gz && \
	cd pcl-pcl-1.9.1 && \
	mkdir build && \
	cd build && \
	# cmake -DCMAKE_BUILD_TYPE=Release -D BUILD_CUDA=ON -D BUILD_GPU=ON -D WITH_CUDA=ON -D WITH_PCAP=ON .. && \
	cmake .. && \
	make -j8 && \
	make install
########## tf & pcl-ros ##########
# RUN	apt-get update && apt-get install -y \
# 		ros-kinetic-tf \
# 		ros-kinetic-pcl-ros
RUN	apt-get update && apt-get install -y \
		ros-kinetic-tf \
		ros-kinetic-pcl-conversions
########## Main ##########
# RUN	cd /home/ros_catkin_ws/src && \
# 	git clone https://github.com/ozakiryota/normal_estimation_pcl && \
# 	cd /home/ros_catkin_ws && \
# 	/bin/bash -c "source /opt/ros/kinetic/setup.bash; catkin_make"
RUN	cd /home/ros_catkin_ws/src && \
	git clone https://github.com/ozakiryota/normal_estimation_pcl
######### initial position ##########
WORKDIR /home/ros_catkin_ws
