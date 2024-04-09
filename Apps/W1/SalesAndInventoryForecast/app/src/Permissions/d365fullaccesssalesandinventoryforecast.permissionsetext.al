namespace System.Security.AccessControl;

using Microsoft.Inventory.InventoryForecast;

permissionsetextension 6323 "D365 FULL ACCESS - Sales and Inventory Forecast" extends "D365 FULL ACCESS"
{
    Permissions = tabledata "MS - Sales Forecast" = RIMD,
                  tabledata "MS - Sales Forecast Parameter" = RIMD,
                  tabledata "MS - Sales Forecast Setup" = RIMD;
}
