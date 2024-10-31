// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AutomaticAccounts;

using System.Security.AccessControl;

permissionsetextension 4855 "D365 READ - AAC" extends "D365 READ"
{
    IncludedPermissionSets = "AAC - Read";
}
