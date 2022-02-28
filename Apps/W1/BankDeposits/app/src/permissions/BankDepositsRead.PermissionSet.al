/// <summary>
/// this permission set is used to easily add all the extension objects into the apps license
/// do not include this permission set in any other permission set
/// and do not change the Access and Assignable properties
/// </summary>
permissionset 1701 "Bank Deposits - Read"
{
    Assignable = false;
    Access = Public;

    IncludedPermissionSets = "Bank Deposits - Objects";

    Permissions = tabledata "Bank Acc. Comment Line" = r,
                  tabledata "Bank Deposit Header" = r,
                  tabledata "Posted Bank Deposit Header" = r,
                  tabledata "Posted Bank Deposit Line" = r;
}