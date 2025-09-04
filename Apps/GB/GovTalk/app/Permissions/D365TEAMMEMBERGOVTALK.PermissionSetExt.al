// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using System.Security.AccessControl;

permissionsetextension 10580 "D365 TEAM MEMBER - GovTalk" extends "D365 TEAM MEMBER"
{
    IncludedPermissionSets = "GovTalk - Objects RM",
                             "GovTalk - Objects X";
}