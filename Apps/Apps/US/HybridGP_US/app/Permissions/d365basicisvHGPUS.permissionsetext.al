namespace System.Security.AccessControl;

using Microsoft.DataMigration.GP;

permissionsetextension 4711 "D365 BASIC ISV - HGPUS" extends "D365 BASIC ISV"
{
    Permissions = tabledata "Supported Tax Year" = RIMD,
                  tabledata "GP 1099 Box Mapping" = RIMD,
                  tabledata "GP 1099 Migration Log" = RIMD;
}