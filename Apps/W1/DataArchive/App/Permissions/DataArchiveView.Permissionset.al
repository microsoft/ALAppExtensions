// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 632 "Data Archive - View"
{
    Access = Public;
    Assignable = true;
    Caption = 'Data Archive - View';

    IncludedPermissionSets = "Data Archive - Read";

    Permissions = tabledata "Data Archive" = imd,
                  tabledata "Data Archive Table" = imd,
                  tabledata "Data Archive Media Field" = imd;
}
