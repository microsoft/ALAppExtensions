// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13694 "Intrastat Export Lines"
{
    TableNo = 263;
    trigger OnRun();
    var
        IntrastatJnlLine: Record "Intrastat Jnl. Line";
    begin
        IntrastatJnlLine.COPYFILTERS(Rec);
        IntrastatJnlLine.SETRANGE("Journal Template Name", Rec."Journal Template Name");
        IntrastatJnlLine.SETRANGE("Journal Batch Name", "Journal Batch Name");
        REPORT.RUN(REPORT::"Intrastat Export To Disk", TRUE, FALSE, IntrastatJnlLine);
    end;
}