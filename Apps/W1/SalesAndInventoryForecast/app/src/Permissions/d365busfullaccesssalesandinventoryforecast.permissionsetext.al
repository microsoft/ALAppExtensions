permissionsetextension 44824 "D365 BUS FULL ACCESS - Sales and Inventory Forecast" extends "D365 BUS FULL ACCESS"
{
    Permissions = tabledata "MS - Sales Forecast" = RIMD,
                  tabledata "MS - Sales Forecast Parameter" = RIMD,
                  tabledata "MS - Sales Forecast Setup" = RIMD;
}
