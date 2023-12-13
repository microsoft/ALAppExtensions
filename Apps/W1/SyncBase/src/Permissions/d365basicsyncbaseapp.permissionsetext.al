#if not CLEAN24
namespace Microsoft.Integration.SyncBase;

using System.Security.AccessControl;

permissionsetextension 12127 "D365 BASIC - SyncBaseApp" extends "D365 BASIC"
{
    Permissions = tabledata "Sync Change" = R,
                  tabledata "Sync Mapping" = R,
                  tabledata "Sync Setup" = R;
}
#endif