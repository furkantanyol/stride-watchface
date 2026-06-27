/* Send a local file to a specific MTP parent-folder id.
   usage: mtpsend <localpath> <remotename> <parentfolderid> */
#include <libmtp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

int main(int argc, char **argv) {
    if (argc != 4) { fprintf(stderr, "usage: %s <local> <remote> <parentid>\n", argv[0]); return 2; }
    const char *local = argv[1];
    uint32_t parent = (uint32_t) strtoul(argv[3], NULL, 10);

    struct stat st;
    if (stat(local, &st) != 0) { perror("stat"); return 1; }

    LIBMTP_Init();
    LIBMTP_mtpdevice_t *dev = LIBMTP_Get_First_Device();
    if (dev == NULL) { fprintf(stderr, "no MTP device\n"); return 1; }

    LIBMTP_file_t *f = LIBMTP_new_file_t();
    f->filename = strdup(argv[2]);
    f->filesize = (uint64_t) st.st_size;
    f->filetype = LIBMTP_FILETYPE_UNKNOWN;
    f->parent_id = parent;
    f->storage_id = dev->storage ? dev->storage->id : 0;

    int ret = LIBMTP_Send_File_From_File(dev, local, f, NULL, NULL);
    if (ret != 0) {
        fprintf(stderr, "send FAILED\n");
        LIBMTP_Dump_Errorstack(dev);
    } else {
        printf("sent '%s' -> parent %u as '%s' (new id %u)\n", local, parent, argv[2], f->item_id);
    }
    LIBMTP_destroy_file_t(f);
    LIBMTP_Release_Device(dev);
    return ret;
}
