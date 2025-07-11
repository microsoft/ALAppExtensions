// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using System.Security.AccessControl;

permissionsetextension 6613 "FS D365 READ" extends "D365 READ"
{
    IncludedPermissionSets = "FS - Read";
}
