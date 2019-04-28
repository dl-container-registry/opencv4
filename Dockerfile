FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04
LABEL maintainer="will.price94+docker@gmail.com"
ARG OPENCV_VERSION=4.1.0

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

# software-properties-common provides add-apt-repository needed for
# adding PPAs
RUN apt-get update && \
    apt-get install -y wget software-properties-common apt-utils


# libjasper-dev is not present in 18.04 so we need to add the xenial
# (16.04) channel to install it
# See https://researchxuyc.wordpress.com/2018/09/26/install-libjasper-in-ubuntu-18-04/
RUN add-apt-repository --yes --update "deb http://security.ubuntu.com/ubuntu xenial-security main" && \
    apt-get update && \
    apt-get install -y \
        build-essential \
        ninja-build \
        cmake \
        git \
        pkg-config \
        libopencv-dev \
        libtbb2 \
        libtbb-dev \
        libatlas-base-dev \
        gfortran \
        libgtk2.0-dev \
        libgtk-3-dev \
        libavcodec-dev \
        libavformat-dev \
        libswscale-dev \
        libavresample-dev \
        libxvidcore-dev \
        libx264-dev \
        gstreamer1.0-tools \
        gstreamer1.0-libav \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-ugly \
        gstreamer1.0-opencv \
        libgstreamer1.0-dev \
        libgstreamer-plugins-base1.0-dev \
        libgstreamer-plugins-base1.0-0 \
        libgstreamer-plugins-good1.0-0 \
        libgstreamer-plugins-good1.0-dev \
        libgstreamer-plugins-bad1.0-0 \
        libgstreamer-plugins-bad1.0-dev \
        gstreamer1.0-libav \
        libxine2-dev \
        libv4l-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libjasper-dev \
        libdc1394-22-dev \
        python-dev \
        python-numpy \
        python3 \
        python3-pip \
        python3-numpy && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB && \
    apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB && \
    wget https://apt.repos.intel.com/setup/intelproducts.list -O /etc/apt/sources.list.d/intelproducts.list && \
    apt-get update && \
    apt-get install -y libeigen3-dev intel-mkl-2019.3-062 && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /src && cd /src && \
    wget "https://github.com/opencv/opencv/archive/$OPENCV_VERSION.zip" -O opencv-${OPENCV_VERSION}.zip && \
    wget "https://github.com/opencv/opencv_contrib/archive/$OPENCV_VERSION.zip" -O opencv_contrib-${OPENCV_VERSION}.zip && \
    apt-get update && \
    apt-get install -y unzip && \
    unzip opencv-$OPENCV_VERSION && \
    unzip opencv_contrib-$OPENCV_VERSION && \
    mkdir -p opencv_build && \
    cd opencv_build && \
    cmake \
        -GNinja \
        -D CMAKE_BUILD_TYPE=Release \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D OPENCV_GENERATE_PKGCONFIG=on \
        -D PYTHON3_EXECUTABLE=python3 \
        -D BUILD_opencv_python3=ON \
        -D WITH_V4L=ON \
        -D WITH_FFMPEG=ON \
        -D WITH_GSTREAMER=ON \
        -D WITH_CUDA=ON \
        -D WITH_CUBLAS=ON \
        -D CUDA_FAST_MATH=ON \
        -D CUDA_ARCH_PTX="5.0 5.2 6.0 6.1 7.0" \
        -D CUDA_ARCH_BIN="5.0 5.2 6.0 6.1 7.0" \
        -D WITH_TBB=ON \
        -D WITH_EIGEN=ON \
        -D WITH_MKL=ON \
        -D MKL_USE_MULTITHREAD=ON \
        -D MKL_WITH_TBB=ON \
        -D ENABLE_FAST_MATH=ON \
        -D INSTALL_C_EXAMPLES=OFF \
        -D INSTALL_PYTHON_EXAMPLES=ON \
        -D BUILD_EXAMPLES=ON \
        -D BUILD_DOCS=OFF \
        -D BUILD_opencv_legacy=OFF \
        -D CMAKE_LIBRARY_PATH=/usr/local/cuda/lib64/stubs \
        -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib-$OPENCV_VERSION/modules/ \
        ../opencv-$OPENCV_VERSION && \
    ninja && \
    ninja install && \
    cd / && rm -rf /src
# Mitigate issue with programs not being able to compile without
# static linking of cuda: -D CUDA_USE_STATIC_CUDA_RUNTIME=OFF
# See https://github.com/opencv/opencv/issues/6542 for more
RUN ln -s /usr/local/cuda/lib64/libcudart.so \
          /usr/local/lib/libopencv_dep_cudart.so
ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"
