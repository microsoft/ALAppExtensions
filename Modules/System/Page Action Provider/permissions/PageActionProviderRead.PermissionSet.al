// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration;

using System.Reflection;
using System.Environment.Configuration;

permissionset 2916 "Page Action Provider - Read"
{
    Access = Internal;
    Assignable = false;

    Permissions = tabledata "Page Action" = r,
                  tabledata "All Profile" = r,
                  tabledata "User Personalization" = r,
                  tabledata "Page Data Personalization" = R; // DotNet NavPageActionALFunctions requires this
}