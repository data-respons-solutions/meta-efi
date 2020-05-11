DESCRIPTION = "systemd-boot efi stub for combining kernel, commandline arguments, bootsplash and initrd in a single blob"
LICENSE = "GPLv2 & LGPLv2.1"
LIC_FILES_CHKSUM = "file://LICENSE.GPL2;md5=751419260aa954499f7abaabaa882bbe \
                    file://LICENSE.LGPL2.1;md5=4fbd65380cdd255951079008b364516c"

SRCREV = "b7ed902b2394f94e7f1fbe6c3194b5cd9a9429e6"
SRCBRANCH = "v244-stable"
SRC_URI = "git://github.com/systemd/systemd-stable.git;protocol=git;branch=${SRCBRANCH}"

SYSTEMD_BOOT_EFI_STUB ?= "invalid.stub"
SYSTEMD_BOOT_EFI_STUB_x86-64 = "linuxx64.efi.stub"
SYSTEMD_BOOT_EFI_STUB_x86 = "linuxia32.efi.stub"
SYSTEMD_BOOT_EFI_STUB_aarch64 = "linuxaa64.efi.stub"
SYSTEMD_BOOT_EFI_STUB_arm = "linuxarm.efi.stub"

S = "${WORKDIR}/git"

DEPENDS = "intltool-native libcap util-linux gnu-efi gperf-native"
inherit meson pkgconfig gettext
inherit deploy

LDFLAGS_prepend = "${@ " ".join(d.getVar('LD').split()[1:])} "

do_write_config[vardeps] += "CC OBJCOPY"
do_write_config_append() {
    cat >${WORKDIR}/meson-${PN}.cross <<EOF
[binaries]
efi_cc = ${@meson_array('CC', d)}
objcopy = ${@meson_array('OBJCOPY', d)}
EOF
}

EXTRA_OEMESON += "-Defi=true \
                  -Dgnu-efi=true \
                  -Defi-includedir=${STAGING_INCDIR}/efi \
                  -Defi-libdir=${STAGING_LIBDIR} \
                  -Defi-ld=${@ d.getVar('LD').split()[0]} \
                  -Dman=false \
                  --cross-file ${WORKDIR}/meson-${PN}.cross \
                  "

# Imported from the old gummiboot recipe
TUNE_CCARGS_remove = "-mfpmath=sse"
COMPATIBLE_HOST = "(x86-64|x86|arm|aarch64)"

do_compile() {
	ninja src/boot/efi/${SYSTEMD_BOOT_EFI_STUB}	
}

do_install() {
	install -d ${D}/${systemd_unitdir}
	install -d ${D}/${systemd_unitdir}/boot
	install -d ${D}/${systemd_unitdir}/boot/efi
	install ${B}/src/boot/efi/${SYSTEMD_BOOT_EFI_STUB} ${D}/${systemd_unitdir}/boot/efi
	ln -s ${SYSTEMD_BOOT_EFI_STUB} ${D}/${systemd_unitdir}/boot/efi/linux.efi.stub
}

do_deploy() {
	install ${B}/src/boot/efi/${SYSTEMD_BOOT_EFI_STUB} ${DEPLOYDIR}
}

FILES_${PN}-dev += "${systemd_unitdir}/boot/efi/*"

addtask deploy before do_build after do_compile
