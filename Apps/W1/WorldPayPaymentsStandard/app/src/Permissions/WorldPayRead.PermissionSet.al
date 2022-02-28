permissionset 29514 "WorldPay - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'WorldPayPaymentsStandard - Read';

    IncludedPermissionSets = "WorldPay - Objects";

    Permissions = tabledata "MS - WorldPay Standard Account" = R,
                    tabledata "MS - WorldPay Std. Template" = R,
                    tabledata "MS - WorldPay Transaction" = R;
}
