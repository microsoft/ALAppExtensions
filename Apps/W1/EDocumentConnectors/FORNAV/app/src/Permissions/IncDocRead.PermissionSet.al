namespace Microsoft.EServices.EDocumentConnector.ForNAV;
using Microsoft.eServices.EDocument;

permissionset 6246262 "ForNAV Inc Doc Read"
{
    Access = Public;
    Assignable = false;

    Permissions = tabledata "ForNAV Incoming Doc" = R;
}