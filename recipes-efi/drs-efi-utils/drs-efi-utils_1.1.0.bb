DESCRIPTION = "Data Respons Solutions efi utilities" 
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit deploy sbsign

SRCREV ?= "457b6033b3f43e612b6508f26d74ffc4fb742e7e"
SRC_URI = "git://git@github.com/data-respons-solutions/drs-efi-utils.git;protocol=ssh;branch=main"

DEPENDS += "gnu-efi"
S = "${WORKDIR}/git"

EXTRA_OEMAKE:append = "SYSROOT=${STAGING_DIR_TARGET}"

do_configure() {
	:
}

addtask do_sbsign after do_compile before do_install
SECURE_BOOT_SIGNING_FILES = "${S}/build/cpu-heater.efi"

do_install() {
	install -d ${D}/EFI/bin
	if [ -f ${S}/build/cpu-heater.efi.signed ]; then
		install -m 0644 ${S}/build/cpu-heater.efi.signed ${D}/EFI/bin/cpu-heater.efi
	else
		install -m 0644 ${S}/build/cpu-heater.efi ${D}/EFI/bin/cpu-heater.efi
	fi
}

addtask deploy after do_install
do_deploy() {
    install -d ${DEPLOYDIR}/EFI/bin
	if [ -f ${S}/build/cpu-heater.efi.signed ]; then
		install -m 0644 ${S}/build/cpu-heater.efi.signed ${DEPLOYDIR}/EFI/bin/cpu-heater.efi
	else
		install -m 0644 ${S}/build/cpu-heater.efi ${DEPLOYDIR}/EFI/bin/cpu-heater.efi
	fi
}

PACKAGES += "${PN}-cpu-heater"
FILES:${PN} = ""
FILES:${PN}-cpu-heater = "/EFI/bin/cpu-heater.efi"

COMPATIBLE_HOST = '(i.86|x86_64)'
