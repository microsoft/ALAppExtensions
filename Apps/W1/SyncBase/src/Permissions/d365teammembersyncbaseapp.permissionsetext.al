permissionsetextension 19131 "D365 TEAM MEMBER - SyncBaseApp" extends "D365 TEAM MEMBER"
{
    Permissions = tabledata "Sync Change" = R,
                  tabledata "Sync Mapping" = R,
                  tabledata "Sync Setup" = R;
}
