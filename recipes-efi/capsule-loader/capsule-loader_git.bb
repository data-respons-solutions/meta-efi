DESCRIPTION = "Load uefi capsule to firmware" 
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

COMPATIBLE_HOST = '(i.86|x86_64)'

DEPENDS += "gnu-efi"

SRCREV ?= "5bf66c9505734ce387d8d9966ad228a960a177a5"
SRC_URI = "git://git@bitbucket.datarespons.com:7999/oe-bsp/efi-capsule-loader.git;protocol=ssh;branch=${BRANCH}"
BRANCH ?= "master"

S = "${WORKDIR}/git"

inherit deploy sbsign

EXTRA_OEMAKE_append += "\
	SYSROOT=${STAGING_DIR_TARGET} \
"

do_configure() {
	:
}

do_compile() {
	oe_runmake
}

addtask do_sbsign after do_compile before do_install
SECURE_BOOT_SIGNING_FILES = "${S}/capsule-loader.efi"

do_install() {
	install -d ${D}/EFI
	install -d ${D}/EFI/bin
	if [ -f ${S}/capsule-loader.efi.signed ]; then
		install -m 0644 ${S}/capsule-loader.efi.signed ${D}/EFI/bin/capsule-loader.efi
	else
		install -m 0644 ${S}/capsule-loader.efi ${D}/EFI/bin/capsule-loader.efi
	fi
}

addtask deploy after do_install
do_deploy() {
    install -d ${DEPLOYDIR}
    install -d ${DEPLOYDIR}/EFI
    install -d ${DEPLOYDIR}/EFI/bin
	if [ -f ${S}/capsule-loader.efi.signed ]; then
		install -m 0644 ${S}/capsule-loader.efi.signed ${DEPLOYDIR}/EFI/bin/capsule-loader.efi
	else
		install -m 0644 ${S}/capsule-loader.efi ${DEPLOYDIR}/EFI/bin/capsule-loader.efi
	fi
}

FILES_${PN} = "/EFI/bin/capsule-loader.efi"
