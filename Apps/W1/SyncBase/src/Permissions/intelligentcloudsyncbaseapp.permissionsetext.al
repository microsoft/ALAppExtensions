#if not CLEAN24
namespace Microsoft.Integration.SyncBase;

using System.Security.AccessControl;

permissionsetextension 39475 "INTELLIGENT CLOUD - SyncBaseApp" extends "INTELLIGENT CLOUD"
{
    Permissions = tabledata "Sync Change" = R,
                  tabledata "Sync Mapping" = R,
                  tabledata "Sync Setup" = R;
}
#endif