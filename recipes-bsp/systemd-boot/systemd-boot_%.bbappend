FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"

SYSTEMD_BOOT_EFI_IMAGE = "${@bb.utils.contains('TARGET_ARCH', 'x86_64', 'bootx64.efi', 'bootia32.efi',d)}"
SYSTEMD_BOOT_EFI_STUB = "${@bb.utils.contains('TARGET_ARCH', 'x86_64', 'linuxx64.efi.stub', 'linuxia32.efi.stub',d)}"

inherit sbsign

RDEPENDS_${PN}_remove = "virtual/systemd-bootconf"

do_compile() {
	ninja src/boot/efi/systemd-${SYSTEMD_BOOT_EFI_IMAGE}
	ninja src/boot/efi/${SYSTEMD_BOOT_EFI_STUB}	
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
	
	install -d ${D}/${systemd_unitdir}
	install -d ${D}/${systemd_unitdir}/boot
	install -d ${D}/${systemd_unitdir}/boot/efi
	install ${B}/src/boot/efi/${SYSTEMD_BOOT_EFI_STUB} ${D}/${systemd_unitdir}/boot/efi
	ln -s ${SYSTEMD_BOOT_EFI_STUB} ${D}/${systemd_unitdir}/boot/efi/linux.efi.stub
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

FILES_${PN} += "/EFI/BOOT/*"
FILES_${PN}-dev += "${systemd_unitdir}/boot/efi/*"
