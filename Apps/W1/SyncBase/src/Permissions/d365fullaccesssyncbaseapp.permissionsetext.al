permissionsetextension 48421 "D365 FULL ACCESS - SyncBaseApp" extends "D365 FULL ACCESS"
{
    Permissions = tabledata "Sync Change" = RIMD,
                  tabledata "Sync Mapping" = RIMD,
                  tabledata "Sync Setup" = RIMD;
}
