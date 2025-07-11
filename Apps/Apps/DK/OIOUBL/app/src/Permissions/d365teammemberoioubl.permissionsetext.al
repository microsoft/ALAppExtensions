// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using System.Security.AccessControl;

permissionsetextension 8351 "D365 TEAM MEMBER - OIOUBL" extends "D365 TEAM MEMBER"
{
    Permissions = tabledata "OIOUBL-Profile" = RIMD;
}
