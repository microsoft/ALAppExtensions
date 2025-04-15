namespace Microsoft.DataMigration.BC;

using System.Security.AccessControl;

permissionsetextension 4021 "INTELLIGENT CLOUD - HBCL" extends "INTELLIGENT CLOUD"
{
    Permissions = tabledata "Source Table Mapping" = RIMD,
    tabledata "Hybrid BC Last Setup" = RIMD;
}