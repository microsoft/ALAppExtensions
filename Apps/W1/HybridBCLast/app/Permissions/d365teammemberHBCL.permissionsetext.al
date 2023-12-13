namespace Microsoft.DataMigration.BC;

using System.Security.AccessControl;

permissionsetextension 4020 "D365 TEAM MEMBER - HBCL" extends "D365 TEAM MEMBER"
{
    Permissions = tabledata "Source Table Mapping" = RIMD,
#if not CLEAN24
#pragma warning disable AL0432
    tabledata "Stg Incoming Document" = RIMD,
#pragma warning restore AL0432
#endif
    tabledata "Hybrid BC Last Setup" = RIMD;
}