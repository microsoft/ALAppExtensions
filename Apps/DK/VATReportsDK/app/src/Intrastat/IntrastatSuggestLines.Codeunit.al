// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13692 "Intrastat Suggest Lines"
{
    TableNo = "Intrastat Jnl. Line";
    trigger OnRun();
    var
        GetItemEntries: Report "Get Item Ledger Entries";
    begin
        GetItemEntries.SetIntrastatJnlLine(Rec);
        GetItemEntries.RUNMODAL();
    end;
}
