permissionset 134687 "Email Admin"
{
    Assignable = true;
    IncludedPermissionSets = "Email - Admin";

    // Include Test Tables
    Permissions = 
        tabledata "Test Email Connector Setup" = RIMD,
        tabledata "Test Email Account" = RIMD;
}