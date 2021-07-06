// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 11713 "PURCH-ADVANCE"
{
    Access = Public;
    Assignable = true;
    Caption = 'Purchase Advance Read';

    Permissions = tabledata "Adv. Letter Line Rel. Buffer" = R,
                  tabledata "Advance Letter Line Relation" = R,
                  tabledata "Advance Link" = R,
                  tabledata "Advance Link Buffer - Entry" = R,
                  tabledata "Advance Link Buffer" = R,
                  tabledata "Purch. Advance Letter Entry" = R,
                  tabledata "Purch. Advance Letter Header" = RIMD,
                  tabledata "Purch. Advance Letter Line" = RIMD,
                  tabledata "Purchase Adv. Payment Template" = R,
                  tabledata "VAT Amount Line Adv. Payment" = R;
}
