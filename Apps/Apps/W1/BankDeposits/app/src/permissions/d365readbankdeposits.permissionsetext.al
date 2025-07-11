namespace Microsoft.Bank.Deposit;

using System.Security.AccessControl;

permissionsetextension 1695 "D365 READ - Bank Deposits" extends "D365 READ"
{
    IncludedPermissionSets = "Bank Deposits - Read";
}
