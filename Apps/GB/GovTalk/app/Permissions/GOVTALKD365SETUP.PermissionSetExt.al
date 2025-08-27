// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using System.Security.AccessControl;

permissionsetextension 10519 "GOVTALK D365 SETUP" extends "D365 SETUP"
{
    Permissions = tabledata "GovTalk Msg. Parts" = RIMD,
                  tabledata "Gov Talk Setup" = RIMD,
                  tabledata "GovTalk Message" = RIMD;
}