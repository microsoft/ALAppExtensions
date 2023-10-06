// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 27000 "BANKDEC-EDIT"
{
    Access = Public;
    Assignable = true;
    Caption = 'Edit Bank Recs';

    Permissions = tabledata "Bank Account" = R,
                  tabledata "Bank Account Ledger Entry" = R,
                  tabledata "Bank Account Posting Group" = R,
                  tabledata "Bank Account Statement" = R,
                  tabledata "Bank Account Statement Line" = R,
                  tabledata "Bank Comment Line" = RIMD,
                  tabledata "Check Ledger Entry" = R,
                  tabledata "Default Dimension" = RIMD;
}
