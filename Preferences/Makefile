TARGET := iphone:clang:latest:15.0
ARCHS := arm64 arm64e
THEOS_PACKAGE_SCHEME := rootless

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME := BitSwagPrefs
BitSwagPrefs_FILES := BSSRootListController.m
BitSwagPrefs_FRAMEWORKS := UIKit Foundation
BitSwagPrefs_INSTALL_PATH := /Library/PreferenceBundles
BitSwagPrefs_CFLAGS := -fobjc-arc
# PSListController vient du framework prive Preferences, charge par Reglages.
# Les symboles sont resolus a l'execution.
BitSwagPrefs_LDFLAGS := -undefined dynamic_lookup

include $(THEOS_MAKE_PATH)/bundle.mk
