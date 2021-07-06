// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 11710 "GL-VIES DEC."
{
    Access = Public;
    Assignable = true;
    Caption = 'GL-Vies declaration read';

    Permissions = tabledata "VIES Declaration Header" = R,
                  tabledata "VIES Declaration Line" = R;
}
