// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.Payroll;
using Microsoft.Utilities;

codeunit 18546 "Voucher Functions"
{
    procedure CheckCurrencyCode(CurrencyCode: Code[10])
    var
        Currency: Record Currency;
    begin
        Currency.Get(CurrencyCode);
    end;

    procedure VoucherTemplateSelection(
        PageID: Integer;
        PageTemplate: Enum "Gen. Journal Template Type";
        RecurringJnl: Boolean;
        var GenJnlLine: Record "Gen. Journal Line";
        var JnlSelected: Boolean)
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJnlTemplateName: Code[10];
        OpenFromBatch: Boolean;
    begin
        JnlSelected := true;

        GenJournalTemplate.Reset();
        GenJournalTemplate.SetRange("Page ID", PageID);
        GenJournalTemplate.SetRange(Recurring, RecurringJnl);
        if not RecurringJnl then
            GenJournalTemplate.SetRange(Type, PageTemplate);
        case GenJournalTemplate.Count() of
            0:
                begin
                    GenJournalTemplate.Init();
                    GenJournalTemplate.Type := PageTemplate;
                    GenJournalTemplate.Recurring := RecurringJnl;
                    if not RecurringJnl then begin
                        GenJnlTemplateName := Format(PageTemplate, MaxStrLen(GenJournalTemplate.Name));
                        GenJournalTemplate.Name := GetAvailableGeneralJournalTemplateName(GenJnlTemplateName);
                        if PageTemplate = PageTemplate::Assets then
                            GenJournalTemplate.Description := FixedAssetTxt
                        else
                            GenJournalTemplate.Description := StrSubstNo(PageTemplateTxt, PageTemplate);
                    end else begin
                        GenJournalTemplate.Name := RecurringTxt;
                        GenJournalTemplate.Description := RecurringJnlTxt;
                    end;
                    GenJournalTemplate.Validate(Type);
                    GenJournalTemplate.Insert();
                    Commit();
                end;
            1:
                GenJournalTemplate.FindFirst();
            else
                JnlSelected := Page.RunModal(0, GenJournalTemplate) = Action::LookupOK;
        end;
        if JnlSelected then begin
            GenJnlLine.FilterGroup := 2;
            GenJnlLine.SetRange("Journal Template Name", GenJournalTemplate.Name);
            GenJnlLine.FilterGroup := 0;
            if OpenFromBatch then begin
                GenJnlLine."Journal Template Name" := '';
                Page.Run(GenJournalTemplate."Page ID", GenJnlLine);
            end;
        end;
    end;

    local procedure GetAvailableGeneralJournalTemplateName(TemplateName: Code[10]): Code[10]
    var
        GenJnlTemplate: Record "Gen. Journal Template";
        PotentialTemplateName: Code[10];
        PotentialTemplateNameIncrement: Integer;
    begin
        // Make sure proposed value + incrementer will fit in Name field
        if StrLen(TemplateName) > 9 then
            TemplateName := Format(TemplateName, 9);

        GenJnlTemplate.Init();
        PotentialTemplateName := TemplateName;
        PotentialTemplateNameIncrement := 0;

        // Expecting few naming conflicts, but limiting to 10 iterations to avoid possible infinite loop.
        while PotentialTemplateNameIncrement < 10 do begin
            GenJnlTemplate.SetFilter(Name, PotentialTemplateName);
            if GenJnlTemplate.Count() = 0 then
                exit(PotentialTemplateName);

            PotentialTemplateNameIncrement := PotentialTemplateNameIncrement + 1;
            PotentialTemplateName := TemplateName + Format(PotentialTemplateNameIncrement);
        end;
    end;

    procedure SetPayrollAppearance()
    var
        TempPayrollServiceConnection: Record "Service Connection" temporary;
        PayrollManagement: Codeunit "Payroll Management";
    begin
        PayrollManagement.OnRegisterPayrollService(TempPayrollServiceConnection);
    end;

    procedure SplitNarration(NarrationText: Text[2000]; IsLineNarration: Boolean; var GenJournalLine: Record "Gen. Journal Line")
    var
        SplitedText: List of [Text];
    begin
        SplitedText := NarrationText.Split(',');
        UpdateNarration(SplitedText, IsLineNarration, GenJournalLine);
    end;

    local procedure UpdateNarration(NarrationText: List of [Text]; IsLineNarration: Boolean; var GenJournalLine: Record "Gen. Journal Line");
    var
        GenLineNarration: Record "Gen. Journal Narration";
        i: Integer;
    begin
        for i := 1 to NarrationText.Count() do begin
            GenLineNarration.Init();
            GenLineNarration.Validate("Journal Template Name", GenJournalLine."Journal Template Name");
            GenLineNarration.Validate("Journal Batch Name", GenJournalLine."Journal Batch Name");
            GenLineNarration.Validate("Document No.", GenJournalLine."Document No.");
            GenLineNarration.Validate("Line No.", NextNarrationLineNo(GenJournalLine));
            if IsLineNarration then
                GenLineNarration.Validate("Gen. Journal Line No.", GenJournalLine."Line No.");
            GenLineNarration.Validate(Narration, NarrationText.Get(i));
            GenLineNarration.Insert(true);
        end;
    end;

    local procedure NextNarrationLineNo(var GenJournalLine: Record "Gen. Journal Line"): Integer
    var
        GenLineNarration: Record "Gen. Journal Narration";
    begin
        GenLineNarration.Reset();
        GenLineNarration.SetRange("Document No.", GenJournalLine."Document No.");
        if GenLineNarration.FindLast() then
            exit(GenLineNarration."Line No." + 10000)
        else
            exit(10000);
    end;

    procedure ShowOldNarration(var GenJournalLine: Record "Gen. Journal Line"): Text[2000]
    var
        GenJournalNarration: Record "Gen. Journal Narration";
        NarrationText: Text[2000];
    begin
        NarrationText := '';
        if GenJournalLine."Document No." <> '' then begin
            GenJournalNarration.Reset();
            GenJournalNarration.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
            GenJournalNarration.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
            GenJournalNarration.SetRange("Document No.", GenJournalLine."Document No.");
            GenJournalNarration.SetFilter("Gen. Journal Line No.", '%1', 0);
            if GenJournalNarration.FindSet() then
                repeat
                    NarrationText += GenJournalNarration.Narration + ',';
                until GenJournalNarration.Next() = 0;
        end;
        NarrationText := DelChr(NarrationText, '>', ',');
        exit(NarrationText)
    end;


    [IntegrationEvent(false, false)]
    procedure OnAfterValidateShortcutDimCode(
       var GenJournalLine: Record "Gen. Journal Line";
       var ShortcutDimCode: array[8] of Code[20];
       DimIndex: Integer)
    begin
    end;

    var
        FixedAssetTxt: Label 'Fixed Asset G/L Journal', Locked = true;
        PageTemplateTxt: Label '%1', Comment = '%1 = Page Template';
        RecurringTxt: Label 'RECURRING', Locked = true;
        RecurringJnlTxt: Label 'Recurring General Journal', Locked = true;
}
