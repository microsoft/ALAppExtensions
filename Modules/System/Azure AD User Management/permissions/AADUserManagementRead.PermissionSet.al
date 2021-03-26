permissionset 9010 "AAD User Management - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "User Login Times - Read",
                             "Azure AD User - View",
                             "Azure AD Plan - View",
                             "Language - View";

    Permissions = tabledata "Azure AD User Update Buffer" = R, // needed to be able to search Azure AD User Update Wizard
                  tabledata User = r,
                  tabledata "User Personalization" = r,
                  tabledata "User Property" = r;
}