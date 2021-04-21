// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13693 "Intrastat Validate Lines"
{
    TableNo = "Intrastat Jnl. Line";
    trigger OnRun();
    var
        TestReportPrint: Codeunit "Test Report-Print";
    begin
        TestReportPrint.PrintIntrastatJnlLine(Rec);
    end;
}
