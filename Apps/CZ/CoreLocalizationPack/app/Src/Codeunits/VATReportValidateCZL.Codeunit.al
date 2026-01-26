// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

codeunit 31172 "VAT Report Validate CZL"
{
    TableNo = "VAT Report Header";

    trigger OnRun()
    begin
        ClearErrorLog();

        ValidateVATReportLinesExists(Rec);
        ValidateVATReportHeader(Rec);

        ShowErrorLog();
    end;

    var
        TempVATReportErrorLog: Record "VAT Report Error Log" temporary;
        VATStatementReportLine: Record "VAT Statement Report Line";
        ErrorID: Integer;
        NoLinesExistErr: Label 'You cannot release the VAT report because no lines exist.';
        StandardVATReportExistsErr: Label 'There is already exist a standard VAT report in the same period.';

    local procedure ClearErrorLog()
    begin
        TempVATReportErrorLog.Reset();
        TempVATReportErrorLog.DeleteAll();
    end;

    local procedure InsertErrorLog(ErrorMessage: Text[250])
    begin
        if TempVATReportErrorLog.FindLast() then
            ErrorID := TempVATReportErrorLog."Entry No." + 1
        else
            ErrorID := 1;

        TempVATReportErrorLog.Init();
        TempVATReportErrorLog."Entry No." := ErrorID;
        TempVATReportErrorLog."Error Message" := ErrorMessage;
        TempVATReportErrorLog.Insert();
    end;

    local procedure ShowErrorLog()
    begin
        if not TempVATReportErrorLog.IsEmpty() then begin
            PAGE.Run(PAGE::"VAT Report Error Log", TempVATReportErrorLog);
            Error('');
        end;
    end;

    local procedure ValidateVATReportLinesExists(VATReportHeader: Record "VAT Report Header")
    begin
        VATStatementReportLine.SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
        VATStatementReportLine.SetRange("VAT Report No.", VATReportHeader."No.");
        if VATStatementReportLine.IsEmpty() then
            InsertErrorLog(NoLinesExistErr);
    end;

    local procedure ValidateVATReportHeader(VATReportHeader: Record "VAT Report Header")
    begin
        if VATReportHeader."VAT Report Type" <> VATReportHeader."VAT Report Type"::Standard then
            exit;

        if VATReportHeader.IsAnotherStandardVATReportInPeriod() then
            InsertErrorLog(StandardVATReportExistsErr);
    end;
}