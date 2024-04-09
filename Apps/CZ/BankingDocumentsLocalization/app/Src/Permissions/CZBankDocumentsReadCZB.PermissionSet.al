permissionset 11790 "CZ Bank Documents - Read CZB"
{
    Access = Internal;
    Assignable = false;
    Caption = 'CZ Bank Documents - Read';

    IncludedPermissionSets = "CZ Bank Documents - Obj. CZB";

    Permissions = tabledata "Bank Statement Header CZB" = R,
                  tabledata "Bank Statement Line CZB" = R,
                  tabledata "Iss. Bank Statement Header CZB" = R,
                  tabledata "Iss. Bank Statement Line CZB" = R,
                  tabledata "Iss. Payment Order Header CZB" = R,
                  tabledata "Iss. Payment Order Line CZB" = R,
                  tabledata "Payment Order Header CZB" = R,
                  tabledata "Payment Order Line CZB" = R,
                  tabledata "Search Rule CZB" = R,
                  tabledata "Search Rule Line CZB" = R;
}
