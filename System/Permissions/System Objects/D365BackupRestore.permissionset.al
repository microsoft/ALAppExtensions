permissionset 8383 "D365 BACKUP/RESTORE"
{
    Access = Public;
    Assignable = true;
    Caption = 'Backup or restore database';

    Permissions = system "Tools, Backup" = X,
                  system "Tools, Restore" = X;
}
