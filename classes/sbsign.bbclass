#
# Sign all files contained in SECURE_BOOT_SIGNING_FILES using:
# SECURE_BOOT_SIGNING_CERT
# SECURE_BOOT_SIGNING_KEY
#

DEPENDS += "sbsigntool-native"

python do_sbsign() {
   import subprocess
   
   key = d.getVar('SECURE_BOOT_SIGNING_KEY', True)
   cert = d.getVar('SECURE_BOOT_SIGNING_CERT', True)
   if cert == None or key == None:
      return
   for file in [d.getVar('SECURE_BOOT_SIGNING_FILES', True)]:
      subprocess.run(['sbsign', '--key', key, '--cert', cert, '--output', file.strip() + '.signed', file.strip()], check=True) 
}

EXPORT_FUNCTIONS do_sbsign
