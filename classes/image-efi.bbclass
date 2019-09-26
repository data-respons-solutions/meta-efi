inherit image sbsign

do_image_efi[depends] += " \
					     ${INITRD_IMAGE}:do_image_complete \
                         systemd-boot:do_populate_sysroot \
                         virtual/kernel:do_deploy \
                       "
do_image_efi[vardeps] +=  "IMAGE_LINK_NAME IMAGE_VERSION_SUFFIX KERNEL_IMAGETYPE INITRD_IMAGE APPEND"

EFI_IMAGE_NAME = "${IMAGE_LINK_NAME}${IMAGE_VERSION_SUFFIX}.efi"
SECURE_BOOT_SIGNING_FILES += "${IMGDEPLOYDIR}/${EFI_IMAGE_NAME}"

IMAGE_CMD_efi() {
	echo "${APPEND}" > ${WORKDIR}/cmdline.txt
	
	objcopy \
    --add-section .cmdline="${WORKDIR}/cmdline.txt" --change-section-vma .cmdline=0x30000 \
    --add-section .linux="${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}" --change-section-vma .linux=0x40000 \
    --add-section .initrd="${DEPLOY_DIR_IMAGE}/${INITRD_IMAGE}-${MACHINE}.cpio.gz" --change-section-vma .initrd=0x3000000 \
    ${STAGING_DIR_TARGET}/${systemd_unitdir}/boot/efi/linux.efi.stub \
    ${IMGDEPLOYDIR}/${EFI_IMAGE_NAME}   
}

do_image_efi_link() {
	ln -sf ${EFI_IMAGE_NAME} ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.efi
    if [ -f ${IMGDEPLOYDIR}/${EFI_IMAGE_NAME}.signed ]; then
    	ln -sf ${EFI_IMAGE_NAME}.signed ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.efi.signed
    fi
}

addtask do_sbsign after do_image_efi before do_image_complete
addtask do_image_efi_link after do_sbsign before do_image_complete
