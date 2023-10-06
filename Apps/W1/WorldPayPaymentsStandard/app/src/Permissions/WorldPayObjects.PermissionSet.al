#if not CLEAN23
permissionset 29513 "WorldPay - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'WorldPayPaymentsStandard - Objects';
    ObsoleteReason = 'WorldPay Payments Standard extension is discontinued';
    ObsoleteState = Pending;
    ObsoleteTag = '23.0';

    Permissions = codeunit "MS - WorldPay Create Demo Data" = X,
                     table "MS - WorldPay Standard Account" = X,
                     codeunit "MS - WorldPay Standard Mgt." = X,
                     page "MS - WorldPay Standard Setup" = X,
                     codeunit "MS - WorldPay Standard Upgrade" = X,
                     page "MS - WorldPay Std. Settings" = X,
                     page "MS - WorldPay Std. Template" = X,
                     table "MS - WorldPay Std. Template" = X,
                     table "MS - WorldPay Transaction" = X;
}
#endif