// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 11750 "CZ Advance Payments - Read CZZ"
{
    Access = Internal;
    Assignable = false;
    Caption = 'CZ Advance Payments - Read';

    Permissions = tabledata "Advance Letter Application CZZ" = R,
                  tabledata "Advance Letter Link Buffer CZZ" = R,
                  tabledata "Advance Letter Template CZZ" = R,
                  tabledata "Purch. Adv. Letter Entry CZZ" = R,
                  tabledata "Purch. Adv. Letter Header CZZ" = R,
                  tabledata "Purch. Adv. Letter Line CZZ" = R,
                  tabledata "Sales Adv. Letter Entry CZZ" = R,
                  tabledata "Sales Adv. Letter Header CZZ" = R,
                  tabledata "Sales Adv. Letter Line CZZ" = R;
}
