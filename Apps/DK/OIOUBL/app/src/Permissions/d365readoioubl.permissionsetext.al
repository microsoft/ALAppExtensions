// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using System.Security.AccessControl;

permissionsetextension 23761 "D365 READ - OIOUBL" extends "D365 READ"
{
    Permissions = tabledata "OIOUBL-Profile" = R;
}
