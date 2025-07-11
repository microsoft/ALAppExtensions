// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using System.Security.AccessControl;

permissionsetextension 26650 "D365 BUS FULL ACCESS - OIOUBL" extends "D365 BUS FULL ACCESS"
{
    Permissions = tabledata "OIOUBL-Profile" = RIMD;
}
