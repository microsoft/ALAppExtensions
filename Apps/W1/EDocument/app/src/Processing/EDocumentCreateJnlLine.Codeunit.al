// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Bank.Reconciliation;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Setup;

codeunit 6137 "E-Document Create Jnl. Line"
{

    Permissions = tabledata "Gen. Journal Line" = imd;

    trigger OnRun()
    begin
        CreateGeneralJournalLine(SourceEDocument, CreatedJnlLine);
    end;

    internal procedure SetSource(var SourceEDocument2: Record "E-Document"; var SourceEDocumentService2: Record "E-Document Service")
    begin
        SourceEDocument.Copy(SourceEDocument2);
        SourceEDocumentService.Copy(SourceEDocumentService2);
    end;

    internal procedure GetCreatedJnlLine(): RecordRef;
    begin
        exit(CreatedJnlLine);
    end;

    local procedure CreateGeneralJournalLine(var EDocument: Record "E-Document"; var JnlLine: RecordRef)
    var
        GenJournalLine: Record "Gen. Journal Line";
        LastGenJournalLine: Record "Gen. Journal Line";
        TextToAccountMapping: Record "Text-to-Account Mapping";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GeneralLedgerSetup: Record "General Ledger Setup";
        EDocService: Record "E-Document Service";
        TextToAccountMappingFound: Boolean;
        TempGenJournalLineInserted: Boolean;
    begin
        EDocService := SourceEDocumentService;
        if (EDocService."General Journal Template Name" = '') or (EDocService."General Journal Batch Name" = '') then
            EDocumentErrorHelper.LogErrorMessage(EDocument, EDocService, EDocService.FieldNo("General Journal Template Name"),
                StrSubstNo(TemplateBatchNameMissingErr,
                    EDocService.FieldCaption("General Journal Template Name"),
                    EDocService.FieldCaption("General Journal Batch Name"),
                    EDocService.TableCaption,
                    EDocService.Code))
        else begin
            GenJournalTemplate.Get(EDocService."General Journal Template Name");
            GenJournalBatch.Get(EDocService."General Journal Template Name", EDocService."General Journal Batch Name");
            LastGenJournalLine.SetRange("Journal Template Name", EDocService."General Journal Template Name");
            LastGenJournalLine.SetRange("Journal Batch Name", EDocService."General Journal Batch Name");
            if not LastGenJournalLine.FindLast() then begin
                LastGenJournalLine.Validate("Journal Template Name", EDocService."General Journal Template Name");
                LastGenJournalLine.Validate("Journal Batch Name", EDocService."General Journal Batch Name");
                LastGenJournalLine."Line No." += 10000;
                LastGenJournalLine.Validate("Document No.", NoSeriesBatch.GetNextNo(GenJournalBatch."No. Series", EDocument."Document Date"));
                TempGenJournalLineInserted := LastGenJournalLine.Insert();
            end;

            // Create the gen jnl line out of the e-doc and text-to-account mapping
            GenJournalLine.Init();
            GenJournalLine.Validate("Journal Template Name", EDocService."General Journal Template Name");
            GenJournalLine.Validate("Journal Batch Name", EDocService."General Journal Batch Name");
            GenJournalLine."Line No." := LastGenJournalLine."Line No." + 10000;
            LastGenJournalLine.CalcSums("Balance (LCY)");
            GenJournalLine.SetUpNewLine(LastGenJournalLine, LastGenJournalLine."Balance (LCY)", true);

            if TempGenJournalLineInserted then
                LastGenJournalLine.Delete();

            case EDocument."Document Type" of
                EDocument."Document Type"::"Purchase Invoice":
                    GenJournalLine."Document Type" := GenJournalLine."Document Type"::Invoice;
                EDocument."Document Type"::"Purchase Credit Memo":
                    GenJournalLine."Document Type" := GenJournalLine."Document Type"::"Credit Memo";
                else
                    EDocumentErrorHelper.LogErrorMessage(EDocument, GenJournalLine, GenJournalLine.FieldNo("Document Type"),
                        StrSubstNo(UnsupportedDocumentTypeErr,
                            GenJournalLine.FieldCaption("Document Type"), EDocument."Document Type"));
            end;

            TextToAccountMapping.SetFilter("Mapping Text", StrSubstNo(MappingTextFilterTxt, EDocument."Bill-to/Pay-to Name"));
            TextToAccountMappingFound := TextToAccountMapping.FindFirst();

            case GenJournalLine."Document Type" of
                GenJournalLine."Document Type"::Invoice:
                    if TextToAccountMappingFound then begin
                        GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"G/L Account");
                        if EDocument."Amount Incl. VAT" >= 0 then
                            GenJournalLine.Validate("Account No.", TextToAccountMapping."Debit Acc. No.")
                        else
                            GenJournalLine.Validate("Account No.", TextToAccountMapping."Credit Acc. No.");
                    end else
                        UseDefaultGLAccount(EDocument, GenJournalLine, GenJournalLine.FieldCaption("Account No."), EDocument."Bill-to/Pay-to Name");
                GenJournalLine."Document Type"::"Credit Memo":
                    if TextToAccountMappingFound then begin
                        GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"G/L Account");
                        if EDocument."Amount Incl. VAT" >= 0 then
                            GenJournalLine.Validate("Account No.", TextToAccountMapping."Credit Acc. No.")
                        else
                            GenJournalLine.Validate("Account No.", TextToAccountMapping."Debit Acc. No.");
                    end else
                        UseDefaultGLAccount(EDocument, GenJournalLine, GenJournalLine.FieldCaption("Account No."), EDocument."Bill-to/Pay-to Name");
            end;

            if EDocument."Bill-to/Pay-to No." <> '' then begin
                GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::Vendor);
                GenJournalLine.Validate("Bal. Account No.", EDocument."Bill-to/Pay-to No.");
            end else
                if TextToAccountMapping."Bal. Source No." <> '' then begin
                    GenJournalLine.Validate("Bal. Account Type", TextToAccountMapping."Bal. Source Type");
                    GenJournalLine.Validate("Bal. Account No.", TextToAccountMapping."Bal. Source No.");
                end else
                    if GenJournalBatch."Bal. Account No." <> '' then begin
                        GenJournalLine.Validate("Bal. Account Type", GenJournalBatch."Bal. Account Type");
                        GenJournalLine.Validate("Bal. Account No.", GenJournalBatch."Bal. Account No.");
                    end else
                        EDocumentErrorHelper.LogErrorMessage(EDocument, TextToAccountMapping, TextToAccountMapping.FieldNo("Mapping Text"),
                            StrSubstNo(NoBalanceAccountMappingErr, EDocument."Bill-to/Pay-to Name"));

            GenJournalLine.Validate("Posting Date", EDocument."Document Date");
            GenJournalLine.Validate("Document Date", EDocument."Document Date");
            GenJournalLine.Validate("Due Date", EDocument."Due Date");
            GenJournalLine.Validate("External Document No.", EDocument."Incoming E-Document No.");
            GeneralLedgerSetup.Get();
            if EDocument."Currency Code" <> '' then
                if EDocument."Currency Code" <> GeneralLedgerSetup."LCY Code" then
                    if VerifyCurrency(EDocument) then
                        GenJournalLine.Validate("Currency Code", EDocument."Currency Code");
            case EDocument."Document Type" of
                EDocument."Document Type"::"Purchase Invoice":
                    GenJournalLine.Validate(Amount, EDocument."Amount Incl. VAT");
                EDocument."Document Type"::"Purchase Credit Memo":
                    GenJournalLine.Validate(Amount, -EDocument."Amount Incl. VAT");
            end;

            GenJournalLine.Validate(Description, EDocument."Bill-to/Pay-to Name");

            OnBeforeGenJnlLineInsertFromEDocument(GenJournalLine, EDocument);

            if not EDocumentErrorHelper.HasErrors(EDocument) then begin
                GenJournalLine.Insert(true);

                JnlLine.GetTable(GenJournalLine);

                if Abs(EDocument."Amount Incl. VAT" - EDocument."Amount Excl. VAT") <> Abs(GenJournalLine."VAT Amount") then
                    EDocumentErrorHelper.LogWarningMessage(EDocument, GenJournalLine, GenJournalLine.FieldNo("Account No."),
                    StrSubstNo(VatAmountMismatchErr, GenJournalLine."VAT Amount", EDocument."Amount Incl. VAT" - EDocument."Amount Excl. VAT"));
            end;
        end;
    end;

    local procedure UseDefaultGLAccount(EDocument: Record "E-Document"; var GenJournalLine: Record "Gen. Journal Line"; FieldName: Text; VendorName: Text)
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        TextToAccountMapping: Record "Text-to-Account Mapping";
        DefaultGLAccount: Code[20];
    begin
        PurchasesPayablesSetup.Get();

        if GenJournalLine."Document Type" = GenJournalLine."Document Type"::Invoice then
            DefaultGLAccount := PurchasesPayablesSetup."Debit Acc. for Non-Item Lines";
        if GenJournalLine."Document Type" = GenJournalLine."Document Type"::"Credit Memo" then
            DefaultGLAccount := PurchasesPayablesSetup."Credit Acc. for Non-Item Lines";

        if DefaultGLAccount = '' then
            EDocumentErrorHelper.LogErrorMessage(EDocument, TextToAccountMapping, TextToAccountMapping.FieldNo("Mapping Text"),
                StrSubstNo(NoDebitAccountMappingErr, FieldName, VendorName))
        else begin
            GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"G/L Account");
            GenJournalLine.Validate("Account No.", DefaultGLAccount);
        end;
    end;

    local procedure VerifyCurrency(EDocument: Record "E-Document"): Boolean
    var
        Currency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        if not Currency.Get(EDocument."Currency Code") then begin
            EDocumentErrorHelper.LogErrorMessage(EDocument, Currency, Currency.FieldNo(Code),
                StrSubstNo(CurrencyDoesNotExistErr, EDocument."Currency Code"));
            exit(false)
        end;
        if not CurrencyExchangeRate.CurrencyExchangeRateExist(EDocument."Currency Code", EDocument."Document Date") then begin
            EDocumentErrorHelper.LogErrorMessage(EDocument, Currency, CurrencyExchangeRate.FieldNo("Exchange Rate Amount"),
                StrSubstNo(CurrencyExchangeDoesNotExistErr, EDocument."Currency Code", EDocument."Document Date"));
            exit(false);
        end;
        exit(true);
    end;

    var
        SourceEDocument: Record "E-Document";
        SourceEDocumentService: Record "E-Document Service";
        NoSeriesBatch: Codeunit "No. Series - Batch";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        SourceDocumentHeader, CreatedJnlLine : RecordRef;
        NoBalanceAccountMappingErr: Label 'Could not fill the Bal. Account No. field for vendor ''''%1''''. Choose the Map Text to Account button to map ''''%1'''' to the relevant G/L account.', Comment = '%1 - vendor name';
        NoDebitAccountMappingErr: Label 'Could not fill the %1 field for vendor ''''%2''''. Choose the Map Text to Account button to map ''''%2'''' to the relevant G/L account.', Comment = '%1 - Debit Acc. No. or Credit Acc. No. field caption, %2 - vendor name';
        VatAmountMismatchErr: Label 'VAT amount %1 on the general journal line does not match VAT amount %2 in the electroinc document.', Comment = '%1 - General Journal Line VAT amount, %2 - Electronic Document VAT amount';
        TemplateBatchNameMissingErr: Label 'You must fill the %1 and %2 fields in for %3 %4. ', Comment = '%1 - General Journal Template Name, %2 - General Journal Batch Name, %3 - E-Document Service caption, %4 - E-Document Service code';
        UnsupportedDocumentTypeErr: Label '%1 %2 is not supported.', Comment = '%1 - Document Type caption, %2 - Document Type"';
        CurrencyDoesNotExistErr: Label 'The currency %1 does not exist. You must add the currency in the Currencies window.', Comment = '%1 referee to a concrete currency';
        CurrencyExchangeDoesNotExistErr: Label 'No exchange rate exists for %1 on %2. You must add the exchange rate in the Currencies window.', Comment = '%1 reference to a concrete currency,%2 to the date for the transaction';
        MappingTextFilterTxt: Label '@%1', Comment = '%1 - Filter text', Locked = true;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeGenJnlLineInsertFromEDocument(var GenJournalLine: Record "Gen. Journal Line"; EDocument: Record "E-Document")
    begin
    end;
}