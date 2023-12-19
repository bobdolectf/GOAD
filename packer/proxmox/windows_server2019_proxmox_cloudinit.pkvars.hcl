winrm_username        = "vagrant"
winrm_password        = "vagrant"
vm_name               = "WinServer2019x64-cloudinit-qcow2"
template_description  = "Windows Server 2019 64-bit - build 17763.737.190906-2324 - template built with Packer - cloudinit - {{isotime \"2006-01-02 03:04:05\"}}"
iso_file              = "local:iso/windows_server2019_x64FREE_en-us.iso"
autounattend_iso      = "./iso/Autounattend_winserver2019_cloudinit.iso"
autounattend_checksum = "sha256:2b3eeb1346c38a3ef5e4daefcf58d212471db7c8a95dd3dff831b78aaa246e8e"
vm_cpu_cores          = "2"
vm_memory             = "4096"
vm_disk_size          = "40G"
vm_sockets            = "1"
os                    = "win10"
vm_disk_format        = "qcow2"