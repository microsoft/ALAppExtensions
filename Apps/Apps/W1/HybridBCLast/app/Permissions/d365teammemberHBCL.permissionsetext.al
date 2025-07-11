namespace Microsoft.DataMigration.BC;

using System.Security.AccessControl;

permissionsetextension 4020 "D365 TEAM MEMBER - HBCL" extends "D365 TEAM MEMBER"
{
    Permissions = tabledata "Source Table Mapping" = RIMD,
    tabledata "Hybrid BC Last Setup" = RIMD;
}