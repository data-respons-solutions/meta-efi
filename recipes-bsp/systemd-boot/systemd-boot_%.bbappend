SYSTEMD_BOOT_EFI_IMAGE = "${@bb.utils.contains('TARGET_ARCH', 'x86_64', 'bootx64.efi', 'bootia32.efi',d)}"

inherit sbsign

RDEPENDS:${PN}:remove = "virtual/systemd-bootconf"

do_compile() {
	ninja src/boot/efi/systemd-${SYSTEMD_BOOT_EFI_IMAGE}
}

addtask do_sbsign after do_compile before do_install
SECURE_BOOT_SIGNING_FILES = "\
	${B}/src/boot/efi/systemd-${SYSTEMD_BOOT_EFI_IMAGE} \
"

do_install() {
	install -d ${D}/EFI
	install -d ${D}/EFI/BOOT
	if [ -f ${B}/src/boot/efi/systemd-${SYSTEMD_BOOT_EFI_IMAGE}.signed ]; then
		install ${B}/src/boot/efi/systemd-${SYSTEMD_BOOT_EFI_IMAGE}.signed ${D}/EFI/BOOT/${SYSTEMD_BOOT_EFI_IMAGE}
	else
		install ${B}/src/boot/efi/systemd-${SYSTEMD_BOOT_EFI_IMAGE} ${D}/EFI/BOOT/${SYSTEMD_BOOT_EFI_IMAGE}
	fi
}

do_deploy() {
	install -d ${DEPLOYDIR}/EFI
	install -d ${DEPLOYDIR}/EFI/BOOT
	if [ -f ${B}/src/boot/efi/systemd-${SYSTEMD_BOOT_EFI_IMAGE}.signed ]; then
		install ${B}/src/boot/efi/systemd-${SYSTEMD_BOOT_EFI_IMAGE}.signed ${DEPLOYDIR}/EFI/BOOT/${SYSTEMD_BOOT_EFI_IMAGE}
	else
		install ${B}/src/boot/efi/systemd-${SYSTEMD_BOOT_EFI_IMAGE} ${DEPLOYDIR}/EFI/BOOT/${SYSTEMD_BOOT_EFI_IMAGE}
	fi
}

FILES:${PN} += "/EFI/BOOT/*"
