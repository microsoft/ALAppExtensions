namespace System.Security.AccessControl;

using Microsoft.DataMigration.GP;

permissionsetextension 4713 "INTELLIGENT CLOUD - HGPUS" extends "INTELLIGENT CLOUD"
{
    Permissions = tabledata "Supported Tax Year" = RIMD,
                  tabledata "GP 1099 Box Mapping" = RIMD,
                  tabledata "GP 1099 Migration Log" = RIMD;
}