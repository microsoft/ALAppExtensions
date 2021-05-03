permissionsetextension 4019 "D365 BASIC ISV - HBCL" extends "D365 BASIC ISV"
{
    Permissions = tabledata "Source Table Mapping" = RIMD,
                  tabledata "Hybrid BC Last Setup" = RIMD,
                  tabledata "Stg Incoming Document" = RIMD;
}