// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 26001 "PURCHASE-DEL.REMIND."
{
    Access = Public;
    Assignable = true;
    Caption = 'Purchase Delivery Reminder';

    Permissions = tabledata "Delivery Reminder Comment Line" = RIMD,
                  tabledata "Delivery Reminder Header" = RIMD,
                  tabledata "Delivery Reminder Ledger Entry" = RIMD,
                  tabledata "Delivery Reminder Level" = RIMD,
                  tabledata "Delivery Reminder Line" = RIMD,
                  tabledata "Delivery Reminder Term" = RIMD,
                  tabledata "Delivery Reminder Text" = RIMD,
                  tabledata "Issued Deliv. Reminder Header" = RIMD,
                  tabledata "Issued Deliv. Reminder Line" = RIMD;
}
