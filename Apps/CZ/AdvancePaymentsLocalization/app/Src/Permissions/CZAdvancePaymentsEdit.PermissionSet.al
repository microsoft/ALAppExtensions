permissionset 11751 "CZ Advance Payments - Edit CZZ"
{
    Access = Internal;
    Assignable = false;
    Caption = 'CZ Advance Payments - Edit';

    IncludedPermissionSets = "CZ Advance Payments - Read CZZ";

    Permissions = tabledata "Advance Letter Application CZZ" = IMD,
                  tabledata "Advance Letter Link Buffer CZZ" = IMD,
                  tabledata "Advance Letter Template CZZ" = IMD,
                  tabledata "Advance Posting Buffer CZZ" = IMD,
                  tabledata "Purch. Adv. Letter Entry CZZ" = IMD,
                  tabledata "Purch. Adv. Letter Header CZZ" = IMD,
                  tabledata "Purch. Adv. Letter Line CZZ" = IMD,
                  tabledata "Sales Adv. Letter Entry CZZ" = IMD,
                  tabledata "Sales Adv. Letter Header CZZ" = IMD,
                  tabledata "Sales Adv. Letter Line CZZ" = IMD;
}
