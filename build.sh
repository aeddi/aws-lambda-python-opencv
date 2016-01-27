#!/bin/bash

# Setting up build env
yum update -y
yum install -y git cmake gcc-c++ gcc python-devel chrpath
mkdir lambda-package build

# Build numpy
pip install --install-option="--prefix=$PWD/build" numpy
mv build/lib64/python2.7/site-packages/numpy lambda-package

# Build OpenCV 3.1
(
	NUMPY=$PWD/lambda-package/numpy/core/include
	cd build
	git clone https://github.com/Itseez/opencv.git
	cd opencv
	git checkout 3.1.0
	cmake										\
		-D CMAKE_BUILD_TYPE=RELEASE				\
		-D WITH_TBB=ON							\
		-D WITH_IPP=ON							\
		-D WITH_V4L=ON							\
		-D ENABLE_AVX=ON						\
		-D ENABLE_SSE42=ON						\
		-D ENABLE_POPCNT=ON						\
		-D ENABLE_FAST_MATH=ON					\
		-D BUILD_EXAMPLES=OFF					\
		-D PYTHON2_NUMPY_INCLUDE_DIRS="$NUMPY"	\
		.
	make
)
mkdir lambda-package/cv2
cp `find opencv/lib "*.so*" -type f` lambda-package/cv2
strip --strip-all lambda-package/cv2/*
chrpath -r '$ORIGIN' lambda-package/cv2/cv2.so
cp ressources/__init.py__ lambda-package/cv2

# Copy template function and zip package
cp ressources/template.py lambda-package/lambda_function.py
zip -r lambda-package.zip lambda-package/*
