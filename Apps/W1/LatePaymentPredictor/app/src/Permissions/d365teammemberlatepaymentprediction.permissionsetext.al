namespace System.Security.AccessControl;

using Microsoft.Finance.Latepayment;
using System.Security.AccessControl;

permissionsetextension 48239 "D365 TEAM MEMBER - Late Payment Prediction" extends "D365 TEAM MEMBER"
{
    Permissions = tabledata "LP Machine Learning Setup" = RimD,
                  tabledata "LP ML Input Data" = RimD;
}
