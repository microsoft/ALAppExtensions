// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Payments;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.PostingHandler;
using Microsoft.Finance.TaxEngine.UseCaseBuilder;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Journal;
using Microsoft.FixedAssets.Ledger;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.Posting;
using Microsoft.Sales.Receivables;

codeunit 18243 "GST Journal Line Subscribers"
{
    var
        GSTJournalLineValidations: Codeunit "GST Journal Line Validations";
        GSTTDSTCSAmtGreaterErr: label 'GST TDS/TCS Base Amount must not be greater than Amount %1.', Comment = '%1 =Amount';
        GSTTDSTCSAmtPostiveErr: label 'GST TDS/TCS Base Amount must be positive.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Document GL Posting", 'OnBeforeGenJnlLineAdjustEntry', '', false, false)]
    local procedure AdjustPartyType(var GenJnlLine: Record "Gen. Journal Line"; var AdjustEntry: Boolean; var IsHandled: Boolean)
    begin
        if (GenJnlLine."Party Type" <> GenJnlLine."Party Type"::" ") and (GenJnlLine."Party Code" <> '') then begin
            if (GenJnlLine."Document Type" = GenJnlLine."Document Type"::Invoice) and (GenJnlLine.Amount < 0) and (GenJnlLine."GST Credit" = GenJnlLine."GST Credit"::Availment) then
                AdjustEntry := true;

            if (GenJnlLine."GST Credit" = GenJnlLine."GST Credit"::"Non-Availment") then
                AdjustEntry := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'GST TDS/GST TCS', false, false)]
    local procedure ValidateGSTTCS(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.OnValidateGSTTDSTCS(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'POS Out Of India', false, false)]
    local procedure ValidatePOSOutOfIndia(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.POSOutOfIndia(rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'POS as Vendor State', false, false)]
    local procedure validatePOSasVendorState(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.POSasVendorState(rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'GST Assessable Value', false, false)]
    local procedure validateGSTAssessableValue(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.GSTAssessableValue(rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Custom Duty Amount', false, false)]
    local procedure validateCustomDutyAmount(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.CustomDutyAmount(rec)
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Sales Invoice Type', false, false)]
    local procedure validateSalesInvoiceType(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.SalesInvoiceType(rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'GST on Advance Payment', false, false)]
    local procedure validateGSTonAdvancePayment(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.GSTonAdvancePayment(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'GST Place of supply', false, false)]
    local procedure ValidateGSTPlaceofSuppply(var Rec: Record "Gen. Journal Line"; var xRec: Record "Gen. Journal Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        GSTJournalLineValidations.GSTPlaceofsuppply(rec, xrec);
        CalculateTax.CallTaxEngineOnGenJnlLine(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'GST Group Code', false, false)]
    local procedure ValidateGSTGroupCode(var Rec: Record "Gen. Journal Line"; var xRec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.GSTGroupCode(Rec, Xrec)
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Party Code', false, false)]
    local procedure ValdiatePartyCode(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.partycode(rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Location Code', false, false)]
    local procedure ValidateLocationCode(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.LocationCode(rec)
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Amount', false, false)]
    local procedure ValidateAmount(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.amount(rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Currency Code', false, false)]
    local procedure ValidateCurrencyCode(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.CurrencyCode(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterAccountNoOnValidateGetVendorBalAccount', '', false, false)]
    local procedure ValidateBalVendNo(var GenJournalLine: Record "Gen. Journal Line"; var Vendor: Record Vendor)
    begin
        GSTJournalLineValidations.BalVendNo(GenJournalLine, Vendor)
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterAccountNoOnValidateGetCustomerBalAccount', '', false, false)]
    local procedure ValidateBalCustNo(var GenJournalLine: Record "Gen. Journal Line"; var Customer: Record Customer)
    begin
        GSTJournalLineValidations.BalCustNo(GenJournalLine, Customer)
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterAccountNoOnValidateGetGLBalAccount', '', false, false)]
    local procedure ValidateBalGLAccountNo(
        var GenJournalLine: Record "Gen. Journal Line";
        var GLAccount: Record "G/L Account")
    begin
        GSTJournalLineValidations.BalGLAccountNo(GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnValidateBalAccountNoOnBeforeAssignValue', '', false, false)]
    local procedure ValidateBalAccountNo(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.BalAccountNo(GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Document Type', false, false)]
    local procedure ValidateDocumentType(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.documenttype(rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnafterInsert(var Rec: Record "Gen. Journal Line")
    begin
        //GSTJournalLineValidations.AfterInsert(Rec)
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeValidateEvent', 'Account Type', false, false)]
    local procedure ValidateAccountType(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.AccountType(Rec)
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeValidateEvent', 'Account no.', false, false)]
    local procedure OnbeforevalidateAccountNo(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.BeforeValidateAccountNo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Account no.', false, false)]
    local procedure OnAfterValidateAccountNo(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.AfterValidateAccountNo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Ship-to Code', false, false)]
    local procedure OnAfterValidateShipToCode(var Rec: Record "Gen. Journal Line"; var xRec: Record "Gen. Journal Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        GSTJournalLineValidations.AfterValidateShipToCode(Rec);
        CalculateTax.CallTaxEngineOnGenJnlLine(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterAccountNoOnValidateGetGLAccount', '', false, false)]
    local procedure GLAccountInfo(
        var GenJournalLine: Record "Gen. Journal Line";
        var GLAccount: Record "G/L Account")
    begin
        GSTJournalLineValidations.PopulateGSTInvoiceCrMemo(true, false, GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterAccountNoOnValidateGetCustomerAccount', '', false, false)]
    local procedure ValidateCustAccount(var GenJournalLine: Record "Gen. Journal Line"; var Customer: Record Customer)
    begin
        GSTJournalLineValidations.CustAccount(GenJournalLine, customer)
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterAccountNoOnValidateGetVendorAccount', '', false, false)]
    local procedure ValidateVendorAccount(var GenJournalLine: Record "Gen. Journal Line"; var Vendor: Record Vendor)
    begin
        GSTJournalLineValidations.VendAccount(GenJournalLine, Vendor)
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterAccountNoOnValidateGetFAAccount', '', false, false)]
    local procedure ValidateFAAccount(
        var GenJournalLine: Record "Gen. Journal Line";
        var FixedAsset: Record "Fixed Asset")
    begin
        GSTJournalLineValidations.FaAccount(GenJournalLine, FixedAsset);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterSetupNewLine', '', false, false)]
    local procedure Setupnewlinevalue(
        GenJournalBatch: Record "Gen. Journal Batch";
        var GenJournalLine: Record "Gen. Journal Line")
    var
        location: Record Location;
    begin
        GenJournalLine."Location Code" := GenJournalBatch."Location Code";
        if Location.Get(GenJournalBatch."Location Code") then begin
            GenJournalLine."Location State Code" := Location."State Code";
            GenJournalLine."Location GST Reg. No." := Location."GST Registration No.";
            GenJournalLine."GST Input Service Distribution" := Location."GST Input Service Distributor";
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Currency Factor', false, false)]
    local procedure OnValidateCurrencyCode(var Rec: Record "Gen. Journal Line"; var xRec: Record "Gen. Journal Line")
    begin
        if not Rec.GetSkipTaxCalculation() then
            TaxEngineCallingHandler(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'GST TDS/TCS Base Amount', false, false)]
    local procedure onAfterValidateValidateGSTTDSTCSBaseAmount(var Rec: Record "Gen. Journal Line")
    begin
        if Rec."GST TDS/TCS Base Amount" <> 0 then begin
            Rec.TestField("Document Type", Rec."Document Type"::Payment);
            Rec.TestField(Amount);

            if Abs(Rec."GST TDS/TCS Base Amount") > Abs(Rec.Amount) then
                Error(GSTTDSTCSAmtGreaterErr, Rec.Amount);

            if (Rec."GST TDS/TCS Base Amount" < 0) then
                error(GSTTDSTCSAmtPostiveErr);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnSetJournalLineFieldsFromApplicationOnAfterFindFirstCustLedgEntryWithAppliesToDocNo', '', false, false)]
    local procedure OnSetJournalLineFieldsFromApplicationOnAfterFindFirstCustLedgEntryWithAppliesToDocNo(var GenJournalLine: Record "Gen. Journal Line"; CustLedgEntry: Record "Cust. Ledger Entry")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        if CustLedgEntry."GST Group Code" <> '' then begin
            GenJournalLine."GST Group Code" := CustLedgEntry."GST Group Code";
            GenJournalLine.Validate("GST Group Code");

            if CustLedgEntry."HSN/SAC Code" <> '' then begin
                GenJournalLine."HSN/SAC Code" := CustLedgEntry."HSN/SAC Code";
                GenJournalLine.Validate("HSN/SAC Code");

                GenJournalLine."Location Code" := CustLedgEntry."Location Code";
                GenJournalLine.Validate("Location Code");
                GenJournalLine."Bal. Account Type" := CustLedgEntry."Bal. Account Type";
                GenJournalLine."Bal. Account No." := CustLedgEntry."Bal. Account No.";
                GenJournalLine.Validate("Bal. Account No.");

                CalculateTax.OnAfterValidateGenJnlLineFields(GenJournalLine);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", 'OnPostBalancingEntryOnBeforeGenJnlPostLine', '', false, false)]
    local procedure OnPostBalancingEntryOnBeforeGenJnlPostLine(var GenJnlLine: Record "Gen. Journal Line"; var PurchHeader: Record "Purchase Header"; var TotalPurchLine: Record "Purchase Line"; var TotalPurchLineLCY: Record "Purchase Line"; PreviewMode: Boolean; SuppressCommit: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        PaymentMethod: Record "Payment Method";
        GLEntry: Record "G/L Entry";
    begin
        if PurchHeader."GST Vendor Type" <> PurchHeader."GST Vendor Type"::" " then
            if PurchHeader."Payment Method Code" <> '' then
                if PaymentMethod.Get(PurchHeader."Payment Method Code") then
                    if PaymentMethod."Bal. Account No." <> '' then begin
                        GLEntry.LoadFields("External Document No.", "Document No.", "G/L Account No.", "Document Type", "Credit Amount", "Debit Amount", Amount);
                        GLEntry.SetRange("External Document No.", GenJnlLine."External Document No.");
                        GLEntry.SetRange("Document No.", GenJnlLine."Document No.");
                        GLEntry.SetRange("G/L Account No.", GetVendorAccount(PurchHeader."Buy-from Vendor No."));
                        if (GenJnlLine."Document Type" = GenJnlLine."Document Type"::Payment) then begin
                            GLEntry.SetRange("Document Type", GenJnlLine."Document Type"::Invoice);
                            GLEntry.SetFilter("Credit Amount", '<>%1', 0);
                        end
                        else
                            if (GenJnlLine."Document Type" = GenJnlLine."Document Type"::Refund) then begin
                                GLEntry.SetRange("Document Type", GenJnlLine."Document Type"::"Credit Memo");
                                GLEntry.SetFilter("Debit Amount", '<>%1', 0);
                            end;

                        if GLEntry.FindFirst() then
                            GenJnlLine.Validate(Amount, GLEntry.Amount * -1);
                    end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Post Invoice Events", 'OnPostBalancingEntryOnBeforeGenJnlPostLine', '', false, false)]
    local procedure OnPostBalancingEntryOnBeforeGenJnlPostLineforSales(var GenJnlLine: Record "Gen. Journal Line"; SalesHeader: Record "Sales Header")
    var
        PaymentMethod: Record "Payment Method";
        GLEntry: Record "G/L Entry";
    begin
        if (SalesHeader."GST Customer Type" <> SalesHeader."GST Customer Type"::" ") and (SalesHeader."GST Customer Type" <> SalesHeader."GST Customer Type"::Export) then
            if SalesHeader."Payment Method Code" <> '' then
                if PaymentMethod.Get(SalesHeader."Payment Method Code") then
                    if PaymentMethod."Bal. Account No." <> '' then begin
                        GLEntry.LoadFields("External Document No.", "Document No.", "G/L Account No.", "Document Type", "Credit Amount", "Debit Amount", Amount);
                        GLEntry.SetRange("External Document No.", GenJnlLine."External Document No.");
                        GLEntry.SetRange("Document No.", GenJnlLine."Document No.");
                        GLEntry.SetRange("G/L Account No.", GetCustomerAccount(SalesHeader."Bill-to Customer No."));
                        if (GenJnlLine."Document Type" = GenJnlLine."Document Type"::Payment) then begin
                            GLEntry.SetRange("Document Type", GenJnlLine."Document Type"::Invoice);
                            GLEntry.SetFilter("Debit Amount", '<>%1', 0);
                        end
                        else
                            if (GenJnlLine."Document Type" = GenJnlLine."Document Type"::Refund) then begin
                                GLEntry.SetRange("Document Type", GenJnlLine."Document Type"::"Credit Memo");
                                GLEntry.SetFilter("Credit Amount", '<>%1', 0);
                            end;

                        if GLEntry.FindFirst() then
                            GenJnlLine.Validate(Amount, (GLEntry.Amount * -1));
                    end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Calculate Depreciation", 'OnBeforeGenJnlLineCreate', '', false, false)]
    local procedure OnBeforeGenJnlLineCreate(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine.SetSkipTaxCalulation(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Use Case Event Handling", 'OnBeforeGenJnlLineUseCaseHandleEvent', '', false, false)]
    local procedure OnBeforeGenJnlLineUseCaseHandleEvent(var Rec: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
        if Rec.GetSkipTaxCalculation() then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Insert G/L Account", 'OnBeforeCalculateNoOfEmptyLines', '', false, false)]
    local procedure OnBeforeCalculateNoOfEmptyLines(var GenJnlLine: Record "Gen. Journal Line"; var TempFAGLPostingBuffer: Record "FA G/L Posting Buffer" temporary)
    begin
        if (GenJnlLine."Source Type" = GenJnlLine."Source Type"::"Fixed Asset") and (GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::Depreciation) then
            GenJnlLine.SetSkipTaxCalulation(true);
    end;

    local procedure GetCustomerAccount(CustomerNo: Code[20]): Code[20]
    var
        Customer: Record Customer;
        CustomerPotingGroup: Record "Customer Posting Group";
    begin
        if Customer.Get(CustomerNo) then
            if CustomerPotingGroup.Get(Customer."Customer Posting Group") then
                exit(CustomerPotingGroup."Receivables Account");
    end;

    local procedure GetVendorAccount(VendorNo: Code[20]): Code[20]
    var
        Vendor: Record Vendor;
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        if Vendor.Get(VendorNo) then
            if VendorPostingGroup.Get(Vendor."Vendor Posting Group") then
                exit(VendorPostingGroup."Payables Account");
    end;

    local procedure TaxEngineCallingHandler(var GenJnlLine: Record "Gen. Journal Line"; var xGenJnlLine: Record "Gen. Journal Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CalculateTax.CallTaxEngineOnGenJnlLine(GenJnlLine, xGenJnlLine);
    end;
}
