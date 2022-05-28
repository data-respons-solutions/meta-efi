DESCRIPTION = "EFI application to install secure boot keys. \
			   Application installs keys DB.sig, KEK.sig and PK.sig \
			   located on root of boot device" 
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

COMPATIBLE_HOST = '(i.86|x86_64)'

DEPENDS += "gnu-efi"
RDEPENDS:${PN} += "efi-keys-sig"

SRC_URI += "\
    file://install-keys.c \
    file://Makefile \
"

inherit deploy sbsign systemd_boot_entry

addtask systemd_boot_entry after do_compile before do_install
SYSTEMD_BOOT_ENTRY = "efi-install"
SYSTEMD_BOOT_EFI = "/EFI/bin/install-keys.efi"

S = "${WORKDIR}"
CFLAGS = "-Wextra -Werror" 
EXTRA_OEMAKE += "\
	SYSROOT=${STAGING_DIR_TARGET} \
"

do_configure() {
	:
}

do_compile() {
	oe_runmake
}

addtask do_sbsign after do_compile before do_install
SECURE_BOOT_SIGNING_FILES = "${S}/install-keys.efi"

do_install() {
	install -d ${D}/EFI
	install -d ${D}/EFI/bin
	if [ -f ${S}/efi-install.efi.signed ]; then
		install -m 0644 ${S}/install-keys.efi.signed ${D}/EFI/bin/install-keys.efi
	else
		install -m 0644 ${S}/install-keys.efi ${D}/EFI/bin/install-keys.efi
	fi
	install -d ${D}/loader
	install -d ${D}/loader/entries
	install ${S}/loader/entries/efi-install.conf ${D}/loader/entries/
}

addtask deploy after do_install
do_deploy() {
    install -d ${DEPLOYDIR}
    install -d ${DEPLOYDIR}/EFI
    install -d ${DEPLOYDIR}/EFI/bin
	if [ -f ${S}/efi-install.efi.signed ]; then
		install -m 0644 ${S}/install-keys.efi.signed ${DEPLOYDIR}/EFI/bin/install-keys.efi
	else
		install -m 0644 ${S}/install-keys.efi ${DEPLOYDIR}/EFI/bin/install-keys.efi
	fi
	install -d ${DEPLOYDIR}/loader
	install -d ${DEPLOYDIR}/loader/entries
	install ${S}/loader/entries/efi-install.conf ${DEPLOYDIR}/loader/entries/
}

FILES:${PN} = "/loader/entries/* /EFI/bin/install-keys.efi"
