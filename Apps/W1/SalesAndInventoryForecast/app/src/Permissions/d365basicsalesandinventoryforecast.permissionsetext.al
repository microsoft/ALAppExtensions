permissionsetextension 4668 "D365 BASIC - Sales and Inventory Forecast" extends "D365 BASIC"
{
    Permissions = tabledata "MS - Sales Forecast" = RIMD,
                  tabledata "MS - Sales Forecast Parameter" = RIMD,
                  tabledata "MS - Sales Forecast Setup" = RIMD;
}
