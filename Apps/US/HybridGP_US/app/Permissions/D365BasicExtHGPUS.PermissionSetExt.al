namespace System.Security.AccessControl;

using Microsoft.DataMigration.GP;

permissionsetextension 4710 "D365 Basic Ext. - HGPUS" extends "D365 BASIC"
{
    Permissions = tabledata "Supported Tax Year" = RIMD,
                  tabledata "GP 1099 Box Mapping" = RIMD,
                  tabledata "GP 1099 Migration Log" = RIMD;
}