// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using System.Security.AccessControl;

permissionsetextension 6612 "FS D365 DYN CRM READ" extends "D365 DYN CRM READ"
{
    IncludedPermissionSets = "FS - Read";
}
