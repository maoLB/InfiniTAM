LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_ARM_NEON := true

GCC=$(NDK_ROOT)/toolchains/arm-linux-androideabi-4.6/gen_standalone/linux-x86_64/bin/arm-linux-androideabi-g++
NVCC=$(CUDA_TOOLKIT_ROOT)/bin/nvcc -ccbin $(GCC) -target-cpu-arch=ARM -m32 -arch=sm_30 -O3 -Xptxas '-dlcm=ca' -target-os-variant=Android

MY_FILE_LIST := $(wildcard Engine/*.cpp) $(wildcard Engine/DeviceSpecific/CPU/*.cpp) $(wildcard Utils/*.cpp) $(wildcard Objects/*.cpp) $(wildcard Engine/DeviceSpecific/CUDA/*.cu)
MY_OBJ_LIST := $(MY_FILE_LIST:%.cu=%.o)
MY_OBJ_LIST := $(MY_OBJ_LIST:%.cpp=%.o)
MY_MODULE := libITMLib.a
MY_INCLUDES += $(CUDA_TOOLKIT_ROOT)/targets/armv7-linux-androideabi/include

%.o: %.cu
	$(NVCC) $(CFLAGS) $(EXTRA_CFLAGS) -c -o "$@" "$<"

%.o: %.cpp
	$(GCC) -O3 -march=armv7-a -mtune=cortex-a15 -c -o "$@" "$<" $(MY_INCLUDES:%=-I%)

$(MY_MODULE): $(MY_OBJ_LIST)
	$(NVCC) -lib -o "$@" $^

LOCAL_MODULE    := libITMLib
LOCAL_SRC_FILES := $(MY_MODULE)

include $(PREBUILT_STATIC_LIBRARY)

