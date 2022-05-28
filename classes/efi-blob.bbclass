inherit deploy sbsign

do_compile[depends] += " \
	${INITRD_IMAGE}:do_image_complete \
"
do_compile[vardeps] +=  "KERNEL_IMAGETYPE INITRD_IMAGE INITRAMFS_FSTYPES APPEND" 

DEPENDS += "systemd-boot-stub virtual/kernel"

S = "${WORKDIR}"

EFI_IMAGE_NAME ?= "${PN}-${MACHINE}.efi"
SYSTEMD_BOOT_EFI ?= "/boot/${EFI_IMAGE_NAME}"

do_compile() {
	echo "${APPEND}" > ${WORKDIR}/cmdline.txt
	${OBJCOPY} \
    --add-section .cmdline="${WORKDIR}/cmdline.txt" --change-section-vma .cmdline=0x30000 \
    --add-section .linux="${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}" --change-section-vma .linux=0x40000 \
    --add-section .initrd="${DEPLOY_DIR_IMAGE}/${INITRD_IMAGE}-${MACHINE}.${INITRAMFS_FSTYPES}" --change-section-vma .initrd=0x3000000 \
    ${STAGING_DIR_TARGET}/${systemd_unitdir}/boot/efi/linux.efi.stub \
    ${WORKDIR}/${EFI_IMAGE_NAME}
}

SECURE_BOOT_SIGNING_FILES += "${WORKDIR}/${EFI_IMAGE_NAME}"
addtask do_sbsign after do_compile before do_install

do_install() {
	install -d ${D}/boot
	if [ -f ${WORKDIR}/${EFI_IMAGE_NAME}.signed ]; then
		install -m 0644 ${WORKDIR}/${EFI_IMAGE_NAME}.signed ${D}/boot/${EFI_IMAGE_NAME}
	else
		install -m 0644 ${WORKDIR}/${EFI_IMAGE_NAME} ${D}/boot/${EFI_IMAGE_NAME}
	fi
}

addtask deploy after do_install before do_build
do_deploy() {
	if [ -f ${WORKDIR}/${EFI_IMAGE_NAME}.signed ]; then
		install -m 0644 ${WORKDIR}/${EFI_IMAGE_NAME}.signed ${DEPLOYDIR}/${EFI_IMAGE_NAME}
	else
		install -m 0644 ${WORKDIR}/${EFI_IMAGE_NAME} ${DEPLOYDIR}/${EFI_IMAGE_NAME}
	fi
}

FILES:${PN} += "/boot/*"
