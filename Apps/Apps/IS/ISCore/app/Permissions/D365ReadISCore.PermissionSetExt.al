// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using System.Security.AccessControl;

permissionsetextension 14606 "D365 READ - IS Core" extends "D365 READ"
{
    IncludedPermissionSets = "IS Core - Read";
}
