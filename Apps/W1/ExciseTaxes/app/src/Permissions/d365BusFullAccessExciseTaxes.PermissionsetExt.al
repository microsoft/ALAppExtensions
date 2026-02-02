// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

using System.Security.AccessControl;

permissionsetextension 7455 "D365 BUS FULL ACCESS ExciseTaxes" extends "D365 BUS FULL ACCESS"
{
    IncludedPermissionSets = "ExciseTaxes - Admin";
}