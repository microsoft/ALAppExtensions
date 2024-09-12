// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using System.Security.AccessControl;

permissionsetextension 6620 "FS D365 FULL ACCESS" extends "D365 FULL ACCESS"
{
    IncludedPermissionSets = "FS - Read";
}
