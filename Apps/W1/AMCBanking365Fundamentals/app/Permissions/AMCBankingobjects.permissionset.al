permissionset 20109 "AMC Banking- Objects"
{
    Assignable = false;
    Access = Internal;
    Caption = 'AMC Banking- Objects';

    Permissions = codeunit "AMC Bank Assisted Mgt." = X,
#if not CLEAN21
                    codeunit "AMC Bank Bank Acc. Rec Lin" = X,
#endif
                    codeunit "AMC Bank Exp. CT Feedback" = X,
                    codeunit "AMC Bank Exp. CT Hndl" = X,
                    codeunit "AMC Bank Exp. CT Launcher" = X,
#if not CLEAN21
                    codeunit "AMC Bank Exp. CT Mapping" = X,
#endif
                    codeunit "AMC Bank Exp. CT Pre-Map" = X,
                    codeunit "AMC Bank Exp. CT Valid." = X,
                    codeunit "AMC Bank Exp. CT Write" = X,
#if not CLEAN20
                    codeunit "AMC Bank Exp. CT Writing" = X,
#endif
                    codeunit "AMC Bank Imp.BankList Hndl" = X,
#if not CLEAN20
                    codeunit "AMC Bank Import Bank STMT" = X,
#endif
                    codeunit "AMC Bank Import Statement" = X,
#if not CLEAN20
                    codeunit "AMC Bank Imp.-Post-Mapping" = X,
#endif
                    codeunit "AMC Bank Imp.-Post-Process" = X,
#if not CLEAN20
                    codeunit "AMC Bank Imp.-Pre-Mapping" = X,
#endif
                    codeunit "AMC Bank Imp.-Pre-Process" = X,
                    codeunit "AMC Bank Imp.STMT. Hndl" = X,
                    codeunit "AMC Banking Mgt." = X,
                    codeunit "AMC Bank Install" = X,
                    codeunit "AMC Bank PrePost Proc" = X,
#if not CLEAN20
                    codeunit "AMC Bank Pre&Post Process" = X,
#endif
                    codeunit "AMC Bank Process Statement" = X,
                    codeunit "AMC Bank REST Request Mgt." = X,
                    codeunit "AMC Bank Service Request Mgt." = X,
                    codeunit "AMC Bank Upg. Notification" = X,
                    codeunit "AMC Bank Upgrade" = X,
                    page "AMC Bank Assist Bank Account" = X,
                    page "AMC Bank Assisted Setup" = X,
                    page "AMC Bank Bank Name List" = X,
                    page "AMC Banking Setup" = X,
                    page "AMC Bank Pmt. Types" = X,
                    page "AMC Bank Signup to Service" = X,
                    page "AMC Bank Webcall Log" = X,
                    table "AMC Bank Banks" = X,
                    table "AMC Banking Setup" = X,
                    table "AMC Bank Pmt. Type" = X;
}