
do_efisign[depends] += " \
                        sbsigntool-native:do_populate_sysroot \
                       "
                       
do_efisign[vardeps] +=  " \
						IMAGE_LINK_NAME \
						IMAGE_VERSION_SUFFIX \
						SECURE_BOOT_SIGNING_KEY \
						SECURE_BOOT_SIGNING_CERT \
						"

sign_efi() {
	efi="${IMAGE_LINK_NAME}${IMAGE_VERSION_SUFFIX}"

    sbsign --key ${SECURE_BOOT_SIGNING_KEY} --cert ${SECURE_BOOT_SIGNING_CERT} ${IMGDEPLOYDIR}/${efi}.efi
    mv ${IMGDEPLOYDIR}/${efi}.efi.signed ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}${IMAGE_VERSION_SUFFIX}-signed.efi
    ln -sf ${IMAGE_LINK_NAME}${IMAGE_VERSION_SUFFIX}-signed.efi ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}-signed.efi
    sbsign --key ${SECURE_BOOT_SIGNING_KEY} --cert ${SECURE_BOOT_SIGNING_CERT} ${DEPLOY_DIR_IMAGE}/EFI/BOOT/bootx64.efi
    mkdir -p ${IMGDEPLOYDIR}/EFI/BOOT
    mv ${DEPLOY_DIR_IMAGE}/EFI/BOOT/bootx64.efi.signed ${IMGDEPLOYDIR}/EFI/BOOT/bootx64-signed.efi
}

python do_efisign() {
    bb.build.exec_func('sign_efi', d)
}

addtask efisign after do_image_efi before do_image_complete   
    