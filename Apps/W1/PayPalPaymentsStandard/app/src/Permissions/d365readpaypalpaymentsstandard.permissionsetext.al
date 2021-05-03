permissionsetextension 44784 "D365 READ - PayPal Payments Standard" extends "D365 READ"
{
    Permissions = tabledata "MS - PayPal Standard Account" = R,
                  tabledata "MS - PayPal Standard Template" = R,
                  tabledata "MS - PayPal Transaction" = R;
}
