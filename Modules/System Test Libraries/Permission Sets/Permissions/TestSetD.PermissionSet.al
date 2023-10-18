// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Security.AccessControl;

using System.TestLibraries.Reflection;
using System.Security.AccessControl;

permissionset 133404 "Test Set D"
{
    Assignable = false;

    Permissions = tabledata "Test Table A" = RIMD,
                  tabledata "Test Table B" = Rim,
                  page "Metadata Permission Subform" = X;
}