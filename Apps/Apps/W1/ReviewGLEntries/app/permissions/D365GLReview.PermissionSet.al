namespace Microsoft.Finance.GeneralLedger.Review;

/// <summary>
/// this permission set is used to grant full access to this app's functionality
/// </summary>
permissionset 22217 "D365 GL Review"
{
    Assignable = true;
    Access = Public;

    IncludedPermissionSets = "Review G/L Entries - View";

}