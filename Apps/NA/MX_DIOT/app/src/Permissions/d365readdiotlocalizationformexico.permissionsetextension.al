permissionsetextension 23717 "D365 READ - DIOT - Localization for Mexico" extends "D365 READ"
{
    Permissions = tabledata "DIOT Concept" = R,
                  tabledata "DIOT Concept Link" = R,
                  tabledata "DIOT Country/Region Data" = R,
                  tabledata "DIOT Report Buffer" = R,
                  tabledata "DIOT Report Vendor Buffer" = R;
}
