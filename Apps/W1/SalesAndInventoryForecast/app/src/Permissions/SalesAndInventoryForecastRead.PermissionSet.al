permissionset 48059 "SalesForecast - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'SalesAndInventoryForecast - Read';

    IncludedPermissionSets = "SalesForecast - Objects";

    Permissions =
                    tabledata "MS - Sales Forecast" = R,
                    tabledata "MS - Sales Forecast Parameter" = R,
                    tabledata "MS - Sales Forecast Setup" = R;
}