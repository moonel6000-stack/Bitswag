TARGET := iphone:clang:latest:15.0
ARCHS := arm64 arm64e
THEOS_PACKAGE_SCHEME := rootless
INSTALL_TARGET_PROCESSES = BitLife

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BitSwag
BitSwag_FILES = Tweak.x Sources/BSMenu.m
BitSwag_CFLAGS = -fobjc-arc
BitSwag_FRAMEWORKS = UIKit Foundation
BitSwag_LIBRARIES =

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = BitSwagPrefs
BitSwagPrefs_FILES = Preferences/BSSRootListController.m
BitSwagPrefs_FRAMEWORKS = UIKit
BitSwagPrefs_PRIVATE_FRAMEWORKS = Preferences
BitSwagPrefs_INSTALL_PATH = /Library/PreferenceBundles
BitSwagPrefs_RESOURCE_DIRS = Preferences/Resources
BitSwagPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
