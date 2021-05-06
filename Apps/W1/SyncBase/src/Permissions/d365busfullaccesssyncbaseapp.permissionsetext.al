permissionsetextension 7400 "D365 BUS FULL ACCESS - SyncBaseApp" extends "D365 BUS FULL ACCESS"
{
    Permissions = tabledata "Sync Change" = RIMD,
                  tabledata "Sync Mapping" = RIMD,
                  tabledata "Sync Setup" = RIMD;
}
