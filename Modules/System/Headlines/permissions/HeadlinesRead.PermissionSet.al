// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Visualization;

using System.Security.AccessControl;

permissionset 1439 "Headlines - Read"
{
    Access = Internal;
    Assignable = false;

    Permissions = tabledata User = r;
}