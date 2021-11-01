// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 632 "Data Archive - View"
{
    Access = Public;
    Assignable = true;
    Caption = 'Data Archive Read - View';

    Permissions = tabledata "Data Archive" = R,
                  tabledata "Data Archive Table" = R,
                  tabledata "Data Archive Media Field" = R;
}
