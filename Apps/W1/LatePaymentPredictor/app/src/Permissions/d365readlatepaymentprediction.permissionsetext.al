namespace System.Security.AccessControl;

using Microsoft.Finance.Latepayment;

permissionsetextension 13804 "D365 READ - Late Payment Prediction" extends "D365 READ"
{
    Permissions = tabledata "LP Machine Learning Setup" = Rim,
                  tabledata "LP ML Input Data" = Rim;
}
