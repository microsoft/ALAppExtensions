namespace Microsoft.EServices.EDocumentConnector.ForNAV;
using System.Security.AccessControl;

permissionset 6414 "ForNAV EDoc Setup"
{
    Access = Internal;
    Assignable = true;
    IncludedPermissionSets = LOGIN, "D365 BASIC", Microsoft.eServices.EDocument."E-Doc. Core - Basic", SUPER;
    Permissions =
        table * = X,
        codeunit * = X,
        page "ForNAV Peppol Oauth API" = X,
        tabledata "ForNAV Peppol Setup" = IMRD,
        tabledata "ForNAV Peppol Role" = R;
}