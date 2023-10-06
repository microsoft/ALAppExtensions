namespace System.Security.AccessControl;

using Microsoft.Inventory.InventoryForecast;

using System.Security.AccessControl;

permissionsetextension 46656 "D365 BASIC ISV - Sales and Inventory Forecast" extends "D365 BASIC ISV"
{
    Permissions = tabledata "MS - Sales Forecast" = RIMD,
                  tabledata "MS - Sales Forecast Parameter" = RIMD,
                  tabledata "MS - Sales Forecast Setup" = RIMD;
}
