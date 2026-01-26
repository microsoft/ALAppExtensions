// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using System.Security.AccessControl;

permissionsetextension 6618 "FS D365 BUS FULL ACCESS" extends "D365 BUS FULL ACCESS"
{
    IncludedPermissionSets = "FS - Read";
}
