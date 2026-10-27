TARGET := iphone:clang:latest:15.0
ARCHS := arm64 arm64e
THEOS_PACKAGE_SCHEME := rootless
INSTALL_TARGET_PROCESSES := BitLife

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := BitSwag
BitSwag_FILES := Tweak.x Sources/BSMenu.m
BitSwag_CFLAGS := -fobjc-arc
BitSwag_FRAMEWORKS := UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
