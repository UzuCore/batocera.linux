################################################################################
#
# mali g31 fbdev
#
################################################################################
# Version.: Commits on Apr 11, 2024
MALI_G31_FBDEV_VERSION = f91ad32d45f09b9ea437bd19b8099b30400bb85f
MALI_G31_FBDEV_SITE = $(call github,knulli-cfw,t507_gpu_drivers,$(MALI_G31_FBDEV_VERSION))
MALI_G31_FBDEV_LICENSE = Proprietary
MALI_G31_FBDEV_LICENSE_FILES = END_USER_LICENCE_AGREEMENT.txt

MALI_G31_FBDEV_INSTALL_STAGING = YES
MALI_G31_FBDEV_PROVIDES = libegl libgles libmali

define MALI_G31_FBDEV_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/lib/pkgconfig

	cp -rf $(@D)/include/* $(STAGING_DIR)/usr/include/
	cp -rf $(@D)/fbdev/include/EGL/* $(STAGING_DIR)/usr/include/EGL/

	cp -rf $(@D)/fbdev/mali-g31/aarch64-linux-gnu-7.4.1/lib64/* $(STAGING_DIR)/usr/lib/

        $(INSTALL) -D -m 0644  $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/gpu/mali-g31-fbdev/egl.pc \
                $(STAGING_DIR)/usr/lib/pkgconfig/egl.pc
        $(INSTALL) -D -m 0644  $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/gpu/mali-g31-fbdev/glesv2.pc \
                $(STAGING_DIR)/usr/lib/pkgconfig/glesv2.pc

endef

define MALI_G31_FBDEV_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/lib

        cp -rf $(@D)/fbdev/mali-g31/aarch64-linux-gnu-7.4.1/lib64/* $(TARGET_DIR)/usr/lib/
endef

$(eval $(generic-package))
