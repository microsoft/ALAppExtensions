permissionsetextension 27130 "D365 BUS FULL ACCESSWorldPay Payments Standard" extends "D365 BUS FULL ACCESS"
{
    Permissions = tabledata "MS - WorldPay Standard Account" = RIMD,
                  tabledata "MS - WorldPay Std. Template" = RIMD,
                  tabledata "MS - WorldPay Transaction" = RIMD;
}
