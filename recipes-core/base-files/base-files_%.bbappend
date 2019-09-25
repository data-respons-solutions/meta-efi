# Automount efivarfs on boot
do_compile_append() {
	echo "efivarfs      /sys/firmware/efi/efivars        efivarfs       defaults,rw           0  0" >> ${WORKDIR}/fstab
}
