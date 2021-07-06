// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 11715 "SALES-ADVANCE"
{
    Access = Public;
    Assignable = true;
    Caption = 'Sales Advance Read';

    Permissions = tabledata "Adv. Letter Line Rel. Buffer" = R,
                  tabledata "Advance Link" = R,
                  tabledata "Advance Link Buffer - Entry" = R,
                  tabledata "Advance Link Buffer" = R,
                  tabledata "Sales Adv. Payment Template" = R,
                  tabledata "Sales Advance Letter Entry" = R,
                  tabledata "Sales Advance Letter Header" = RIMD,
                  tabledata "Sales Advance Letter Line" = RIMD,
                  tabledata "VAT Amount Line Adv. Payment" = R;
}
