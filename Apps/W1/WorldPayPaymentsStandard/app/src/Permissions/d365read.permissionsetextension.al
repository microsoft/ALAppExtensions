permissionsetextension 29920 "D365 READWorldPay Payments Standard" extends "D365 READ"
{
    Permissions = tabledata "MS - WorldPay Standard Account" = R,
                  tabledata "MS - WorldPay Std. Template" = R,
                  tabledata "MS - WorldPay Transaction" = R;
}
