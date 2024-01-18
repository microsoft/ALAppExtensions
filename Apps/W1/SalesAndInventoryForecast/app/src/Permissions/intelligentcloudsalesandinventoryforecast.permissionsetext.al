namespace System.Security.AccessControl;

using Microsoft.Inventory.InventoryForecast;

permissionsetextension 48056 "INTELLIGENT CLOUD - Sales and Inventory Forecast" extends "INTELLIGENT CLOUD"
{
    Permissions = tabledata "MS - Sales Forecast" = RIMD,
                  tabledata "MS - Sales Forecast Parameter" = RIMD,
                  tabledata "MS - Sales Forecast Setup" = RIMD;
}
