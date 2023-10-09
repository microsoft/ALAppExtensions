// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.DataAdministration;

using System.Environment;

permissionset 1887 "Environment Cleanup - Read"
{
    Assignable = false;

    Permissions = tabledata Company = r;
}