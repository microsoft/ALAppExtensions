// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 11703 "CASH-DOCUMENT"
{
    Access = Public;
    Assignable = true;
    Caption = 'Cash documents read';

    ObsoleteState = Pending;
    ObsoleteReason = 'Moved to Cash Desk Localization for Czech.';
    ObsoleteTag = '18.0';

    Permissions = tabledata "Cash Desk Cue" = R,
                  tabledata "Cash Desk Event" = R,
                  tabledata "Cash Desk Report Selections" = R,
                  tabledata "Cash Desk User" = R,
                  tabledata "Cash Document Header" = RIMD,
                  tabledata "Cash Document Line" = RIMD,
                  tabledata "Currency Nominal Value" = R;
}
