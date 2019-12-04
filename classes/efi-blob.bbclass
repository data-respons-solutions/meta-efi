inherit deploy sbsign systemd_boot_entry

do_compile[depends] += " \
	${INITRD_IMAGE}:do_image_complete \
"

do_compile[vardeps] +=  "KERNEL_IMAGETYPE INITRD_IMAGE APPEND"

DEPENDS += "systemd-boot virtual/kernel"

S = "${WORKDIR}"

EFI_IMAGE_NAME ?= "${PN}-${MACHINE}.efi"

SYSTEMD_BOOT_ENTRY ?= "${PN}-${MACHINE}"
SYSTEMD_BOOT_EFI ?= "/EFI/bin/${EFI_IMAGE_NAME}"
addtask systemd_boot_entry after do_compile before do_install

do_compile() {
	echo "${APPEND}" > ${WORKDIR}/cmdline.txt
	objcopy \
    --add-section .cmdline="${WORKDIR}/cmdline.txt" --change-section-vma .cmdline=0x30000 \
    --add-section .linux="${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}" --change-section-vma .linux=0x40000 \
    --add-section .initrd="${DEPLOY_DIR_IMAGE}/${INITRD_IMAGE}-${MACHINE}.cpio.gz" --change-section-vma .initrd=0x3000000 \
    ${STAGING_DIR_TARGET}/${systemd_unitdir}/boot/efi/linux.efi.stub \
    ${WORKDIR}/${EFI_IMAGE_NAME}
}

SECURE_BOOT_SIGNING_FILES += "${WORKDIR}/${EFI_IMAGE_NAME}"
addtask do_sbsign after do_compile before do_install

do_install() {
	install -d ${D}/EFI
	install -d ${D}/EFI/bin
	if [ -f ${WORKDIR}/${EFI_IMAGE_NAME}.signed ]; then
		install -m 0644 ${WORKDIR}/${EFI_IMAGE_NAME}.signed ${D}/EFI/bin/${EFI_IMAGE_NAME}
	else
		install -m 0644 ${WORKDIR}/${EFI_IMAGE_NAME} ${D}/EFI/bin/${EFI_IMAGE_NAME}
	fi
	install -d ${D}/loader
	install -d ${D}/loader/entries
	install ${WORKDIR}/loader/entries/${SYSTEMD_BOOT_ENTRY}.conf ${D}/loader/entries/
}

addtask deploy after do_install before do_build
do_deploy() {
	install -d ${DEPLOYDIR}/EFI
	install -d ${DEPLOYDIR}/EFI/bin
	if [ -f ${WORKDIR}/${EFI_IMAGE_NAME}.signed ]; then
		install -m 0644 ${WORKDIR}/${EFI_IMAGE_NAME}.signed ${DEPLOYDIR}/EFI/bin/${EFI_IMAGE_NAME}
	else
		install -m 0644 ${WORKDIR}/${EFI_IMAGE_NAME} ${DEPLOYDIR}/EFI/bin/${EFI_IMAGE_NAME}
	fi
	install -d ${DEPLOYDIR}/loader
	install -d ${DEPLOYDIR}/loader/entries
	install ${WORKDIR}/loader/entries/${SYSTEMD_BOOT_ENTRY}.conf ${DEPLOYDIR}/loader/entries/
}

FILES_${PN} += "/loader/entries/* /EFI/bin/${EFI_IMAGE_NAME}"