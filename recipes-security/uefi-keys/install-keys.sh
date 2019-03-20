#/bin/bash

# Install test keys into EFI

die () {
	echo $1
	mount -o remount,ro efivarfs
	mount -o remount,ro /mnt/pendrive
	exit 1
}

mount -o remount,rw efivarfs || echo "Failed remounting efivarfs" | exit 1
mount -o remount,rw /mnt/pendrive || die "Failed remounting pendrive"

# Generate signed signature lists
for key in PK; do
	cert-to-efi-sig-list ${key}.crt ${key}.esl || die "Failed generating efi signature list"
	sign-efi-sig-list -k ${key}.key -c ${key}.crt ${key} ${key}.esl ${key}.auth || die "Failed signing signature list"
done

# Update keys
efi-updatevar -c db.crt -k db.key db || die "Failed installing db key"
efi-updatevar -c KEK.crt -k KEK.key KEK || die "Failed installing KEK key"
efi-updatevar -f PK.auth PK || die "Failed installing PK key"