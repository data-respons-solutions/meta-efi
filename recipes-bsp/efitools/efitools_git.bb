SUMMARY = "Tools to support reading and manipulating the UEFI signature database"
DESCRIPTION = "\
From the EFI Tools package in the Linux user-space, it's now possible \
to read and manipulate the UEFI signatures database via the new \
efi-readvar and efi-updatevar commands. Aside from needing efitools \
1.4, the EFIVARFS file-system is also needed, which was only introduced \
in the Linux 3.8 kernel. \
"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=e28f66b16cb46be47b20a4cdfe6e99a1"

PV = "1.9.2+git${SRCPV}"

DEPENDS += "gnu-efi openssl"

SRC_URI = "\
	git://git.kernel.org/pub/scm/linux/kernel/git/jejb/efitools.git \
    file://Fix-for-the-cross-compilation.patch \
    file://Kill-all-the-build-warning-caused-by-implicit-declar.patch \
    file://Add-static-keyword-for-IsValidVariableHeader.patch \
    file://Dynamically-load-openssl.cnf-for-openssl-1.0.x-and-1.patch \
    file://0001-console.c-Fix-compilation-against-latest-usr-include.patch \
"

SRCREV = "392836a46ce3c92b55dc88a1aebbcfdfc5dcddce"

COMPATIBLE_HOST = '(i.86|x86_64).*-linux'

S = "${WORKDIR}/git"

EXTRA_OEMAKE = "\
    NM='${NM}' AR='${AR}' \
    EXTRA_LDFLAGS='${LDFLAGS}' \
    INCDIR_PREFIX='${STAGING_DIR_TARGET}' \
    CRTPATH_PREFIX='${STAGING_DIR_TARGET}' \
"

EXTRA_OEMAKE_append_x86 += " ARCH=ia32"
EXTRA_OEMAKE_append_x86-64 += " ARCH=x86_64"

do_compile() {
	oe_runmake cert-to-efi-sig-list
	oe_runmake sig-list-to-certs
	oe_runmake sign-efi-sig-list
	oe_runmake hash-to-efi-sig-list
	oe_runmake efi-readvar
	oe_runmake efi-updatevar
	oe_runmake cert-to-efi-hash-list
	oe_runmake efi-keytool
}

do_install() {
	install -d ${D}${bindir}
	install -m 0755 ${S}/cert-to-efi-sig-list ${D}${bindir}
	install -m 0755 ${S}/sig-list-to-certs ${D}${bindir}
	install -m 0755 ${S}/sign-efi-sig-list ${D}${bindir}
	install -m 0755 ${S}/hash-to-efi-sig-list ${D}${bindir}
	install -m 0755 ${S}/efi-readvar ${D}${bindir}
	install -m 0755 ${S}/efi-updatevar ${D}${bindir}
	install -m 0755 ${S}/cert-to-efi-hash-list ${D}${bindir}
	install -m 0755 ${S}/efi-keytool ${D}${bindir}
}

RDEPENDS_${PN}_append += "\
    parted mtools coreutils util-linux openssl libcrypto \
"
