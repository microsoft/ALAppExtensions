// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

using System.Security.AccessControl;

permissionsetextension 6390 "Cont. EDoc. Connector - Read" extends "D365 READ"
{
    IncludedPermissionSets = ContEDocConnRead;
}