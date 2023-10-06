// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AutomaticAccounts;

using Microsoft.Finance.Deferral;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;

codeunit 4850 "AA Codes Posting Helper"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostGLAccOnBeforeDeferralPosting', '', false, false)]
    local procedure OnPostGLAccOnBeforeDeferralPosting(sender: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        PostAccGroup(sender, GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostDeferralPostBufferOnAfterInsertGLEntry', '', false, false)]
    local procedure OnPostDeferralPostBufferOnAfterInsertGLEntry(sender: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line"; var DeferralPostBuffer: Record "Deferral Posting Buffer")
    begin
        // Do not post auto acc. group for initial deferral pair
        if DeferralPostBuffer."Deferral Account" <> GenJournalLine."Account No." then
            PostAutoAccGroupFromDeferralLine(
              sender, GenJournalLine, DeferralPostBuffer."Amount (LCY)", DeferralPostBuffer."Posting Date", DeferralPostBuffer."G/L Account");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostDeferralPosBufferOnBeforeDeleteDeferralPostBuffer', '', false, false)]
    local procedure OnPostDeferralPosBufferOnBeforeDeleteDeferralPostBuffer(sender: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line"; var DeferralPostBuffer: Record "Deferral Posting Buffer")
    var
        DeferralTemplate: Record "Deferral Template";
    begin
        DeferralTemplate.Get(DeferralPostBuffer."Deferral Code");
        if DeferralTemplate."Deferral %" <> 100 then
            PostAutoAccGroupFromDeferralLine(sender, GenJournalLine, GenJournalLine."Amount (LCY)", GenJournalLine."Posting Date", '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostDeferralOnAfterInsertGLEntry', '', false, false)]
    local procedure OnPostDeferralOnAfterInsertGLEntry(sender: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line"; TempDeferralLine: Record "Deferral Line" temporary)
    begin
        PostAutoAccGroupFromDeferralLine(sender, GenJournalLine, TempDeferralLine."Amount (LCY)", TempDeferralLine."Posting Date", '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostDeferralOnAfterTempDeferralLineLoopCompleted', '', false, false)]
    local procedure OnPostDeferralOnAfterTempDeferralLineLoopCompleted(sender: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line"; TempDeferralLine: Record "Deferral Line" temporary;
        DeferralTemplate: Record "Deferral Template"; DeferralHeader: Record "Deferral Header")
    begin
        if DeferralTemplate."Deferral %" <> 100 then
            PostAutoAccGroupFromDeferralLine(
                sender, GenJournalLine, GenJournalLine."VAT Base Amount (LCY)" - DeferralHeader."Amount to Defer (LCY)", GenJournalLine."Posting Date", '');
    end;

    local procedure PostAutoAcc(var GenJnlLine: Record "Gen. Journal Line"; sender: Codeunit "Gen. Jnl.-Post Line")
    var
        AutoAccHeader: Record "Automatic Account Header";
        AutomaticAccountLine: Record "Automatic Account Line";
        GenJnlLine2: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        GLSetup: Record "General Ledger Setup";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
        NoOfAutoAccounts: Decimal;
        TotalAmount: Decimal;
        SourceCurrBaseAmount: Decimal;
        AccLine: Integer;
    begin
        GLSetup.Get();
        GenJnlLine.TestField("Account Type", GenJnlLine."Account Type"::"G/L Account");
        Clear(TotalAmount);
        AccLine := 0;
        TotalAmount := 0;
        AutoAccHeader.Get(GenJnlLine."Automatic Account Group");
        AutoAccHeader.CalcFields(Balance);
        AutoAccHeader.TestField(Balance, 0);
        AutomaticAccountLine.Reset();
        AutomaticAccountLine.SetRange("Automatic Acc. No.", AutoAccHeader."No.");

        NoOfAutoAccounts := AutomaticAccountLine.Count();
        if AutomaticAccountLine.FindSet() then
            repeat
                GenJnlLine2 := GenJnlLine;
                if AutomaticAccountLine."G/L Account No." = '' then
                    GenJnlLine2.Validate("Account No.", GenJnlLine."Account No.")
                else
                    GenJnlLine2.Validate("Account No.", AutomaticAccountLine."G/L Account No.");
                GenJnlLine2.Validate("Bal. Account No.", '');
                GenJnlLine2.Validate("Currency Code", GenJnlLine."Currency Code");

                GenJnlLine2.Validate("Gen. Bus. Posting Group", '');
                GenJnlLine2.Validate("Gen. Prod. Posting Group", '');
                GenJnlLine2.Validate("Gen. Posting Type", GenJnlLine."Gen. Posting Type"::" ");
                GenJnlLine2.Validate(Description, AutoAccHeader.Description);
                GenJnlLine2.Validate(
                  Amount,
                  Round(GenJnlLine."VAT Base Amount" * AutomaticAccountLine."Allocation %" / 100, GLSetup."Amount Rounding Precision"));
                if GenJnlLine2."Source Currency Code" = GLSetup."Additional Reporting Currency" then begin
                    SourceCurrBaseAmount := GenJnlLine2."Source Curr. VAT Base Amount";
                    GenJnlLine2.Validate(
                      "Source Currency Amount", Round(SourceCurrBaseAmount * AutomaticAccountLine."Allocation %" / 100, GLSetup."Amount Rounding Precision"));
                end;
                GenJnlLine2.Validate("Automatic Account Group", '');
                GenJnlLine2."Dimension Set ID" := GenJnlLine."Dimension Set ID";
                GenJnlLine2."Shortcut Dimension 1 Code" := GenJnlLine."Shortcut Dimension 1 Code";
                GenJnlLine2."Shortcut Dimension 2 Code" := GenJnlLine."Shortcut Dimension 2 Code";
                CopyDimensionFromAutoAccLine(GenJnlLine2, AutomaticAccountLine);
                AccLine := AccLine + 1;
                TotalAmount := TotalAmount + GenJnlLine2.Amount;
                if (AccLine = NoOfAutoAccounts) and (TotalAmount <> 0) then
                    GenJnlLine2.Validate(Amount, GenJnlLine2.Amount - TotalAmount);

                GenJnlCheckLine.RunCheck(GenJnlLine2);

                sender.InitGLEntry(GenJnlLine2, GLEntry,
                  GenJnlLine2."Account No.", GenJnlLine2."Amount (LCY)",
                  GenJnlLine2."Source Currency Amount", true, GenJnlLine2."System-Created Entry");
                GLEntry."Gen. Posting Type" := GenJnlLine."Gen. Posting Type";
                GLEntry."Bal. Account Type" := GenJnlLine."Bal. Account Type";
                GLEntry."Bal. Account No." := GenJnlLine."Bal. Account No.";
                GLEntry."No. Series" := GenJnlLine2."Posting No. Series";
                if GenJnlLine."Additional-Currency Posting" =
                   GenJnlLine."Additional-Currency Posting"::"Additional-Currency Amount Only"
                then begin
                    GLEntry."Additional-Currency Amount" := GenJnlLine.Amount;
                    GLEntry.Amount := 0;
                end;
                sender.InsertGLEntry(GenJnlLine2, GLEntry, true);
            until AutomaticAccountLine.Next() = 0;
        GenJnlLine.Validate("Automatic Account Group", '');
    end;

    local procedure CopyDimensionFromAutoAccLine(var GenJournalLine: Record "Gen. Journal Line"; AutomaticAccountLine: Record "Automatic Account Line")
    var
        DimMgt: Codeunit DimensionManagement;
        DimensionSetIDArr: array[10] of Integer;
    begin
        if AutomaticAccountLine."Dimension Set ID" <> 0 then
            if GenJournalLine."Dimension Set ID" = 0 then begin
                GenJournalLine."Dimension Set ID" := AutomaticAccountLine."Dimension Set ID";
                DimMgt.UpdateGlobalDimFromDimSetID(
                  GenJournalLine."Dimension Set ID", GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code");
            end else begin
                DimensionSetIDArr[1] := GenJournalLine."Dimension Set ID";
                DimensionSetIDArr[2] := AutomaticAccountLine."Dimension Set ID";
                GenJournalLine."Dimension Set ID" :=
                  DimMgt.GetCombinedDimensionSetID(
                    DimensionSetIDArr, GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code");
            end;
    end;

    local procedure PostAccGroup(sender: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        if (GenJournalLine."Automatic Account Group" <> '') and (GenJournalLine."Deferral Code" = '') then
            PostAutoAcc(GenJournalLine, sender);
    end;

    local procedure PostAutoAccGroupFromDeferralLine(sender: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line"; PostAmount: Decimal; PostingDate: Date; PostingAccountNo: Code[20])
    var
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
    begin
        if GenJournalLine."Automatic Account Group" <> '' then begin
            TempGenJournalLine.Init();
            TempGenJournalLine.Copy(GenJournalLine);
            TempGenJournalLine.Validate("Deferral Code", '');
            TempGenJournalLine.Validate("Posting Date", PostingDate);
            TempGenJournalLine.Validate("Amount (LCY)", PostAmount);
            TempGenJournalLine.Validate("VAT Base Amount", PostAmount);
            if PostingAccountNo <> '' then
                TempGenJournalLine."Account No." := PostingAccountNo;
            PostAccGroup(sender, TempGenJournalLine);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterAccountNoOnValidateGetGLAccount', '', false, false)]
    local procedure OnAfterAccountNoOnValidateGetGLAccount(var GenJournalLine: Record "Gen. Journal Line"; var GLAccount: Record "G/L Account"; CallingFieldNo: Integer)
    begin
        GenJournalLine."Automatic Account Group" := GLAccount."Automatic Account Group";
        if GenJournalLine."Posting Date" <> 0D then
            if GenJournalLine."Posting Date" = ClosingDate(GenJournalLine."Posting Date") then
                GenJournalLine."Automatic Account Group" := '';
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Posting Buffer", 'OnAfterPrepareSales', '', false, false)]
    local procedure OnAfterInvPostBufferPrepareSales(var SalesLine: Record "Sales Line"; var InvoicePostingBuffer: Record "Invoice Posting Buffer")
    begin
        InvoicePostingBuffer."Automatic Account Group" := SalesLine."Automatic Account Group";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Posting Buffer", 'OnAfterPreparePurchase', '', false, false)]
    local procedure OnAfterInvPostBufferPreparePurchase(var PurchaseLine: Record "Purchase Line"; var InvoicePostingBuffer: Record "Invoice Posting Buffer")
    begin
        InvoicePostingBuffer."Automatic Account Group" := PurchaseLine."Automatic Account Group";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Posting Buffer", 'OnAfterCopyToGenJnlLine', '', false, false)]
    local procedure OnAfterCopyToGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; InvoicePostingBuffer: Record "Invoice Posting Buffer");
    begin
        GenJnlLine."Automatic Account Group" := InvoicePostingBuffer."Automatic Account Group";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Posting Buffer", 'OnBuildPrimaryKeyAfterDeferralCode', '', false, false)]
    local procedure OnBuildPrimaryKeyAfterDeferralCode(var GroupID: Text; InvoicePostingBuffer: Record "Invoice Posting Buffer");
    begin
        GroupID := GroupID + InvoicePostingBuffer.PadField(InvoicePostingBuffer."Automatic Account Group", MaxStrLen(InvoicePostingBuffer."Automatic Account Group"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeCopyFromGLAccount', '', false, false)]
    local procedure OnBeforeCopyFromGLAccount(var PurchaseLine: Record "Purchase Line"; xPurchaseLine: Record "Purchase Line"; CallingFieldNo: Integer; var IsHandled: Boolean)
    var
        GLAccount: Record "G/L Account";
    begin
        if IsHandled then
            exit;
        GLAccount.Get(PurchaseLine."No.");
        PurchaseLine."Automatic Account Group" := GLAccount."Automatic Account Group";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterAssignGLAccountValues', '', false, false)]
    local procedure OnAfterAssignGLAccountValues(var SalesLine: Record "Sales Line"; GLAccount: Record "G/L Account"; SalesHeader: Record "Sales Header")
    begin
        SalesLine."Automatic Account Group" := GLAccount."Automatic Account Group";
    end;

}
