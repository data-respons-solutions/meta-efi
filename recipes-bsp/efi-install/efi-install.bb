DESCRIPTION = "Install UEFI secure boot from EFI interface \
			    NOTE: Work in progress.."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS += "gnu-efi"

SRC_URI += "\
    file://efi-install.c \
    file://Makefile \
"

inherit deploy

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
    install -m 0755 ${S}/efi-install.efi ${DEPLOYDIR}/efi-install.efi
}

addtask deploy after do_compile
