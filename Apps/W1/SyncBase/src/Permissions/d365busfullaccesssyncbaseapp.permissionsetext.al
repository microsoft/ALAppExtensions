#if not CLEAN24
namespace Microsoft.Integration.SyncBase;

using System.Security.AccessControl;

permissionsetextension 7400 "D365 BUS FULL ACCESS - SyncBaseApp" extends "D365 BUS FULL ACCESS"
{
    Permissions = tabledata "Sync Change" = RIMD,
                  tabledata "Sync Mapping" = RIMD,
                  tabledata "Sync Setup" = RIMD;
}
#endif