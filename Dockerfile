FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04
LABEL maintainer="will.price94+docker@gmail.com"
ARG OPENCV_VERSION=4.1.0

# software-properties-common provides add-apt-repository needed for
# adding PPAs
RUN apt-get update && \
    apt-get install -y wget software-properties-common

# libjasper-dev is not present in 18.04 so we need to add the xenial
# (16.04) channel to install it
# See https://researchxuyc.wordpress.com/2018/09/26/install-libjasper-in-ubuntu-18-04/
RUN add-apt-repository --yes --update "deb http://security.ubuntu.com/ubuntu xenial-security main" && \
    apt-get update && \
    apt-get install -y \
        build-essential \
        cmake \
        git \
        libgtk2.0-dev \
        pkg-config \
        libavcodec-dev \
        libavformat-dev \
        libswscale-dev \
        python-dev \
        python-numpy \
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libjasper-dev \
        libdc1394-22-dev \
        python3 \
        python3-pip \
        python3-numpy && \
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
        -D CMAKE_BUILD_TYPE=Release \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D OPENCV_GENERATE_PKGCONFIG=on \
        -D PYTHON3_EXECUTABLE=python3 \
        -D WITH_CUDA=ON \
        -D WITH_CUBLAS=1 \
        -D CUDA_FAST_MATH=1 \
        -D CUDA_ARCH_PTX="5.2 6.0 6.1 7.0" \
        -D CUDA_ARCH_BIN="5.2 6.0 6.1 7.0" \
        -D ENABLE_FAST_MATH=1 \
        -D INSTALL_C_EXAMPLES=OFF \
        -D INSTALL_PYTHON_EXAMPLES=ON \
        -D BUILD_EXAMPLES=ON \
        -D BUILD_DOCS=OFF \
        -D BUILD_opencv_legacy=OFF \
        -D CMAKE_LIBRARY_PATH=/usr/local/cuda/lib64/stubs \
        -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib-$OPENCV_VERSION/modules/ \
        ../opencv-$OPENCV_VERSION && \
    make -j $(nproc) && \
    make install && \
    cd / && rm -rf /src
# Mitigate issue with programs not being able to compile without
# static linking of cuda: -D CUDA_USE_STATIC_CUDA_RUNTIME=OFF
# See https://github.com/opencv/opencv/issues/6542 for more
RUN ln -s /usr/local/cuda/lib64/libcudart.so \
          /usr/local/lib/libopencv_dep_cudart.so


# vim: set tw=150:
