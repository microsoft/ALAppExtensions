namespace Microsoft.EServices.EDocumentConnector.ForNAV;
using Microsoft.eServices.EDocument;

permissionset 6413 "ForNAV EDoc Edit"
{
    Access = Public;
    Assignable = true;

    IncludedPermissionSets = "E-Doc. Core - Edit", "ForNAV EDoc Inc Read";
}