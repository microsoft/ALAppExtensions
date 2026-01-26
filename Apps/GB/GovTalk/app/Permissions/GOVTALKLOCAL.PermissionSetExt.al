// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using System.Security.AccessControl;

permissionsetextension 10525 "GOVTALK LOCAL" extends "LOCAL"
{
    Permissions = tabledata "GovTalk Msg. Parts" = RIMD,
                  tabledata "Gov Talk Setup" = r,
                  tabledata "GovTalk Message" = RIMD;
}