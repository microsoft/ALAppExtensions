// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using System.Security.AccessControl;

permissionsetextension 13910 "D365 Read - OIOUBL Format" extends "D365 READ"
{
    IncludedPermissionSets = "EDocOIOUBL - Read";
}