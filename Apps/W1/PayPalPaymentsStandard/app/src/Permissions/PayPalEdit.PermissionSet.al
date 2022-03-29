permissionset 45615 "PayPal - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'PayPal Payments Standard - Edit';

    IncludedPermissionSets = "PayPal - Read";

    Permissions = tabledata "MS - PayPal Standard Account" = IMD,
                    tabledata "MS - PayPal Standard Template" = IMD,
                    tabledata "MS - PayPal Transaction" = IMD;
}
