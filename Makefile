include theos/makefiles/common.mk

TWEAK_NAME = StatusTime
StatusTime_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

StatusTime_FRAMEWORKS = UIKit

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += statustimeprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
