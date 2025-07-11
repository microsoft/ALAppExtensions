namespace Microsoft.Finance.GeneralLedger.Review;

/// <summary>
/// this permission set is used to easily add all the extension objects into the apps license
/// do not include this permission set in any other permission set
/// and do not change the Access and Assignable properties
/// </summary>
permissionset 22220 "Review G/L Entries - View"
{
    Assignable = false;
    Access = Public;

    IncludedPermissionSets = "Review G/L Entries - Read";

    Permissions = tabledata "G/L Entry Review Entry" = imd,
                  tabledata "G/L Entry Review Setup" = imd;
}