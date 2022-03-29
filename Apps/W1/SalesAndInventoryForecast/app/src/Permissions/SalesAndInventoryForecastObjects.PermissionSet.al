permissionset 48058 "SalesForecast - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'SalesAndInventoryForecast - Objects';

    Permissions = table "MS - Sales Forecast" = X,
                     table "MS - Sales Forecast Parameter" = X,
                     table "MS - Sales Forecast Setup" = X,
                     page "Sales Forecast" = X,
                     codeunit "Sales Forecast Handler" = X,
                     codeunit "Sales Forecast Install" = X,
                     page "Sales Forecast No Chart" = X,
                     codeunit "Sales Forecast Notifier" = X,
                     query "Sales Forecast Query" = X,
                     codeunit "Sales Forecast Scheduler" = X,
                     page "Sales Forecast Setup Card" = X,
                     codeunit "Sales Forecast Update" = X,
                     codeunit "Sales Forecast Upgrade" = X;
}
