// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13694 "Intrastat Export Lines"
{
    TableNo = "Intrastat Jnl. Line";
    trigger OnRun();
    var
        IntrastatJnlLine: Record "Intrastat Jnl. Line";
    begin
        IntrastatJnlLine.COPYFILTERS(Rec);
        IntrastatJnlLine.SETRANGE("Journal Template Name", Rec."Journal Template Name");
        IntrastatJnlLine.SETRANGE("Journal Batch Name", "Journal Batch Name");
        REPORT.RUN(REPORT::"Intrastat - Make Disk Tax Auth", TRUE, FALSE, IntrastatJnlLine);
    end;
}
