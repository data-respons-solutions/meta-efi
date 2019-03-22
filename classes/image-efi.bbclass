inherit image sbsign

do_image_efi[depends] += " \
					     ${INITRD_IMAGE}:do_image_complete \
                         systemd-boot:do_deploy \
                         virtual/kernel:do_deploy \
                       "
do_image_efi[vardeps] +=  "IMAGE_LINK_NAME IMAGE_VERSION_SUFFIX KERNEL_IMAGETYPE INITRD_IMAGE APPEND"

EFI_IMAGE_NAME = "${IMAGE_LINK_NAME}${IMAGE_VERSION_SUFFIX}.efi"
SECURE_BOOT_SIGNING_FILES += "${IMGDEPLOYDIR}/${EFI_IMAGE_NAME}"

IMAGE_CMD_efi() {
	cmdline="cmdline.txt"
	kernel="${KERNEL_IMAGETYPE}"
	initrd="${INITRD_IMAGE}-${MACHINE}.cpio.gz"

	mkdir -p ${B}
	echo "${APPEND}" > ${B}/${cmdline}
	cp ${DEPLOY_DIR_IMAGE}/${kernel} ${B}/${kernel}
	cp ${DEPLOY_DIR_IMAGE}/${initrd} ${B}/${initrd}
	
	objcopy \
    --add-section .cmdline="${B}/${cmdline}" --change-section-vma .cmdline=0x30000 \
    --add-section .linux="${B}/${kernel}" --change-section-vma .linux=0x40000 \
    --add-section .initrd="${B}/${initrd}" --change-section-vma .initrd=0x3000000 \
    ${DEPLOY_DIR_IMAGE}/linuxx64.efi.stub \
    ${IMGDEPLOYDIR}/${EFI_IMAGE_NAME}
    
    ln -sf ${EFI_IMAGE_NAME} ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.efi
}

do_image_efi_signed_link() {
    if [ -f ${IMGDEPLOYDIR}/${EFI_IMAGE_NAME}.signed ]; then
    	ln -sf ${EFI_IMAGE_NAME}.signed ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.efi.signed
    fi
}

addtask do_sbsign after do_image_efi before do_image_complete
addtask do_image_efi_signed_link after do_sbsign before do_image_complete
