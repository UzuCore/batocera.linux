################################################################################
#
# EmulationStation theme "Art Book Next"
#
################################################################################
# Version.: Commits on June 11, 2024
ES_THEME_ART_BOOK_NEXT_VERSION = 13267db8eea66f0eb82b9dd2aee8f68478a06682
ES_THEME_ART_BOOK_NEXT_SITE = $(call github,UzuCore,es-theme-art-book-dc,$(ES_THEME_ART_BOOK_NEXT_VERSION))

define ES_THEME_ART_BOOK_NEXT_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-art-book-next
    cp -r $(@D)/* $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-art-book-next
endef

$(eval $(generic-package))
