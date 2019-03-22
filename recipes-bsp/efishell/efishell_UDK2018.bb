SUMMARY = "EFI shell"
DESCRIPTION = "Pre-compiled EFI shell binaries by tianocore EDK2 project"
HOMEPAGE = "https://github.com/tianocore/tianocore.github.io/wiki/EDK-II"
LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/BSD-2-Clause;md5=8bef8e6712b1be5aa76af1ebde9d6378"

BRANCH ?= "UDK2018"
SRC_URI = "git://github.com/tianocore/edk2.git;protocol=ssh;branch=${BRANCH}"
SRCREV ?= "49fa59e82e4c6ea798f65fc4e5948eae63ad6e07"

COMPATIBLE_HOST = '(i.86|x86_64)'

S = "${WORKDIR}/git"

inherit deploy sbsign

do_configure() {
	:
}

do_compile() {
	:
}

do_deploy() {
	:
}


do_deploy_x86-64() {
	install -m 0644 ${S}/ShellBinPkg/UefiShell/X64/Shell.efi ${DEPLOYDIR}/shell_x64.efi
	if [ -f ${S}/ShellBinPkg/UefiShell/X64/Shell.efi.signed ]; then
		install -m 0644 ${S}/ShellBinPkg/UefiShell/X64/Shell.efi.signed ${DEPLOYDIR}/shell_x64.efi.signed
	fi
}

do_deploy_x86() {
	install -m 0644 ${S}/ShellBinPkg/UefiShell/Ia32/Shell.efi ${DEPLOYDIR}/shell_x86.efi
	if [ -f ${S}/ShellBinPkg/UefiShell/Ia32/Shell.efi.signed ]; then
		install -m 0644 ${S}/ShellBinPkg/UefiShell/Ia32/Shell.efi.signed ${DEPLOYDIR}/shell_x86.efi.signed
	fi
}

SECURE_BOOT_SIGNING_FILES = "\
	${@bb.utils.contains('HOST_ARCH','x86_64','${S}/ShellBinPkg/UefiShell/X64/Shell.efi','',d)} \
	${@bb.utils.contains('HOST_ARCH','x86','${S}/ShellBinPkg/UefiShell/Ia32/Shell.efi','',d)} \
"

addtask do_deploy after do_sbsign before do_build
addtask do_sbsign after do_compile before do_deploy
