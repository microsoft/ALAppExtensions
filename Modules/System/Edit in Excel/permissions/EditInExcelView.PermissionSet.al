// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Excel;

using System.Integration;

permissionset 1482 "Edit in Excel - View"
{
    Access = Public;
    Assignable = true;
    Caption = 'Edit in Excel - View';

    IncludedPermissionSets = "Edit in Excel - Read",
                             "Web Service Management - View";

    Permissions = system "Allow Action Export To Excel" = X;
}
