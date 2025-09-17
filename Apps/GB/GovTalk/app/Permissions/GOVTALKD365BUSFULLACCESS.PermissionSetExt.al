// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using System.Security.AccessControl;

permissionsetextension 10504 "GOVTALK D365 BUS FULL ACCESS" extends "D365 BUS FULL ACCESS"
{
    Permissions = tabledata "Gov Talk Setup" = RIMD;
}