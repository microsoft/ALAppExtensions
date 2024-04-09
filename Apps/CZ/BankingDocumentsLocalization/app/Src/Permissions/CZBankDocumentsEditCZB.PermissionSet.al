permissionset 11791 "CZ Bank Documents - Edit CZB"
{
    Access = Internal;
    Assignable = false;
    Caption = 'CZ Bank Documents - Edit';

    IncludedPermissionSets = "CZ Bank Documents - Read CZB";

    Permissions = tabledata "Bank Statement Header CZB" = IMD,
                  tabledata "Bank Statement Line CZB" = IMD,
                  tabledata "Iss. Bank Statement Header CZB" = IMD,
                  tabledata "Iss. Bank Statement Line CZB" = IMD,
                  tabledata "Iss. Payment Order Header CZB" = IMD,
                  tabledata "Iss. Payment Order Line CZB" = IMD,
                  tabledata "Payment Order Header CZB" = IMD,
                  tabledata "Payment Order Line CZB" = IMD,
                  tabledata "Search Rule CZB" = IMD,
                  tabledata "Search Rule Line CZB" = IMD;
}
