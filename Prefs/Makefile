ARCHS = armv7 arm64
SDKVERSION = 7.0
TARGET = iphone:7.0

include theos/makefiles/common.mk

BUNDLE_NAME = statustimeprefs
statustimeprefs_FILES = statustimeprefs.mm
statustimeprefs_INSTALL_PATH = /Library/PreferenceBundles
statustimeprefs_FRAMEWORKS = UIKit
statustimeprefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/statustimeprefs.plist$(ECHO_END)
