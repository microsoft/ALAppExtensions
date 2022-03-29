permissionset 29512 "WorldPay - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'WorldPayPaymentsStandard - Edit';

    IncludedPermissionSets = "WorldPay - Read";

    Permissions = tabledata "MS - WorldPay Standard Account" = IMD,
                    tabledata "MS - WorldPay Std. Template" = IMD,
                    tabledata "MS - WorldPay Transaction" = IMD;
}