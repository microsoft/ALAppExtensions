permissionset 45617 "PayPal - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'PayPal Payments Standard - Read';

    IncludedPermissionSets = "PayPal - Objects";

    Permissions = tabledata "MS - PayPal Standard Account" = R,
                tabledata "MS - PayPal Standard Template" = R,
                tabledata "MS - PayPal Transaction" = R;
}
