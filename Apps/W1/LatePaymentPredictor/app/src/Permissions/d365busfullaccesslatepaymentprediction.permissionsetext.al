namespace System.Security.AccessControl;

using Microsoft.Finance.Latepayment;
using System.Security.AccessControl;

permissionsetextension 28676 "D365 BUS FULL ACCESS - Late Payment Prediction" extends "D365 BUS FULL ACCESS"
{
    Permissions = tabledata "LP Machine Learning Setup" = RIMD,
                  tabledata "LP ML Input Data" = RIMD;
}
