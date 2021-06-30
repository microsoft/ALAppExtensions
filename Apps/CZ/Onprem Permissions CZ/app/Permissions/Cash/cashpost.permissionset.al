// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 11704 "CASH-POST"
{
    Access = Public;
    Assignable = true;
    Caption = 'Cash documents post';

    ObsoleteState = Pending;
    ObsoleteReason = 'Moved to Cash Desk Localization for Czech.';
    ObsoleteTag = '18.0';

    Permissions = tabledata "Cash Desk Event" = R,
                  tabledata "Cash Desk Report Selections" = R,
                  tabledata "Cash Desk User" = R,
                  tabledata "Cash Document Header" = IMD,
                  tabledata "Cash Document Line" = IMD,
                  tabledata "Currency Nominal Value" = R,
                  tabledata "Posted Cash Document Header" = RI,
                  tabledata "Posted Cash Document Line" = RI;
}
