// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using System.Security.AccessControl;

permissionsetextension 4815 "LOCAL - Intr. Core" extends LOCAL
{
    IncludedPermissionSets = "Intr. Core - Read";
}
