permissionset 134686 "Email Edit"
{
    Assignable = true;
    IncludedPermissionSets = "Email - Edit";

    // Include Test Tables
    Permissions = 
        tabledata "Test Email Connector Setup" = RIMD,
        tabledata "Test Email Account" = RIMD; // Needed for the Record to get passed in Library Assert
}