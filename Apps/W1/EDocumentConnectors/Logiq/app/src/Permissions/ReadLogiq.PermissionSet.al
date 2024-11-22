namespace Microsoft.EServices.EDocumentConnector.Logiq;

permissionset 6381 "Read - Logiq"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "Objects - Logiq";

    Permissions = tabledata "Connection Setup" = R,
                tabledata "Connection User Setup" = R;
}