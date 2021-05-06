permissionsetextension 11037 "D365 BUS FULL ACCESS - DIOT - Localization for Mexico" extends "D365 BUS FULL ACCESS"
{
    Permissions = tabledata "DIOT Concept" = RIMD,
                  tabledata "DIOT Concept Link" = RIMD,
                  tabledata "DIOT Country/Region Data" = RIMD,
                  tabledata "DIOT Report Buffer" = RIMD,
                  tabledata "DIOT Report Vendor Buffer" = RIMD;
}
