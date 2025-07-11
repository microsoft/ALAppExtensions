// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.eServices.EDocument.OrderMatch;
using Microsoft.eServices.EDocument.Service.Participant;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.OrderMatch.Copilot;
using Microsoft.eServices.EDocument.Processing;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.eServices.EDocument.IO.Peppol;

permissionset 6105 "E-Doc. Core - User"
{
    Assignable = true;
    Caption = 'E-Document - User';

    IncludedPermissionSets = "E-Doc. Core - Read";

    Permissions =
        tabledata "E-Document" = iMD,
    #region Service
        tabledata "E-Document Service" = im,
        tabledata "E-Document Service Status" = imd,
        tabledata "E-Doc. Service Data Exch. Def." = im,
        tabledata "E-Doc. Service Supported Type" = im,
    #endregion
    #region Mapping
        tabledata "E-Doc. Mapping" = im,
        tabledata "E-Doc. Mapping Log" = imd,
    #endregion Mapping
    #region Logging
        tabledata "E-Document Log" = imd,
        tabledata "E-Doc. Data Storage" = im,
        tabledata "E-Document Integration Log" = im,
    #endregion Logging
        tabledata "E-Doc. Imported Line" = IMD,
        tabledata "E-Doc. Order Match" = IMD,
        tabledata "E-Doc. PO Match Prop. Buffer" = IMD,
        tabledata "Service Participant" = IMD,
    #region Purchase draft
        tabledata "E-Doc. Import Parameters" = IMD,
        tabledata "E-Document Purchase Header" = IMD,
        tabledata "E-Document Purchase Line" = IMD,
        tabledata "E-Document Line - Field" = IMD,
        tabledata "E-Doc. Vendor Assign. History" = IMD,
        tabledata "E-Doc. Purchase Line History" = IMD,
        tabledata "ED Purchase Line Field Setup" = IMD,
        tabledata "E-Doc. Record Link" = IMD;
    #endregion Purchase draft
}