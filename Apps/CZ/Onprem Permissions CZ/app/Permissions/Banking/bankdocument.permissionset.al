// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 11700 "BANK-DOCUMENT"
{
    Access = Public;
    Assignable = true;
    Caption = 'Bank Acc.,Payment,Stat. Read';

    Permissions = tabledata "Bank Statement Header" = RIMD,
                  tabledata "Bank Statement Line" = RIMD,
                  tabledata "Constant Symbol" = R,
                  tabledata "Payment Order Header" = RIMD,
                  tabledata "Payment Order Line" = RIMD;
}
