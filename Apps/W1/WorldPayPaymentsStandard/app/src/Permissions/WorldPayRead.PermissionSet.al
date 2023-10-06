#if not CLEAN23
permissionset 29514 "WorldPay - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'WorldPayPaymentsStandard - Read';
    ObsoleteReason = 'WorldPay Payments Standard extension is discontinued';
    ObsoleteState = Pending;
    ObsoleteTag = '23.0';

    IncludedPermissionSets = "WorldPay - Objects";

    Permissions = tabledata "MS - WorldPay Standard Account" = R,
                    tabledata "MS - WorldPay Std. Template" = R,
                    tabledata "MS - WorldPay Transaction" = R;
}
#endif