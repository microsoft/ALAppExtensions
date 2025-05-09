namespace Microsoft.EServices.EDocumentConnector.ForNAV;
using System.Security.AccessControl;

permissionset 6246261 "ForNAV Endpoint"
{
    Access = Internal;
    Assignable = true;
    IncludedPermissionSets = LOGIN, "D365 BASIC", Microsoft.eServices.EDocument."E-Doc. Core - Basic", SUPER;
    Permissions =
        table * = X,
        codeunit * = X,
        page "ForNAV Incoming Docs Api" = X,
        tabledata "ForNAV Incoming Doc" = IMRD;
}