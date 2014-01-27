include theos/makefiles/common.mk

TWEAK_NAME = StatusTime+
StatusTime+_FILES = StatusTime+.xm

include $(THEOS_MAKE_PATH)/tweak.mk

StatusTime_FRAMEWORKS = UIKit

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += Prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
