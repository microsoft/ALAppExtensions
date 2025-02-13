namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Foundation.ExtendedText;

codeunit 31152 "Transfer Extended Text CZP"
{
    var
        GLAccount: Record "G/L Account";
        TempExtTextLine: Record "Extended Text Line" temporary;
        TransferExtendedText: Codeunit "Transfer Extended Text";
        NextLineNo: Integer;
        LineSpacing: Integer;
        MakeUpdateRequired: Boolean;
        AutoText: Boolean;

    procedure CashDeskCheckIfAnyExtText(var CashDocumentLineCZP: Record "Cash Document Line CZP"; Unconditionally: Boolean): Boolean
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        exit(CashDeskCheckIfAnyExtText(CashDocumentLineCZP, Unconditionally, CashDocumentHeaderCZP));
    end;

    procedure CashDeskCheckIfAnyExtText(var CashDocumentLineCZP: Record "Cash Document Line CZP"; Unconditionally: Boolean; CashDocumentHeaderCZP: Record "Cash Document Header CZP") Result: Boolean
    var
        ExtendedTextHeader: Record "Extended Text Header";
        CashDeskCZP: Record "Cash Desk CZP";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCashDeskCheckIfAnyExtText(CashDocumentLineCZP, CashDocumentHeaderCZP, Unconditionally, MakeUpdateRequired, AutoText, Result, IsHandled);
        if IsHandled then
            exit(Result);

        MakeUpdateRequired := false;
        if TransferExtendedText.IsDeleteAttachedLines(CashDocumentLineCZP."Line No.", CashDocumentLineCZP."Account No.", CashDocumentLineCZP."Attached to Line No.") and not CashDocumentLineCZP.IsExtendedText() then
            MakeUpdateRequired := DeleteCashDocumentLines(CashDocumentLineCZP);

        AutoText := false;

        if Unconditionally then
            AutoText := true
        else
            case CashDocumentLineCZP."Account Type" of
                CashDocumentLineCZP."Account Type"::" ":
                    AutoText := true;
                CashDocumentLineCZP."Account Type"::"G/L Account":
                    if GLAccount.Get(CashDocumentLineCZP."Account No.") then
                        AutoText := GLAccount."Automatic Ext. Texts";
            end;

        OnCashDeskCheckIfAnyExtTextOnBeforeSetFilters(CashDocumentLineCZP, AutoText, Unconditionally);

        if AutoText then begin
            CashDocumentLineCZP.TestField("Cash Document No.");

            if CashDocumentHeaderCZP."No." = '' then
                CashDocumentHeaderCZP.Get(CashDocumentLineCZP."Cash Desk No.", CashDocumentLineCZP."Cash Document No.");
            CashDeskCZP.Get(CashDocumentLineCZP."Cash Desk No.");

            case CashDocumentLineCZP."Account Type" of
                CashDocumentLineCZP."Account Type"::" ":
                    ExtendedTextHeader.SetRange("Table Name", ExtendedTextHeader."Table Name"::"Standard Text");
                CashDocumentLineCZP."Account Type"::"G/L Account":
                    ExtendedTextHeader.SetRange("Table Name", ExtendedTextHeader."Table Name"::"G/L Account");
            end;
            ExtendedTextHeader.SetRange("No.", CashDocumentLineCZP."Account No.");
            ExtendedTextHeader.SetRange("Cash Desk CZP", true);
            OnCashDeskCheckIfAnyExtTextAutoText(ExtendedTextHeader, CashDocumentHeaderCZP, CashDocumentLineCZP, Unconditionally, MakeUpdateRequired);
            exit(ReadExtTextLines(ExtendedTextHeader, CashDocumentHeaderCZP."Document Date", CashDeskCZP."Language Code"));
        end;
    end;

    procedure ReadExtTextLines(var ExtTextHeader: Record "Extended Text Header"; DocDate: Date; LanguageCode: Code[10]) Result: Boolean
    var
        ExtTextLine: Record "Extended Text Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeReadLines(ExtTextHeader, DocDate, LanguageCode, IsHandled, Result, TempExtTextLine);
        if IsHandled then
            exit(Result);

        ExtTextHeader.SetCurrentKey(
          "Table Name", "No.", "Language Code", "All Language Codes", "Starting Date", "Ending Date");
        ExtTextHeader.SetRange("Starting Date", 0D, DocDate);
        OnReadExtTextLinesOnBeforeSetFilters(ExtTextHeader);
        ExtTextHeader.SetFilter("Ending Date", '%1..|%2', DocDate, 0D);
        if LanguageCode = '' then begin
            ExtTextHeader.SetRange("Language Code", '');
            if not ExtTextHeader.FindSet() then
                exit;
        end else begin
            ExtTextHeader.SetRange("Language Code", LanguageCode);
            if not ExtTextHeader.FindSet() then begin
                ExtTextHeader.SetRange("All Language Codes", true);
                ExtTextHeader.SetRange("Language Code", '');
                if not ExtTextHeader.FindSet() then
                    exit;
            end;
        end;
        TempExtTextLine.DeleteAll();
        repeat
            ExtTextLine.SetRange("Table Name", ExtTextHeader."Table Name");
            ExtTextLine.SetRange("No.", ExtTextHeader."No.");
            ExtTextLine.SetRange("Language Code", ExtTextHeader."Language Code");
            ExtTextLine.SetRange("Text No.", ExtTextHeader."Text No.");
            if ExtTextLine.FindSet() then begin
                repeat
                    TempExtTextLine := ExtTextLine;
                    OnReadExtTextLinesOnBeforeTempExtTextLineInsert(TempExtTextLine, ExtTextHeader);
                    TempExtTextLine.Insert();
                until ExtTextLine.Next() = 0;
                Result := true;
            end;
        until ExtTextHeader.Next() = 0;

        OnAfterReadLines(TempExtTextLine, ExtTextHeader, LanguageCode);
    end;

    local procedure DeleteCashDocumentLines(var CashDocumentLineCZP: Record "Cash Document Line CZP"): Boolean
    var
        CashDocumentLineCZP2: Record "Cash Document Line CZP";
        IsHandled: Boolean;
        Found: Boolean;
    begin
        CashDocumentLineCZP2.SetRange("Cash Desk No.", CashDocumentLineCZP."Cash Desk No.");
        CashDocumentLineCZP2.SetRange("Cash Document No.", CashDocumentLineCZP."Cash Document No.");
        CashDocumentLineCZP2.SetRange("Attached to Line No.", CashDocumentLineCZP."Line No.");
        OnDeleteCashDocumentLinesOnAfterSetFilters(CashDocumentLineCZP2, CashDocumentLineCZP);
        CashDocumentLineCZP2 := CashDocumentLineCZP;
        Found := false;
        if CashDocumentLineCZP2.Find('>') then begin
            repeat
                IsHandled := false;
                OnDeleteCashDocumentLinesOnBeforeDelete(CashDocumentLineCZP, CashDocumentLineCZP2, IsHandled);
                if not IsHandled then begin
                    CashDocumentLineCZP2.Delete(true);
                    Found := true;
                end;
            until CashDocumentLineCZP2.Next() = 0;
            exit(Found);
        end;
    end;

    procedure InsertCashDeskExtText(var CashDocumentLineCZP: Record "Cash Document Line CZP")
    var
        DummyCashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        InsertCashDeskExtTextRetLast(CashDocumentLineCZP, DummyCashDocumentLineCZP);
    end;

    procedure InsertCashDeskExtTextRetLast(var CashDocumentLineCZP: Record "Cash Document Line CZP"; var LastInsertedCashDocumentLineCZP: Record "Cash Document Line CZP")
    var
        ToCashDocumentLineCZP: Record "Cash Document Line CZP";
        IsHandled: Boolean;
    begin
        OnBeforeInsertCashDeskExtText(CashDocumentLineCZP, TempExtTextLine, IsHandled, MakeUpdateRequired, LastInsertedCashDocumentLineCZP);
        if IsHandled then
            exit;

        LineSpacing := 10; // New fixed Line Spacing method
        OnInsertCashDeskExtTextRetLastOnAfterSetLineSpacing(LineSpacing);

        ToCashDocumentLineCZP.Reset();
        ToCashDocumentLineCZP.SetRange("Cash Desk No.", CashDocumentLineCZP."Cash Desk No.");
        ToCashDocumentLineCZP.SetRange("Cash Document No.", CashDocumentLineCZP."Cash Document No.");
        ToCashDocumentLineCZP := CashDocumentLineCZP;
        OnInsertCashDeskExtTextRetLastOnBeforeToCashDocumentLineFind(ToCashDocumentLineCZP);

        NextLineNo := CashDocumentLineCZP."Line No." + LineSpacing;

        TempExtTextLine.Reset();
        OnInsertCashDeskExtTextRetLastOnBeforeFindTempExtTextLine(TempExtTextLine, CashDocumentLineCZP);
        if TempExtTextLine.FindSet() then begin
            repeat
                ToCashDocumentLineCZP.Init();
                ToCashDocumentLineCZP."Cash Desk No." := CashDocumentLineCZP."Cash Desk No.";
                ToCashDocumentLineCZP."Cash Document No." := CashDocumentLineCZP."Cash Document No.";
                ToCashDocumentLineCZP."Line No." := NextLineNo;
                NextLineNo := NextLineNo + LineSpacing;
                ToCashDocumentLineCZP.Description := TempExtTextLine.Text;
                ToCashDocumentLineCZP."Attached to Line No." := CashDocumentLineCZP."Line No.";

                IsHandled := false;
                OnInsertCashDeskExtTextRetLastOnBeforeToCashDocumentLineInsert(ToCashDocumentLineCZP, CashDocumentLineCZP, TempExtTextLine, NextLineNo, LineSpacing, IsHandled);
                if not IsHandled then
                    ToCashDocumentLineCZP.Insert();
            until TempExtTextLine.Next() = 0;
            MakeUpdateRequired := true;
        end;
        TempExtTextLine.DeleteAll();
        LastInsertedCashDocumentLineCZP := ToCashDocumentLineCZP;
    end;

    procedure MakeUpdate(): Boolean
    begin
        exit(MakeUpdateRequired);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCashDeskCheckIfAnyExtText(var CashDocumentLineCZP: Record "Cash Document Line CZP"; CashDocumentHeaderCZP: Record "Cash Document Header CZP"; Unconditionally: Boolean; var MakeUpdateRequired: Boolean; var AutoText: Boolean; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteCashDocumentLinesOnAfterSetFilters(var ToCashDocumentLineCZP: Record "Cash Document Line CZP"; FromCashDocumentLineCZP: Record "Cash Document Line CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteCashDocumentLinesOnBeforeDelete(var CashDocumentLineCZP: Record "Cash Document Line CZP"; var CashDocumentLineCZPToDelete: Record "Cash Document Line CZP"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCashDeskCheckIfAnyExtTextOnBeforeSetFilters(var CashDocumentLineCZP: Record "Cash Document Line CZP"; var AutoText: Boolean; Unconditionally: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCashDeskCheckIfAnyExtTextAutoText(var ExtendedTextHeader: Record "Extended Text Header"; var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var CashDocumentLineCZP: Record "Cash Document Line CZP"; Unconditionally: Boolean; var MakeUpdateRequired: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertCashDeskExtText(var CashDocumentLineCZP: Record "Cash Document Line CZP"; var TempExtTextLine: Record "Extended Text Line" temporary; var IsHandled: Boolean; var MakeUpdateRequired: Boolean; var LastCashDocumentLineCZP: Record "Cash Document Line CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertCashDeskExtTextRetLastOnBeforeToCashDocumentLineFind(var CashDocumentLineCZP: Record "Cash Document Line CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertCashDeskExtTextRetLastOnAfterSetLineSpacing(var LineSpacing: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertCashDeskExtTextRetLastOnBeforeFindTempExtTextLine(var TempExtendedTextLine: Record "Extended Text Line" temporary; CashDocumentLineCZP: Record "Cash Document Line CZP");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertCashDeskExtTextRetLastOnBeforeToCashDocumentLineInsert(var ToCashDocumentLineCZP: Record "Cash Document Line CZP"; var CashDocumentLineCZP: Record "Cash Document Line CZP"; TempExtTextLine: Record "Extended Text Line" temporary; var NextLineNo: Integer; LineSpacing: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReadLines(var ExtendedTextHeader: Record "Extended Text Header"; DocDate: Date; LanguageCode: Code[10]; var IsHandled: Boolean; var Result: Boolean; var TempExtTextLine: Record "Extended Text Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReadExtTextLinesOnBeforeSetFilters(var ExtTextHeader: Record "Extended Text Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReadExtTextLinesOnBeforeTempExtTextLineInsert(var TempExtendedTextLine: Record "Extended Text Line" temporary; ExtendedTextHeader: Record "Extended Text Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReadLines(var TempExtendedTextLine: Record "Extended Text Line" temporary; var ExtendedTextHeader: Record "Extended Text Header"; LanguageCode: Code[10])
    begin
    end;
}
