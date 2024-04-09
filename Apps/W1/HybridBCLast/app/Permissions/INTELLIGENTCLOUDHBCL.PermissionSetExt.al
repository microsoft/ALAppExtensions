namespace Microsoft.DataMigration.BC;

using System.Security.AccessControl;

permissionsetextension 4021 "INTELLIGENT CLOUD - HBCL" extends "INTELLIGENT CLOUD"
{
    Permissions = tabledata "Source Table Mapping" = RIMD,
#if not CLEAN24
#pragma warning disable AL0432
    tabledata "Stg Incoming Document" = RIMD,
#pragma warning restore AL0432
#endif
    tabledata "Hybrid BC Last Setup" = RIMD;
}