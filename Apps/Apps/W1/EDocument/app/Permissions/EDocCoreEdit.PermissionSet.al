#if not CLEAN27
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.eServices.EDocument.IO.Peppol;
using Microsoft.EServices.EDocument.OrderMatch;
using Microsoft.eServices.EDocument.Service.Participant;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.OrderMatch.Copilot;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;

permissionset 6102 "E-Doc. Core - Edit"
{
    Access = Public;
    Assignable = true;
    Caption = 'E-Document - Edit';
    ObsoleteReason = 'Use "E-Doc. Core - User" instead.';
    ObsoleteState = Pending;
    ObsoleteTag = '27.0';

    IncludedPermissionSets = "E-Doc. Core - Read";

    Permissions =
        tabledata "E-Doc. Mapping" = IMD,
        tabledata "E-Doc. Mapping Log" = IMD,
        tabledata "E-Doc. Data Storage" = IMD,
        tabledata "E-Document" = IMD,
        tabledata "E-Document Log" = IMD,
        tabledata "E-Document Service" = IMD,
        tabledata "E-Document Service Status" = IMD,
        tabledata "E-Document Integration Log" = IMD,
        tabledata "E-Doc. Service Data Exch. Def." = IMD,
        tabledata "E-Doc. Service Supported Type" = IMD,
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
#endif