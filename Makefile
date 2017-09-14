include $(THEOS)/makefiles/common.mk

export TARGET = simulator:clang
ARCHS = x86_64

TWEAK_NAME = NoPlaceLikeHome

NoPlaceLikeHome_FILES = Tweak.xm
NoPlaceLikeHome_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
