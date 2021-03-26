permissionsetextension 28528 "D365 TEAM MEMBER - Sales and Inventory Forecast" extends "D365 TEAM MEMBER"
{
    Permissions = tabledata "MS - Sales Forecast" = RIMD,
                  tabledata "MS - Sales Forecast Parameter" = RIMD,
                  tabledata "MS - Sales Forecast Setup" = RIMD;
}
