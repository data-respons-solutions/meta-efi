SUMMARY = "EFI shell"
DESCRIPTION = "Pre-compiled EFI shell binaries by tianocore EDK2 project"
HOMEPAGE = "https://github.com/tianocore/tianocore.github.io/wiki/EDK-II"
LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://License.txt;md5=243bd6447a4adc58484671b3811779ce"

BRANCH ?= "UDK2018"
SRC_URI = "git://git@github.com/tianocore/edk2.git;protocol=ssh;branch=${BRANCH}"
SRCREV ?= "49fa59e82e4c6ea798f65fc4e5948eae63ad6e07"

COMPATIBLE_HOST = '(i.86|x86_64)'

S = "${WORKDIR}/git"

inherit deploy sbsign systemd_boot_entry

addtask systemd_boot_entry after do_compile before do_install
SYSTEMD_BOOT_ENTRY = "efi-shell"
SYSTEMD_BOOT_EFI = "/EFI/bin/shell.efi"

EFI_SHELL_DIR = "${@bb.utils.contains('TARGET_ARCH', 'x86_64', 'X64', 'Ia32',d)}"

do_configure() {
	:
}

do_compile() {
	:
}

addtask do_sbsign after do_compile before do_install
SECURE_BOOT_SIGNING_FILES = "${S}/ShellBinPkg/UefiShell/${EFI_SHELL_DIR}/Shell.efi"

do_install() {
	install -d ${D}/EFI
	install -d ${D}/EFI/bin
	if [ -f ${S}/ShellBinPkg/UefiShell/${EFI_SHELL_DIR}/Shell.efi.signed ]; then
		install ${S}/ShellBinPkg/UefiShell/${EFI_SHELL_DIR}/Shell.efi.signed ${D}/EFI/bin/shell.efi
	else
		install ${S}/ShellBinPkg/UefiShell/${EFI_SHELL_DIR}/Shell.efi ${D}/EFI/bin/shell.efi
	fi
	install -d ${D}/loader
	install -d ${D}/loader/entries
	install ${S}/loader/entries/efi-shell.conf ${D}/loader/entries/
}

addtask do_deploy after do_sbsign before do_build
do_deploy() {
	install -d ${DEPLOYDIR}/EFI
	install -d ${DEPLOYDIR}/EFI/bin
	if [ -f ${S}/ShellBinPkg/UefiShell/${EFI_SHELL_DIR}/Shell.efi.signed ]; then
		install ${S}/ShellBinPkg/UefiShell/${EFI_SHELL_DIR}/Shell.efi.signed ${DEPLOYDIR}/EFI/bin/shell.efi
	else
		install ${S}/ShellBinPkg/UefiShell/${EFI_SHELL_DIR}/Shell.efi ${DEPLOYDIR}/EFI/bin/shell.efi
	fi
	install -d ${DEPLOYDIR}/loader
	install -d ${DEPLOYDIR}/loader/entries
	install ${S}/loader/entries/efi-shell.conf ${DEPLOYDIR}/loader/entries/
}

FILES:${PN} += "/loader/entries/* /EFI/bin/*"
