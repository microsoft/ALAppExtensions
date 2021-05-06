permissionsetextension 32397 "D365 READ - Sales and Inventory Forecast" extends "D365 READ"
{
    Permissions = tabledata "MS - Sales Forecast" = R,
                  tabledata "MS - Sales Forecast Parameter" = R,
                  tabledata "MS - Sales Forecast Setup" = R;
}
