DESCRIPTION = "Installation of EFI keys" 
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGES = "${PN}-sig ${PN}-cert ${PN}-key"

SRC_URI += "\
	file://${SECURE_BOOT_PK_SIG} \
	file://${SECURE_BOOT_PK_CERT} \
	file://${SECURE_BOOT_PK_KEY} \
	file://${SECURE_BOOT_KEK_SIG} \
	file://${SECURE_BOOT_KEK_CERT} \
	file://${SECURE_BOOT_KEK_KEY} \
	file://${SECURE_BOOT_DB_SIG} \
	file://${SECURE_BOOT_DB_CERT} \
	file://${SECURE_BOOT_DB_KEY} \
"

S = "${WORKDIR}"

do_install() {
	install -d ${D}/EFI
	install -d ${D}/EFI/keys
	install ${SECURE_BOOT_PK_SIG} ${D}/
	install ${SECURE_BOOT_PK_CERT} ${D}/EFI/keys/
	install ${SECURE_BOOT_PK_KEY} ${D}/EFI/keys/
	install ${SECURE_BOOT_KEK_SIG} ${D}/
	install ${SECURE_BOOT_KEK_CERT} ${D}/EFI/keys/
	install ${SECURE_BOOT_KEK_KEY} ${D}/EFI/keys/
	install ${SECURE_BOOT_DB_SIG} ${D}/
	install ${SECURE_BOOT_DB_CERT} ${D}/EFI/keys/
	install ${SECURE_BOOT_DB_KEY} ${D}/EFI/keys/
}

FILES_${PN}-sig += "/*.sig"
FILES_${PN}-cert += "/EFI/keys/*.crt"
FILES_${PN}-key += "/EFI/keys/*.key"