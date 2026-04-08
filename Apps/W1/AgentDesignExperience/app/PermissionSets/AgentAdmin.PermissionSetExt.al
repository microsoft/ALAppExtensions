// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer;

using System.Environment.Configuration;
using System.Reflection;
using System.Security.AccessControl;

permissionsetextension 4350 AgentAdmin extends "Agent - Admin"
{
    Permissions =
        // Permissions required for importing profiles for sample agents.
#pragma warning disable AS0110, AA0050, PTE0016
        tabledata "All Profile" = M,
        tabledata "Profile Configuration Symbols" = imd,
        tabledata "Tenant Profile" = imd,
        tabledata "Tenant Profile Extension" = imd,
        tabledata "Tenant Profile Page Metadata" = imd,
        tabledata "Tenant Profile Setting" = imd;
#pragma warning restore AS0110, AA0050, PTE0016
}