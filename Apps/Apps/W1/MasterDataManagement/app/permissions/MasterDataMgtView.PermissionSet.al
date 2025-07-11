namespace Microsoft.Integration.MDM;

/// <summary>
/// this permission set is used to easily add all the extension objects into the apps license
/// do not include this permission set in any other permission set
/// and do not change the Access and Assignable properties
/// </summary>
permissionset 7232 "Master Data Mgt. - View"
{
    Assignable = false;
    Access = Public;

    IncludedPermissionSets = "Master Data Mgt. - Read";

    Permissions = tabledata "Master Data Full Synch. R. Ln." = imd,
                  tabledata "Master Data Mgt. Coupling" = imd,
                  tabledata "Master Data Mgt. Subscriber" = imd,
                  tabledata "Master Data Management Setup" = imd;
}