// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSBase;

using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.Currency;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Location;
using Microsoft.Finance.TaxBase;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.TaxEngine.PostingHandler;

codeunit 18807 "TCS Management"
{
    var
        AccountingPeriodErr: Label 'Posting Date doesn''t lie in Tax Accounting Period', Locked = true;
        PANNOErr: Label 'The Customer P.A.N. is invalid.';
        PANReferenceEmptyErr: Label 'The P.A.N. Reference No. field must be filled for the customer.';
        NOCAccountTypeErr: Label '%1 cannot be entered for %2 %3.', Comment = '%1=TCS Nature of Collection Caption., %2= Account type Field Caption. %3=Value of Account Type.';
        NOCTypeErr: Label '%1 does not exist in table %2.', Comment = '%1=TCS Nature of Collection Value, %2=TCS NOC Table Caption';
        TCSNOCErr: Label 'TCS Nature of Collection %1 is not defined for Customer no. %2.', Comment = '%1= TCS Nature of Collection, %2= Customer No.';

    procedure OpenTCSEntries(FromEntry: Integer; ToEntry: Integer)
    var
        TCSEntry: Record "TCS Entry";
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Entry No.", FromEntry, ToEntry);
        if GLEntry.FindFirst() then begin
            TCSEntry.SetRange("Transaction No.", GLEntry."Transaction No.");
            Page.Run(0, TCSEntry);
        end;
    end;

    procedure ConvertTCSAmountToLCY(
        CurrencyCode: Code[10];
        Amount: Decimal;
        CurrencyFactor: Decimal;
        PostingDate: Date): Decimal
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        TaxComponent: Record "Tax Component";
        TCSSetup: Record "TCS Setup";
    begin
        if not TCSSetup.Get() then
            exit;

        TCSSetup.TestField("Tax Type");

        TaxComponent.SetRange("Tax Type", TCSSetup."Tax Type");
        TaxComponent.SetRange(Name, TCSSetup."Tax Type");
        TaxComponent.FindFirst();

        exit(Round(
        CurrencyExchangeRate.ExchangeAmtFCYToLCY(
        PostingDate, CurrencyCode, Amount, CurrencyFactor), TaxComponent."Rounding Precision"));
    end;

    procedure RoundTCSAmount(TCSAmount: Decimal): Decimal
    var
        TaxComponent: Record "Tax Component";
        TCSSetup: Record "TCS Setup";
        TCSRoundingDirection: Text;
    begin
        if not TCSSetup.Get() then
            exit;

        TCSSetup.TestField("Tax Type");

        TaxComponent.SetRange("Tax Type", TCSSetup."Tax Type");
        TaxComponent.SetRange(Name, TCSSetup."Tax Type");
        TaxComponent.FindFirst();
        case TaxComponent.Direction of
            TaxComponent.Direction::Nearest:
                TCSRoundingDirection := '=';
            TaxComponent.Direction::Up:
                TCSRoundingDirection := '>';
            TaxComponent.Direction::Down:
                TCSRoundingDirection := '<';
        end;

        exit(Round(TCSAmount, TaxComponent."Rounding Precision", TCSRoundingDirection));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnbeforePostGenJnlLine', '', false, false)]
    local procedure CheckTCSValidation(var GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."TCS Nature of Collection" = '' then
            exit;

        if GenJournalLine."System-Created Entry" then
            exit;

        CheckPANValidatins(GenJournalLine);
        CheckCompInfoDetails();
        CheckTaxAccountingPeriod(GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Account No.', false, false)]
    local procedure AssignNOCGenJnlLine(var Rec: Record "Gen. Journal Line")
    var
        AllowedNOC: Record "Allowed NOC";
    begin
        if Rec."Account Type" <> Rec."Account Type"::Customer then
            exit;

        AllowedNOC.SetRange("Customer No.", Rec."Account No.");
        AllowedNOC.SetRange(AllowedNOC."Default Noc", true);
        if not AllowedNOC.FindFirst() then
            Rec.Validate("TCS Nature of Collection", '')
        else
            Rec.Validate("TCS Nature of Collection", AllowedNOC."TCS Nature of Collection");
    end;

    [EventSubscriber(ObjectType::Table, database::"Gen. Journal Line", 'OnAfterValidateEvent', 'TCS Nature of Collection', false, false)]
    local procedure ChecKDefinedNOC(var Rec: Record "Gen. Journal Line")
    var
        AllowedNOC: Record "Allowed NOC";
        CompanyInformation: Record "Company Information";
        Location: Record Location;
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
    begin
        if Rec."TCS Nature of Collection" = '' then
            exit;

        if Rec."Account Type" <> Rec."Account Type"::Customer then
            Error(NOCAccountTypeErr, Rec.FieldCaption("TCS Nature of Collection"), Rec.FieldCaption("Account Type"), Rec."Account Type");

        if not TCSNatureOfCollection.Get(Rec."TCS Nature of Collection") then
            Error(NOCTypeErr, Rec."TCS Nature of Collection", TCSNatureOfCollection.TableCaption());

        if not AllowedNOC.Get(Rec."Account No.", Rec."TCS Nature of Collection") then
            Error(TCSNOCErr, Rec."TCS Nature of Collection", Rec."Account No.");

        CompanyInformation.Get();
        Rec.Validate("T.C.A.N. No.", CompanyInformation."T.C.A.N. No.");
        if Rec."Location Code" <> '' then begin
            Location.Get(Rec."Location Code");
            Rec.Validate("T.C.A.N. No.", Location."T.C.A.N. No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Account Type', false, false)]
    local procedure ClearTCSFields(var Rec: Record "Gen. Journal Line"; var xRec: Record "Gen. Journal Line")
    begin
        if xRec."Account Type" = xRec."Account Type"::Customer then
            Rec.Validate("TCS Nature of Collection", '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Document GL Posting", 'OnPrepareTransValueToPost', '', false, false)]
    local procedure SetTotalTCSInclSHECessAmount(var TempTransValue: Record "Tax Transaction Value")
    var
        TCSSetup: Record "TCS Setup";
        TaxComponent: Record "Tax Component";
        TaxBaseSubscribers: Codeunit "Tax Base Subscribers";
        ComponenetNameLbl: Label 'Total TCS';
    begin
        if TempTransValue."Value Type" <> TempTransValue."Value Type"::COMPONENT then
            exit;

        if not TCSSetup.Get() then
            exit;

        if TempTransValue."Tax Type" <> TCSSetup."Tax Type" then
            exit;

        TaxComponent.SetRange("Tax Type", TCSSetup."Tax Type");
        TaxComponent.SetRange(Name, ComponenetNameLbl);
        if not TaxComponent.FindFirst() then
            exit;

        if TempTransValue."Value ID" <> TaxComponent.Id then
            exit;

        TaxBaseSubscribers.GetTCSAmount(TempTransValue.Amount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Subscribers", 'OnAfterGetTCSAmountFromTransNo', '', false, false)]
    local procedure OnAfterGetTCSAmountFromTransNo(TransactionNo: Integer; var Amount: Decimal)
    var
        TCSEntry: Record "TCS Entry";
    begin
        TCSEntry.SetRange("Transaction No.", TransactionNo);
        if TCSEntry.FindSet() then begin
            TCSEntry.CalcSums("Total TCS Including SHE CESS");
            Amount := TCSEntry."Total TCS Including SHE CESS";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Subscribers", 'OnAfterGetAmountFromDocumentNoForEInv', '', false, false)]
    local procedure OnAfterGetAmountFromDocumentNoForEInv(DocumentNo: Code[20]; var Amount: Decimal)
    begin
        GetAmountFromDocumentNoForEInv(DocumentNo, Amount);
    end;

    local procedure GetAmountFromDocumentNoForEInv(DocumentNo: Code[20]; var Amount: Decimal)
    var
        TCSEntry: Record "TCS Entry";
    begin
        OnBeforeFilterGetAmtFromDocumentNoForEInv(TCSEntry, DocumentNo);

        TCSEntry.SetRange("Document No.", DocumentNo);
        if TCSEntry.FindFirst() then
            Amount := (TCSEntry."TCS Amount" + TCSEntry."eCESS Amount" + TCSEntry."SHE Cess Amount" + TCSEntry."Surcharge Amount");

        OnAfterGetAmtFromDocumentNoForEInv(TCSEntry, Amount, DocumentNo);
    end;

    local procedure CheckPANValidatins(GenJournalLine: Record "Gen. Journal Line")
    var
        Customer: Record Customer;
        Location: Record Location;
    begin
        if Location.Get(GenJournalLine."Location Code") then
            Location.TestField("T.C.A.N. No.");
        GenJournalLine.TestField("T.C.A.N. No.");
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer then
            Customer.Get(GenJournalLine."Account No.")
        else
            Customer.Get(GenJournalLine."Bal. Account No.");

        if StrLen(Customer."P.A.N. No.") <> 10 then
            Error(PANNOErr);

        if (Customer."P.A.N. No." = '') or (Customer."P.A.N. Status" <> Customer."P.A.N. Status"::" ") then
            if (Customer."P.A.N. Status" <> Customer."P.A.N. Status"::" ") and (Customer."P.A.N. Reference No." = '') then
                Error(PANReferenceEmptyErr);
    end;

    local procedure CheckCompInfoDetails()
    var
        CompanyInformation: Record "Company Information";
        DeductorCategory: Record "Deductor Category";
    begin
        CompanyInformation.Get();
        CompanyInformation.TestField("Deductor Category");
        CompanyInformation.TestField("T.C.A.N. No.");
        CompanyInformation.TestField("P.A.N. No.");
        CompanyInformation.TestField("State Code");
        CompanyInformation.TestField("Post Code");
        DeductorCategory.Get(CompanyInformation."Deductor Category");

        if DeductorCategory."DDO Code Mandatory" then begin
            CompanyInformation.TestField("DDO Code");
            CompanyInformation.TestField("DDO Registration No.");
        end;

        if DeductorCategory."PAO Code Mandatory" then begin
            CompanyInformation.TestField("PAO Code");
            CompanyInformation.TestField("PAO Registration No.");
        end;

        if DeductorCategory."Ministry Details Mandatory" then begin
            CompanyInformation.TestField("Ministry Type");
            CompanyInformation.TestField("Ministry Code");
        end
    end;

    local procedure CheckTaxAccountingPeriod(GenJournalLine: Record "Gen. Journal Line")
    var
        TaxAccountingPeriod: Record "Tax Accounting Period";
        TCSSetup: Record "TCS Setup";
        TaxType: Record "Tax Type";
        AccountingStartDate: Date;
        AccountingEndDate: Date;
    begin
        if not TCSSetup.Get() then
            exit;

        TCSSetup.TestField("Tax Type");
        TaxType.Get(TCSSetup."Tax Type");

        TaxAccountingPeriod.SetCurrentKey("Starting Date");
        TaxAccountingPeriod.SetRange("Tax Type Code", TaxType."Accounting Period");
        TaxAccountingPeriod.SetRange(Closed, false);
        if TaxAccountingPeriod.FindFirst() then
            AccountingStartDate := TaxAccountingPeriod."Starting Date";

        if TaxAccountingPeriod.FindLast() then
            AccountingEndDate := TaxAccountingPeriod."Ending Date";

        if (GenJournalLine."Posting Date" < AccountingStartDate) or (GenJournalLine."Posting Date" > AccountingEndDate) then
            Error(AccountingPeriodErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Document Type', false, false)]
    local procedure OnAfterValidateDocumentType(var Rec: Record "Gen. Journal Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        Rec."Excl. GST in TCS Base" := false;
        Rec."TCS On Recpt. Of Pmt. Amount" := 0;
        if Rec."TCS Nature of Collection" = '' then
            exit;

        CalculateTax.CallTaxEngineOnGenJnlLine(Rec, Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateTotalTCSAmountInCustLedgerEntry(var Rec: Record "Cust. Ledger Entry")
    var
        TCSEntry: Record "TCS Entry";
    begin
        TCSEntry.SetRange("Transaction No.", Rec."Transaction No.");
        TCSEntry.SetRange("TCS on Recpt. Of Pmt.", true);
        TCSEntry.SetFilter("Document No.", '<>%1', Rec."Document No.");
        if TCSEntry.FindFirst() then begin
            if TCSEntry."Document Type" in [TCSEntry."Document Type"::Invoice, TCSEntry."Document Type"::Payment] then
                Rec."Total TCS Including SHE CESS" -= Abs(TCSEntry."Total TCS Including SHE CESS");

            if Rec."TCS Nature of Collection" = '' then
                Rec."TCS Nature of Collection" := TCSEntry."TCS Nature of Collection";
            Rec.Modify();
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFilterGetAmtFromDocumentNoForEInv(var TCSEntry: Record "TCS Entry"; DocumentNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetAmtFromDocumentNoForEInv(TCSEntry: Record "TCS Entry"; var Amount: Decimal; DocumentNo: code[20])
    begin
    end;
}
