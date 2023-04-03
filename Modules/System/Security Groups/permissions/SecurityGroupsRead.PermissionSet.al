// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9020 "Security Groups - Read"
{
    Access = Internal;
    Assignable = false;

    Permissions = tabledata "Access Control" = r,
                  tabledata User = r;
}
