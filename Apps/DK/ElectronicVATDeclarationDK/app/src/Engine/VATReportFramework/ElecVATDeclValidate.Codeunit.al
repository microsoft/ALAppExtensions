namespace Microsoft.Finance.VAT.Reporting;

codeunit 13614 "Elec. VAT Decl. Validate"
{
    TableNo = "VAT Report Header";

    var
        TempVATReportErrorLog: Record "VAT Report Error Log" temporary;
        ErrorID: Integer;
        NoLinesErr: Label 'You cannot release the VAT report because no lines exist.';
        BoxNoErr: Label 'Box No. %1 is not allowed. Only numbers from 2 to 17 are allowed.', Comment = '%1: Box No. Code';
        NoAmountsErr: Label 'You cannot release the VAT report because no amounts exist on lines.';

    trigger OnRun()
    begin
        ClearErrorLog();

        ValidateVATReportLinesExists(Rec);
        ValidateVATReportLines(Rec);

        ShowErrorLog();
    end;

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
            Page.Run(Page::"VAT Report Error Log", TempVATReportErrorLog);
            Error('');
        end;
    end;

    local procedure ValidateVATReportLinesExists(VATReportHeader: Record "VAT Report Header")
    var
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        VATStatementReportLine.SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
        VATStatementReportLine.SetRange("VAT Report No.", VATReportHeader."No.");
        if VATStatementReportLine.IsEmpty() then begin
            InsertErrorLog(NoLinesErr);
            ShowErrorLog();
        end;
    end;

    local procedure ValidateVATReportLines(VATReportHeader: Record "VAT Report Header")
    var
        VATStatementReportLine: Record "VAT Statement Report Line";
        AllowedBoxNos: List of [Text[30]];
        AmountExists: Boolean;
    begin
        AllowedBoxNos := GetAllowedBoxNos();
        VATStatementReportLine.SetRange("VAT Report No.", VATReportHeader."No.");
        VATStatementReportLine.SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
        if VATStatementReportLine.FindSet() then
            repeat
                if not AllowedBoxNos.Contains(VATStatementReportLine."Box No.") then
                    InsertErrorLog(StrSubstNo(BoxNoErr, VATStatementReportLine."Box No."));
                if VATStatementReportLine.Amount <> 0 then
                    AmountExists := true;
            until VATStatementReportLine.Next() = 0;
        if not AmountExists then
            InsertErrorLog(NoAmountsErr);
    end;

    local procedure GetAllowedBoxNos() AllowedBoxNos: List of [Text[30]]
    var
        i: Integer;
    begin
        for i := 2 to 17 do
            AllowedBoxNos.Add(Format(i));
    end;
}