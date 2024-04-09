// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 11781 "CZ Cash Desk - Edit CZP"
{
    Access = Internal;
    Assignable = false;
    Caption = 'CZ Cash Desk - Edit';

    IncludedPermissionSets = "CZ Cash Desk - Read CZP";

    Permissions = tabledata "Cash Desk Cue CZP" = IMD,
                  tabledata "Cash Desk CZP" = IMD,
                  tabledata "Cash Desk Event CZP" = IMD,
                  tabledata "Cash Desk Rep. Selections CZP" = IMD,
                  tabledata "Cash Desk User CZP" = IMD,
                  tabledata "Cash Document Header CZP" = IMD,
                  tabledata "Cash Document Line CZP" = IMD,
                  tabledata "Currency Nominal Value CZP" = IMD,
                  tabledata "Posted Cash Document Hdr. CZP" = IMD,
                  tabledata "Posted Cash Document Line CZP" = IMD;
}
