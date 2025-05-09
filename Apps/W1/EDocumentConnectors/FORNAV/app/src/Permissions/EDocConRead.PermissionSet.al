namespace Microsoft.EServices.EDocumentConnector.ForNAV;

using Microsoft.eServices.EDocument;

permissionset 6246260 "ForNAV EDocCon. Read"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "E-Doc. Core - Read";
    Permissions = tabledata "ForNAV Incoming Doc" = R;
}