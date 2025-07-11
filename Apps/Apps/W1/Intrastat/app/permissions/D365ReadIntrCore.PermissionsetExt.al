// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using System.Security.AccessControl;

permissionsetextension 4812 "D365 READ - Intr. Core" extends "D365 READ"
{
    IncludedPermissionSets = "Intr. Core - Read";
}
