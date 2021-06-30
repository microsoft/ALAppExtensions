// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 9013 "User Login Times - View"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "User Login Times - Read";

    Permissions = tabledata "User Login" = im;
}
