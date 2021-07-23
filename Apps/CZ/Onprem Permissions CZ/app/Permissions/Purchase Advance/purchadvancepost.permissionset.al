// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 11714 "PURCH-ADVANCE, POST"
{
    Access = Public;
    Assignable = true;
    Caption = 'Purchase Advance Post';

    Permissions = tabledata "Adv. Letter Line Rel. Buffer" = RIMD,
                  tabledata "Advance Letter Line Relation" = Rimd,
                  tabledata "Advance Link" = RIMD,
                  tabledata "Advance Link Buffer - Entry" = RIMD,
                  tabledata "Advance Link Buffer" = RIMD,
                  tabledata "Purch. Advance Letter Entry" = Rimd,
                  tabledata "Purch. Advance Letter Header" = RIMD,
                  tabledata "Purch. Advance Letter Line" = RIMD,
                  tabledata "Purchase Adv. Payment Template" = RIMD,
                  tabledata "VAT Amount Line Adv. Payment" = RIMD;
}
