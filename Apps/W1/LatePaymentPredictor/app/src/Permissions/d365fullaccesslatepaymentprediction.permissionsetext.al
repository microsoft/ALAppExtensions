namespace System.Security.AccessControl;

using Microsoft.Finance.Latepayment;
using System.Security.AccessControl;

permissionsetextension 3503 "D365 FULL ACCESS - Late Payment Prediction" extends "D365 FULL ACCESS"
{
    Permissions = tabledata "LP Machine Learning Setup" = RIMD,
                  tabledata "LP ML Input Data" = RIMD;
}
