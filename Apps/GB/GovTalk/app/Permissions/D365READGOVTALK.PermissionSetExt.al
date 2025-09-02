// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using System.Security.AccessControl;

permissionsetextension 10575 "D365 READ - GovTalk" extends "D365 READ"
{
    IncludedPermissionSets = "GovTalk - Objects Read",
                             "GovTalk - Objects X";
}