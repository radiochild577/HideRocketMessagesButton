include $(THEOS)/makefiles/common.mk

TWEAK_NAME = HideRocketMessagesButton

HideRocketMessagesButton_FILES = Tweak.xm
HideRocketMessagesButton_CFLAGS = -fobjc-arc
HideRocketMessagesButton_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
    install.exec "killall -9 SpringBoard"