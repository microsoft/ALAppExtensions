// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 10707 "CAR-SETUP"
{
    Access = Public;
    Assignable = true;
    Caption = 'Cartera - Setup';

    Permissions = tabledata "Cartera Setup" = RIMD,
                  tabledata "Operation Fee" = RIMD;
}
