namespace System.Security.AccessControl;

using Microsoft.Finance.Latepayment;
permissionset 8312 "LatePayment - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'LatePaymentPredictor - Read';

    IncludedPermissionSets = "LatePayment - Objects";

    Permissions = tabledata "LP Machine Learning Setup" = Rim,
                    tabledata "LP ML Input Data" = Rim;
}
