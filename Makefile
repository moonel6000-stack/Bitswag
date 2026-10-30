ARCHS = arm64 arm64e
THEOS_PACKAGE_SCHEME = rootless
TARGET = iphone:clang:latest:17.0
INSTALL_TARGET_PROCESSES = BitLife
include $(THEOS)/makefiles/common.mk
TWEAK_NAME = BitSwag
BitSwag_FILES = Sources/Tweak.x Sources/BSMenu.m
BitSwag_CFLAGS = -I$(THEOS)/vendor/include -fobjc-arc -Wno-deprecated-declarations
BitSwag_FRAMEWORKS = UIKit Foundation QuartzCore
BitSwag_LDFLAGS = -L$(THEOS)/vendor/lib -ldobby
include $(THEOS_MAKE_PATH)/tweak.mk
