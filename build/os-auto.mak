# build/os-auto.mak.  Generated from os-auto.mak.in by configure.

export OS_CFLAGS   := $(CC_DEF)PJ_AUTOCONF=1 -I/Users/magictech/Desktop/nimit/h264/genrated_code/include -O2 -Wno-unused-label -miphoneos-version-min=7.0 -DPJ_SDK_NAME="\"iPhoneOS16.1.sdk\"" -arch arm64 -isysroot /Applications/XCode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS16.1.sdk -DPJ_IS_BIG_ENDIAN=0 -DPJ_IS_LITTLE_ENDIAN=1 -I/Users/magictech/Desktop/nimit/Opus-iOS-master/dependencies//include

export OS_CXXFLAGS := $(CC_DEF)PJ_AUTOCONF=1 -g -O2

export OS_LDFLAGS  := -L/Users/magictech/Desktop/nimit/h264/genrated_code/lib -O2 -miphoneos-version-min=7.0 -arch arm64 -isysroot /Applications/XCode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS16.1.sdk -framework AudioToolbox -framework Foundation -L/Users/magictech/Desktop/nimit/Opus-iOS-master/dependencies//lib -lopus -lopenh264 -lstdc++ -lm -lpthread  -framework CoreAudio -framework CoreFoundation -framework AudioToolbox -framework CFNetwork -framework UIKit -framework AVFoundation -framework UIKit -framework AVFoundation -framework CoreGraphics -framework QuartzCore -framework CoreVideo -framework CoreMedia -framework VideoToolbox -framework OpenGLES

export OS_SOURCES  := 


