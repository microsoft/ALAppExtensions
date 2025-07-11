﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Security.AccessControl;

permissionsetextension 6100 "D365 READ - E-Doc. Core" extends "D365 READ"
{
    IncludedPermissionSets = "E-Doc. Core - Read";
}