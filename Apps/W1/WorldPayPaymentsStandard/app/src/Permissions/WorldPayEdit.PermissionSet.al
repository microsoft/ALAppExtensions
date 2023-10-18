#if not CLEAN23
permissionset 29512 "WorldPay - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'WorldPayPaymentsStandard - Edit';
    ObsoleteReason = 'WorldPay Payments Standard extension is discontinued';
    ObsoleteState = Pending;
    ObsoleteTag = '23.0';

    IncludedPermissionSets = "WorldPay - Read";

    Permissions = tabledata "MS - WorldPay Standard Account" = IMD,
                    tabledata "MS - WorldPay Std. Template" = IMD,
                    tabledata "MS - WorldPay Transaction" = IMD;
}
#endif