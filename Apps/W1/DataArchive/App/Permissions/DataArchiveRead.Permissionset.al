// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
permissionset 629 "Data Archive - Read"
{
    Access = Public;
    Assignable = true;
    Caption = 'Data Archive - Read';

    IncludedPermissionSets = "DataArchive - Objects";

    Permissions = tabledata "Data Archive" = R,
                  tabledata "Data Archive Table" = R,
                  tabledata "Data Archive Media Field" = R;
}
