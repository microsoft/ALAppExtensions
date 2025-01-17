// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using System.Security.AccessControl;

permissionsetextension 6361 "D365 Basic - EDocument Connector" extends "D365 BASIC"
{
    IncludedPermissionSets = "EDocConnector - Edit";
}