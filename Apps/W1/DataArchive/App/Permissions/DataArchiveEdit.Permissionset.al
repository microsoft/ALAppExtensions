// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 631 "Data Archive - Edit"
{
    Access = Public;
    Assignable = true;
    Caption = 'Data Archive - Edit';

    IncludedPermissionSets = "Data Archive - View";
    Permissions = tabledata "Data Archive" = IMD,
                  tabledata "Data Archive Table" = IMD,
                  tabledata "Data Archive Media Field" = IMD;
}
