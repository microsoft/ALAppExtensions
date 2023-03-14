permissionset 8310 "LatePayment - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'LatePaymentPredictor - Edit';

    IncludedPermissionSets = "LatePayment - Read";

    Permissions = tabledata "LP Machine Learning Setup" = IMD,
                    tabledata "LP ML Input Data" = IMD;
}
