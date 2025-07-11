// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using System.Security.AccessControl;

permissionsetextension 43222 "D365 BASIC ISV - OIOUBL" extends "D365 BASIC ISV"
{
    Permissions = tabledata "OIOUBL-Profile" = RIMD;
}
