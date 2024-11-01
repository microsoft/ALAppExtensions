// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.eServices.EDocument.IO.Peppol;
using Microsoft.EServices.EDocument.OrderMatch;
using Microsoft.eServices.EDocument.Service.Participant;

permissionset 6102 "E-Doc. Core - Edit"
{
    Access = Public;
    Assignable = true;
    Caption = 'E-Document Core - Edit';

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
        tabledata "Service Participant" = IMD;
}
