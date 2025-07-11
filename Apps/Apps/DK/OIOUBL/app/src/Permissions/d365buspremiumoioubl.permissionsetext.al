// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using System.Security.AccessControl;

permissionsetextension 9722 "D365 BUS PREMIUM - OIOUBL" extends "D365 BUS PREMIUM"
{
    Permissions = tabledata "OIOUBL-Profile" = RIMD;
}
