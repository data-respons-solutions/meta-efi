DESCRIPTION = "systemd-boot efi stub for combining kernel, commandline arguments, bootsplash and initrd in a single blob"
LICENSE = "GPL-2.0-only & LGPL-2.1-only"
LIC_FILES_CHKSUM = "file://LICENSE.GPL2;md5=751419260aa954499f7abaabaa882bbe \
                    file://LICENSE.LGPL2.1;md5=4fbd65380cdd255951079008b364516c"

SRCREV = "c3aead556847dd2694d559620123b65ff16afe8c"
SRCBRANCH = "v250-stable"
SRC_URI = "git://github.com/systemd/systemd-stable.git;protocol=https;branch=${SRCBRANCH}"

S = "${WORKDIR}/git"

require conf/image-uefi.conf

DEPENDS = "intltool-native libcap util-linux gnu-efi gperf-native python3-jinja2-native"
inherit meson pkgconfig gettext
inherit deploy

LDFLAGS:prepend = "${@ " ".join(d.getVar('LD').split()[1:])} "

do_write_config[vardeps] += "CC OBJCOPY"
do_write_config:append() {
    cat >${WORKDIR}/meson-${PN}.cross <<EOF
[binaries]
efi_cc = ${@meson_array('CC', d)}
objcopy = ${@meson_array('OBJCOPY', d)}
EOF
}

EFI_LD = "bfd"

EXTRA_OEMESON += "-Defi=true \
                  -Dgnu-efi=true \
                  -Defi-includedir=${STAGING_INCDIR}/efi \
                  -Defi-libdir=${STAGING_LIBDIR} \
                  -Defi-ld=${EFI_LD} \
                  -Dman=false \
                  --cross-file ${WORKDIR}/meson-${PN}.cross \
                  "

# Imported from the old gummiboot recipe
TUNE_CCARGS:remove = "-mfpmath=sse"
COMPATIBLE_HOST = "(aarch64.*|arm.*|x86_64.*|i.86.*)-linux"
COMPATIBLE_HOST:x86-x32 = "null"


do_compile() {
	ninja src/boot/efi/linux${EFI_ARCH}.efi.stub
}

do_install() {
	install -d ${D}/${systemd_unitdir}
	install -d ${D}/${systemd_unitdir}/boot
	install -d ${D}/${systemd_unitdir}/boot/efi
	install ${B}/src/boot/efi/linux${EFI_ARCH}.efi.stub ${D}/${systemd_unitdir}/boot/efi
	ln -s linux${EFI_ARCH}.efi.stub ${D}/${systemd_unitdir}/boot/efi/linux.efi.stub
}

do_deploy() {
	install ${B}/src/boot/efi/linux${EFI_ARCH}.efi.stub ${DEPLOYDIR}
}

FILES:${PN}-dev += "${systemd_unitdir}/boot/efi/*"

addtask deploy before do_build after do_compile
