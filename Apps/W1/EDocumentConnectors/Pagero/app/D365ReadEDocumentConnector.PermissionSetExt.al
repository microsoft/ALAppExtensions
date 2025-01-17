// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using System.Security.AccessControl;
using Microsoft.EServices.EDocumentConnector;

permissionsetextension 6362 "D365 Read - EDocument Connector" extends "D365 READ"
{
    IncludedPermissionSets = "EDocConnector - Edit";
}