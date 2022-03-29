permissionset 8312 "LatePayment - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'LatePaymentPredictor - Read';

    IncludedPermissionSets = "LatePayment - Objects";

    Permissions = tabledata "LP Machine Learning Setup" = R,
                    tabledata "LP ML Input Data" = R;
}
