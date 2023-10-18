namespace Microsoft.Integration.MDM;

/// <summary>
/// this permission set is used to easily add all the extension objects into the apps license
/// do not include this permission set in any other permission set
/// and do not change the Access and Assignable properties
/// </summary>
permissionset 7231 "Master Data Mgt. - Read"
{
    Assignable = false;
    Access = Public;

    IncludedPermissionSets = "Master Data Mgt. - Objects";

    Permissions = tabledata "Master Data Full Synch. R. Ln." = r,
                  tabledata "Master Data Mgt. Coupling" = r,
                  tabledata "Master Data Mgt. Subscriber" = r,
                  tabledata "Master Data Management Setup" = r;
    ;
}