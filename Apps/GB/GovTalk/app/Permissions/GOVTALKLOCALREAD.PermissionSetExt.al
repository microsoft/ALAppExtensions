// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using System.Security.AccessControl;

permissionsetextension 10526 "GOVTALK LOCAL READ" extends "LOCAL READ"
{
    Permissions = tabledata "GovTalk Msg. Parts" = R,
                  tabledata "Gov Talk Setup" = r,
                  tabledata "GovTalk Message" = R;
}