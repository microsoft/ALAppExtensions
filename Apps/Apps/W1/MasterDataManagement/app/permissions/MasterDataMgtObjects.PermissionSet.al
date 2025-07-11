namespace Microsoft.Integration.MDM;

/// <summary>
/// this permission set is used to easily add all the extension objects into the apps license
/// do not include this permission set in any other permission set
/// and do not change the Access and Assignable properties
/// </summary>
permissionset 7230 "Master Data Mgt. - Objects"
{
    Assignable = false;
    Access = Public;

    Permissions = codeunit * = X,
                  page * = X,
                  table * = X,
                  xmlport * = X;
}