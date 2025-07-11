// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 11702 "BANK-SETUP"
{
    Access = Public;
    Assignable = true;
    Caption = 'Bank Acc., Operation Setup';

    Permissions = tabledata "Bank Account" = RIMD,
                  tabledata "Bank Export/Import Setup" = RIMD;
}
