// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

using System.Environment;

permissionset 94 "Company - Read"
{
    Access = Public;
    Assignable = false;

    Permissions = tabledata Company = R;
}
