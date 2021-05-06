permissionsetextension 6558 "D365 TEAM MEMBER - PayPal Payments Standard" extends "D365 TEAM MEMBER"
{
    Permissions = tabledata "MS - PayPal Standard Account" = R,
                  tabledata "MS - PayPal Standard Template" = R,
                  tabledata "MS - PayPal Transaction" = R;
}
