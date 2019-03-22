DESCRIPTION = "EFI application to install secure boot keys. \
			   Application installs keys DB.sig, KEK.sig and PK.sig \
			   located on root of boot device" 
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

COMPATIBLE_HOST = '(i.86|x86_64)'

DEPENDS += "gnu-efi"

SRC_URI += "\
    file://efi-install.c \
    file://Makefile \
"

inherit deploy sbsign

CFLAGS += "-Wextra -Werror"

S = "${WORKDIR}"

EXTRA_OEMAKE_append += "\
	SYSROOT=${STAGING_DIR_TARGET} \
	"

do_configure() {
	:
}

do_compile() {
	oe_runmake

}

do_deploy() {
    install -d ${DEPLOYDIR}
    install -m 0644 ${S}/efi-install.efi ${DEPLOYDIR}/efi-install.efi
    if [ -f ${S}/efi-install.efi.signed ]; then
    	install -m 0644 ${S}/efi-install.efi.signed ${DEPLOYDIR}/efi-install.efi.signed
    fi
}

SECURE_BOOT_SIGNING_FILES = "${S}/efi-install.efi"

addtask deploy after do_compile
addtask do_sbsign after do_compile before do_deploy
