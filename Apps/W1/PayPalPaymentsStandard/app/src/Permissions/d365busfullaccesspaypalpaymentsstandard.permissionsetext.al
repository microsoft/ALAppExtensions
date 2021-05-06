permissionsetextension 20369 "D365 BUS FULL ACCESS - PayPal Payments Standard" extends "D365 BUS FULL ACCESS"
{
    Permissions = tabledata "MS - PayPal Standard Account" = RIMD,
                  tabledata "MS - PayPal Standard Template" = RIMD,
                  tabledata "MS - PayPal Transaction" = RIMD;
}
