namespace System.Security.AccessControl;

using Microsoft.DataMigration.GP;

permissionsetextension 4712 "D365 TEAM MEMBER - HGPUS" extends "D365 TEAM MEMBER"
{
    Permissions = tabledata "Supported Tax Year" = RIMD,
                  tabledata "GP 1099 Box Mapping" = RIMD,
                  tabledata "GP 1099 Migration Log" = RIMD;
}