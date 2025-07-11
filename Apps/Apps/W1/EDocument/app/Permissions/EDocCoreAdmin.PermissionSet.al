namespace Microsoft.eServices.EDocument;

using Microsoft.eServices.EDocument.IO.Peppol;

permissionset 6104 "E-Doc. Core - Admin"
{
    Assignable = true;
    Access = Public;
    Caption = 'E-Document - Admin';

    IncludedPermissionSets = "E-Doc. Core - User";

    Permissions =
        tabledata "E-Document Service" = IMD,
        tabledata "E-Doc. Service Data Exch. Def." = IMD,
        tabledata "E-Doc. Service Supported Type" = IMD,
        tabledata "E-Doc. Mapping" = IMD;
}