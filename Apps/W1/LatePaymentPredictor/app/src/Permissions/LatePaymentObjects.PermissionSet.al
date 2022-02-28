permissionset 8311 "LatePayment - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'LatePaymentPredictor - Objects';

    Permissions = codeunit "Late Payment Install" = X,
                     codeunit "Late Payment Upgrade" = X,
                     page "LP Machine Learning Setup" = X,
                     table "LP Machine Learning Setup" = X,
                     table "LP ML Input Data" = X,
                     codeunit "LP Model Management" = X,
                     page "LP Prediction FactBox" = X,
                     codeunit "LP Prediction Mgt." = X,
                     query "LPP Sales Invoice Header Input" = X,
                     codeunit "LPP Scheduler" = X,
                     codeunit "LP Subscribers" = X,
                     codeunit "LPP Update" = X;
}
