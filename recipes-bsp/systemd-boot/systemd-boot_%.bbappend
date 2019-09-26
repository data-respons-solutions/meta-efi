FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"

SYSTEMD_BOOT_EFI_IMAGE = "${@bb.utils.contains('TARGET_ARCH', 'x86_64', 'bootx64.efi', 'bootia32.efi',d)}"
SYSTEMD_BOOT_EFI_STUB = "${@bb.utils.contains('TARGET_ARCH', 'x86_64', 'linuxx64.efi.stub', 'linuxia32.efi.stub',d)}"

SRC_URI += 	" \
    file://loader.conf \
    file://efi.conf \
    file://linux.conf \
"
do_compile() {
	ninja src/boot/efi/systemd-${SYSTEMD_BOOT_EFI_IMAGE}
	ninja src/boot/efi/${SYSTEMD_BOOT_EFI_STUB}	
}

do_install() {
	install -d ${D}/boot
	install -d ${D}/boot/EFI
	install -d ${D}/boot/EFI/BOOT
	install ${B}/src/boot/efi/systemd-${SYSTEMD_BOOT_EFI_IMAGE} ${D}/boot/EFI/BOOT/${SYSTEMD_BOOT_EFI_IMAGE}
	
	install -d ${D}/${systemd_unitdir}
	install -d ${D}/${systemd_unitdir}/boot
	install -d ${D}/${systemd_unitdir}/boot/efi
	install ${B}/src/boot/efi/${SYSTEMD_BOOT_EFI_STUB} ${D}/${systemd_unitdir}/boot/efi
	ln -s ${SYSTEMD_BOOT_EFI_STUB} ${D}/${systemd_unitdir}/boot/efi/linux.efi.stub
}

FILES_${PN}-dev += "${systemd_unitdir}/boot/efi/*"

do_deploy() {
	install -d ${DEPLOYDIR}/EFI
	install -d ${DEPLOYDIR}/EFI/BOOT
	install ${B}/src/boot/efi/systemd-${SYSTEMD_BOOT_EFI_IMAGE} ${DEPLOYDIR}/EFI/BOOT/${SYSTEMD_BOOT_EFI_IMAGE}
	if [ -f ${B}/src/boot/efi/systemd-${SYSTEMD_BOOT_EFI_IMAGE}.signed ]; then
		install ${B}/src/boot/efi/systemd-${SYSTEMD_BOOT_EFI_IMAGE}.signed ${DEPLOYDIR}/EFI/BOOT/${SYSTEMD_BOOT_IMAGE}.signed
	fi
	
	install -d ${DEPLOYDIR}/loader
	install -m 0644 ${WORKDIR}/loader.conf ${DEPLOYDIR}/loader/loader.conf
	rm ${WORKDIR}/loader.conf
	install -d ${DEPLOYDIR}/loader/entries
	for f in ${WORKDIR}/*.conf; do 
		install -m 0644 ${f} ${DEPLOYDIR}/loader/entries/
	done
}

RDEPENDS_${PN}_remove = "virtual/systemd-bootconf"

inherit sbsign

SECURE_BOOT_SIGNING_FILES = "\
	${B}/src/boot/efi/systemd-${SYSTEMD_BOOT_EFI_IMAGE} \
"

addtask do_sbsign after do_compile before do_deploy
