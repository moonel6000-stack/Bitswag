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

BUNDLE_NAME := BitSwagPrefs
BitSwagPrefs_FILES := Preferences/BSSRootListController.m
BitSwagPrefs_FRAMEWORKS := UIKit Foundation
# PSListController is supplied by iOS's private Preferences framework at runtime.
# Avoid linking against a private SDK framework that is absent on the GitHub runner.
BitSwagPrefs_LDFLAGS := -undefined dynamic_lookup
BitSwagPrefs_INSTALL_PATH := /Library/PreferenceBundles
BitSwagPrefs_RESOURCE_DIRS := Preferences/Resources
BitSwagPrefs_CFLAGS := -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
