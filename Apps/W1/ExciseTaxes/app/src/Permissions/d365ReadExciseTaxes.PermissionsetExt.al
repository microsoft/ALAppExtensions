// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

using System.Security.AccessControl;

permissionsetextension 7456 "D365 READ ExciseTaxes" extends "D365 READ"
{
    IncludedPermissionSets = "ExciseTaxes - Read";
}