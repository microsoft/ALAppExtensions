namespace Microsoft.eServices.EDocument;

using Microsoft.eServices.EDocument.OrderMatch;
using Microsoft.eServices.EDocument.Service.Participant;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.OrderMatch.Copilot;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;

permissionset 6105 "E-Doc. Core - User"
{
    Assignable = true;
    Caption = 'E-Doc. User', MaxLength = 30;

    IncludedPermissionSets = "E-Doc. Core - Read";

    Permissions =
        tabledata "E-Doc. Mapping" = IMD,
        tabledata "E-Doc. Mapping Log" = IMD,
        tabledata "E-Doc. Data Storage" = IMD,
        tabledata "E-Document" = IMD,
        tabledata "E-Document Log" = IMD,
        tabledata "E-Document Service Status" = IMD,
        tabledata "E-Document Integration Log" = IMD,
        tabledata "E-Doc. Imported Line" = IMD,
        tabledata "E-Doc. Order Match" = IMD,
        tabledata "Service Participant" = IMD,
        tabledata "E-Doc. Import Parameters" = IMD,
        tabledata "E-Doc. PO Match Prop. Buffer" = IMD,
        tabledata "E-Document Header Mapping" = IMD,
        tabledata "E-Document Line Mapping" = IMD,
        tabledata "E-Document Purchase Header" = IMD,
        tabledata "E-Document Purchase Line" = IMD;
}
