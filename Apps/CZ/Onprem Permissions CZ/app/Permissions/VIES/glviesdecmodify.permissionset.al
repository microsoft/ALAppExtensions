// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 11711 "GL-VIES DEC. MODIFY"
{
    Access = Public;
    Assignable = true;
    Caption = 'GL-Vies declaration modify';

    Permissions = tabledata "VIES Declaration Header" = RIMD,
                  tabledata "VIES Declaration Line" = RIMD;
}
