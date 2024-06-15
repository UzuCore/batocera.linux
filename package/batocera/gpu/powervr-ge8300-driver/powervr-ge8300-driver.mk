################################################################################
#
# PowerVR GE8300_DRIVER GPU driver
#
################################################################################
# Version.: Commits on May 16, 2024
#POWERVR_GE8300_DRIVER_VERSION = 3334cfc9f363dae79c9107d43f8073e0c9db12e5
POWERVR_GE8300_DRIVER_VERSION = main
POWERVR_GE8300_DRIVER_SITE = https://github.com/knulli-cfw/ge8300-drivers.git
POWERVR_GE8300_DRIVER_SITE_METHOD = git

POWERVR_GE8300_DRIVER_LICENSE = Propietary

POWERVR_GE8300_DRIVER_INSTALL_STAGING = YES
POWERVR_GE8300_DRIVER_PROVIDES = libegl libgles

define POWERVR_GE8300_DRIVER_INSTALL_STAGING_CMDS
        mkdir -p $(STAGING_DIR)/usr/lib/pkgconfig

        cp -rf $(@D)/3rdparty/include/khronos/* $(STAGING_DIR)/usr/include/

        cp -rf $(@D)/fbdev/glibc/lib64/* $(STAGING_DIR)/usr/lib/

        $(INSTALL) -D -m 0644  $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/gpu/powervr-ge8300-driver/egl.pc \
                $(STAGING_DIR)/usr/lib/pkgconfig/egl.pc
        $(INSTALL) -D -m 0644  $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/gpu/powervr-ge8300-driver/glesv2.pc \
                $(STAGING_DIR)/usr/lib/pkgconfig/glesv2.pc

endef

define POWERVR_GE8300_DRIVER_INSTALL_TARGET_CMDS
        mkdir -p $(TARGET_DIR)/usr/lib

        cp -rf $(@D)/fbdev/glibc/lib64/* $(TARGET_DIR)/usr/lib/

	cp $(@D)/fbdev/glibc/bin/pvrsrvctl $(TARGET_DIR)/usr/bin/
endef

$(eval $(generic-package))

