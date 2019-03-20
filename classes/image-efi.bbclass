inherit image

do_image_efi[depends] += " \
					     ${INITRD_IMAGE}:do_image_complete \
                         systemd-boot:do_deploy \
                         virtual/kernel:do_deploy \
                       "
do_image_efi[vardeps] +=  "IMAGE_LINK_NAME IMAGE_VERSION_SUFFIX KERNEL_IMAGETYPE INITRD_IMAGE APPEND"

IMAGE_CMD_efi() {
	cmdline="cmdline.txt"
	kernel="${KERNEL_IMAGETYPE}"
	initrd="${INITRD_IMAGE}-${MACHINE}.cpio.gz"
	efi="${IMAGE_LINK_NAME}${IMAGE_VERSION_SUFFIX}.efi"

	mkdir -p ${B}
	echo "${APPEND}" > ${B}/${cmdline}
	cp ${DEPLOY_DIR_IMAGE}/${kernel} ${B}/${kernel}
	cp ${DEPLOY_DIR_IMAGE}/${initrd} ${B}/${initrd}
	
	objcopy \
    --add-section .cmdline="${B}/${cmdline}" --change-section-vma .cmdline=0x30000 \
    --add-section .linux="${B}/${kernel}" --change-section-vma .linux=0x40000 \
    --add-section .initrd="${B}/${initrd}" --change-section-vma .initrd=0x3000000 \
    ${DEPLOY_DIR_IMAGE}/linuxx64.efi.stub \
    ${IMGDEPLOYDIR}/${efi}
    
    ln -sf ${efi} ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.efi
}
