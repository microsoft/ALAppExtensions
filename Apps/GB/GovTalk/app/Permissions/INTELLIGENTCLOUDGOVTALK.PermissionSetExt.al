// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using System.Security.AccessControl;

permissionsetextension 10581 "Intelligent Cloud - GovTalk" extends "INTELLIGENT CLOUD"
{
    IncludedPermissionSets = "GovTalk - Objects Read",
                             "GovTalk - Objects X";
}