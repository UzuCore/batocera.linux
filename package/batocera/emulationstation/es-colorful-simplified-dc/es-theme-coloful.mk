################################################################################
#
# EmulationStation theme "colorful simplified"
#
################################################################################
# Version: Commits on October 25, 2024
ES_THEME_COLORFUL_VERSION = 421cec038116fe7b6711fa35683470884a28ed55
ES_THEME_COLORFUL_SITE = $(call github,UzuCore,es-colorful-simplified-dc,$(ES_THEME_COLORFUL_VERSION))

define ES_THEME_COLORFUL_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/usr/share/emulationstation/themes/es-colorful-simplified
    cp -r $(@D)/* $(TARGET_DIR)/usr/share/emulationstation/themes/es-colorful-simplified
endef

$(eval $(generic-package))
