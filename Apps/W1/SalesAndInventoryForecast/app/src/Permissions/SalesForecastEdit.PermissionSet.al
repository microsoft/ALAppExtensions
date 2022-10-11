permissionset 48057 "SalesForecast - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'SalesAndInventoryForecast - Edit';

    IncludedPermissionSets = "SalesForecast - Read";

    Permissions = tabledata "MS - Sales Forecast" = IMD,
                    tabledata "MS - Sales Forecast Parameter" = IMD,
                    tabledata "MS - Sales Forecast Setup" = IMD;
}
