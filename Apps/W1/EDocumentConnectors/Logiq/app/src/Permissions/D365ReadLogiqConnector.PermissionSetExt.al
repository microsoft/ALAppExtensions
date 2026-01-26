// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

using System.Security.AccessControl;

permissionsetextension 6430 "D365 Read - Logiq Connector" extends "D365 READ"
{
    IncludedPermissionSets = "Read - Logiq";
}
