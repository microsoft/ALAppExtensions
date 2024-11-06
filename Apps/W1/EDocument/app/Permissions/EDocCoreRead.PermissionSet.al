// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.eServices.EDocument.IO.Peppol;
using Microsoft.EServices.EDocument.OrderMatch;
using Microsoft.eServices.EDocument.Service.Participant;

permissionset 6101 "E-Doc. Core - Read"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "E-Doc. Core - Objects";
    Permissions =
        tabledata "E-Doc. Mapping" = R,
        tabledata "E-Doc. Mapping Log" = R,
        tabledata "E-Doc. Data Storage" = R,
        tabledata "E-Document" = R,
        tabledata "E-Document Log" = R,
        tabledata "E-Document Service" = R,
        tabledata "E-Document Service Status" = R,
        tabledata "E-Document Integration Log" = R,
        tabledata "E-Doc. Service Data Exch. Def." = R,
        tabledata "E-Doc. Service Supported Type" = R,
        tabledata "E-Doc. Imported Line" = R,
        tabledata "E-Doc. Order Match" = R,
        tabledata "Service Participant" = R;
}