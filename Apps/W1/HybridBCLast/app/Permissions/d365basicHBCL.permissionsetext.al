permissionsetextension 4018 "D365 BASIC - HBCL" extends "D365 BASIC"
{
    Permissions = tabledata "Source Table Mapping" = RIMD,
                  tabledata "Hybrid BC Last Setup" = RIMD,
                  tabledata "Stg Incoming Document" = RIMD;
}