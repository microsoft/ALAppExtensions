/// <summary>
/// this permission set is used to easily add all the extension objects into the apps license
/// do not include this permission set in any other permission set
/// and do not change the Access and Assignable properties
/// </summary>
permissionset 1702 "Bank Deposits - View"
{
    Assignable = false;
    Access = Public;

    IncludedPermissionSets = "Bank Deposits - Read";

    Permissions = tabledata "Bank Acc. Comment Line" = imd,
                  tabledata "Bank Deposit Header" = imd,
                  tabledata "Posted Bank Deposit Header" = imd,
                  tabledata "Posted Bank Deposit Line" = imd;
}