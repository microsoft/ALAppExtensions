namespace Microsoft.EServices.EDocumentConnector.ForNAV;
using System.Security.AccessControl;
permissionset 6411 "ForNAV EDoc Endpoint"
{
    Access = Internal;
    Assignable = true;
    IncludedPermissionSets = LOGIN, "D365 BASIC", Microsoft.eServices.EDocument."E-Doc. Core - Basic", SUPER;
    Permissions =
        table * = X,
        codeunit * = X,
        page "ForNAV Incoming E-Docs Api" = X,
        tabledata "ForNAV Incoming E-Document" = IMRD;
}