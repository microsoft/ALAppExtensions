permissionsetextension 16230 "D365 BUS PREMIUM - Sales and Inventory Forecast" extends "D365 BUS PREMIUM"
{
    Permissions = tabledata "MS - Sales Forecast" = RIMD,
                  tabledata "MS - Sales Forecast Parameter" = RIMD,
                  tabledata "MS - Sales Forecast Setup" = RIMD;
}
