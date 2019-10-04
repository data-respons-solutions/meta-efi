#
# Generate systemd boot entry
#

python do_systemd_boot_entry() {
    s = d.getVar("S")
    entry = d.getVar('SYSTEMD_BOOT_ENTRY')
    entry_dir = os.path.join(s, 'loader/entries')
    entry_file = os.path.join(entry_dir, '{}.conf'.format(entry))
    efi = d.getVar('SYSTEMD_BOOT_EFI')
	
    if not entry:
        bb.debug(1, "No entry, nothing to do")
        return
        
    if not os.path.exists(entry_dir):
        os.makedirs(entry_dir)
        
    try:
        with open(entry_file, 'w') as f:
            f.write('title {}\n'.format(entry))
            if efi:
                f.write('efi {}\n'.format(efi))
    except OSError:
        bb.fatal('Unable to open entry file {}'.format(entry_file))
}

EXPORT_FUNCTIONS do_systemd_boot_entry