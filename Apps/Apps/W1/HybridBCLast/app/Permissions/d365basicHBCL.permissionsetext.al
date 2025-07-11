namespace Microsoft.DataMigration.BC;

using System.Security.AccessControl;

permissionsetextension 4018 "D365 BASIC - HBCL" extends "D365 BASIC"
{
    Permissions = tabledata "Source Table Mapping" = RIMD,
    tabledata "Hybrid BC Last Setup" = RIMD;
}