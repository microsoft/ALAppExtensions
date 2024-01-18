#if not CLEAN24
namespace Microsoft.Integration.SyncBase;

using System.Security.AccessControl;

permissionsetextension 6351 "D365 READ - SyncBaseApp" extends "D365 READ"
{
    Permissions = tabledata "Sync Change" = R,
                  tabledata "Sync Mapping" = R,
                  tabledata "Sync Setup" = R;
}
#endif