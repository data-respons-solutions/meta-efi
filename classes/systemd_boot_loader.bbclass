#
# Generate systemd boot loader.conf
#

ROOTFS_POSTPROCESS_COMMAND:append = " generate_systemd_boot_loader_conf; "

SYSTEMD_BOOT_DEFAULT_TIMEOUT ?= "1"

python generate_systemd_boot_loader_conf() {
    s = d.getVar('IMAGE_ROOTFS')
    default = d.getVar('SYSTEMD_BOOT_DEFAULT_ENTRY')
    timeout = d.getVar('SYSTEMD_BOOT_DEFAULT_TIMEOUT')
    loader_dir = os.path.join(s, 'loader')
    loader_file = os.path.join(loader_dir, 'loader.conf')
	
    if not default:
        bb.fatal("SYSTEMD_BOOT_LOADER_DEFAULT not defined")
        return
        
    if not os.path.exists(loader_dir):
        os.makedirs(loader_dir)
        
    try:
        with open(loader_file, 'w') as f:
            f.write('default {}\n'.format(default))
            f.write('timeout {}\n'.format(timeout))
    except OSError:
        bb.fatal('Unable to open entry file {}'.format(loader_file))
}
