/// <summary>
/// this permission set is used to easily add all the extension objects into the apps license
/// do not include this permission set in any other permission set
/// and do not change the Access and Assignable properties
/// </summary>
permissionset 1681 "Email Logging - Read"
{
    Assignable = false;
    Access = Public;

    IncludedPermissionSets = "Email Logging - Obj.";

    Permissions = tabledata "Email Logging Setup" = r;
}