FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"

do_compile_append() {
	ninja src/boot/efi/linuxx64.efi.stub
}

COMPATIBLE_HOST = "x86_64"

SRC_URI += 	" \
    file://loader.conf \
    file://efi.conf \
    file://linux.conf \
"

do_deploy_x86-64 () {
	install -d ${DEPLOYDIR}/EFI
	install -d ${DEPLOYDIR}/EFI/BOOT
	install -m 0644 ${B}/src/boot/efi/systemd-bootx64.efi ${DEPLOYDIR}/EFI/BOOT/${SYSTEMD_BOOT_IMAGE}
	if [ -f ${B}/src/boot/efi/systemd-bootx64.efi.signed ]; then
		install -m 0644 ${B}/src/boot/efi/systemd-bootx64.efi.signed ${DEPLOYDIR}/EFI/BOOT/${SYSTEMD_BOOT_IMAGE}.signed
	fi
	install -m 0644 ${B}/src/boot/efi/linuxx64.efi.stub ${DEPLOYDIR}/linuxx64.efi.stub
	
	install -d ${DEPLOYDIR}/loader
	install -m 0644 ${WORKDIR}/loader.conf ${DEPLOYDIR}/loader/loader.conf
	rm ${WORKDIR}/loader.conf
	install -d ${DEPLOYDIR}/loader/entries
	for f in ${WORKDIR}/*.conf; do 
		install -m 0644 ${f} ${DEPLOYDIR}/loader/entries/
	done
}

do_deploy() {
	:
}

RDEPENDS_${PN}_remove = "virtual/systemd-bootconf"

inherit sbsign

SECURE_BOOT_SIGNING_FILES = "\
	${@bb.utils.contains('HOST_ARCH','x86_64','${B}/src/boot/efi/systemd-bootx64.efi','',d)} \
"

addtask do_sbsign after do_compile before do_deploy
