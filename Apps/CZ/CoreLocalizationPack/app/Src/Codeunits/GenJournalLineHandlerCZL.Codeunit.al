// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Service.Document;

codeunit 11746 "Gen. Journal Line Handler CZL"
{
    Permissions = tabledata "VAT Entry" = d,
                  tabledata "G/L Entry - VAT Entry Link" = d;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Document Type', false, false)]
    local procedure UpdateBankInfoOnAfterGenJnlLineDocumentTypeValidate(var Rec: Record "Gen. Journal Line")
    begin
        Rec.Validate("Bank Account Code CZL", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Bill-to/Pay-to No.', false, false)]
    local procedure UpdateBankInfoOnAfterGenJnlLineBiilToPayToNoValidate(var Rec: Record "Gen. Journal Line")
    begin
        Rec.Validate("Bank Account Code CZL", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeValidateEvent', 'Account No.', false, false)]
    local procedure UpdateOriginalDocPartnerTypeOnBeforeGenJnlLineAccountNoValidate(var Rec: Record "Gen. Journal Line")
    begin
        Rec.Validate("Original Doc. Partner Type CZL", Rec."Original Doc. Partner Type CZL"::" ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeValidateEvent', 'Bal. Account No.', false, false)]
    local procedure UpdateOriginalDocPartnerTypeOnBeforeGenJnlLineBalAccountNoValidate(var Rec: Record "Gen. Journal Line")
    begin
        Rec.Validate("Original Doc. Partner Type CZL", Rec."Original Doc. Partner Type CZL"::" ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterSetUpNewLine', '', false, false)]
    local procedure UpdateVatDateOnAfterGenJnlLineSetUpNewLine(var GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."VAT Reporting Date" = 0D then
            GenJournalLine."VAT Reporting Date" := WorkDate();
        GenJournalLine."Original Doc. VAT Date CZL" := GenJournalLine."VAT Reporting Date";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterUpdateCountryCodeAndVATRegNo', '', false, false)]
    local procedure UpdateRegNoOnAfterUpdateCountryCodeAndVATRegNo(var GenJournalLine: Record "Gen. Journal Line")
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        BillPaySellBuyNo: Code[20];
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Bill-to/Sell-to VAT Calc." = GeneralLedgerSetup."Bill-to/Sell-to VAT Calc."::"Bill-to/Pay-to No." then
            BillPaySellBuyNo := GenJournalLine."Bill-to/Pay-to No.";
        if GeneralLedgerSetup."Bill-to/Sell-to VAT Calc." = GeneralLedgerSetup."Bill-to/Sell-to VAT Calc."::"Sell-to/Buy-from No." then
            BillPaySellBuyNo := GenJournalLine."Sell-to/Buy-from No.";

        if BillPaySellBuyNo = '' then begin
            GenJournalLine."Registration No. CZL" := '';
            exit;
        end;
        case true of
            (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) or (GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::Customer):
                begin
                    Customer.Get(BillPaySellBuyNo);
                    GenJournalLine."Registration No. CZL" := Customer.GetRegistrationNoTrimmedCZL();
                    GenJournalLine."Tax Registration No. CZL" := Customer."Tax Registration No. CZL";
                end;
            (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor) or (GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::Vendor):
                begin
                    Vendor.Get(BillPaySellBuyNo);
                    GenJournalLine."Registration No. CZL" := Vendor.GetRegistrationNoTrimmedCZL();
                    GenJournalLine."Tax Registration No. CZL" := Vendor."Tax Registration No. CZL";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromSalesHeader', '', false, false)]
    local procedure UpdateFieldsOnAfterCopyGenJnlLineFromSalesHeader(var GenJournalLine: Record "Gen. Journal Line"; SalesHeader: Record "Sales Header")
    begin
        GenJournalLine."VAT Reporting Date" := SalesHeader."VAT Reporting Date";
        GenJournalLine."Registration No. CZL" := SalesHeader.GetRegistrationNoTrimmedCZL();
        GenJournalLine."Tax Registration No. CZL" := SalesHeader."Tax Registration No. CZL";
        GenJournalLine."EU 3-Party Intermed. Role CZL" := SalesHeader."EU 3-Party Intermed. Role CZL";
        GenJournalLine."Original Doc. VAT Date CZL" := SalesHeader."Original Doc. VAT Date CZL";
        GenJournalLine."Additional Currency Factor CZL" := SalesHeader."Additional Currency Factor CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromPurchHeader', '', false, false)]
    local procedure UpdateFieldsOnAfterCopyGenJnlLineFromPurchHeader(var GenJournalLine: Record "Gen. Journal Line"; PurchaseHeader: Record "Purchase Header")
    begin
        GenJournalLine."VAT Reporting Date" := PurchaseHeader."VAT Reporting Date";
        GenJournalLine."Registration No. CZL" := PurchaseHeader."Registration No. CZL";
        GenJournalLine."Tax Registration No. CZL" := PurchaseHeader."Tax Registration No. CZL";
        GenJournalLine."EU 3-Party Intermed. Role CZL" := PurchaseHeader."EU 3-Party Intermed. Role CZL";
        GenJournalLine."Original Doc. VAT Date CZL" := PurchaseHeader."Original Doc. VAT Date CZL";
        GenJournalLine."Additional Currency Factor CZL" := PurchaseHeader."Additional Currency Factor CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterCopyToGenJnlLine', '', false, false)]
    local procedure UpdateVatDateOnAfterCopyToGenJnlLineFromServiceHeader(var GenJournalLine: Record "Gen. Journal Line"; ServiceHeader: Record "Service Header")
    begin
        GenJournalLine."VAT Reporting Date" := ServiceHeader."VAT Reporting Date";
        GenJournalLine."Registration No. CZL" := ServiceHeader."Registration No. CZL";
        GenJournalLine."Tax Registration No. CZL" := ServiceHeader."Tax Registration No. CZL";
        GenJournalLine."EU 3-Party Intermed. Role CZL" := ServiceHeader."EU 3-Party Intermed. Role CZL";
        GenJournalLine."Posting Group" := ServiceHeader."Customer Posting Group";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnGetDocumentBalanceOnBeforeCalcBalance', '', false, false)]
    local procedure TestNotCheckDocTypeCZLOnGetDocumentBalanceOnBeforeCalcBalance(var GenJournalLine: Record "Gen. Journal Line"; GenJnlTemplate: Record "Gen. Journal Template")
    begin
        if GenJnlTemplate."Not Check Doc. Type CZL" then
            GenJournalLine.SetRange("Document Type");
    end;


    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromSalesHeaderPrepmt', '', false, false)]
    local procedure CopyVATDateOnAfterCopyGenJnlLineFromSalesHeaderPrepmt(SalesHeader: Record "Sales Header"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."VAT Reporting Date" := SalesHeader."VAT Reporting Date";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromSalesHeaderPrepmtPost', '', false, false)]
    local procedure CopyVATDateOnAfterCopyGenJnlLineFromSalesHeaderPrepmtPost(SalesHeader: Record "Sales Header"; var GenJournalLine: Record "Gen. Journal Line"; UsePmtDisc: Boolean)
    begin
        GenJournalLine."VAT Reporting Date" := SalesHeader."VAT Reporting Date";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromPurchHeaderPrepmt', '', false, false)]
    local procedure CopyVATDateOnAfterCopyGenJnlLineFromPurchHeaderPrepmt(PurchaseHeader: Record "Purchase Header"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."VAT Reporting Date" := PurchaseHeader."VAT Reporting Date";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromPurchHeaderPrepmtPost', '', false, false)]
    local procedure CopyVATDateOnAfterCopyGenJnlLineFromPurchHeaderPrepmtPost(PurchaseHeader: Record "Purchase Header"; var GenJournalLine: Record "Gen. Journal Line"; UsePmtDisc: Boolean)
    begin
        GenJournalLine."VAT Reporting Date" := PurchaseHeader."VAT Reporting Date";
    end;

}