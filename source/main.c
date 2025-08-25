#include <ps4.h>
#include <file.h>

int _main(struct thread *td) {
    
    
    initKernel();
    initLibc();
    initPthread();
    jailbreak();
    initSysUtil();

    copy_file("/dev/sflash0", "/data/sflash0.bin");
    printf_notification("sflash0 copied!\nChecking file size...");

    struct stat info;
    int res = 0;

    if (!stat("/data/sflash0.bin", &info)) {
        if (info.st_size == 33554432) {
            printf_notification("sflash0.bin is %d bytes\nDump is correct!", info.st_size);
            res = 1;
        }
        else {
            printf_notification("sflash0.bin is %d bytes\nDump is NOT correct!\nTry reboot and run the payload again!", info.st_size);
            res = unlink("/data/sflash0.bin");
            return 0;
        }
    }
    else {
        printf_notification("sflash0.bin doesn't exist!\nSomething gone wrong...");
        return 0;
    }

    if (res == 1) {
        printf_notification("Copying sflash0.bin to USB...");
        int usbdir = open("/mnt/usb0/.dirtest", O_WRONLY | O_CREAT | O_TRUNC, 0777);
        if (usbdir == -1) {
            usbdir = open("/mnt/usb1/.dirtest", O_WRONLY | O_CREAT | O_TRUNC, 0777);
            if (usbdir == -1) {
                printf_notification("USB not found!\nOnly internal backup was done\n(/data/sflash0.bin)!");
            }
            else {
                close(usbdir);
                unlink("/mnt/usb1/.dirtest");
                copy_file("/data/sflash0.bin", "/mnt/usb1/sflash0.bin");
                printf_notification("Dump copied to USB1 successfully!");
            }
        }
        else {
            close(usbdir);
            unlink("/mnt/usb0/.dirtest");
            copy_file("/data/sflash0.bin", "/mnt/usb0/sflash0.bin");
            printf_notification("Dump copied to USB0 successfully!");
        }
    }

    return 0;
}
