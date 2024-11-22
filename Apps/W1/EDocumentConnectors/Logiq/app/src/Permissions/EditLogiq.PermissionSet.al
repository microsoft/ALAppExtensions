namespace Microsoft.EServices.EDocumentConnector.Logiq;

permissionset 6382 "Edit - Logiq"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "Read - Logiq";

    Permissions = tabledata "Connection Setup" = IM,
                tabledata "Connection User Setup" = IM;
}