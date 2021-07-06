// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 2616 "Printer Management - Read"
{
    Access = Internal;
    Assignable = false;

    Permissions = tabledata Printer = r;
}