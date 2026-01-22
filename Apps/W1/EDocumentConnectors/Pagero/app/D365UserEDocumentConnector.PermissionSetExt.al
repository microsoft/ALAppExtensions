// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.eServices.EDocument;
using Microsoft.EServices.EDocumentConnector;

permissionsetextension 6363 "D365 User - EDocument Connector" extends "E-Doc. Core - User"
{
    IncludedPermissionSets = "EDocConnector - Edit";
}