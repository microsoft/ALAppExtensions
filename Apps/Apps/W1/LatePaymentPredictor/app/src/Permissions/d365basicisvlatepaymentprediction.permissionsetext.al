namespace System.Security.AccessControl;

using Microsoft.Finance.Latepayment;

permissionsetextension 26131 "D365 BASIC ISV - Late Payment Prediction" extends "D365 BASIC ISV"
{
    Permissions = tabledata "LP Machine Learning Setup" = RimD,
                  tabledata "LP ML Input Data" = RimD;
}
