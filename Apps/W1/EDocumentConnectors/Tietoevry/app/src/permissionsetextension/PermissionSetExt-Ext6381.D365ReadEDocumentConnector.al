// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

using System.Security.AccessControl;
using Microsoft.EServices.EDocumentConnector;

permissionsetextension 6381 "D365 Read - EDocument Connector" extends "D365 READ"
{
    IncludedPermissionSets = "TE EDocConn. - Edit";
}