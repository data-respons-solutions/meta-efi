FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"

do_compile_append() {
	oe_runmake efi-keytool
}

do_install_append() {
	install -m 0755 ${WORKDIR}/git/efi-keytool ${D}${bindir}/efi-keytool
}

do_deploy () {
	:
}

SRC_URI += "\
	file://0001-Remove-all-authenticated-attributes-from-signature.patch \
"
