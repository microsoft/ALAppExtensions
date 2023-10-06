namespace System.Security.AccessControl;

using Microsoft.Finance.Latepayment;
using System.Security.AccessControl;

permissionsetextension 38237 "D365 BASIC - Late Payment Prediction" extends "D365 BASIC"
{
    Permissions = tabledata "LP Machine Learning Setup" = RimD,
                  tabledata "LP ML Input Data" = RimD;
}
