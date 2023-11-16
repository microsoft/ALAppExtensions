// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 11780 "CZ Cash Desk - Read CZP"
{
    Access = Internal;
    Assignable = false;
    Caption = 'CZ Cash Desk - Read';

    IncludedPermissionSets = "CZ Cash Desk - Objects CZP";

    Permissions = tabledata "Cash Desk Cue CZP" = R,
                  tabledata "Cash Desk CZP" = R,
                  tabledata "Cash Desk Event CZP" = R,
                  tabledata "Cash Desk Rep. Selections CZP" = R,
                  tabledata "Cash Desk User CZP" = R,
                  tabledata "Cash Document Header CZP" = R,
                  tabledata "Cash Document Line CZP" = R,
                  tabledata "Currency Nominal Value CZP" = R,
                  tabledata "Posted Cash Document Hdr. CZP" = R,
                  tabledata "Posted Cash Document Line CZP" = R;
}
