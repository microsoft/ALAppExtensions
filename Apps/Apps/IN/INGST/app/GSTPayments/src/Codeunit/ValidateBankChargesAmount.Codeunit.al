// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Payments;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Check;
using Microsoft.Bank.Ledger;
using Microsoft.Finance.Deferral;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Finance.TaxEngine.UseCaseBuilder;
using Microsoft.Inventory.Location;

codeunit 18247 "Validate Bank Charges Amount"
{
    var
        GSTPostingBuffer: array[2] of Record "GST Posting Buffer" temporary;
        BankChargeCodeGSTAmount: Decimal;
        BankChargeGSTAmount: Decimal;
        BankChargeAmount: Decimal;
        PostedDocNo: Code[20];
        GSTBankChargeBoolErr: Label 'You Can not have multiple Bank Charges, when Bank Charge Boolean in General Journal Line is True.';
        GSTBankChargeFxBoolErr: Label 'You Can not have multiple Bank Charges with Foreign Exchange True.';
        DiffSignErr: Label 'All bank charge lines must have same sign Amount.';

    local procedure InsertDetailedGSTLedgerInformation(
            DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
            GenJournalLine: Record "Gen. Journal Line";
            JournalBankCharges: Record "Journal Bank Charges";
            DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry")
    var
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        OriginalDocTypeEnum: Enum "Original Doc Type";
    begin
        DetailedGSTLedgerEntryInfo.Init();
        DetailedGSTLedgerEntryInfo."Entry No." := DetailedGSTLedgerEntry."Entry No.";
        DetailedGSTLedgerEntryInfo."Location State Code" := DetailedGSTEntryBuffer."Location State Code";
        DetailedGSTLedgerEntryInfo."Gen. Bus. Posting Group" := GenJournalLine."Gen. Bus. Posting Group";
        DetailedGSTLedgerEntryInfo."Gen. Prod. Posting Group" := GenJournalLine."Gen. Prod. Posting Group";
        DetailedGSTLedgerEntryInfo."Nature of Supply" := DetailedGSTLedgerEntryInfo."Nature of Supply"::B2B;
        DetailedGSTLedgerEntryInfo."Original Doc. No." := DetailedGSTLedgerEntry."Document No.";
        OriginalDocTypeEnum := DetailedGSTLedgerDocument2OriginalDocumentTypeEnum(DetailedGSTLedgerEntry."Document Type");
        DetailedGSTLedgerEntryInfo."original Doc. Type" := OriginalDocTypeEnum;
        DetailedGSTLedgerEntryInfo."CLE/VLE Entry No." := 0;
        DetailedGSTLedgerEntryInfo."Buyer/Seller State Code" := DetailedGSTEntryBuffer."Buyer/Seller State Code";
        DetailedGSTLedgerEntryInfo."User ID" := CopyStr(UserId, 1, MaxStrLen(DetailedGSTLedgerEntryInfo."User ID"));
        DetailedGSTLedgerEntryInfo.Cess := DetailedGSTEntryBuffer.Cess;
        DetailedGSTLedgerEntryInfo."Component Calc. Type" := DetailedGSTEntryBuffer."Component Calc. Type";
        DetailedGSTLedgerEntryInfo."Jnl. Bank Charge" := JournalBankCharges."Bank Charge";
        DetailedGSTLedgerEntryInfo."Bank Charge Entry" := DetailedGSTLedgerEntryInfo."Jnl. Bank Charge" <> '';
        DetailedGSTLedgerEntryInfo."Foreign Exchange" := JournalBankCharges."Foreign Exchange";
        if DetailedGSTLedgerEntry."GST Base Amount" > 0 then
            DetailedGSTLedgerEntryInfo.Positive := true;

        DetailedGSTLedgerEntryInfo.Insert(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Journal Bank Charges", 'OnBeforeValidateEvent', 'Amount', false, false)]
    local procedure CheckValidation(var Rec: Record "Journal Bank Charges")
    var
        JnlBankChargesDummy: Record "Journal Bank Charges";
        GenJnlLine: Record "Gen. Journal Line";
        JnlBankCharges: Record "Journal Bank Charges";
    begin
        JnlBankChargesDummy.SetRange("Journal Template Name", Rec."Journal Template Name");
        JnlBankChargesDummy.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        JnlBankChargesDummy.SetRange("Line No.", Rec."Line No.");
        JnlBankChargesDummy.SetRange("Foreign Exchange", true);
        if JnlBankChargesDummy.Count > 1 then
            Error(GSTBankChargeFxBoolErr);

        JnlBankChargesDummy.SetRange("Foreign Exchange");
        GenJnlLine.Get(Rec."Journal Template Name", Rec."Journal Batch Name", Rec."Line No.");
        if GenJnlLine."Bank Charge" and (JnlBankChargesDummy.Count > 1) then
            Error(GSTBankChargeBoolErr);

        if JnlBankChargesDummy.FindSet() then
            repeat
                JnlBankCharges.CheckBankChargeAmountSign(GenJnlLine, JnlBankChargesDummy);
                CalculateGSTAmounts(JnlBankChargesDummy);
            until JnlBankChargesDummy.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterRunWithoutCheck', '', false, false)]
    local procedure OnGenJnlPostLineOnAfterRunWithOutCheck(sender: Codeunit "Gen. Jnl.-Post Line")
    var
        JnlBankChargesSessionMgt: Codeunit "GST Bank Charge Session Mgt.";
    begin
        JnlBankChargesSessionMgt.PostGSTBakChargesGenJournalLine(sender);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteGenJournalLine(var Rec: Record "Gen. Journal Line"; RunTrigger: Boolean)
    begin
        if RunTrigger then
            DeleteJournalBankCharges(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostBankAccOnBeforeBankAccLedgEntryInsert', '', false, false)]
    local procedure PostBankChargesEntries(
        var BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        var GenJournalLine: Record "Gen. Journal Line";
        BankAccount: Record "Bank Account")
    begin
        InitPostedJnlBankCharge(GenJournalLine, 1);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostBankAccOnBeforeBankAccLedgEntryInsert', '', false, false)]
    local procedure IncludeChargeAmount(var BankAccountLedgerEntry: Record "Bank Account Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line")
    var
        JnlBankCharges: Record "Journal Bank Charges";
        JnlBankChargesSessionMgt: Codeunit "GST Bank Charge Session Mgt.";
        DummySignOfBankAccLedgAmount: Integer;
    begin
        JnlBankCharges.Reset();
        JnlBankCharges.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        JnlBankCharges.SetRange("Journal Batch Name", GenJournalLine."JOurnal Batch Name");
        JnlBankCharges.SetRange("Line No.", GenJournalLine."Line No.");
        if JnlBankCharges.IsEmpty then
            exit;

        BankChargeAmount := JnlBankChargesSessionMgt.GetBankChargeAmount();
        if BankChargeAmount <> 0 then
            UpdateBankChargeAmt(BankAccountLedgerEntry, GenJournalLine, GenJournalLine."Amount (LCY)", DummySignOfBankAccLedgAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Use Case Event Library", 'OnAddUseCaseEventstoLibrary', '', false, false)]
    local procedure OnAddUseCaseEventstoLibrary()
    var
        TaxUseCaseCU: Codeunit "Use Case Event Library";
    begin
        TaxUseCaseCU.AddUseCaseEventToLibrary('OnAfterAmountUpdate', Database::"Journal Bank Charges", 'After Update Amount For Bank Charges');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Journal Bank Charges", 'OnAfterValidateEvent', 'Amount', false, false)]
    local procedure HandleBankChargeUseCase(var Rec: Record "Journal Bank Charges")
    var
        GenJnlLine: Record "Gen. Journal Line";
        TaxCaseExecution: Codeunit "Use Case Execution";
    begin
        if GenJnlLine.Get(Rec."Journal Template Name", Rec."Journal Batch Name", Rec."Line No.") then;
        TaxCaseExecution.HandleEvent('OnAfterAmountUpdate', Rec, GenJnlLine."Currency Code", GenJnlLine."Currency Factor");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Journal Bank Charges", 'OnAfterValidateEvent', 'Bank Charge', false, false)]
    local procedure CallTaxEngineOnBankCharge(var Rec: Record "Journal Bank Charges")
    var
        GenJournalLine: Record "Gen. Journal Line";
        UseCaseExecution: Codeunit "Use Case Execution";
    begin
        if GenJournalLine.Get(Rec."Journal Template Name", Rec."Journal Batch Name", Rec."Line No.") then;
        UseCaseExecution.HandleEvent('OnAfterAmountUpdate', Rec, GenJournalLine."Currency Code", GenJournalLine."Currency Factor");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Journal Bank Charges", 'OnAfterValidateEvent', 'GST Document Type', false, false)]
    local procedure HandleBankChargeUseCaseOnDocumentType(var Rec: Record "Journal Bank Charges")
    var
        GenJnlLine: Record "Gen. Journal Line";
        TaxCaseExecution: Codeunit "Use Case Execution";
    begin
        if GenJnlLine.Get(Rec."Journal Template Name", Rec."Journal Batch Name", Rec."Line No.") then;
        TaxCaseExecution.HandleEvent('OnAfterAmountUpdate', Rec, GenJnlLine."Currency Code", GenJnlLine."Currency Factor");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tax Transaction Value", 'OnBeforeTableFilterApplied', '', false, false)]
    local procedure OnBeforeTableFilterApplied(var TaxRecordID: RecordID; TemplateNameFilter: Text; BatchFilter: Text; LineNoFilter: Integer; DocumentNoFilter: Text; TableIDFilter: Integer)
    var
        JnlBankCharges: Record "Journal Bank Charges";
    begin
        if TableIDFilter = Database::"Journal Bank Charges" then begin
            JnlBankCharges.Reset();
            JnlBankCharges.SetRange("Journal Template Name", TemplateNameFilter);
            JnlBankCharges.SetRange("Journal Batch Name", BatchFilter);
            JnlBankCharges.SetRange("Line No.", LineNoFilter);
            JnlBankCharges.SetRange("Bank Charge", DocumentNoFilter);
            if JnlBankCharges.FindFirst() then
                TaxRecordID := JnlBankCharges.RecordId();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostBankAccOnBeforeInitBankAccLedgEntry', '', false, false)]
    local procedure PostBankCharges(var GenJournalLine: Record "Gen. Journal Line"; var NextTransactionNo: Integer; var NextEntryNo: Integer)
    var
        JnlBankChargesSessionMgt: Codeunit "GST Bank Charge Session Mgt.";
    begin
        JnlBankChargesSessionMgt.SetTransactionNo(NextTransactionNo);
        JnlBankChargesSessionMgt.SetNextEntryNo(NextEntryNo);
        InsertDetaildGSTBufferBankCharge(GenJournalLine);
        InitPostedJnlBankCharge(GenJournalLine, 0);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostBankAccOnBeforeCheckLedgEntryInsert', '', false, false)]
    local procedure UpdateChequeDetails(var GenJournalLine: Record "Gen. Journal Line"; var CheckLedgerEntry: Record "Check Ledger Entry")
    var
        JnlBankChargesSessionMgt: Codeunit "GST Bank Charge Session Mgt.";
        TotalBankChargeAmount: Decimal;
    begin
        if not (GenJournalLine."Bank Payment Type" in [GenJournalLine."Bank Payment Type"::"Computer Check", GenJournalLine."Bank Payment Type"::"Manual Check"]) then
            exit;

        TotalBankChargeAmount := 0;
        TotalBankChargeAmount := JnlBankChargesSessionMgt.GetBankChargeAmount();
        if TotalBankChargeAmount = 0 then
            exit;

        CheckLedgerEntry.Amount := CheckLedgerEntry.Amount - Abs(TotalBankChargeAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforePostDeferral', '', false, false)]
    local procedure OnBeforePostDeferral(var GenJournalLine: Record "Gen. Journal Line"; var AccountNo: Code[20]; var IsHandled: Boolean)
    var
        DeferralHeader: Record "Deferral Header";
        DeferralDocType: Enum "Deferral Document Type";
    begin
        if not DeferralHeader.Get(DeferralDocType::"G/L", GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name", 0, '', GenJournalLine."Line No.") then
            if GenJournalLine."GST Group Code" <> '' then
                IsHandled := true
            else
                IsHandled := false;
    end;

    local procedure InsertDetaildGSTBufferBankCharge(var GenJnlLine: Record "Gen. Journal Line")
    var
        GLSetup: Record "General Ledger Setup";
        JnlBankCharges: Record "Journal Bank Charges";
        TaxTransValue: Record "Tax Transaction Value";
        GSTSetup: Record "GST Setup";
        TaxComponent: Record "Tax Component";
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        Location: Record Location;
        BankAccount: Record "Bank Account";
        GSTBaseValidation: Codeunit "GST Base Validation";
        GSTPurchaseNonAvailment: Codeunit "GST Purchase Non Availment";
        TaxRecordID: RecordID;
        GSTComponentCode: Text[30];
        LineNo: Integer;
        Sign: Integer;
    begin
        LineNo := GetDetailedGSTEntryBufferNextLineNo();

        GLSetup.Get();
        JnlBankCharges.Reset();
        JnlBankCharges.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
        JnlBankCharges.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
        JnlBankCharges.SetRange("Line No.", GenJnlLine."Line No.");
        if JnlBankCharges.FindSet() then
            repeat
                TaxRecordID := JnlBankCharges.RecordId();
                if not GSTSetup.Get() then
                    exit;

                GSTSetup.TestField("GST Tax Type");
                TaxTransValue.Reset();
                TaxTransValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
                TaxTransValue.SetRange("Tax Record ID", TaxRecordId);
                TaxTransValue.SetRange("Value Type", TaxTransValue."Value Type"::COMPONENT);
                if TaxTransValue.FindSet() then
                    repeat
                        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
                        TaxComponent.SetRange(Id, TaxTransValue."Value ID");
                        if TaxComponent.FindFirst() then
                            GSTComponentCode := TaxComponent.Name;

                        DetailedGSTEntryBuffer.Init();
                        DetailedGSTEntryBuffer."Entry No." := LineNo;
                        LineNo += 10000;
                        DetailedGSTEntryBuffer."Transaction Type" := DetailedGSTEntryBuffer."Transaction Type"::Purchase;
                        DetailedGSTEntryBuffer."Line No." := GenJnlLine."Line No.";
                        DetailedGSTEntryBuffer."Jnl. Bank Charge" := JnlBankCharges."Bank Charge";
                        DetailedGSTEntryBuffer."External Document No." := JnlBankCharges."External Document No.";
                        DetailedGSTEntryBuffer."Bank Charge Entry" := true;
                        DetailedGSTEntryBuffer."Journal Template Name" := JnlBankCharges."Journal Template Name";
                        DetailedGSTEntryBuffer."Journal Batch Name" := JnlBankCharges."Journal Batch Name";
                        DetailedGSTEntryBuffer."Document No." := GenJnlLine."Document No.";
                        DetailedGSTEntryBuffer."Posting Date" := GenJnlLine."Posting Date";
                        DetailedGSTEntryBuffer."Source Type" := "Source Type"::"Bank Account";
                        DetailedGSTEntryBuffer."HSN/SAC Code" := JnlBankCharges."HSN/SAC Code";
                        DetailedGSTEntryBuffer."GST Group Type" := JnlBankCharges."GST Group Type";
                        DetailedGSTEntryBuffer."Location Code" := GenJnlLine."Location Code";
                        DetailedGSTEntryBuffer."GST Component Code" := GSTComponentCode;
                        DetailedGSTEntryBuffer."GST Group Code" := JnlBankCharges."GST Group Code";
                        Sign := JnlBankCharges.CheckBankChargeAmountSign(GenJnlLine, JnlBankCharges);
                        if GenJnlLine."Bank Charge" then
                            DetailedGSTEntryBuffer."GST Base Amount" := Abs(GenJnlLine."Amount (LCY)") * Sign
                        else
                            DetailedGSTEntryBuffer."GST Base Amount" := Abs(JnlBankCharges."Amount (LCY)") * Sign;

                        DetailedGSTEntryBuffer."GST %" := TaxTransValue.Percent;
                        DetailedGSTEntryBuffer.Quantity := 1;
                        if not JnlBankCharges.Exempted then
                            DetailedGSTEntryBuffer."GST Amount" := GSTPurchaseNonAvailment.RoundTaxAmount(GSTSetup."GST Tax Type", TaxComponent.ID, TaxTransValue.Amount)
                        else
                            DetailedGSTEntryBuffer.Exempted := true;

                        DetailedGSTEntryBuffer."Currency Code" := GenJnlLine."Currency Code";
                        if DetailedGSTEntryBuffer."Currency Code" <> '' then
                            DetailedGSTEntryBuffer."Currency Factor" := GenJnlLine."Currency Factor"
                        else
                            DetailedGSTEntryBuffer."Currency Factor" := 1;

                        DetailedGSTEntryBuffer."GST Amount" := GSTPurchaseNonAvailment.RoundTaxAmount(GSTSetup."GST Tax Type", TaxComponent.ID, TaxTransValue.Amount);
                        DetailedGSTEntryBuffer."GST Rounding Precision" := GLSetup."Inv. Rounding Precision (LCY)";
                        DetailedGSTEntryBuffer."GST Rounding Type" := GSTBaseValidation.GenLedInvRoundingType2GSTInvRoundingTypeEnum(GLSetup."Inv. Rounding Type (LCY)");
                        DetailedGSTEntryBuffer."GST Inv. Rounding Precision" := JnlBankCharges."GST Inv. Rounding Precision";
                        DetailedGSTEntryBuffer."GST Inv. Rounding Type" := JnlBankCharges."GST Inv. Rounding Type";
                        DetailedGSTEntryBuffer."GST on Advance Payment" := GenJnlLine."GST on Advance Payment";
                        Location.Get(DetailedGSTEntryBuffer."Location Code");
                        DetailedGSTEntryBuffer."Location  Reg. No." := Location."GST Registration No.";
                        GenJnlLine.TestField("Location State Code");
                        DetailedGSTEntryBuffer."Location State Code" := GenJnlLine."Location State Code";
                        DetailedGSTEntryBuffer."Input Service Distribution" := GenJnlLine."GST Input Service Distribution";
                        if GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::"Bank Account" then
                            if GenJnlLine."Bal. Account No." <> '' then
                                BankAccount.Get(GenJnlLine."Bal. Account No.");

                        if GenJnlLine."Account Type" = GenJnlLine."Account Type"::"Bank Account" then
                            if GenJnlLine."Account No." <> '' then
                                BankAccount.Get(GenJnlLine."Account No.");

                        DetailedGSTEntryBuffer."Buyer/Seller Reg. No." := BankAccount."GST Registration No.";
                        DetailedGSTEntryBuffer."Buyer/Seller State Code" := BankAccount."State Code";
                        DetailedGSTEntryBuffer."Source No." := BankAccount."No.";
                        if JnlBankCharges."GST Credit" = JnlBankCharges."GST Credit"::"Non-Availment" then
                            DetailedGSTEntryBuffer."Non-Availment" := true;

                        if DetailedGSTEntryBuffer."Non-Availment" then begin
                            DetailedGSTEntryBuffer."GST Input/Output Credit Amount" := 0;
                            DetailedGSTEntryBuffer."Amount Loaded on Item" := GSTPurchaseNonAvailment.RoundTaxAmount(GSTSetup."GST Tax Type", TaxComponent.ID, TaxTransValue.Amount);
                        end else begin
                            DetailedGSTEntryBuffer."Amount Loaded on Item" := 0;
                            DetailedGSTEntryBuffer."GST Input/Output Credit Amount" := GSTPurchaseNonAvailment.RoundTaxAmount(GSTSetup."GST Tax Type", TaxComponent.ID, TaxTransValue.Amount);
                        end;

                        if (DetailedGSTEntryBuffer."GST Amount" <> 0) then
                            DetailedGSTEntryBuffer.Insert();

                    until TaxTransValue.Next() = 0;
            until JnlBankCharges.Next() = 0;
    end;

    local procedure GetDetailedGSTEntryBufferNextLineNo(): Integer
    var
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        NextLineNo: Integer;
    begin
        if DetailedGSTEntryBuffer.FindLast() then
            NextLineNo := DetailedGSTEntryBuffer."Line No.";
        exit(NextLineNo + 10000);
    end;

    local procedure UpdateBankChargeAmt(
        var BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        var GenJournalLine: Record "Gen. Journal Line";
        AmountLCY: Decimal;
        SignOfBankAccLedgAmount: Integer)
    var
        JnlBankChargesSessionMgt: Codeunit "GST Bank Charge Session Mgt.";
        DocType: Enum "BankCharges DocumentType";
    begin
        DocType := GetBankChargeDocType(GenJournalLine);
        if DocType <> DocType::" " then begin
            if DocType = DocType::Invoice then
                SignOfBankAccLedgAmount := -1
            else
                SignOfBankAccLedgAmount := 1
        end else
            if AmountLCY > 0 then begin
                if AmountLCY > BankChargeAmount then
                    SignOfBankAccLedgAmount := Abs(BankAccountLedgerEntry.Amount) / BankAccountLedgerEntry.Amount
                else
                    SignOfBankAccLedgAmount := 1;
            end else
                SignOfBankAccLedgAmount := Abs(BankAccountLedgerEntry.Amount) / BankAccountLedgerEntry.Amount;

        JnlBankChargesSessionMgt.SetBankChargeSign(SignOfBankAccLedgAmount);
        BankAccountLedgerEntry.Amount += (SignOfBankAccLedgAmount * BankChargeAmount);
        BankAccountLedgerEntry."Amount (LCY)" += (SignOfBankAccLedgAmount * BankChargeAmount);
        BankAccountLedgerEntry."Remaining Amount" := BankAccountLedgerEntry.Amount;
        BankAccountLedgerEntry.UpdateDebitCredit(GenJournalLine.Correction);
        BankChargeAmount := (SignOfBankAccLedgAmount * BankChargeAmount);
        GenJournalLine."Amount (LCY)" += BankChargeAmount;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterPostBankAcc', '', false, false)]
    local procedure ReverseGenJnlLineAmount(var GenJnlLine: Record "Gen. Journal Line")
    var
        JnlBankChargesSessionMgt: Codeunit "GST Bank Charge Session Mgt.";
        BankChargeSign: Integer;
    begin
        BankChargeAmount := JnlBankChargesSessionMgt.GetBankChargeAmount();
        BankChargeSign := JnlBankChargesSessionMgt.GetBankChargeSign() * -1;
        GenJnlLine."Amount (LCY)" += (BankChargeAmount * BankChargeSign);
    end;

    local procedure GetBankChargeDocType(GenJournalLine: Record "Gen. Journal Line"): Enum "BankCharges DocumentType"
    var
        JnlBankCharges: Record "Journal Bank Charges";
    begin
        JnlBankCharges.Reset();
        JnlBankCharges.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        JnlBankCharges.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        JnlBankCharges.SetRange("Line No.", GenJournalLine."Line No.");
        if JnlBankCharges.FindFirst() then
            exit(JnlBankCharges."GST Document Type");
    end;

    local procedure DeleteDetailedGSTBufferBankCharges(var JnlBankCharges: Record "Journal Bank Charges")
    var
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
    begin
        DetailedGSTEntryBuffer.SetCurrentKey("Transaction Type", "Journal Template Name", "Journal Batch Name", "Line No.", "Jnl. Bank Charge");
        DetailedGSTEntryBuffer.SetRange("Journal Template Name", JnlBankCharges."Journal Template Name");
        DetailedGSTEntryBuffer.SetRange("Journal Batch Name", JnlBankCharges."Journal Batch Name");
        DetailedGSTEntryBuffer.SetRange("Line No.", JnlBankCharges."Line No.");
        DetailedGSTEntryBuffer.SetRange("Jnl. Bank Charge", JnlBankCharges."Bank Charge");
        if DetailedGSTEntryBuffer.FindSet() then
            DetailedGSTEntryBuffer.DeleteAll();
    end;

    local procedure InitPostedJnlBankCharge(GenJnlLine: Record "Gen. Journal Line"; ExecutionOption: Option ReturnTotChgAmount,PostGLEntriesForBankChg)
    var
        JnlBankCharges: Record "Journal Bank Charges";
        GLSetup: Record "General Ledger Setup";
        BankCharge: Record "Bank Charge";
        BankAccount: Record "Bank Account";
        BankAccountPostingGroup: Record "Bank Account Posting Group";
        JnlBankChargesSessionMgt: Codeunit "GST Bank Charge Session Mgt.";
        DeleteJnlBankChgRecords: Boolean;
        GSTRounding: Decimal;
        BankChargeGSTInvAmt: Decimal;
        IsHandled: Boolean;
    begin
        if (GenJnlLine."Journal Template Name" = '') or (GenJnlLine."Journal Batch Name" = '') then
            exit;

        GLSetup.Get();
        CheckMultiLineBankChargesInvRounding(GenJnlLine);
        CheckSameBankChargeForeignExchange(GenJnlLine);
        CheckBankChargeDocumentType(GenJnlLine);
        CheckSameBankChargeSign(GenJnlLine);

        JnlBankCharges.Reset();
        JnlBankCharges.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
        JnlBankCharges.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
        JnlBankCharges.SetRange("Line No.", GenJnlLine."Line No.");
        JnlBankCharges.SetRange("Foreign Exchange", true);
        if JnlBankCharges.FindSet() and (JnlBankCharges.Count > 1) then
            Error(GSTBankChargeFxBoolErr);

        JnlBankCharges.SetRange("Foreign Exchange");
        if JnlBankCharges.IsEmpty() then
            exit;

        GSTPostingBuffer[1].DeleteAll();
        if JnlBankCharges.FindSet() then begin
            if GenJnlLine."Bank Charge" and (JnlBankCharges."GST Group Code" <> '') and (JnlBankCharges.Count > 1) then
                Error(GSTBankChargeBoolErr);

            if GenJnlLine."GST Input Service Distribution" and (JnlBankCharges.GETGSTBaseAmount(JnlBankCharges.RecordId) <> 0) then
                GenJnlLine.TestField("GST Input Service Distribution", false);

            repeat
                Clear(BankChargeCodeGSTAmount);
                Clear(BankChargeGSTAmount);
                if (JnlBankCharges."GST Group Code" <> '') and (GenJnlLine."Document Type" in [GenJnlLine."Document Type"::Payment, GenJnlLine."Document Type"::Refund]) then
                    PostBankChargeGST(GenJnlLine, JnlBankCharges);

                BankChargeGSTAmount := GetBankChargeCodeAmount(JnlBankCharges, false);
                BankChargeCodeGSTAmount := GetBankChargeCodeAmount(JnlBankCharges, true);
                BankChargeGSTInvAmt += GetBankChargeCodeAmount(JnlBankCharges, false);

                if JnlBankCharges."GST Inv. Rounding Precision" <> 0 then
                    GSTRounding :=
                    -(BankChargeGSTAmount -
                     Round(
                         BankChargeGSTAmount,
                         JnlBankCharges."GST Inv. Rounding Precision",
                         JnlBankCharges.GSTInvoiceRoundingDirection()));

                if ExecutionOption = ExecutionOption::ReturnTotChgAmount then
                    if not JnlBankCharges."Foreign Exchange" then
                        BankChargeAmount += Abs(JnlBankCharges."Amount (LCY)" + BankChargeGSTAmount + GSTRounding)
                    else
                        BankChargeAmount += Abs(BankChargeGSTAmount + GSTRounding);


                if ExecutionOption = ExecutionOption::PostGLEntriesForBankChg then begin
                    BankCharge.Get(JnlBankCharges."Bank Charge");

                    if JnlBankCharges."GST Group Code" <> '' then
                        if GenJnlLine."Document Type" in [GenJnlLine."Document Type"::Payment, GenJnlLine."Document Type"::Refund] then
                            PostBankChargeGST(GenJnlLine, JnlBankCharges);

                    FillGSTPostingBufferBankCharge(JnlBankCharges, GenJnlLine);
                    if JnlBankCharges."GST Group Code" <> '' then
                        if GenJnlLine."Document Type" in [GenJnlLine."Document Type"::Payment, GenJnlLine."Document Type"::Refund] then
                            InsertPostedJnlBankCharges(JnlBankCharges, GenJnlLine)
                        else
                            exit
                    else
                        InsertPostedJnlBankCharges(JnlBankCharges, GenJnlLine);

                    IsHandled := false;
                    OnBeforePostBankCharges(JnlBankCharges, IsHandled);
                    if Not IsHandled then begin
                        if (JnlBankCharges.Amount + BankChargeCodeGSTAmount <> 0) and (not JnlBankCharges."Foreign Exchange") then
                            JnlBankChargesSessionMgt.CreateGSTBankChargesGenJournallLine(
                                GenJnlLine,
                                BankCharge.Account,
                                (JnlBankCharges.Amount + BankChargeCodeGSTAmount),
                                (JnlBankCharges."Amount (LCY)" + BankChargeCodeGSTAmount));

                        if (JnlBankCharges.Amount + BankChargeCodeGSTAmount <> 0) and (JnlBankCharges."Foreign Exchange") then
                            if JnlBankCharges."GST credit" = JnlBankCharges."GST credit"::"Non-Availment" then
                                JnlBankChargesSessionMgt.CreateGSTBankChargesGenJournallLine(
                                    GenJnlLine,
                                    BankCharge.Account,
                                    BankChargeCodeGSTAmount,
                                    BankChargeCodeGSTAmount);
                    end;

                    DeleteJnlBankChgRecords := true;
                end;
            until JnlBankCharges.Next() = 0;
            if ExecutionOption = ExecutionOption::ReturnTotChgAmount then
                JnlBankChargesSessionMgt.SetBankChargeAmount(BankChargeAmount);

            OnAfterSetBankChargeAmount(BankChargeAmount, BankChargeGSTAmount, ExecutionOption, GenJnlLine, JnlBankChargesSessionMgt, JnlBankCharges);
            if JnlBankCharges."GST Inv. Rounding Precision" <> 0 then
                GSTRounding :=
                  -(BankChargeGSTInvAmt -
                    Round(
                      BankChargeGSTInvAmt,
                      JnlBankCharges."GST Inv. Rounding Precision",
                      JnlBankCharges.GSTInvoiceRoundingDirection()));

            if ExecutionOption = ExecutionOption::PostGLEntriesForBankChg then begin
                PostGSTOnBankCharge(GenJnlLine);

                if GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::"Bank Account" then
                    BankAccount.Get(GenJnlLine."Bal. Account No.")
                else
                    if GenJnlLine."Account Type" = GenJnlLine."Account Type"::"Bank Account" then
                        BankAccount.Get(GenJnlLine."Account No.");

                BankAccountPostingGroup.Get((BankAccount."Bank Acc. Posting Group"));
                BankAccountPostingGroup.TestField("GST Rounding Account");

                if (GSTRounding <> 0) then
                    JnlBankChargesSessionMgt.CreateGSTBankChargesGenJournallLine(GenJnlLine, BankAccountPostingGroup."GST Rounding Account", GSTRounding, GSTRounding);
            end;

            if DeleteJnlBankChgRecords then
                JnlBankCharges.DeleteAll();
        end;
    end;

    local procedure PostGSTOnBankCharge(GenJnlLine: Record "Gen. Journal Line")
    var
        JnlBankChargesSessionMgt: Codeunit "GST Bank Charge Session Mgt.";
    begin
        if GSTPostingBuffer[1].FindLast() then begin
            repeat
                if (GSTPostingBuffer[1]."Account No." <> '') and (GSTPostingBuffer[1]."GST Amount" <> 0) then
                    JnlBankChargesSessionMgt.CreateGSTBankChargesGenJournallLine(
                        GenJnlLine, GSTPostingBuffer[1]."Account No.",
                        (GSTPostingBuffer[1]."GST Amount"),
                        (GSTPostingBuffer[1]."GST Amount"));

                PostedDocNo := GenJnlLine."Document No.";
                InsertGSTLedgerEntryBankCharges(GSTPostingBuffer[1], GenJnlLine);
            until GSTPostingBuffer[1].Next(-1) = 0;

            InsertDetailedGSTLedgEntryBankCharges(GenJnlLine, JnlBankChargesSessionMgt.GetTranxactionNo());
        end;
    end;

    local procedure InsertGSTLedgerEntryBankCharges(GSTPostingBuffer: Record "GST Posting Buffer"; GenJournalLine: Record "Gen. Journal Line")
    var
        BankAccount: Record "Bank Account";
        GSTLedgerEntry: Record "GST Ledger Entry";
        JnlBankChargesSessionMgt: Codeunit "GST Bank Charge Session Mgt.";
    begin
        GSTLedgerEntry.Init();
        GSTLedgerEntry."Entry No." := 0;
        GSTLedgerEntry."Gen. Bus. Posting Group" := GSTPostingBuffer."Gen. Bus. Posting Group";
        GSTLedgerEntry."Gen. Prod. Posting Group" := GSTPostingBuffer."Gen. Prod. Posting Group";
        GSTLedgerEntry."Posting Date" := GenJournalLine."Posting Date";
        GSTLedgerEntry."Document No." := GenJournalLine."Document No.";
        GSTLedgerEntry."GST Amount" := GSTPostingBuffer."GST Amount";
        GSTLedgerEntry."GST Base Amount" := GSTPostingBuffer."GST Base Amount";
        GSTLedgerEntry."Currency Code" := GenJournalLine."Currency Code";
        GSTLedgerEntry."Currency Factor" := GenJournalLine."Currency Factor";
        GSTLedgerEntry."Source Type" := GSTLedgerEntry."Source Type"::"Bank Account";
        GSTLedgerEntry."Transaction Type" := GSTLedgerEntry."Transaction Type"::Purchase;
        if BankAccount.Get(GenJournalLine."Bal. Account No.") then
            GSTLedgerEntry."Source No." := GenJournalLine."Bal. Account No."
        else
            if BankAccount.Get(GenJournalLine."Account No.") then
                GSTLedgerEntry."Source No." := GenJournalLine."Account No.";

        GSTLedgerEntry."User ID" := CopyStr(UserId, 1, MaxStrLen(GSTLedgerEntry."User ID"));
        GSTLedgerEntry."Source Code" := GenJournalLine."Source Code";
        GSTLedgerEntry."Reason Code" := GenJournalLine."Reason Code";
        GSTLedgerEntry.Availment := GSTPostingBuffer.Availment;
        GSTLedgerEntry."Transaction No." := JnlBankChargesSessionMgt.GetTranxactionNo();
        GSTLedgerEntry."GST Component Code" := GSTPostingBuffer."GST Component Code";
        if GSTLedgerEntry."GST Base Amount" > 0 then
            GSTLedgerEntry."Document Type" := GSTLedgerEntry."Document Type"::Invoice
        else
            GSTLedgerEntry."Document Type" := GSTLedgerEntry."Document Type"::"Credit Memo";

        GSTLedgerEntry."External Document No." := GSTPostingBuffer."External Document No.";
        GSTLedgerEntry."Skip Tax Engine Trigger" := true;
        GSTLedgerEntry.Insert(true);
    end;

    local procedure InsertDetailedGSTLedgEntryBankCharges(GenJournalLine: Record "Gen. Journal Line"; NextTransactionNo: Integer)
    var
        JournalBankCharges: Record "Journal Bank Charges";
        EntryNo: Integer;
    begin
        EntryNo := GetNextGSTDetailEntryNo();
        JournalBankCharges.Reset();
        JournalBankCharges.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        JournalBankCharges.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        JournalBankCharges.SetRange("Line No.", GenJournalLine."Line No.");
        if JournalBankCharges.FindSet() then
            repeat
                FillDetailedGSTLedgerEntry(JournalBankCharges, EntryNo, NextTransactionNo, GenJournalLine);
                DeleteDetailedGSTBufferBankCharges(JournalBankCharges);
            until JournalBankCharges.Next() = 0;
    end;

    local procedure GetNextGSTDetailEntryNo(): Integer
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        EntryNo: Integer;
    begin
        if DetailedGSTLedgerEntry.FindLast() then
            EntryNo := DetailedGSTLedgerEntry."Entry No.";
        exit(EntryNo + 1);
    end;

    local procedure CheckMultiLineBankChargesInvRounding(GenJournalLine: Record "Gen. Journal Line")
    var
        JnlBankCharges: Record "Journal Bank Charges";
        GSTInvRounding: Decimal;
        GSTInvRoundingType: Enum "GST Inv Rounding Type";
    begin
        JnlBankCharges.Reset();
        JnlBankCharges.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        JnlBankCharges.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        JnlBankCharges.SetRange("Line No.", GenJournalLine."Line No.");
        JnlBankCharges.SetFilter("GST Group Code", '<>%1', '');
        if JnlBankCharges.FindSet() then begin
            GSTInvRounding := JnlBankCharges."GST Inv. Rounding Precision";
            GSTInvRoundingType := JnlBankCharges."GST Inv. Rounding Type";
            repeat
                JnlBankCharges.TestField("GST Inv. Rounding Precision", GSTInvRounding);
                JnlBankCharges.TestField("GST Inv. Rounding Type", GSTInvRoundingType);
            until JnlBankCharges.Next() = 0;
        end;
    end;

    local procedure CheckBankChargeDocumentType(GenJournalLine: Record "Gen. Journal Line")
    var
        JnlBankCharges: Record "Journal Bank Charges";
        DocType: Enum "BankCharges DocumentType";
    begin
        JnlBankCharges.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        JnlBankCharges.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        JnlBankCharges.SetRange("Line No.", GenJournalLine."Line No.");
        JnlBankCharges.SetFilter("GST Document Type", '%1|%2', JnlBankCharges."GST Document Type"::Invoice, JnlBankCharges."GST Document Type"::"Credit Memo");
        if JnlBankCharges.FindSet() then begin
            DocType := JnlBankCharges."GST Document Type";
            repeat
                JnlBankCharges.TestField("GST Document Type", DocType);
            until JnlBankCharges.Next() = 0;
        end;
    end;

    local procedure CheckSameBankChargeForeignExchange(GenJournalLine: Record "Gen. Journal Line")
    var
        JnlBankCharges: Record "Journal Bank Charges";
        Sign: Integer;
        ForeignExch: Boolean;
    begin
        JnlBankCharges.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        JnlBankCharges.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        JnlBankCharges.SetRange("Line No.", GenJournalLine."Line No.");
        JnlBankCharges.SetRange("Foreign Exchange", true);
        if JnlBankCharges.FindFirst() then begin
            ForeignExch := true;
            if JnlBankCharges.GETGSTBaseAmount(JnlBankCharges.RecordId) > 0 then
                Sign := 1
            else
                if JnlBankCharges.GETGSTBaseAmount(JnlBankCharges.RecordId) < 0 then
                    Sign := -1;

        end;
        JnlBankCharges.Reset();
        JnlBankCharges.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        JnlBankCharges.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        JnlBankCharges.SetRange("Line No.", GenJournalLine."Line No.");
        if JnlBankCharges.FindSet() then
            repeat
                if ForeignExch and ((JnlBankCharges.Amount > 0) and (Sign = -1)) or ((JnlBankCharges.Amount < 0) and (Sign = 1)) then
                    Error(DiffSignErr);
            until JnlBankCharges.Next() = 0;
    end;

    local procedure CheckSameBankChargeSign(GenJournalLine: Record "Gen. Journal Line")
    var
        JnlBankCharges: Record "Journal Bank Charges";
        Sign: Integer;
    begin
        JnlBankCharges.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        JnlBankCharges.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        JnlBankCharges.SetRange("Line No.", GenJournalLine."Line No.");
        if JnlBankCharges.FindFirst() then
            if JnlBankCharges.Amount > 0 then
                Sign := 1
            else
                if JnlBankCharges.Amount < 0 then
                    Sign := -1;

        JnlBankCharges.Reset();
        JnlBankCharges.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        JnlBankCharges.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        JnlBankCharges.SetRange("Line No.", GenJournalLine."Line No.");
        if JnlBankCharges.FindSet() then
            repeat
                if ((JnlBankCharges.Amount > 0) and (Sign = -1)) or ((JnlBankCharges.Amount < 0) and (Sign = 1)) then
                    Error(DiffSignErr);
            until JnlBankCharges.Next() = 0;
    end;

    local procedure PostBankChargeGST(GenJournalLine: Record "Gen. Journal Line"; JnlBankCharges: Record "Journal Bank Charges")
    var
        BankCharge: Record "Bank Charge";
    begin
        BankCharge.Get(JnlBankCharges."Bank Charge");
        CheckGSTValidationsBankCharge(GenJournalLine, JnlBankCharges);
        JnlBankCharges.CheckBankChargeAmountSign(GenJournalLine, JnlBankCharges);
    end;

    local procedure CheckGSTValidationsBankCharge(GenJournalLine: Record "Gen. Journal Line"; JnlBankCharges: Record "Journal Bank Charges")
    var
        BankCharge: Record "Bank Charge";
    begin
        if GenJournalLine."Bank Charge" then begin
            BankCharge.Get(JnlBankCharges."Bank Charge");
            if ((GenJournalLine.Amount > 0) and (GenJournalLine."Document Type" = GenJournalLine."Document Type"::Payment)) or
               ((GenJournalLine.Amount < 0) and (GenJournalLine."Document Type" = GenJournalLine."Document Type"::Refund))
            then begin
                GenJournalLine.TestField("Account Type", GenJournalLine."Account Type"::"G/L Account");
                GenJournalLine.TestField("Bal. Account Type", GenJournalLine."Bal. Account Type"::"Bank Account");
                BankCharge.TestField(Account, GenJournalLine."Account No.");
            end else
                if ((GenJournalLine.Amount < 0) and (GenJournalLine."Document Type" = GenJournalLine."Document Type"::Payment)) or
                   ((GenJournalLine.Amount > 0) and (GenJournalLine."Document Type" = GenJournalLine."Document Type"::Refund))
                then begin
                    GenJournalLine.TestField("Account Type", GenJournalLine."Account Type"::"Bank Account");
                    GenJournalLine.TestField("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
                    BankCharge.TestField(Account, GenJournalLine."Bal. Account No.");
                end;
        end;
    end;

    local procedure GetBankChargeCodeAmount(JnlBankCharges: Record "Journal Bank Charges"; NonAvailment: Boolean): Decimal
    var
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        BankGSTAmount: Decimal;
    begin
        SetFilterForBankCharge(DetailedGSTEntryBuffer, JnlBankCharges);
        if not DetailedGSTEntryBuffer.FindSet() then
            exit(0);

        repeat
            if NonAvailment then
                BankGSTAmount += DetailedGSTEntryBuffer."Amount Loaded on Item"
            else
                BankGSTAmount += DetailedGSTEntryBuffer."GST Amount";
        until DetailedGSTEntryBuffer.Next() = 0;

        exit(BankGSTAmount);
    end;

    local procedure SetFilterForBankCharge(var DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer"; JnlBankCharges: Record "Journal Bank Charges")
    begin
        DetailedGSTEntryBuffer.SetCurrentKey("Transaction Type", "Journal Template Name", "Journal Batch Name", "Line No.");
        DetailedGSTEntryBuffer.SetRange("Transaction Type", DetailedGSTEntryBuffer."Transaction Type"::Purchase);
        DetailedGSTEntryBuffer.SetRange("Journal Template Name", JnlBankCharges."Journal Template Name");
        DetailedGSTEntryBuffer.SetRange("Journal Batch Name", JnlBankCharges."Journal Batch Name");
        DetailedGSTEntryBuffer.SetRange("Line No.", JnlBankCharges."Line No.");
        DetailedGSTEntryBuffer.SetRange("Source Type", "Source Type"::"Bank Account");
        DetailedGSTEntryBuffer.SetRange("Jnl. Bank Charge", JnlBankCharges."Bank Charge");
    end;

    local procedure FillGSTPostingBufferBankCharge(JnlBankCharges: Record "Journal Bank Charges"; GenJournalLine: Record "Gen. Journal Line")
    var
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
    begin
        SetFilterForBankCharge(DetailedGSTEntryBuffer, JnlBankCharges);
        if DetailedGSTEntryBuffer.FindSet() then
            repeat
                Clear(GSTPostingBuffer[1]);
                GSTPostingBuffer[1]."Transaction Type" := GSTPostingBuffer[1]."Transaction Type"::Purchase;
                GSTPostingBuffer[1]."Gen. Bus. Posting Group" := GenJournalLine."Gen. Bus. Posting Group";
                GSTPostingBuffer[1]."Gen. Prod. Posting Group" := GenJournalLine."Gen. Prod. Posting Group";
                GSTPostingBuffer[1]."Global Dimension 1 Code" := GenJournalLine."Shortcut Dimension 1 Code";
                GSTPostingBuffer[1]."Global Dimension 2 Code" := GenJournalLine."Shortcut Dimension 2 Code";
                GSTPostingBuffer[1]."GST Group Code" := DetailedGSTEntryBuffer."GST Group Code";
                GSTPostingBuffer[1]."GST Component Code" := DetailedGSTEntryBuffer."GST Component Code";
                GSTPostingBuffer[1]."Party Code" := DetailedGSTEntryBuffer."Source No.";
                if not DetailedGSTEntryBuffer."Non-Availment" then begin
                    GSTPostingBuffer[1].Availment := true;
                    GSTPostingBuffer[1]."Account No." :=
                    GetGSTReceivableAccountNo(DetailedGSTEntryBuffer."Location State Code", DetailedGSTEntryBuffer."GST Component Code");
                end;

                GSTPostingBuffer[1]."GST Base Amount" := DetailedGSTEntryBuffer."GST Base Amount";
                GSTPostingBuffer[1]."GST Amount" := DetailedGSTEntryBuffer."GST Amount";
                GSTPostingBuffer[1]."External Document No." := DetailedGSTEntryBuffer."External Document No.";
                UpdateGSTPostingBufferBankCharge();
            until DetailedGSTEntryBuffer.Next() = 0;
    end;

    local procedure UpdateGSTPostingBufferBankCharge()
    begin
        GSTPostingBuffer[2] := GSTPostingBuffer[1];
        if GSTPostingBuffer[2].Find() then begin
            GSTPostingBuffer[2]."GST Base Amount" += GSTPostingBuffer[1]."GST Base Amount";
            GSTPostingBuffer[2]."GST Amount" += GSTPostingBuffer[1]."GST Amount";
            GSTPostingBuffer[2].Modify();
        end else
            GSTPostingBuffer[1].Insert();
    end;

    local procedure InsertPostedJnlBankCharges(JnlBankCharges: Record "Journal Bank Charges"; GenJnlLine: Record "Gen. Journal Line")
    var
        PostedJnlBankCharges: Record "Posted Jnl. Bank Charges";
        BankAccount: Record "Bank Account";
        JnlBankChargesSessionMgt: Codeunit "GST Bank Charge Session Mgt.";
    begin
        if GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::"Bank Account" then
            if GenJnlLine."Bal. Account No." <> '' then
                BankAccount.Get(GenJnlLine."Bal. Account No.");

        if GenJnlLine."Account Type" = GenJnlLine."Account Type"::"Bank Account" then
            if GenJnlLine."Account No." <> '' then
                BankAccount.Get(GenJnlLine."Account No.");

        PostedJnlBankCharges.Init();
        PostedJnlBankCharges."GL Entry No." := JnlBankChargesSessionMgt.GETEntryNo();
        PostedJnlBankCharges."Bank Charge" := JnlBankCharges."Bank Charge";
        PostedJnlBankCharges.Amount := JnlBankCharges.Amount;
        PostedJnlBankCharges."Amount (LCY)" := JnlBankCharges."Amount (LCY)";
        PostedJnlBankCharges."Document No." := GenJnlLine."Document No.";
        PostedJnlBankCharges."Posting Date" := GenJnlLine."Posting Date";
        if JnlBankCharges."GST Group Code" <> '' then begin
            if GenJnlLine."Bank Charge" then begin
                PostedJnlBankCharges.Amount := Abs(GenJnlLine.Amount);
                PostedJnlBankCharges."Amount (LCY)" := Abs(GenJnlLine."Amount (LCY)");
            end;

            PostedJnlBankCharges."GST Group Code" := JnlBankCharges."GST Group Code";
            PostedJnlBankCharges."GST Group Type" := JnlBankCharges."GST Group Type";
            PostedJnlBankCharges."Foreign Exchange" := JnlBankCharges."Foreign Exchange";
            PostedJnlBankCharges."HSN/SAC Code" := JnlBankCharges."HSN/SAC Code";
            PostedJnlBankCharges.Exempted := JnlBankCharges.Exempted;
            PostedJnlBankCharges."GST Credit" := JnlBankCharges."GST Credit";
            if GenJnlLine."Location State Code" <> GenJnlLine."GST Bill-to/BuyFrom State Code" then
                PostedJnlBankCharges."GST Jurisdiction Type" := PostedJnlBankCharges."GST Jurisdiction Type"::Interstate
            else
                PostedJnlBankCharges."GST Jurisdiction Type" := PostedJnlBankCharges."GST Jurisdiction Type"::Intrastate;

            PostedJnlBankCharges."GST Bill to/Buy From State" := BankAccount."State Code";
            PostedJnlBankCharges."Location State Code" := GenJnlLine."Location State Code";
            PostedJnlBankCharges."Location  Reg. No." := GenJnlLine."Location GST Reg. No.";
            PostedJnlBankCharges."GST Registration Status" := JnlBankCharges."GST Registration Status";
            PostedJnlBankCharges."GST Inv. Rounding Precision" := JnlBankCharges."GST Inv. Rounding Precision";
            PostedJnlBankCharges."GST Inv. Rounding Type" := JnlBankCharges."GST Inv. Rounding Type";
            PostedJnlBankCharges."Nature of Supply" := PostedJnlBankCharges."Nature of Supply"::B2B;
            JnlBankCharges.TestField("External Document No.");
            PostedJnlBankCharges."External Document No." := JnlBankCharges."External Document No.";
            PostedJnlBankCharges."Transaction No." := JnlBankChargesSessionMgt.GetTranxactionNo();
            PostedJnlBankCharges.LCY := JnlBankCharges.LCY;
            PostedJnlBankCharges."GST Document Type" := JnlBankCharges."GST Document Type";
        end;

        PostedJnlBankCharges.Insert(true);
    end;

    local procedure GetGSTReceivableAccountNo(GSTStateCode: Code[10]; GSTComponentCode: Code[30]): Code[20]
    var
        GSTPostingSetup: Record "GST Posting Setup";
        GSTComponentID: Integer;
    begin
        GSTComponentID := GetGSTComponentID(GSTComponentCode);
        GSTPostingSetup.Get(GSTStateCode, GSTComponentID);
        GSTPostingSetup.TestField("Receivable Account");
        exit(GSTPostingSetup."Receivable Account");
    end;

    local procedure GetGSTComponentID(GSTComponentCode: Code[30]): Integer
    var
        TaxComponent: Record "Tax Component";
    begin
        TaxComponent.SetRange(Name, GSTComponentCode);
        TaxComponent.FindFirst();
        exit(TaxComponent.Id);
    end;

    local procedure DeleteJournalBankCharges(var GenJournalLine: Record "Gen. Journal Line")
    var
        JnlBankCharges: Record "Journal Bank Charges";
    begin
        JnlBankCharges.Reset();
        JnlBankCharges.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        JnlBankCharges.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        JnlBankCharges.SetRange("Line No.", GenJournalLine."Line No.");
        JnlBankCharges.DeleteAll();
    end;

    local procedure CalculateGSTAmounts(JnlBankCharges: Record "journal Bank Charges")
    var
        GenJnlLine: Record "Gen. Journal Line";
        BankAccount: Record "Bank Account";
        Location: Record Location;
    begin
        if (JnlBankCharges."Journal Template Name" = '') or (JnlBankCharges."Journal Batch Name" = '') then
            exit;

        GenJnlLine.Get(JnlBankCharges."Journal Template Name", JnlBankCharges."Journal Batch Name", JnlBankCharges."Line No.");
        if (JnlBankCharges."GST Document Type" = JnlBankCharges."GST Document Type"::" ") and (JnlBankCharges."GST Group Code" <> '') and not GenJnlLine."Bank Charge" then
            JnlBankCharges.TestField("GST Document Type");

        if not (GenJnlLine."Document Type" in [GenJnlLine."Document Type"::Payment, GenJnlLine."Document Type"::Refund]) then
            exit;

        if JnlBankCharges."GST Group Code" = '' then
            exit;

        if JnlBankCharges."GST Group Code" <> '' then begin
            JnlBankCharges.TestField("GST Group Type");
            JnlBankCharges.TestField("HSN/SAC Code");
            if GenJnlLine."Bal. Account No." <> '' then
                BankAccount.Get(GenJnlLine."Bal. Account No.")
            else
                BankAccount.Get(GenJnlLine."Account No.");

            BankAccount.TestField("GST Registration No.");
            BankAccount.TestField("State Code");
            GenJnlLine.TestField("Location Code");
            GenJnlLine.TestField("Location State Code");
            Location.Get(GenJnlLine."Location Code");
            Location.TestField("State Code");
            Location.TestField("GST Registration No.");
            JnlBankCharges.TestField("External Document No.");
        end;
    end;

    local procedure DetailedGSTLedgerDocument2OriginalDocumentTypeEnum(DetailedGSTLedgerDocumentType: Enum "GST Document Type"): Enum "Original Doc Type"
    var
        ConversionErr: Label 'Document Type %1 is not a valid option.', Comment = '%1 = Detailed GST Ledger Document Type';
    begin
        case DetailedGSTLedgerDocumentType of
            DetailedGSTLedgerDocumentType::"Credit Memo":
                exit("Original Doc Type"::"Credit Memo");
            DetailedGSTLedgerDocumentType::Invoice:
                exit("Original Doc Type"::Invoice);
            DetailedGSTLedgerDocumentType::Refund:
                exit("Original Doc Type"::Refund);
            DetailedGSTLedgerDocumentType::payment:
                exit("Original Doc Type"::payment);
            else
                Error(ConversionErr, DetailedGSTLedgerDocumentType);
        end;
    end;

    local procedure FillDetailedGSTLedgerEntry(JournalBankCharges: Record "Journal Bank Charges"; var EntryNo: Integer; NextTransactionNo: Integer; GenJournalLine: Record "Gen. Journal Line")
    var
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        BankAccount: Record "Bank Account";
        BankCharge: Record "Bank Charge";
        DocumentTypeTxt: Text;
        GSTDocumentType: Enum "original Doc Type";
    begin
        DetailedGSTEntryBuffer.SetCurrentKey("Transaction Type", "Journal Template Name", "Journal Batch Name", "Line No.");
        DetailedGSTEntryBuffer.SetRange("Transaction Type", DetailedGSTEntryBuffer."Transaction Type"::Purchase);
        DetailedGSTEntryBuffer.SetRange("Journal Template Name", JournalBankCharges."Journal Template Name");
        DetailedGSTEntryBuffer.SetRange("Journal Batch Name", JournalBankCharges."Journal Batch Name");
        DetailedGSTEntryBuffer.SetRange("Line No.", JournalBankCharges."Line No.");
        DetailedGSTEntryBuffer.SetRange("Jnl. Bank Charge", JournalBankCharges."Bank Charge");
        if DetailedGSTEntryBuffer.FindSet() then
            repeat
                DetailedGSTLedgerEntry.Init();
                DetailedGSTLedgerEntry."Entry No." := EntryNo;
                EntryNo += 1;
                DetailedGSTLedgerEntry."Entry Type" := DetailedGSTLedgerEntry."Entry Type"::"Initial Entry";
                DetailedGSTLedgerEntry."Transaction No." := NextTransactionNo;
                DetailedGSTLedgerEntry."Document No." := GenJournalLine."Document No.";
                DetailedGSTLedgerEntry."Posting Date" := DetailedGSTEntryBuffer."Posting Date";
                DetailedGSTEntryBuffer.TestField("Location Code");
                DetailedGSTEntryBuffer.TestField("Location  Reg. No.");
                DetailedGSTEntryBuffer.TestField("Location State Code");
                DetailedGSTLedgerEntry."Location Code" := DetailedGSTEntryBuffer."Location Code";
                DetailedGSTLedgerEntry."GST Vendor Type" := "GST Vendor Type"::Registered;
                DetailedGSTLedgerEntry."Location  Reg. No." := DetailedGSTEntryBuffer."Location  Reg. No.";
                DetailedGSTLedgerEntry."GST Exempted Goods" := DetailedGSTEntryBuffer.Exempted;
                DetailedGSTLedgerEntry."GST Rounding Type" := DetailedGSTEntryBuffer."GST Rounding Type";
                DetailedGSTLedgerEntry."GST Rounding Precision" := DetailedGSTEntryBuffer."GST Rounding Precision";
                DetailedGSTLedgerEntry."GST Inv. Rounding Type" := DetailedGSTEntryBuffer."GST Inv. Rounding Type";
                DetailedGSTLedgerEntry."GST Inv. Rounding Precision" := DetailedGSTEntryBuffer."GST Inv. Rounding Precision";
                DocumentTypeTxt := Format(DetailedGSTLedgerEntry."Document Type");
                Evaluate(GSTDocumentType, DocumentTypeTxt);
                DetailedGSTLedgerEntry."HSN/SAC Code" := DetailedGSTEntryBuffer."HSN/SAC Code";
                DetailedGSTLedgerEntry."GST Group Type" := DetailedGSTEntryBuffer."GST Group Type";
                DetailedGSTLedgerEntry."Buyer/Seller Reg. No." := DetailedGSTEntryBuffer."Buyer/Seller Reg. No.";
                if BankAccount.Get(GenJournalLine."Bal. Account No.") then
                    DetailedGSTLedgerEntry."Source No." := GenJournalLine."Bal. Account No."
                else
                    if BankAccount.Get(GenJournalLine."Account No.") then
                        DetailedGSTLedgerEntry."Source No." := GenJournalLine."Account No.";

                if DetailedGSTEntryBuffer."Location State Code" <> DetailedGSTEntryBuffer."Buyer/Seller State Code" then
                    DetailedGSTLedgerEntry."GST Jurisdiction Type" := DetailedGSTLedgerEntry."GST Jurisdiction Type"::Interstate
                else
                    DetailedGSTLedgerEntry."GST Jurisdiction Type" := DetailedGSTLedgerEntry."GST Jurisdiction Type"::Intrastate;

                if not DetailedGSTEntryBuffer."Non-Availment" then
                    DetailedGSTLedgerEntry."GST Credit" := DetailedGSTLedgerEntry."GST Credit"::Availment
                else
                    DetailedGSTLedgerEntry."GST Credit" := DetailedGSTLedgerEntry."GST Credit"::"Non-Availment";

                DetailedGSTLedgerEntry."Credit Availed" := DetailedGSTLedgerEntry."GST Credit" = DetailedGSTLedgerEntry."GST Credit"::Availment;
                DetailedGSTLedgerEntry."Source Type" := "Source Type"::"Bank Account";
                DetailedGSTLedgerEntry.Type := DetailedGSTLedgerEntry.Type::"G/L Account";
                DetailedGSTLedgerEntry."Transaction Type" := DetailedGSTLedgerEntry."Transaction Type"::Purchase;
                BankCharge.Get(JournalBankCharges."Bank Charge");
                DetailedGSTLedgerEntry."No." := BankCharge.Account;
                DetailedGSTLedgerEntry."GST Component Code" := DetailedGSTEntryBuffer."GST Component Code";
                if DetailedGSTLedgerEntry."Credit Availed" then
                    DetailedGSTLedgerEntry."G/L Account No." := GetGSTReceivableAccountNo(
                        DetailedGSTEntryBuffer."Location State Code",
                        DetailedGSTLedgerEntry."GST Component Code")
                else
                    DetailedGSTLedgerEntry."G/L Account No." := DetailedGSTLedgerEntry."No.";

                DetailedGSTLedgerEntry."GST Group Code" := DetailedGSTEntryBuffer."GST Group Code";
                DetailedGSTLedgerEntry."Document Line No." := DetailedGSTEntryBuffer."Line No.";
                DetailedGSTLedgerEntry."GST Base Amount" := DetailedGSTEntryBuffer."GST Base Amount";
                DetailedGSTLedgerEntry."GST Amount" := DetailedGSTEntryBuffer."GST Amount";
                if DetailedGSTLedgerEntry."GST Base Amount" > 0 then begin
                    DetailedGSTLedgerEntry."Document Type" := DetailedGSTLedgerEntry."Document Type"::Invoice;
                    DetailedGSTLedgerEntry.Quantity := 1;
                end else begin
                    DetailedGSTLedgerEntry."Document Type" := DetailedGSTLedgerEntry."Document Type"::"Credit Memo";
                    DetailedGSTLedgerEntry.Quantity := -1;
                end;

                DetailedGSTLedgerEntry."GST %" := DetailedGSTEntryBuffer."GST %";
                if DetailedGSTLedgerEntry."GST Exempted Goods" then
                    DetailedGSTLedgerEntry."GST %" := 0;

                if DetailedGSTLedgerEntry."GST Credit" = DetailedGSTLedgerEntry."GST Credit"::"Non-Availment" then
                    DetailedGSTLedgerEntry."Amount Loaded on Item" := DetailedGSTLedgerEntry."GST Amount";

                if JournalBankCharges.LCY then
                    DetailedGSTLedgerEntry."Currency Factor" := 1
                else begin
                    DetailedGSTLedgerEntry."Currency Code" := GenJournalLine."Currency Code";
                    DetailedGSTLedgerEntry."Currency Factor" := GenJournalLine."Currency Factor";
                end;

                DetailedGSTLedgerEntry."External Document No." := JournalBankCharges."External Document No.";
                DetailedGSTLedgerEntry.TestField("HSN/SAC Code");
                DetailedGSTLedgerEntry."Skip Tax Engine Trigger" := true;
                DetailedGSTLedgerEntry.Insert(true);
                InsertDetailedGSTLedgerInformation(DetailedGSTEntryBuffer, GenJournalLine, JournalBankCharges, DetailedGSTLedgerEntry);
            until DetailedGSTEntryBuffer.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostBankCharges(var JnlBankCharges: Record "Journal Bank Charges"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetBankChargeAmount(
        var BankChargeAmount: Decimal;
        var BankChargeGSTAmount: Decimal;
        ExecutionOption: Option;
        var GenJnlLine: Record "Gen. Journal Line";
        var JnlBankChargesSessionMgt: Codeunit "GST Bank Charge Session Mgt.";
        var JnlBankCharges: Record "Journal Bank Charges")
    begin
    end;
}
