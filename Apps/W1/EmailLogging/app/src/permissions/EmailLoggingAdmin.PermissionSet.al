/// <summary>
/// this permission set is used to easily add all the extension objects into the apps license
/// do not include this permission set in any other permission set
/// and do not change the Access and Assignable properties
/// </summary>
permissionset 1682 "Email Logging - Admin"
{
    Assignable = false;
    Access = Public;
    IncludedPermissionSets = "Email Logging - Read";

    Permissions = tabledata "Email Logging Setup" = imd;
}