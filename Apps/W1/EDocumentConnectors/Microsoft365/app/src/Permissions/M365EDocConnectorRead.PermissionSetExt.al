// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using Microsoft.EServices.EDocument;

permissionsetextension 6384 "M365 EDoc. Connector - Read" extends "E-Doc. Core - Read"
{
    IncludedPermissionSets = M365EDocConnRead;
}