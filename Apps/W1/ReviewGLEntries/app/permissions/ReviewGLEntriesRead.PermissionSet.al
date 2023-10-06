namespace Microsoft.Finance.GeneralLedger.Review;

/// <summary>
/// this permission set is used to easily add all the extension objects into the apps license
/// do not include this permission set in any other permission set
/// and do not change the Access and Assignable properties
/// </summary>
permissionset 22219 "Review G/L Entries - Read"
{
    Assignable = false;
    Access = Public;

    IncludedPermissionSets = "Review G/L Entries - Objects";

    Permissions = tabledata "G/L Entry Review Entry" = r,
                  tabledata "G/L Entry Review Setup" = r;
}