namespace Microsoft.Bank.Deposit;

/// <summary>
/// this permission set is used to grant full access to this app's functionality
/// </summary>
permissionset 1703 "Bank Deposits"
{
    Assignable = true;
    Access = Public;
    IncludedPermissionSets = "Bank Deposits - View";
}