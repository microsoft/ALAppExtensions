#if not CLEAN24
namespace Microsoft.Integration.SyncBase;

using System.Security.AccessControl;

permissionsetextension 35149 "D365 BASIC ISV - SyncBaseApp" extends "D365 BASIC ISV"
{
    Permissions = tabledata "Sync Change" = RIMD,
                  tabledata "Sync Mapping" = RIMD,
                  tabledata "Sync Setup" = RIMD;
}
#endif