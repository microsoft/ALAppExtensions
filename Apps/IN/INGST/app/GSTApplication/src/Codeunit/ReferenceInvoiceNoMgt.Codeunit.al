// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Application;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.FixedAssets.Journal;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;
using Microsoft.Sales.Receivables;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using Microsoft.Service.Posting;

codeunit 18435 "Reference Invoice No. Mgt."
{
    var
        RefGenJournalLine: Record "Gen. Journal Line";
        ReferenceNoMsg: Label 'Reference Invoice No is required where Invoice Type is Debit Note and Supplementary.';
        ReferenceNoErr: Label 'Selected Document No does not exist for Reference Invoice No.';
        ReferenceInvoiceNoErr: Label 'You cannot select Non GST Document on a GST Document.';
        ReferenceNoNonGSTErr: Label 'You cannot select Non GST - Invoice in Reference Invoice No.';
        RefNoAlterErr: Label 'Reference Invoice No cannot be updated after verification.';
        ReferenceVerifyErr: Label 'Reference Invoice No cannot be update after Verification.';
        VendInvNoErr: Label 'The field Reference Invoice No. of table %1 contains a value that cannot be found in the related table Vendor Ledger Entry.', Comment = '%1 = Document No.';
        CustInvNoErr: Label 'The field Reference Invoice No. of table %1 contains a value that cannot be found in the related table Cust. Ledger Entry.', Comment = '%1 = Document No.';
        SameDocErr: Label 'You cannot apply same document.';
        RCMValueCheckErr: Label 'You cannot select RCM and Non - RCM Invoice together.';
        DocumentTypeErr: Label 'You cannot select Credit Memo/Payment for Reference Invoice.';
        ReferenceInvoiceErr: Label 'Reference Invoice No is not require updation for Non-GST Document.';
        DiffVendNoErr: Label 'You cannot select Reference Invoice No. from different vendors.';
        DiffCustNoErr: Label 'You cannot select Reference Invoice No. from different customers.';
        DiffStateCodeErr: Label 'State code  must be same in both the Document.';
        DiffGSTRegNoErr: Label 'GST Registration No. must be same in both the Documents of %1 for %2.', Comment = '%1 = Field Name, %2 = Posted Document No. / Reference Invoice No.';
        DiffJurisdictionErr: Label '%1  must be same in both the Documents.', Comment = '%1 = Field Name';
        DiffCurrencyCodeErr: Label '%1 must be same in both the documents.', Comment = '%1 = Field Name';
        PurchaseDocumentErr: Label 'Invoice posted from Purchase Document is applicable for application.';
        SalesDocumentErr: Label 'Invoice posted from Sales Document is applicable for application.';
        PostingDateErr: Label 'Posted Invoice No. %1 Posting Date must be earlier than Document No. %2.', Comment = '%1 = Document No., %2 = Document No.';
        DiffGSTWithoutPaymentOfDutyErr: Label 'GST Without Payment of Duty must be same in both the Documents.';
        DateErr: Label '%1 and %2 cannot be blank in GST Accounting Period.', Comment = '%1 = Credit Memo Locking Date, %2 = Annual Return Filed Date';
        EqualDateLockErr: Label 'Document No. %1 cannot be posted as Posting Date must be earlier than %2 & %3 %4.', Comment = '%1 =Document No., %2 = Field Name, %3 = Field Name, %4 = Date';
        DateLockErr: Label 'Document No. %1 cannot be posted as Posting Date must be earlier than %2 %3.', Comment = '%1 =Document No., %2 = Field Name, %3 = Date';
        UpdateGSTNosErr: Label 'Please Update GST Registration No. for Document No. %1 through batch first, then proceed for application.', Comment = '%1 = Document No';
        OneDocumentErr: Label 'You cannot apply more than 1 Document to %1 %2.', Comment = '%1 = Document Type,%2 = Document No.';
        DiffLocationGSTRegErr: Label 'Location GST Reg. No. must be same in both the Documents.';
        InvoiceNoBlankErr: Label 'Credit Memo No. %1 has already been applied against Invoice No. %2.', Comment = '%1 =Document No., %2 = Invoice No.';
        CompGSTRegNoARNNoErr: Label 'Company Information must have either GST Registration No. or ARN No.';
        ReferenceInvNoPurchErr: Label 'Reference Invoice No. must have a value in Purchase Header: Document Type = %1, No = %2. It cannot be zero or empty.', Comment = '%1 = Document Type,%2 = Document No.';
        ReferenceInvNoSalesErr: Label 'Reference Invoice No. must have a value in Sales Header: Document Type = %1, No = %2. It cannot be zero or empty.', Comment = '%1 = Document Type,%2 = Document No.';
        ReferenceNoJnlErr: Label 'Reference Invoice No. must have a value  in Journal: Document Type = %1, No = %2. It cannot be zero or empty.', Comment = '%1 = Document Type and %2 = Document No';
        ReferenceInvNoServiceErr: Label 'Reference Invoice No. must have a value in Service Header: Document Type = %1, No = %2. It cannot be zero or empty.', Comment = '%1 = Document Type,%2 = Document No.';

    procedure VerifyReferenceNo(var RefInvNo: Record "Reference Invoice No.")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        FirstRecord: Boolean;
        RCMValue: Boolean;
        GSTDocumentType: Enum "GST Document Type";
    begin
        ReferenceInvoiceNo.SetRange("Document No.", RefInvNo."Document No.");
        ReferenceInvoiceNo.SetRange("Document Type", RefInvNo."Document Type");
        ReferenceInvoiceNo.SetRange("Source No.", RefInvNo."Source No.");
        if ReferenceInvoiceNo.FindSet() then
            repeat
                if RefInvNo."Document No." = RefInvNo."Reference Invoice Nos." then
                    Error(SameDocErr);

                if RefInvNo."Source Type" = RefInvNo."Source Type"::Vendor then begin
                    VendorLedgerEntry.SetCurrentKey("Document No.", "Vendor No.", "Entry No.");
                    VendorLedgerEntry.SetRange("Vendor No.", RefInvNo."Source No.");
                    VendorLedgerEntry.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
                    if VendorLedgerEntry.FindFirst() then begin
                        if not FirstRecord then begin
                            RCMValue := VendorLedgerEntry."RCM Exempt";
                            FirstRecord := true;
                        end else
                            if RCMValue <> VendorLedgerEntry."RCM Exempt" then
                                Error(RCMValueCheckErr);

                        DetailedGSTLedgerEntry.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
                        GSTDocumentType := GenJnlDocumentType2GSTDocumentType(VendorLedgerEntry."Document Type");
                        DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocumentType);
                        DetailedGSTLedgerEntry.SetRange("Source No.", RefInvNo."Source No.");
                        if not DetailedGSTLedgerEntry.IsEmpty() then begin
                            if not ReferenceInvoiceNo.Verified then
                                ReferenceInvoiceNo.Verified := true;

                            ReferenceInvoiceNo.Modify();
                        end else
                            Error(ReferenceInvoiceErr);
                    end else
                        Error(ReferenceNoErr);
                end;

                if RefInvNo."Source Type" = RefInvNo."Source Type"::Customer then begin
                    CustLedgerEntry.SetCurrentKey("Document No.", "Customer No.", "Entry No.");
                    CustLedgerEntry.SetRange("Customer No.", RefInvNo."Source No.");
                    CustLedgerEntry.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
                    if CustLedgerEntry.FindFirst() then begin
                        DetailedGSTLedgerEntry.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
                        GSTDocumentType := GenJnlDocumentType2GSTDocumentType(CustLedgerEntry."Document Type");
                        DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocumentType);
                        DetailedGSTLedgerEntry.SetRange("Source No.", RefInvNo."Source No.");
                        if not DetailedGSTLedgerEntry.IsEmpty() then begin
                            if not ReferenceInvoiceNo.Verified then
                                ReferenceInvoiceNo.Verified := true;

                            ReferenceInvoiceNo.Modify();
                        end else
                            Error(ReferenceInvoiceErr);
                    end else
                        Error(ReferenceNoErr);
                end;
            until ReferenceInvoiceNo.Next() = 0;
    end;

    procedure UpdateReferenceInvoiceNoforVendor(
        var ReferenceInvoiceNo: Record "Reference Invoice No.";
        DocumentType: Enum "Purchase Document Type";
        DocumentNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        VendorLedgerEntries: Page "Vendor Ledger Entries";
        GSTDocumentType: Enum "GST Document Type";
        SalesDoctype: Enum "Sales Document Type";
    begin
        PurchaseHeader.SetRange("Document Type", DocumentType);
        PurchaseHeader.SetRange("No.", DocumentNo);
        if PurchaseHeader.FindFirst() then begin
            if not IsGSTApplicable("Transaction Type Enum"::Purchase, PurchaseHeader."Document Type", SalesDoctype, PurchaseHeader."No.") then
                Error(ReferenceInvoiceNoErr);

            VendorLedgerEntry.SetCurrentKey("Document No.", "Document Type", "Vendor No.");
            VendorLedgerEntry.SetRange("Vendor No.", PurchaseHeader."Pay-to Vendor No.");
            VendorLedgerEntry.SetRange("Document Type", PurchaseHeader."Document Type"::Invoice);
            if VendorLedgerEntry.FindFirst() then begin
                VendorLedgerEntries.SetTableView(VendorLedgerEntry);
                VendorLedgerEntries.SetRecord(VendorLedgerEntry);
                VendorLedgerEntries.LookupMode(true);
                if VendorLedgerEntries.RunModal() = Action::LookupOK then begin
                    VendorLedgerEntries.GetRecord(VendorLedgerEntry);
                    if not (VendorLedgerEntry."Document Type" = VendorLedgerEntry."Document Type"::Invoice) then
                        Error(DocumentTypeErr);

                    GSTDocumentType := GenJnlDocumentType2GSTDocumentType(VendorLedgerEntry."Document Type");
                    DetailedGSTLedgerEntry.SetRange("Document No.", VendorLedgerEntry."Document No.");
                    DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocumentType);
                    if not DetailedGSTLedgerEntry.IsEmpty() then begin
                        if (PurchaseHeader."Invoice Type" in [
                                PurchaseHeader."Invoice Type"::"Debit Note",
                                PurchaseHeader."Invoice Type"::Supplementary]) or
                            (PurchaseHeader."Document Type" in [
                                PurchaseHeader."Document Type"::"Credit Memo",
                                PurchaseHeader."Document Type"::"Return Order"])
                        then
                            ReferenceInvoiceNo."Reference Invoice Nos." := VendorLedgerEntry."Document No."
                        else
                            Error(ReferenceNoMsg);

                        if PurchaseHeader."Pay-to Vendor No." <> VendorLedgerEntry."Vendor No." then
                            Error(DiffVendNoErr);
                    end else
                        Error(ReferenceInvoiceErr);
                end;

                CheckGSTPurchCrMemoValidationReference(PurchaseHeader, ReferenceInvoiceNo."Reference Invoice Nos.");
            end;

            PurchaseHeader."RCM Exempt" := CheckRCMExemptDate(PurchaseHeader);
        end else
            UpdateReferenceInvoiceforVendorLedgerEntries(ReferenceInvoiceNo);
    end;

    procedure UpdateReferenceInvoiceNoforCustomer(
        var ReferenceInvoiceNo: Record "Reference Invoice No.";
        DocumentType: Enum "Sales Document Type";
        DocumentNo: Code[20])
    var
        IsFoundSales: Boolean;
        IsFoundService: Boolean;
    begin
        IsFoundSales := UpdateReferenceInvoiceNoforCustomerSales(ReferenceInvoiceNo, DocumentType, DocumentNo);
        IsFoundService := UpdateReferenceInvoiceNoforCustomerService(ReferenceInvoiceNo, DocumentType, DocumentNo);

        if (not IsFoundSales) and (not IsFoundService) then
            UpdateReferenceInvoiceforCustomerLedgerEntries(ReferenceInvoiceNo);
    end;

    procedure UpdateReferenceInvoiceNoforCustomerSales(
        var ReferenceInvoiceNo: Record "Reference Invoice No.";
        DocumentType: Enum "Sales Document Type";
        DocumentNo: Code[20]): Boolean
    var
        SalesHeader: Record "Sales Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        CustomerLedgerEntries: Page "Customer Ledger Entries";
        GSTDocumentType: Enum "GST Document Type";
        PurchDocType: Enum "Purchase Document Type";
    begin
        SalesHeader.SetRange("Document Type", DocumentType);
        SalesHeader.SetRange("No.", DocumentNo);
        if not SalesHeader.FindFirst() then
            exit(false);

        if not IsGSTApplicable("Transaction Type Enum"::Sales, PurchDocType, SalesHeader."Document Type", SalesHeader."No.") then
            Error(ReferenceInvoiceNoErr);

        CustLedgerEntry.SetCurrentKey("Document No.", "Document Type", "Customer No.");
        CustLedgerEntry.SetRange("Customer No.", SalesHeader."Bill-to Customer No.");
        CustLedgerEntry.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        if CustLedgerEntry.FindFirst() then begin
            CustomerLedgerEntries.SetTableView(CustLedgerEntry);
            CustomerLedgerEntries.SetRecord(CustLedgerEntry);
            CustomerLedgerEntries.LookupMode(true);
            if CustomerLedgerEntries.RunModal() = Action::LookupOK then begin
                CustomerLedgerEntries.GetRecord(CustLedgerEntry);
                if not (CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Invoice) then
                    Error(DocumentTypeErr);

                GSTDocumentType := GenJnlDocumentType2GSTDocumentType(CustLedgerEntry."Document Type");
                DetailedGSTLedgerEntry.SetRange("Document No.", CustLedgerEntry."Document No.");
                DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocumentType);
                if not DetailedGSTLedgerEntry.IsEmpty() then begin
                    if (SalesHeader."Invoice Type" in [
                            SalesHeader."Invoice Type"::"Debit Note",
                            SalesHeader."Invoice Type"::Supplementary]) or
                        (SalesHeader."Document Type" in [
                            SalesHeader."Document Type"::"Credit Memo",
                            SalesHeader."Document Type"::"Return Order"])
                    then
                        ReferenceInvoiceNo."Reference Invoice Nos." := CustLedgerEntry."Document No."
                    else
                        Error(ReferenceNoMsg);

                    if SalesHeader."Bill-to Customer No." <> CustLedgerEntry."Customer No." then
                        Error(DiffCustNoErr);
                end else
                    Error(ReferenceInvoiceErr);
            end;

            CheckGSTSalesCrMemoValidationReference(SalesHeader, ReferenceInvoiceNo."Reference Invoice Nos.");
        end;

        exit(true);
    end;

    procedure UpdateReferenceInvoiceNoforCustomerService(
        var ReferenceInvoiceNo: Record "Reference Invoice No.";
        DocumentType: Enum "Sales Document Type";
        DocumentNo: Code[20]): Boolean
    var
        ServiceHeader: Record "Service Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        CustomerLedgerEntries: Page "Customer Ledger Entries";
        GSTDocumentType: Enum "GST Document Type";
        PurchDocType: Enum "Purchase Document Type";
    begin
        ServiceHeader.SetRange("Document Type", DocumentType);
        ServiceHeader.SetRange("No.", DocumentNo);
        if not ServiceHeader.FindFirst() then
            exit(false);

        if not IsGSTApplicable("Transaction Type Enum"::Service, PurchDocType, ServiceHeader."Document Type", ServiceHeader."No.") then
            Error(ReferenceInvoiceNoErr);

        CustLedgerEntry.SetCurrentKey("Document No.", "Document Type", "Customer No.");
        CustLedgerEntry.SetRange("Customer No.", ServiceHeader."Customer No.");
        CustLedgerEntry.SetRange("Document Type", ServiceHeader."Document Type"::Invoice);
        if CustLedgerEntry.FindFirst() then begin
            CustomerLedgerEntries.SetTableView(CustLedgerEntry);
            CustomerLedgerEntries.SetRecord(CustLedgerEntry);
            CustomerLedgerEntries.LookUpMode(true);
            if CustomerLedgerEntries.RunModal() = Action::LookupOK then begin
                CustomerLedgerEntries.GetRecord(CustLedgerEntry);
                if not (CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Invoice) then
                    Error(DocumentTypeErr);

                GSTDocumentType := GenJnlDocumentType2GSTDocumentType(CustLedgerEntry."Document Type");
                DetailedGSTLedgerEntry.SetRange("Document No.", CustLedgerEntry."Document No.");
                DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocumentType);
                if not DetailedGSTLedgerEntry.IsEmpty() then begin
                    if (ServiceHeader."Invoice Type" in [
                        ServiceHeader."Invoice Type"::"Debit note",
                        ServiceHeader."Invoice Type"::Supplementary]) or
                        (ServiceHeader."Document Type" in [ServiceHeader."Document Type"::"Credit Memo"])
                    then
                        ReferenceInvoiceNo."Reference Invoice Nos." := CustLedgerEntry."Document No."
                    else
                        Message(ReferenceNoMsg);

                    if ServiceHeader."Bill-to Customer No." <> CustLedgerEntry."Customer No." then
                        Error(DiffCustNoErr);
                end else
                    Error(ReferenceInvoiceErr);
            end;
            CheckGSTServiceCrMemoValidationReference(ServiceHeader, ReferenceInvoiceNo."Reference Invoice Nos.");
        end;

        exit(true);
    end;

    procedure UpdateReferenceInvoiceforCustomerLedgerEntries(var ReferenceInvoiceNo: Record "Reference Invoice No.")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntryToCheck: Record "Cust. Ledger Entry";
        CustLedgerEntryCopy: Record "Cust. Ledger Entry";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        CustomerLedgerEntries: Page "Customer Ledger Entries";
    begin
        CustLedgerEntry.SetRange("Customer No.", ReferenceInvoiceNo."Source No.");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        if CustLedgerEntry.FindFirst() then begin
            Clear(CustomerLedgerEntries);
            CustomerLedgerEntries.SetTableView(CustLedgerEntry);
            CustomerLedgerEntries.SetRecord(CustLedgerEntry);
            CustomerLedgerEntries.LookupMode(true);
            if CustomerLedgerEntries.RunModal() = Action::LookupOK then begin
                CustomerLedgerEntries.GetRecord(CustLedgerEntry);
                DetailedGSTLedgerEntry.SetRange("Document No.", CustLedgerEntry."Document No.");
                DetailedGSTLedgerEntry.SetRange("Source No.", CustLedgerEntry."Customer No.");
                if DetailedGSTLedgerEntry.FindFirst() then begin
                    if (DetailedGSTLedgerEntry."Document Type" = DetailedGSTLedgerEntry."Document Type"::Invoice) or
                       (DetailedGSTLedgerEntry."Document Type" = DetailedGSTLedgerEntry."Document Type"::"Credit Memo")
                    then
                        ReferenceInvoiceNo."Reference Invoice Nos." := CustLedgerEntry."Document No.";

                    CustLedgerEntryToCheck.SetRange("Document No.", ReferenceInvoiceNo."Document No.");
                    if CustLedgerEntryToCheck.FindFirst() then
                        CustLedgerEntryCopy.Copy(CustLedgerEntryToCheck);

                    CheckGSTSalesCrMemoValidationsOffline(
                      CustLedgerEntryCopy,
                      CustLedgerEntry,
                      0,
                      ReferenceInvoiceNo."Reference Invoice Nos.");

                    if CustLedgerEntryToCheck."Customer No." <> DetailedGSTLedgerEntry."Source No." then
                        Error(DiffCustNoErr);
                end else
                    Error(ReferenceNoNonGSTErr)
            end;
        end;
    end;

    procedure VerifyReferenceNoJournals(var RefInvNo: Record "Reference Invoice No.")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        FirstRecord: Boolean;
        RCMValue: Boolean;
        GSTDocumentType: Enum "GST Document Type";
    begin
        ReferenceInvoiceNo.SetRange("Document No.", RefInvNo."Document No.");
        ReferenceInvoiceNo.SetRange("Document Type", RefInvNo."Document Type");
        ReferenceInvoiceNo.SetRange("Source No.", RefInvNo."Source No.");
        ReferenceInvoiceNo.SetRange("Journal Template Name", RefInvNo."Journal Template Name");
        ReferenceInvoiceNo.SetRange("Journal Batch Name", RefInvNo."Journal Batch Name");
        if ReferenceInvoiceNo.FindSet() then
            repeat
                if RefInvNo."Source Type" = RefInvNo."Source Type"::Vendor then begin
                    VendorLedgerEntry.SetCurrentKey("Document No.", "Document Type", "Vendor No.");
                    VendorLedgerEntry.SetRange("Vendor No.", RefInvNo."Source No.");
                    VendorLedgerEntry.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
                    if VendorLedgerEntry.FindFirst() then begin
                        if not FirstRecord then begin
                            RCMValue := VendorLedgerEntry."RCM Exempt";
                            FirstRecord := true;
                        end else
                            if RCMValue <> VendorLedgerEntry."RCM Exempt" then
                                Error(RCMValueCheckErr);

                        GSTDocumentType := GenJnlDocumentType2GSTDocumentType(VendorLedgerEntry."Document Type");
                        DetailedGSTLedgerEntry.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
                        DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocumentType);
                        DetailedGSTLedgerEntry.SetRange("Source No.", RefInvNo."Source No.");
                        if not DetailedGSTLedgerEntry.IsEmpty() then begin
                            if not ReferenceInvoiceNo.Verified then
                                ReferenceInvoiceNo.Verified := true;

                            ReferenceInvoiceNo."Source Type" := ReferenceInvoiceNo."Source Type"::Vendor;
                            ReferenceInvoiceNo.Modify();
                        end else
                            Error(ReferenceInvoiceErr);
                    end else
                        Error(ReferenceNoErr);
                end;

                if RefInvNo."Source Type" = "Source Type"::Customer then begin
                    CustLedgerEntry.SetCurrentKey("Document No.", "Document Type", "Customer No.");
                    CustLedgerEntry.SetRange("Customer No.", RefInvNo."Source No.");
                    CustLedgerEntry.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
                    if CustLedgerEntry.FindFirst() then begin
                        GSTDocumentType := GenJnlDocumentType2GSTDocumentType(CustLedgerEntry."Document Type");

                        DetailedGSTLedgerEntry.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
                        DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocumentType);
                        DetailedGSTLedgerEntry.SetRange("Source No.", RefInvNo."Source No.");
                        if not DetailedGSTLedgerEntry.IsEmpty() then begin
                            if not ReferenceInvoiceNo.Verified then
                                ReferenceInvoiceNo.Verified := true;

                            ReferenceInvoiceNo."Source Type" := ReferenceInvoiceNo."Source Type"::Customer;
                            ReferenceInvoiceNo.Modify();
                        end else
                            Error(ReferenceInvoiceErr);
                    end else
                        Error(ReferenceNoErr);
                end;
            until ReferenceInvoiceNo.Next() = 0
    end;

    procedure UpdateReferenceInvoiceNoforPurchJournals(
        var RefInvNo: Record "Reference Invoice No.";
        DocumentType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
        JournalTemplateName: Code[10];
        JournalBatchName: Code[10])
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        GenJnLine: Record "Gen. Journal Line";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        VendorLedgerEntries: Page "Vendor Ledger Entries";
        GSTDocumentType: Enum "GST Document Type";
    begin
        GenJnLine.SetRange("Journal Template Name", JournalTemplateName);
        GenJnLine.SetRange("Journal Batch Name", JournalBatchName);
        GenJnLine.SetRange("Document Type", DocumentType);
        GenJnLine.SetRange("Document No.", DocumentNo);
        GenJnLine.SetRange("Account Type", GenJnLine."Account Type"::Vendor);
        if GenJnLine.FindFirst() then begin
            VendorLedgerEntry.SetCurrentKey("Document No.", "Document Type", "Vendor No.");
            VendorLedgerEntry.SetRange("Vendor No.", GenJnLine."Account No.");
            VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
            if VendorLedgerEntry.FindFirst() then begin
                VendorLedgerEntries.SetTableView(VendorLedgerEntry);
                VendorLedgerEntries.SetRecord(VendorLedgerEntry);
                VendorLedgerEntries.LookupMode(true);
                if VendorLedgerEntries.RunModal() = Action::LookupOK then begin
                    VendorLedgerEntries.GetRecord(VendorLedgerEntry);
                    if not (VendorLedgerEntry."Document Type" = VendorLedgerEntry."Document Type"::Invoice) then
                        Error(DocumentTypeErr);

                    GSTDocumentType := GenJnlDocumentType2GSTDocumentType(VendorLedgerEntry."Document Type");

                    DetailedGSTLedgerEntry.SetRange("Document No.", VendorLedgerEntry."Document No.");
                    DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocumentType);
                    if not DetailedGSTLedgerEntry.IsEmpty() then begin
                        if (GenJnLine."Purch. Invoice Type" in [
                            GenJnLine."Purch. Invoice Type"::"Debit Note",
                            GenJnLine."Purch. Invoice Type"::Supplementary]) or
                           (GenJnLine."Document Type" = GenJnLine."Document Type"::"Credit Memo")
                        then
                            RefInvNo."Reference Invoice Nos." := VendorLedgerEntry."Document No."
                        else
                            Error(ReferenceNoMsg);

                        if GenJnLine."Account No." <> VendorLedgerEntry."Vendor No." then
                            Error(DiffVendNoErr);
                    end else
                        Error(ReferenceInvoiceErr);
                end;

                CheckGSTPurchCrMemoValidationsJournalReference(GenJnLine, RefInvNo."Reference Invoice Nos.");
            end else
                Error(ReferenceInvoiceNoErr);
        end else
            UpdateReferenceInvoiceforVendorLedgerEntries(RefInvNo);
    end;

    procedure UpdateReferenceInvoiceNoforSalesJournals(
        var RefInvNo: Record "Reference Invoice No.";
        DocumentType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
        JournalTemplateName: Code[10];
        JournalBatchName: Code[10])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GenJnlLine: Record "Gen. Journal Line";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        CustomerLedgerEntries: Page "Customer Ledger Entries";
        GSTDocumentType: Enum "GST Document Type";
    begin
        GenJnlLine.SetRange("Journal Template Name", JournalTemplateName);
        GenJnlLine.SetRange("Journal Batch Name", JournalBatchName);
        GenJnlLine.SetRange("Document Type", DocumentType);
        GenJnlLine.SetRange("Document No.", DocumentNo);
        GenJnlLine.SetRange("Account Type", GenJnlLine."Account Type"::Customer);
        if GenJnlLine.FindFirst() then begin
            CustLedgerEntry.SetCurrentKey("Document No.", "Document Type", "Customer No.");
            CustLedgerEntry.SetRange("Customer No.", GenJnlLine."Account No.");
            CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
            if CustLedgerEntry.FindFirst() then begin
                CustomerLedgerEntries.SetTableView(CustLedgerEntry);
                CustomerLedgerEntries.SetRecord(CustLedgerEntry);
                CustomerLedgerEntries.LookupMode(true);
                if CustomerLedgerEntries.RunModal() = Action::LookupOK then begin
                    CustomerLedgerEntries.GetRecord(CustLedgerEntry);
                    if not (CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Invoice) then
                        Error(DocumentTypeErr);

                    GSTDocumentType := GenJnlDocumentType2GSTDocumentType(CustLedgerEntry."Document Type");

                    DetailedGSTLedgerEntry.SetRange("Document No.", CustLedgerEntry."Document No.");
                    DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocumentType);
                    if not DetailedGSTLedgerEntry.IsEmpty() then begin
                        if (GenJnlLine."Sales Invoice Type" in [
                            GenJnlLine."Sales Invoice Type"::"Debit Note",
                            GenJnlLine."Sales Invoice Type"::Supplementary]) or
                           (GenJnlLine."Document Type" = GenJnlLine."Document Type"::"Credit Memo")
                        then
                            RefInvNo."Reference Invoice Nos." := CustLedgerEntry."Document No."
                        else
                            Error(ReferenceNoMsg);

                        if GenJnlLine."Account No." <> CustLedgerEntry."Customer No." then
                            Error(DiffCustNoErr);
                    end else
                        Error(ReferenceInvoiceErr);
                end;

                CheckGSTSalesCrMemoJournalValidationReference(GenJnlLine, RefInvNo."Reference Invoice Nos.");
            end else
                Error(ReferenceInvoiceNoErr);
        end else
            UpdateReferenceInvoiceforCustomerLedgerEntries(RefInvNo);
    end;

    procedure CheckGSTPurchCrMemoValidationReference(PurchaseHeader: Record "Purchase Header"; ReferenceInvoiceNo: Code[20])
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchaseLine: Record "Purchase Line";
        CurrStateCode: Code[10];
        PostedStateCode: Code[10];
        CurrDocumentGSTRegNo: Code[20];
        PostedDocumentGSTRegNo: Code[20];
        CurrDocLocRegNo: Code[20];
        PostedDocLocRegNo: Code[20];
        CurrDocGSTJurisdiction: Enum "GST Jurisdiction Type";
        PostedDocGSTJurisdiction: Enum "GST Jurisdiction Type";
        PostedCurrencyCode: Code[10];
        IsDummy: Boolean;
        PurchDocType: Enum "Purchase Document Type";
        SalesDocType: Enum "Sales Document Type";
    begin
        if IsGSTApplicable("Transaction Type Enum"::Purchase, PurchaseHeader."Document Type", SalesDocType, PurchaseHeader."No.") then begin
            if not (PurchaseHeader."Document Type" in [
                PurchaseHeader."Document Type"::Invoice,
                PurchaseHeader."Document Type"::"Return Order",
                PurchaseHeader."Document Type"::"Credit Memo",
                PurchaseHeader."Document Type"::Order])
            then
                exit;

            if (ReferenceInvoiceNo <> '') and
               (PurchInvHeader.Get(ReferenceInvoiceNo) and
               IsGSTApplicable("Transaction Type Enum"::Purchase, PurchDocType, SalesDocType, PurchInvHeader."No."))
            then begin
                CheckGSTAppliedDocument(
                    "Transaction Type Enum"::Purchase,
                    PurchaseHeader."Document Type",
                    SalesDocType,
                    PurchaseHeader."No.",
                    ReferenceInvoiceNo,
                    IsDummy,
                    '',
                    '',
                    0);

                CurrStateCode := GetStateCode(
                    "Transaction Type Enum"::Purchase,
                    PurchaseHeader."Document Type",
                    PurchaseHeader."No.",
                    true);

                PostedStateCode := GetStateCode(
                    "Transaction Type Enum"::Purchase,
                    PurchaseHeader."Document Type"::Invoice,
                    ReferenceInvoiceNo,
                    false);

                CurrDocumentGSTRegNo := GetPlaceOfSupplyRegistrationNo(
                    "Transaction Type Enum"::Purchase,
                    PurchaseHeader."Document Type",
                    SalesDocType,
                    PurchaseHeader."No.",
                    true,
                    IsDummy);

                PostedDocumentGSTRegNo := GetPlaceOfSupplyRegistrationNo(
                    "Transaction Type Enum"::Purchase,
                    PurchaseHeader."Document Type"::Invoice,
                    SalesDocType,
                    ReferenceInvoiceNo,
                    false,
                    IsDummy);

                CurrDocLocRegNo := GetLocationRegistrationNo(
                    "Transaction Type Enum"::Purchase,
                    PurchaseHeader."Document Type",
                    SalesDocType,
                    PurchaseHeader."No.",
                    true,
                    IsDummy);

                PostedDocLocRegNo := GetLocationRegistrationNo(
                    "Transaction Type Enum"::Purchase,
                    PurchaseHeader."Document Type",
                    SalesDocType,
                    ReferenceInvoiceNo,
                    false,
                    IsDummy);

                CurrDocGSTJurisdiction := GetGSTJurisdiction(
                    "Transaction Type Enum"::Purchase,
                    PurchaseHeader."Document Type",
                    SalesDocType,
                    PurchaseHeader."No.",
                    true,
                    IsDummy);

                PostedDocGSTJurisdiction := GetGSTJurisdiction(
                    "Transaction Type Enum"::Purchase,
                    PurchaseHeader."Document Type"::Invoice,
                    SalesDocType,
                    ReferenceInvoiceNo,
                    false,
                    IsDummy);

                PostedCurrencyCode := GetCurrencyCode(
                    "Transaction Type Enum"::Purchase,
                    PurchaseHeader."Document Type"::Invoice,
                    ReferenceInvoiceNo,
                    PurchaseHeader."Buy-from Vendor No.");

                if CurrStateCode <> PostedStateCode then
                    Error(DiffStateCodeErr);

                if CurrDocumentGSTRegNo <> PostedDocumentGSTRegNo then begin
                    if PurchaseHeader."Order Address Code" <> '' then
                        Error(DiffGSTRegNoErr, PurchaseHeader.FieldCaption("Order Address GST Reg. No."), ReferenceInvoiceNo);

                    Error(DiffGSTRegNoErr, PurchaseHeader.FieldCaption("Vendor GST Reg. No."), ReferenceInvoiceNo);
                end;

                if CurrDocLocRegNo <> PostedDocLocRegNo then
                    Error(DiffGSTRegNoErr, PurchaseLine.FieldCaption("Location Code"), ReferenceInvoiceNo);

                if CurrDocGSTJurisdiction <> PostedDocGSTJurisdiction then
                    Error(DiffJurisdictionErr, PurchaseLine.FieldCaption("GST Jurisdiction Type"));

                if PurchaseHeader."Currency Code" <> PostedCurrencyCode then
                    Error(DiffCurrencyCodeErr, PurchaseLine.FieldCaption("Currency Code"));
            end;

            CheckGSTPurchCrMemoValidationInJournals(PurchaseHeader, ReferenceInvoiceNo);
        end;
    end;

    procedure CheckGSTPurchCrMemoValidationInJournals(PurchaseHeader: Record "Purchase Header"; ReferenceInvoiceNo: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
        CurrStateCode: Code[10];
        PostedStateCode: Code[10];
        CurrDocumentGSTRegNo: Code[20];
        PostedDocumentGSTRegNo: Code[20];
        CurrDocLocRegNo: Code[20];
        PostedDocLocRegNo: Code[20];
        CurrDocGSTJurisdiction: Enum "GST Jurisdiction Type";
        PostedDocGSTJurisdiction: Enum "GST Jurisdiction Type";
        PostedCurrencyCode: Code[10];
        InJournal: Boolean;
        IsDummy: Boolean;
        SalesDocType: Enum "Sales Document Type";
    begin
        InJournal := IsGSTFromJournal("Transaction Type Enum"::Purchase, ReferenceInvoiceNo, PurchaseHeader."Buy-from Vendor No.");
        if (ReferenceInvoiceNo <> '') and InJournal then begin
            CheckGSTAppliedDocumentPurchDocToJournals(ReferenceInvoiceNo, PurchaseHeader."No.", PurchaseHeader."Document Type"::Invoice);
            CurrStateCode := GetStateCode(
                "Transaction Type Enum"::Purchase,
                PurchaseHeader."Document Type",
                PurchaseHeader."No.",
                true);

            PostedStateCode := GetStateCode(
                "Transaction Type Enum"::Purchase,
                PurchaseHeader."Document Type"::Invoice,
                ReferenceInvoiceNo,
                false);

            CurrDocumentGSTRegNo := GetPlaceOfSupplyRegistrationNo(
                "Transaction Type Enum"::Purchase,
                PurchaseHeader."Document Type",
                SalesDocType,
                PurchaseHeader."No.",
                true,
                IsDummy);

            PostedDocumentGSTRegNo := GetPlaceOfSupplyRegistrationNoDocToJournals(
                "Transaction Type Enum"::Purchase,
                PurchaseHeader."Document Type"::Invoice,
                SalesDocType,
                ReferenceInvoiceNo,
                false,
                IsDummy);

            CurrDocLocRegNo := GetLocationRegistrationNo(
                "Transaction Type Enum"::Purchase,
                PurchaseHeader."Document Type",
                SalesDocType,
                PurchaseHeader."No.",
                true,
                IsDummy);

            PostedDocLocRegNo := GetLocationRegistrationNoDocToJournals(
                "Transaction Type Enum"::Purchase,
                PurchaseHeader."Document Type",
                SalesDocType,
                ReferenceInvoiceNo,
                false,
                IsDummy);

            CurrDocGSTJurisdiction := GetGSTJurisdiction(
                "Transaction Type Enum"::Purchase,
                PurchaseHeader."Document Type",
                SalesDocType,
                PurchaseHeader."No.",
                true,
                IsDummy);

            PostedDocGSTJurisdiction := GetGSTJurisdictionDocToJournals(
                "Transaction Type Enum"::Purchase,
                PurchaseHeader."Document Type"::Invoice,
                SalesDocType,
                ReferenceInvoiceNo,
                false,
                IsDummy);

            PostedCurrencyCode := GetCurrencyCode(
                "Transaction Type Enum"::Purchase,
                PurchaseHeader."Document Type"::Invoice,
                ReferenceInvoiceNo,
                PurchaseHeader."Buy-from Vendor No.");

            if CurrStateCode <> PostedStateCode then
                Error(DiffStateCodeErr);

            if CurrDocumentGSTRegNo <> PostedDocumentGSTRegNo then begin
                if PurchaseHeader."Order Address Code" <> '' then
                    Error(DiffGSTRegNoErr, PurchaseHeader.FieldCaption("Order Address GST Reg. No."), ReferenceInvoiceNo);

                Error(DiffGSTRegNoErr, PurchaseHeader.FieldCaption("Vendor GST Reg. No."), ReferenceInvoiceNo);
            end;

            if CurrDocLocRegNo <> PostedDocLocRegNo then
                Error(DiffGSTRegNoErr, PurchaseLine.FieldCaption("Location Code"), ReferenceInvoiceNo);

            if CurrDocGSTJurisdiction <> PostedDocGSTJurisdiction then
                Error(DiffJurisdictionErr, PurchaseLine.FieldCaption("GST Jurisdiction Type"));

            if PurchaseHeader."Currency Code" <> PostedCurrencyCode then
                Error(DiffCurrencyCodeErr, PurchaseLine.FieldCaption("Currency Code"));
        end;
    end;

    procedure CheckGSTSalesCrMemoValidationReference(
        SalesHeader: Record "Sales Header";
        ReferenceInvoiceNo: Code[20])
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesLine: Record "Sales Line";
        CurrDocumentGSTRegNo: Code[20];
        PostedDocumentGSTRegNo: Code[20];
        CurrDocLocRegNo: Code[20];
        PostedDocLocRegNo: Code[20];
        CurrDocGSTJurisdiction: Enum "GST Jurisdiction Type";
        PostedDocGSTJurisdiction: Enum "GST Jurisdiction Type";
        PostedCurrencyCode: Code[10];
        IsDummy: Boolean;
        DocType: Enum "Document Type Enum";
        PurchDocType: Enum "Purchase Document Type";
        SalesDocType: Enum "Sales Document Type";
    begin
        if not (SalesHeader."Document Type" in [
            SalesHeader."Document Type"::"Return Order",
            SalesHeader."Document Type"::"Credit Memo",
            SalesHeader."Document Type"::Order,
            SalesHeader."Document Type"::Invoice])
        then
            exit;

        if IsGSTApplicable("Transaction Type Enum"::Sales, PurchDocType, SalesHeader."Document Type", SalesHeader."No.") and
            SalesInvoiceHeader.Get(ReferenceInvoiceNo) and
            (ReferenceInvoiceNo <> '') and
            IsGSTApplicable("Transaction Type Enum"::Sales, PurchDocType, SalesDocType, SalesInvoiceHeader."No.")
        then begin
            DocType := SalesDocumentType2DocumentTypeEnum(SalesHeader."Document Type");
            CheckGSTAppliedDocument(
                "Transaction Type Enum"::Sales,
                PurchDocType,
                SalesHeader."Document Type",
                SalesHeader."No.",
                ReferenceInvoiceNo,
                IsDummy, '', '', 0);

            CurrDocumentGSTRegNo := GetPlaceOfSupplyRegistrationNo(
                "Transaction Type Enum"::Sales,
                PurchDocType,
                SalesHeader."Document Type",
                SalesHeader."No.",
                true,
                IsDummy);

            PostedDocumentGSTRegNo := GetPlaceOfSupplyRegistrationNo(
                "Transaction Type Enum"::Sales,
                PurchDocType,
                SalesHeader."Document Type"::Invoice,
                ReferenceInvoiceNo,
                false,
                IsDummy);

            CurrDocLocRegNo := GetLocationRegistrationNo(
                "Transaction Type Enum"::Sales,
                PurchDocType,
                SalesHeader."Document Type",
                SalesHeader."No.",
                true,
                IsDummy);

            PostedDocLocRegNo := GetLocationRegistrationNo(
                "Transaction Type Enum"::Sales,
                PurchDocType,
                SalesHeader."Document Type",
                ReferenceInvoiceNo,
                false,
                IsDummy);

            CurrDocGSTJurisdiction := GetGSTJurisdiction(
                "Transaction Type Enum"::Sales,
                PurchDocType,
                SalesHeader."Document Type",
                SalesHeader."No.",
                true,
                IsDummy);

            PostedDocGSTJurisdiction := GetGSTJurisdiction(
                "Transaction Type Enum"::Sales,
                PurchDocType,
                SalesHeader."Document Type"::Invoice,
                ReferenceInvoiceNo,
                false,
                IsDummy);

            PostedCurrencyCode := GetCurrencyCode(
                "Transaction Type Enum"::Sales,
                "Gen. Journal Document Type"::Invoice,
                ReferenceInvoiceNo,
                SalesHeader."Sell-to Customer No.");

            if CurrDocumentGSTRegNo <> PostedDocumentGSTRegNo then
                Error(DiffGSTRegNoErr, SalesLine.FieldCaption("GST Place of Supply"), ReferenceInvoiceNo);

            if CurrDocLocRegNo <> PostedDocLocRegNo then
                Error(DiffGSTRegNoErr, SalesLine.FieldCaption("Location Code"), ReferenceInvoiceNo);

            if CurrDocGSTJurisdiction <> PostedDocGSTJurisdiction then
                Error(DiffJurisdictionErr, SalesLine.FieldCaption("GST Jurisdiction Type"));

            if PostedCurrencyCode <> SalesHeader."Currency Code" then
                Error(DiffCurrencyCodeErr, SalesLine.FieldCaption("Currency Code"));
        end;

        CheckGSTSalesCrMemoValidationInJournals(SalesHeader, ReferenceInvoiceNo);
    end;

    procedure CheckGSTSalesCrMemoValidationInJournals(SalesHeader: Record "Sales Header"; ReferenceInvoiceNo: Code[20])
    var
        SalesLine: Record "Sales Line";
        CurrDocumentGSTRegNo: Code[20];
        PostedDocumentGSTRegNo: Code[20];
        CurrDocLocRegNo: Code[20];
        PostedDocLocRegNo: Code[20];
        CurrDocGSTJurisdiction: Enum "GST Jurisdiction Type";
        PostedDocGSTJurisdiction: Enum "GST Jurisdiction Type";
        PostedCurrencyCode: Code[10];
        InJournal: Boolean;
        IsDummy: Boolean;
        PurchDocType: Enum "Purchase Document Type";
    begin
        InJournal := IsGSTFromJournal("Transaction Type Enum"::Sales, ReferenceInvoiceNo, SalesHeader."Sell-to Customer No.");

        if IsGSTApplicable("Transaction Type Enum"::Sales, PurchDocType, SalesHeader."Document Type", SalesHeader."No.") and
            (ReferenceInvoiceNo <> '') and
            InJournal
        then begin
            CheckGSTAppliedDocumentSalesDocToJournals(ReferenceInvoiceNo, SalesHeader."No.", SalesHeader."Document Type"::Invoice);

            CurrDocumentGSTRegNo := GetPlaceOfSupplyRegistrationNo(
                "Transaction Type Enum"::Sales,
                PurchDocType,
                SalesHeader."Document Type",
                SalesHeader."No.",
                true,
                IsDummy);

            PostedDocumentGSTRegNo := GetPlaceOfSupplyRegistrationNoDocToJournals(
                "Transaction Type Enum"::Sales,
                PurchDocType,
                SalesHeader."Document Type"::Invoice,
                ReferenceInvoiceNo,
                false,
                IsDummy);

            CurrDocLocRegNo := GetLocationRegistrationNo(
                "Transaction Type Enum"::Sales,
                PurchDocType,
                SalesHeader."Document Type",
                SalesHeader."No.",
                true,
                IsDummy);

            PostedDocLocRegNo := GetLocationRegistrationNoDocToJournals(
                "Transaction Type Enum"::Sales,
                PurchDocType,
                SalesHeader."Document Type",
                ReferenceInvoiceNo,
                false,
                IsDummy);

            CurrDocGSTJurisdiction := GetGSTJurisdiction(
                "Transaction Type Enum"::Sales,
                PurchDocType,
                SalesHeader."Document Type",
                SalesHeader."No.",
                true,
                IsDummy);

            PostedDocGSTJurisdiction := GetGSTJurisdictionDocToJournals(
                "Transaction Type Enum"::Sales,
                PurchDocType,
                SalesHeader."Document Type"::Invoice,
                ReferenceInvoiceNo,
                false,
                IsDummy);

            PostedCurrencyCode := GetCurrencyCode(
                "Transaction Type Enum"::Sales,
                "Gen. Journal Document Type"::Invoice,
                ReferenceInvoiceNo,
                SalesHeader."Sell-to Customer No.");

            if CurrDocumentGSTRegNo <> PostedDocumentGSTRegNo then
                Error(DiffGSTRegNoErr, SalesLine.FieldCaption("GST Place of Supply"), ReferenceInvoiceNo);

            if CurrDocLocRegNo <> PostedDocLocRegNo then
                Error(DiffGSTRegNoErr, SalesLine.FieldCaption("Location Code"), ReferenceInvoiceNo);

            if CurrDocGSTJurisdiction <> PostedDocGSTJurisdiction then
                Error(DiffJurisdictionErr, SalesLine.FieldCaption("GST Jurisdiction Type"));

            if PostedCurrencyCode <> SalesHeader."Currency Code" then
                Error(DiffCurrencyCodeErr, SalesLine.FieldCaption("Currency Code"));
        end;
    end;

    procedure CheckRCMExemptDate(var PurchaseHeader: Record "Purchase Header"): Boolean
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        GSTDocumentType: Enum "Document Type Enum";
    begin
        if PurchaseHeader."GST Vendor Type" <> PurchaseHeader."GST Vendor Type"::Unregistered then
            exit(false);

        if (PurchaseHeader."Document Type" in [
            PurchaseHeader."Document Type"::Order,
            PurchaseHeader."Document Type"::Invoice])
        then begin
            PurchaseHeader.TestField("Posting Date");

            PurchasesPayablesSetup.Get();
            PurchasesPayablesSetup.TestField("RCM Exempt Start Date (Unreg)");
            PurchasesPayablesSetup.TestField("RCM Exempt Start Date (Unreg)");
            if (PurchaseHeader."Posting Date" >= PurchasesPayablesSetup."RCM Exempt Start Date (Unreg)") and
               (PurchaseHeader."Posting Date" <= PurchasesPayablesSetup."RCM Exempt End Date (Unreg)")
            then
                exit(true);
        end else
            if (PurchaseHeader."Document Type" in [
                PurchaseHeader."Document Type"::"Credit Memo",
                PurchaseHeader."Document Type"::"Return Order"])
            then begin
                GSTDocumentType := PurchDocumentType2DocumentTypeEnum(PurchaseHeader."Document Type");

                ReferenceInvoiceNo.SetRange("Document Type", GSTDocumentType);
                ReferenceInvoiceNo.SetRange("Document No.", PurchaseHeader."No.");
                ReferenceInvoiceNo.SetRange(Verified, true);
                if ReferenceInvoiceNo.FindFirst() then begin
                    VendorLedgerEntry.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
                    if VendorLedgerEntry.FindFirst() and VendorLedgerEntry."RCM Exempt" then
                        exit(true);
                end;
            end;

        exit(false);
    end;

    procedure CheckRCMExemptDateJournal(var GenJournalLine: Record "Gen. Journal Line"): Boolean
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        DocumentType: Enum "Document Type Enum";
    begin
        if GenJournalLine."GST Vendor Type" <> GenJournalLine."GST Vendor Type"::Unregistered then
            exit(false);

        if GenJournalLine."Document Type" in [GenJournalLine."Document Type"::Invoice] then begin
            GenJournalLine.TestField("Posting Date");

            PurchasesPayablesSetup.Get();
            PurchasesPayablesSetup.TestField("RCM Exempt Start Date (Unreg)");
            PurchasesPayablesSetup.TestField("RCM Exempt Start Date (Unreg)");
            if (GenJournalLine."Posting Date" >= PurchasesPayablesSetup."RCM Exempt Start Date (Unreg)") and
               (GenJournalLine."Posting Date" <= PurchasesPayablesSetup."RCM Exempt End Date (Unreg)")
            then
                exit(true);
        end else
            if GenJournalLine."Document Type" in [GenJournalLine."Document Type"::"Credit Memo"] then begin
                ReferenceInvoiceNo.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
                ReferenceInvoiceNo.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
                DocumentType := GenJnlDocumentType2DocumentTypeEnum(GenJournalLine."Document Type");

                ReferenceInvoiceNo.SetRange("Document Type", DocumentType);
                ReferenceInvoiceNo.SetRange("Document No.", GenJournalLine."Document No.");
                ReferenceInvoiceNo.SetRange(Verified, true);
                if ReferenceInvoiceNo.FindFirst() then begin
                    VendorLedgerEntry.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
                    if VendorLedgerEntry.FindFirst() and VendorLedgerEntry."RCM Exempt" then
                        exit(true);
                end;
            end;

        exit(false);
    end;

    procedure UpdateReferenceInvoiceNoPurchHeader(var PurchaseHeader: Record "Purchase Header")
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        UpdateReferenceInvoiceNo: Page "Update Reference Invoice No";
        SalesDocType: Enum "Sales Document Type";
        GSTDocumentType: Enum "Document Type Enum";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateReferenceInvoiceNoPurchaseHeader(PurchaseHeader, IsHandled);
        if IsHandled then
            exit;

        if not IsGSTApplicable("Transaction Type Enum"::Purchase, PurchaseHeader."Document Type", SalesDocType, PurchaseHeader."No.") then
            Error(ReferenceInvoiceNoErr);

        if PurchaseHeader."Document Type" in [PurchaseHeader."Document Type"::Order, PurchaseHeader."Document Type"::Invoice] then
            if not (PurchaseHeader."Invoice Type" in [
                PurchaseHeader."Invoice Type"::"Debit Note",
                PurchaseHeader."Invoice Type"::Supplementary])
            then
                Error(ReferenceNoErr);

        GSTDocumentType := PurchDocumentType2DocumentTypeEnum(PurchaseHeader."Document Type");

        ReferenceInvoiceNo.Reset();
        ReferenceInvoiceNo.SetRange("Document No.", PurchaseHeader."No.");
        ReferenceInvoiceNo.SetRange("Document Type", GSTDocumentType);
        ReferenceInvoiceNo.SetRange("Source No.", PurchaseHeader."Pay-to Vendor No.");
        UpdateReferenceInvoiceNo.SetSourceType(ReferenceInvoiceNo."Source Type"::Vendor);
        UpdateReferenceInvoiceNo.SetTableView(ReferenceInvoiceNo);
        UpdateReferenceInvoiceNo.Run();
    end;

    procedure UpdateReferenceInvoiceNoSalesHeader(var SalesHeader: Record "Sales Header")
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        UpdateReferenceInvoiceNo: Page "Update Reference Invoice No";
        PurchDocType: Enum "Purchase Document Type";
        GSTDocumentType: Enum "Document Type Enum";
        ISHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateRefInvoiceNoSalesHeader(SalesHeader, IsHandled);
        if IsHandled then
            exit;

        if not IsGSTApplicable("Transaction Type Enum"::Sales, PurchDocType, SalesHeader."Document Type", SalesHeader."No.") then
            Error(ReferenceInvoiceNoErr);

        if SalesHeader."Document Type" in [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice] then
            if not (SalesHeader."Invoice Type" in [
                SalesHeader."Invoice Type"::"Debit Note",
                SalesHeader."Invoice Type"::Supplementary])
            then
                Error(ReferenceNoErr);

        GSTDocumentType := SalesDocumentType2DocumentTypeEnum(SalesHeader."Document Type");

        ReferenceInvoiceNo.Reset();
        ReferenceInvoiceNo.SetRange("Document No.", SalesHeader."No.");
        ReferenceInvoiceNo.SetRange("Document Type", GSTDocumentType);
        ReferenceInvoiceNo.SetRange("Source No.", SalesHeader."Bill-to Customer No.");

        UpdateReferenceInvoiceNo.SetSourceType(ReferenceInvoiceNo."Source Type"::Customer);
        UpdateReferenceInvoiceNo.SetTableView(ReferenceInvoiceNo);
        UpdateReferenceInvoiceNo.Run();
    end;

    procedure UpdateReferenceInvoiceNoGenJournal(var GenJnlLine: Record "Gen. Journal Line")
    var
        GenJrnlLine: Record "Gen. Journal Line";
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        UpdateReferenceInvJournals: Page "Update Reference Inv. Journals";
        GSTDocumentType: Enum "Document Type Enum";
    begin
        GenJrnlLine.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
        GenJrnlLine.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
        GenJrnlLine.SetRange("Document No.", GenJnlLine."Document No.");
        GenJrnlLine.SetRange("GST in Journal", true);
        GenJrnlLine.SetFilter("Account Type", '%1|%2', GenJrnlLine."Account Type"::Customer, GenJrnlLine."Account Type"::Vendor);
        if GenJrnlLine.FindFirst() then begin
            if not (GenJnlLine."Document Type" in [GenJnlLine."Document Type"::"Credit Memo", GenJnlLine."Document Type"::Invoice]) then
                Error(DocumentTypeErr);

            if (GenJrnlLine."Account Type" = GenJrnlLine."Account Type"::Vendor) and
               (GenJrnlLine."Document Type" = GenJrnlLine."Document Type"::Invoice) and not
               (GenJrnlLine."Purch. Invoice Type" in [
                   GenJrnlLine."Purch. Invoice Type"::"Debit Note",
                   GenJrnlLine."Purch. Invoice Type"::Supplementary])
            then
                Error(ReferenceNoErr);

            if (GenJrnlLine."Account Type" = GenJrnlLine."Account Type"::Customer) and
               (GenJrnlLine."Document Type" = GenJrnlLine."Document Type"::Invoice) and not
               (GenJrnlLine."Sales Invoice Type" in [
                   GenJrnlLine."Sales Invoice Type"::"Debit Note",
                   GenJrnlLine."Sales Invoice Type"::Supplementary])
            then
                Error(ReferenceNoErr);

            GSTDocumentType := GenJnlDocumentType2DocumentTypeEnum(GenJnlLine."Document Type");

            ReferenceInvoiceNo.Reset();
            ReferenceInvoiceNo.SetRange("Document No.", GenJnlLine."Document No.");
            ReferenceInvoiceNo.SetRange("Document Type", GSTDocumentType);
            ReferenceInvoiceNo.SetRange("Source No.", GenJrnlLine."Account No.");
            ReferenceInvoiceNo.SetRange("Journal Template Name", GenJrnlLine."Journal Template Name");
            ReferenceInvoiceNo.SetRange("Journal Batch Name", GenJrnlLine."Journal Batch Name");

            if GenJrnlLine."Account Type" = GenJrnlLine."Account Type"::Customer then
                UpdateReferenceInvJournals.SetSourceType(ReferenceInvoiceNo."Source Type"::Customer);

            UpdateReferenceInvJournals.SetTableView(ReferenceInvoiceNo);
            UpdateReferenceInvJournals.Run();
        end else
            Error(ReferenceInvoiceNoErr);
    end;

    procedure UpdateReferenceInvoiceNoServiceHeader(var ServiceHeader: Record "Service Header")
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        UpdateReferenceInvoiceNo: Page "Update Reference Invoice No";
        PurchDocType: Enum "Purchase Document Type";
        GSTDocumentType: Enum "Document Type Enum";
    begin
        if not IsGSTApplicable("Transaction Type Enum"::Service, PurchDocType, ServiceHeader."Document Type", ServiceHeader."No.") then
            Error(ReferenceInvoiceNoErr);

        if ServiceHeader."Document Type" in [ServiceHeader."Document Type"::Order, ServiceHeader."Document Type"::Invoice] then
            if not (ServiceHeader."Invoice Type" in [
                ServiceHeader."Invoice Type"::"Debit Note",
                ServiceHeader."Invoice Type"::Supplementary])
            then
                Error(ReferenceNoErr);

        GSTDocumentType := ServiceDocumentType2DocumentTypeEnum(ServiceHeader."Document Type");

        ReferenceInvoiceNo.Reset();
        ReferenceInvoiceNo.SetRange("Document No.", ServiceHeader."No.");
        ReferenceInvoiceNo.SetRange("Document Type", GSTDocumentType);
        ReferenceInvoiceNo.SetRange("Source No.", ServiceHeader."Bill-to Customer No.");

        UpdateReferenceInvoiceNo.SetSourceType(ReferenceInvoiceNo."Source Type"::Customer);
        UpdateReferenceInvoiceNo.SetTableView(ReferenceInvoiceNo);
        UpdateReferenceInvoiceNo.Run();
    end;

    local procedure UpdateReferenceInvoiceforVendorLedgerEntries(var ReferenceInvoiceNo: Record "Reference Invoice No.")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntryToCheck: Record "Vendor Ledger Entry";
        VendorLedgerEntryCopy: Record "Vendor Ledger Entry";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        VendorLedgerEntries: Page "Vendor Ledger Entries";
    begin
        VendorLedgerEntry.SetRange("Vendor No.", ReferenceInvoiceNo."Source No.");
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
        if VendorLedgerEntry.FindFirst() then begin
            Clear(VendorLedgerEntries);
            VendorLedgerEntries.SetTableView(VendorLedgerEntry);
            VendorLedgerEntries.SetRecord(VendorLedgerEntry);
            VendorLedgerEntries.LookupMode(true);
            if VendorLedgerEntries.RunModal() = Action::LookupOK then begin
                VendorLedgerEntries.GetRecord(VendorLedgerEntry);
                if not (VendorLedgerEntry."Document Type" = VendorLedgerEntry."Document Type"::Invoice) then
                    Error(DocumentTypeErr);

                DetailedGSTLedgerEntry.SetRange("Document No.", VendorLedgerEntry."Document No.");
                DetailedGSTLedgerEntry.SetRange("Source No.", VendorLedgerEntry."Vendor No.");
                if DetailedGSTLedgerEntry.FindFirst() then begin
                    if (DetailedGSTLedgerEntry."Document Type" = DetailedGSTLedgerEntry."Document Type"::Invoice) or
                       (DetailedGSTLedgerEntry."Document Type" = DetailedGSTLedgerEntry."Document Type"::"Credit Memo")
                    then
                        ReferenceInvoiceNo."Reference Invoice Nos." := VendorLedgerEntry."Document No.";

                    VendorLedgerEntryToCheck.SetRange("Document No.", ReferenceInvoiceNo."Document No.");
                    if VendorLedgerEntryToCheck.FindFirst() then
                        VendorLedgerEntryCopy.Copy(VendorLedgerEntryToCheck);

                    CheckGSTPurchCrMemoValidationsOffline(
                      VendorLedgerEntryCopy, VendorLedgerEntry, 0, ReferenceInvoiceNo."Reference Invoice Nos.");

                    if VendorLedgerEntryToCheck."Vendor No." <> DetailedGSTLedgerEntry."Source No." then
                        Error(DiffVendNoErr);
                end else
                    Error(ReferenceInvoiceErr)
            end;
        end;
    end;

    local procedure CheckGSTPurchCrMemoValidationsOffline(
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        ApplyingVendorLedgerEntry: Record "Vendor Ledger Entry";
        Entrys: Integer;
        ReferenceInvoiceNo: Code[20])
    var
        VendorLedgerEntryInv: Record "Vendor Ledger Entry";
        VendorLedgerEntryCrMemo: Record "Vendor Ledger Entry";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvoiceHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        InvGSTJurisdiction: Enum "GST Jurisdiction Type";
        CrMemoGSTJuridiction: Enum "GST Jurisdiction Type";
        InvoiceFromJournal: Boolean;
        CrMemoFromJournal: Boolean;
        PurchDocType: Enum "Purchase Document Type";
        SalesDocType: Enum "Sales Document Type";
    begin
        if VendorLedgerEntry."Document Type" = VendorLedgerEntry."Document Type"::Invoice then begin
            VendorLedgerEntryInv.Copy(ApplyingVendorLedgerEntry);
            VendorLedgerEntryCrMemo.Copy(VendorLedgerEntry);
        end else begin
            VendorLedgerEntryInv.Copy(ApplyingVendorLedgerEntry);
            VendorLedgerEntryCrMemo.Copy(VendorLedgerEntry);
        end;

        InvoiceFromJournal := VendorLedgerEntryInv."Journal Entry";
        CrMemoFromJournal := VendorLedgerEntryCrMemo."Journal Entry";

        if not InvoiceFromJournal then
            if PurchInvHeader.Get(VendorLedgerEntryInv."Document No.") then;

        if not CrMemoFromJournal then
            if PurchCrMemoHdr.Get(VendorLedgerEntryCrMemo."Document No.") then;

        if (PurchCrMemoHdr."No." = '') and not CrMemoFromJournal then
            PurchInvoiceHeader.Get(VendorLedgerEntryCrMemo."Document No.");

        if not InvoiceFromJournal then
            if IsGSTApplicable("Transaction Type Enum"::Purchase, PurchDocType, SalesDocType, PurchInvHeader."No.") then begin
                VendorLedgerEntryCrMemo.TestField("RCM Exempt", VendorLedgerEntryInv."RCM Exempt");

                CheckGSTAppliedDocumentPosted(
                    VendorLedgerEntryCrMemo."Posting Date",
                    VendorLedgerEntryInv."Posting Date",
                    VendorLedgerEntryCrMemo."Document No.",
                    VendorLedgerEntryInv."Document No.");

                if IsGSTApplicable("Transaction Type Enum"::Purchase, PurchDocType, SalesDocType, PurchCrMemoHdr."No.") or
                    IsGSTApplicable("Transaction Type Enum"::Purchase, PurchDocType, SalesDocType, PurchInvoiceHeader."No.") or
                    VendorLedgerEntryCrMemo."GST in Journal"
                then begin
                    if VendorLedgerEntryInv."Location GST Reg. No." <> VendorLedgerEntryCrMemo."Location GST Reg. No." then
                        Error(DiffLocationGSTRegErr);

                    if VendorLedgerEntryInv."Buyer GST Reg. No." <> VendorLedgerEntryCrMemo."Buyer GST Reg. No." then
                        Error(DiffGSTRegNoErr, VendorLedgerEntryInv.FieldCaption("Buyer GST Reg. No."), ReferenceInvoiceNo);

                    InvGSTJurisdiction := GetGSTJurisdiction(
                        "Transaction Type Enum"::Purchase,
                        VendorLedgerEntryInv."Document Type",
                        SalesDocType,
                        VendorLedgerEntryInv."Document No.",
                        false,
                        InvoiceFromJournal);

                    CrMemoGSTJuridiction := GetGSTJurisdiction(
                        "Transaction Type Enum"::Purchase,
                        VendorLedgerEntryCrMemo."Document Type",
                        SalesDocType,
                        VendorLedgerEntryCrMemo."Document No.",
                        false,
                        CrMemoFromJournal);

                    if InvGSTJurisdiction <> CrMemoGSTJuridiction then
                        Error(DiffJurisdictionErr, VendorLedgerEntryInv.FieldCaption("GST Jurisdiction Type"));

                    if VendorLedgerEntryInv."Currency Code" <> VendorLedgerEntryCrMemo."Currency Code" then
                        Error(DiffCurrencyCodeErr, VendorLedgerEntryInv.FieldCaption("Currency Code"));
                end;
            end;

        if InvoiceFromJournal then begin
            if PurchCrMemoHdr."No." <> '' then
                CheckPurchAppliedEntries(
                    VendorLedgerEntryInv,
                    VendorLedgerEntryCrMemo,
                    Database::"Purch. Cr. Memo Hdr.",
                    PurchInvoiceHeader,
                    PurchCrMemoHdr,
                    Entrys,
                    CrMemoFromJournal)
            else
                CheckPurchAppliedEntries(
                    VendorLedgerEntryInv,
                    VendorLedgerEntryCrMemo,
                    Database::"Purch. Inv. Header",
                    PurchInvoiceHeader,
                    PurchCrMemoHdr,
                    Entrys,
                    CrMemoFromJournal);

            if VendorLedgerEntryInv."GST in Journal" then begin
                VendorLedgerEntryCrMemo.TestField("RCM Exempt", VendorLedgerEntryInv."RCM Exempt");
                CheckGSTAppliedDocumentPosted(
                    VendorLedgerEntryCrMemo."Posting Date",
                    VendorLedgerEntryInv."Posting Date",
                    VendorLedgerEntryCrMemo."Document No.",
                    VendorLedgerEntryInv."Document No.");

                if IsGSTApplicable("Transaction Type Enum"::Purchase, PurchDocType, SalesDocType, PurchCrMemoHdr."No.") or
                    IsGSTApplicable("Transaction Type Enum"::Purchase, PurchDocType, SalesDocType, PurchInvoiceHeader."No.") or
                    VendorLedgerEntryCrMemo."GST in Journal"
                then begin
                    if VendorLedgerEntryInv."Location GST Reg. No." <> VendorLedgerEntryCrMemo."Location GST Reg. No." then
                        Error(DiffLocationGSTRegErr);

                    if VendorLedgerEntryInv."Buyer GST Reg. No." <> VendorLedgerEntryCrMemo."Buyer GST Reg. No." then
                        Error(DiffGSTRegNoErr, VendorLedgerEntryInv.FieldCaption("Buyer GST Reg. No."), ReferenceInvoiceNo);

                    InvGSTJurisdiction := GetGSTJurisdiction(
                        "Transaction Type Enum"::Purchase,
                        VendorLedgerEntryInv."Document Type",
                        SalesDocType,
                        VendorLedgerEntryInv."Document No.",
                        false,
                        InvoiceFromJournal);

                    CrMemoGSTJuridiction := GetGSTJurisdiction(
                        "Transaction Type Enum"::Purchase,
                        VendorLedgerEntryCrMemo."Document Type",
                        SalesDocType,
                        VendorLedgerEntryCrMemo."Document No.",
                        false,
                        CrMemoFromJournal);

                    if InvGSTJurisdiction <> CrMemoGSTJuridiction then
                        Error(DiffJurisdictionErr, VendorLedgerEntryInv.FieldCaption("GST Jurisdiction Type"));

                    if VendorLedgerEntryInv."Currency Code" <> VendorLedgerEntryCrMemo."Currency Code" then
                        Error(DiffCurrencyCodeErr, VendorLedgerEntryInv.FieldCaption("Currency Code"));
                end;
            end;
        end;
    end;

    local procedure CheckGSTPurchCrMemoValidationsJournalReference(GenJournalLine: Record "Gen. Journal Line"; ReferenceInvoiceNo: Code[20])
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        CurrVendNo: Code[20];
        CurrStateCode: Code[10];
        PostedStateCode: Code[10];
        CurrDocumentGSTRegNo: Code[20];
        PostedDocumentGSTRegNo: Code[20];
        CurrDocLocRegNo: Code[20];
        PostedDocLocRegNo: Code[20];
        CurrDocGSTJurisdiction: Enum "GST Jurisdiction Type";
        PostedDocGSTJurisdiction: Enum "GST Jurisdiction Type";
        PostedCurrencyCode: Code[10];
        InJournal: Boolean;
        PurchDocType: Enum "Purchase Document Type";
        SalesDocType: Enum "Sales Document Type";
    begin
        if not (GenJournalLine."Document Type" in [
            GenJournalLine."Document Type"::"Credit Memo",
            GenJournalLine."Document Type"::Invoice])
        then
            exit;

        CurrVendNo := GetVendorNo(GenJournalLine);
        if IsGSTApplicableJournal(GenJournalLine) then
            if ReferenceInvoiceNo <> '' then begin
                InJournal := IsGSTFromJournal("Transaction Type Enum"::Purchase, ReferenceInvoiceNo, CurrVendNo);
                if not InJournal and
                    PurchInvHeader.Get(ReferenceInvoiceNo) and
                    IsGSTApplicable("Transaction Type Enum"::Purchase, PurchDocType, SalesDocType, PurchInvHeader."No.") or
                    InJournal
                then begin
                    CheckGSTAppliedDocument(
                        "Transaction Type Enum"::Purchase,
                        GenJournalLine."Document Type"::Invoice,
                        SalesDocType,
                        GenJournalLine."Document No.",
                        ReferenceInvoiceNo,
                        InJournal,
                        GenJournalLine."Journal Template Name",
                        GenJournalLine."Journal Batch Name",
                        GenJournalLine."Line No.");

                    CurrStateCode := GetStateCodeforGenJnlPurchValidation(
                        "Transaction Type Enum"::Purchase,
                        GenJournalLine."Document Type",
                        GenJournalLine."Document No.",
                        true,
                        true,
                        GenJournalLine."Journal Template Name",
                        GenJournalLine."Journal Batch Name",
                        GenJournalLine."Line No.");

                    PostedStateCode := GetStateCodeforGenJnlPurchValidation(
                        "Transaction Type Enum"::Purchase,
                        GenJournalLine."Document Type"::Invoice,
                        ReferenceInvoiceNo,
                        false,
                        InJournal,
                        GenJournalLine."Journal Template Name",
                        GenJournalLine."Journal Batch Name",
                        GenJournalLine."Line No.");

                    CurrDocumentGSTRegNo := GetPlaceOfSupplyRegistrationNo(
                        "Transaction Type Enum"::Purchase,
                        GenJournalLine."Document Type",
                        SalesDocType,
                        GenJournalLine."Document No.",
                        true,
                        true,
                        GenJournalLine."Journal Template Name",
                        GenJournalLine."Journal Batch Name",
                        GenJournalLine."Line No.");

                    PostedDocumentGSTRegNo := GetPlaceOfSupplyRegistrationNo(
                        "Transaction Type Enum"::Purchase,
                        GenJournalLine."Document Type"::Invoice,
                        SalesDocType,
                        ReferenceInvoiceNo,
                        false,
                        InJournal);

                    CurrDocLocRegNo := GetLocationRegistrationNo(
                        "Transaction Type Enum"::Purchase,
                        GenJournalLine."Document Type",
                        SalesDocType,
                        GenJournalLine."Document No.",
                        true,
                        true,
                        GenJournalLine."Journal Template Name",
                        GenJournalLine."Journal Batch Name",
                        GenJournalLine."Line No.");

                    PostedDocLocRegNo := GetLocationRegistrationNo(
                        "Transaction Type Enum"::Purchase,
                        GenJournalLine."Document Type",
                        SalesDocType,
                        ReferenceInvoiceNo,
                        false,
                        InJournal);

                    CurrDocGSTJurisdiction := GetGSTJurisdiction(
                        "Transaction Type Enum"::Purchase,
                        GenJournalLine."Document Type",
                        SalesDocType,
                        GenJournalLine."Document No.",
                        true,
                        true,
                        GenJournalLine."Journal Template Name",
                        GenJournalLine."Journal Batch Name",
                        GenJournalLine."Line No.");

                    PostedDocGSTJurisdiction := GetGSTJurisdiction(
                        "Transaction Type Enum"::Purchase,
                        GenJournalLine."Document Type"::Invoice,
                        SalesDocType,
                        ReferenceInvoiceNo,
                        false,
                        InJournal);

                    PostedCurrencyCode := GetCurrencyCode(
                        "Transaction Type Enum"::Purchase,
                        GenJournalLine."Document Type"::Invoice,
                        ReferenceInvoiceNo,
                        CurrVendNo);

                    if CurrStateCode <> PostedStateCode then
                        Error(DiffStateCodeErr);

                    if CurrDocumentGSTRegNo <> PostedDocumentGSTRegNo then begin
                        if GenJournalLine."Order Address Code" <> '' then
                            Error(DiffGSTRegNoErr, GenJournalLine.FieldCaption(GenJournalLine."Order Address GST Reg. No."), ReferenceInvoiceNo);

                        Error(DiffGSTRegNoErr, GenJournalLine.FieldCaption("Vendor GST Reg. No."), ReferenceInvoiceNo);
                    end;

                    if CurrDocLocRegNo <> PostedDocLocRegNo then
                        Error(DiffGSTRegNoErr, GenJournalLine.FieldCaption("Location Code"), ReferenceInvoiceNo);

                    if CurrDocGSTJurisdiction <> PostedDocGSTJurisdiction then
                        Error(DiffJurisdictionErr, GenJournalLine.FieldCaption("GST Jurisdiction Type"));

                    if GenJournalLine."Currency Code" <> PostedCurrencyCode then
                        Error(DiffCurrencyCodeErr, GenJournalLine.FieldCaption("Currency Code"));
                end;
            end;
    end;

    local procedure UpdateCustomerValidations(var ReferenceInvoiceNo: Record "Reference Invoice No.")
    var
        SalesHeader: Record "Sales Header";
        ServiceHeader: Record "Service Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntryToCheck: Record "Cust. Ledger Entry";
        CustLedgerEntryCopy: Record "Cust. Ledger Entry";
        GenJnlLine: Record "Gen. Journal Line";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        if ReferenceInvoiceNo."Source Type" = ReferenceInvoiceNo."Source Type"::Customer then begin
            if SalesHeader.Get(ReferenceInvoiceNo."Document Type", ReferenceInvoiceNo."Document No.") then begin
                CustLedgerEntryToCheck.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
                if CustLedgerEntryToCheck.FindFirst() then
                    if not (CustLedgerEntryToCheck."Document Type" = CustLedgerEntryToCheck."Document Type"::Invoice) then
                        Error(DocumentTypeErr);

                DetailedGSTLedgerEntry.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
                DetailedGSTLedgerEntry.SetRange("Source No.", CustLedgerEntryToCheck."Customer No.");
                if not DetailedGSTLedgerEntry.FindFirst() then
                    Error(ReferenceInvoiceErr);

                CheckGSTSalesCrMemoValidationReference(SalesHeader, ReferenceInvoiceNo."Reference Invoice Nos.");
            end else begin
                GenJnlLine.SetRange("Journal Template Name", ReferenceInvoiceNo."Journal Template Name");
                GenJnlLine.SetRange("Journal Batch Name", ReferenceInvoiceNo."Journal Batch Name");
                GenJnlLine.SetRange("Document No.", ReferenceInvoiceNo."Document No.");
                if GenJnlLine.FindFirst() then begin
                    CustLedgerEntryToCheck.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
                    if CustLedgerEntryToCheck.FindFirst() then
                        if not (CustLedgerEntryToCheck."Document Type" = CustLedgerEntryToCheck."Document Type"::Invoice) then
                            Error(DocumentTypeErr);

                    DetailedGSTLedgerEntry.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
                    DetailedGSTLedgerEntry.SetRange("Source No.", CustLedgerEntryToCheck."Customer No.");
                    if not DetailedGSTLedgerEntry.FindFirst() then
                        Error(ReferenceInvoiceErr);

                    CheckGSTSalesCrMemoJournalValidationReference(GenJnlLine, ReferenceInvoiceNo."Reference Invoice Nos.");
                end;
            end;

            CustLedgerEntryToCheck.SetRange("Document No.", ReferenceInvoiceNo."Document No.");
            if CustLedgerEntryToCheck.FindFirst() then begin
                CustLedgerEntryCopy.Copy(CustLedgerEntryToCheck);
                CustLedgerEntry.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
                if CustLedgerEntry.FindFirst() then begin
                    if not (CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Invoice) then
                        Error(DocumentTypeErr);

                    if CustLedgerEntryToCheck."Customer No." <> ReferenceInvoiceNo."Source No." then
                        Error(DiffCustNoErr);

                    DetailedGSTLedgerEntry.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
                    DetailedGSTLedgerEntry.SetRange("Source No.", CustLedgerEntry."Customer No.");
                    if DetailedGSTLedgerEntry.IsEmpty() then
                        Error(ReferenceInvoiceErr);

                    CheckGSTSalesCrMemoValidationsOffline(
                        CustLedgerEntryCopy,
                        CustLedgerEntry,
                        0,
                        ReferenceInvoiceNo."Reference Invoice Nos.");
                end;
            end;

            if ServiceHeader.Get(ReferenceInvoiceNo."Document Type", ReferenceInvoiceNo."Document No.") then begin
                CustLedgerEntryToCheck.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
                if CustLedgerEntryToCheck.FindFirst() then
                    if not (CustLedgerEntryToCheck."Document Type" = CustLedgerEntryToCheck."Document Type"::Invoice) then
                        Error(DocumentTypeErr);

                DetailedGSTLedgerEntry.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
                DetailedGSTLedgerEntry.SetRange("Source No.", CustLedgerEntryToCheck."Customer No.");
                if DetailedGSTLedgerEntry.IsEmpty() then
                    Error(ReferenceInvoiceErr);

                CheckGSTServiceCrMemoValidationReference(ServiceHeader, ReferenceInvoiceNo."Reference Invoice Nos.");
            end;
        end;
    end;

    local procedure CheckGSTAppliedDocument(
        TransType: Enum "Transaction Type Enum";
        PurchDocType: Enum "Purchase Document Type";
        SalesDocType: Enum "Sales Document Type";
        DocumentNo: Code[20];
        AppliedDocumentNo: Code[20];
        InJournal: Boolean;
        TemplateName: Code[10];
        Batchname: Code[10];
        LineNo: Integer)
    var
        ServiceDocType: Enum "Service Document Type";
    begin
        case TransType of
            "Transaction Type Enum"::Purchase:
                CheckGSTAppliedDocumentPurchase(AppliedDocumentNo, InJournal, PurchDocType, DocumentNo, TemplateName, Batchname, LineNo);
            "Transaction Type Enum"::Sales:
                CheckGSTAppliedDocumentSales(AppliedDocumentNo, InJournal, SalesDocType, DocumentNo, TemplateName, Batchname, LineNo);
            "Transaction Type Enum"::Service:
                begin
                    ServiceDocType := SalesDocumentType2ServiceDocumentTypeEnum(SalesDocType);
                    CheckGSTAppliedDocumentService(AppliedDocumentNo, ServiceDocType, DocumentNo);
                end;
        end;
    end;

    local procedure GetStateCode(
        TransType: Enum "Transaction Type Enum";
        PurchDocType: Enum "Purchase Document Type";
        DocumentNo: Code[20];
        CurrentDocument: Boolean) StateCode: Code[10]
    var
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        GSTDocumentType: Enum "GST Document Type";
    begin
        if CurrentDocument then
            case TransType of
                "Transaction Type Enum"::Purchase:
                    begin
                        if DocumentNo <> '' then begin
                            PurchaseHeader.Get(PurchDocType, DocumentNo);
                            if PurchaseHeader."Order Address Code" <> '' then
                                StateCode := PurchaseHeader."GST Order Address State"
                            else begin
                                Vendor.Get(PurchaseHeader."Pay-to Vendor No.");
                                StateCode := Vendor."State Code";
                            end;
                        end;
                        exit(StateCode);
                    end;
            end;

        GSTDocumentType := PurchDocumentType2GSTDocumentType(PurchDocType);

        DetailedGSTLedgerEntry.Reset();
        if TransType = "Transaction Type Enum"::Purchase then
            DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase)
        else
            DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);

        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
        DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocumentType);
        DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
        DetailedGSTLedgerEntry.FindFirst();

        DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.");

        exit(DetailedGSTLedgerEntryInfo."Buyer/Seller State Code");
    end;

    local procedure GetStateCodeforGenJnlPurchValidation(
        TransType: Enum "Transaction Type Enum";
        GenJnlDocType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
        CurrentDocument: Boolean;
        InJournal: Boolean;
        TemplateName: Code[10];
        BatchName: Code[10];
        LineNo: Integer): Code[10]
    var
        Vendor: Record Vendor;
        GenJnlLine: Record "Gen. Journal Line";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        GSTDocumentType: Enum "GST Document Type";
    begin
        if CurrentDocument then
            case TransType of
                "Transaction Type Enum"::Purchase:
                    if InJournal and (DocumentNo <> '') then begin
                        GenJnlLine.Get(TemplateName, BatchName, LineNo);
                        if GenJnlLine."Order Address Code" <> '' then
                            exit(GenJnlLine."Order Address State Code")
                        else begin
                            Vendor.Get(GetVendorNo(GenJnlLine));
                            exit(Vendor."State Code");
                        end;
                    end;
            end;

        GSTDocumentType := GenJnlDocumentType2GSTDocumentType(GenJnlDocType);

        DetailedGSTLedgerEntry.Reset();
        if TransType = "Transaction Type Enum"::Purchase then
            DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase)
        else
            DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);

        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
        DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocumentType);
        DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
        DetailedGSTLedgerEntry.SetRange("Journal Entry", InJournal);
        DetailedGSTLedgerEntry.FindFirst();

        DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.");

        exit(DetailedGSTLedgerEntryInfo."Buyer/Seller State Code");
    end;

    local procedure GetPlaceOfSupplyRegistrationNo(
        TransType: Enum "Transaction Type Enum";
        PurchDocType: Enum "Purchase Document Type";
        SalesDocType: Enum "Sales Document Type";
        DocumentNo: Code[20];
        CurrentDocument: Boolean;
        InJournal: Boolean): Code[20]
    begin
        exit(
            GetPlaceOfSupplyRegistrationNo(
                TransType,
                PurchDocType,
                SalesDocType,
                DocumentNo,
                CurrentDocument,
                InJournal,
                '',
                '',
                0));
    end;

    local procedure GetPlaceOfSupplyRegistrationNo(
        TransType: Enum "Transaction Type Enum";
        PurchDocType: Enum "Purchase Document Type";
        SalesDocType: Enum "Sales Document Type";
        DocumentNo: Code[20];
        CurrentDocument: Boolean;
        InJournal: Boolean;
        TemplateName: Code[10];
        BatchName: Code[10];
        LineNo: Integer): Code[20]
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTDocType: Enum "GST Document Type";
        ServiceDocType: Enum "Service Document Type";
    begin
        if CurrentDocument then
            case TransType of
                "Transaction Type Enum"::Sales:
                    exit(GetPlaceOfSupplyRegistrationNoSales(SalesDocType, DocumentNo, InJournal, TemplateName, BatchName, LineNo));
                "Transaction Type Enum"::Purchase:
                    exit(GetPlaceOfSupplyRegistrationNoPurchase(PurchDocType, DocumentNo, InJournal, TemplateName, BatchName, LineNo));
                "Transaction Type Enum"::Service:
                    begin
                        ServiceDocType := SalesDocumentType2ServiceDocumentTypeEnum(SalesDocType);
                        exit(GetPlaceOfSupplyRegistrationNoService(ServiceDocType, DocumentNo));
                    end;
            end;

        DetailedGSTLedgerEntry.Reset();
        if TransType = "Transaction Type Enum"::Purchase then begin
            GSTDocType := PurchDocumentType2GSTDocumentType(PurchDocType);

            DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
            DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocType);
        end else begin
            GSTDocType := PurchDocumentType2GSTDocumentType(SalesDocType);

            DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);
            DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocType);
        end;

        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
        DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
        DetailedGSTLedgerEntry.SetRange("Journal Entry", InJournal);
        DetailedGSTLedgerEntry.FindFirst();

        if (DetailedGSTLedgerEntry."Buyer/Seller Reg. No." = '') and (DetailedGSTLedgerEntry."ARN No." <> '') then
            Error(UpdateGSTNosErr, DetailedGSTLedgerEntry."Document No.");

        exit(DetailedGSTLedgerEntry."Buyer/Seller Reg. No.");
    end;

    local procedure GetPlaceOfSupplyRegistrationNoSales(
        SalesDocType: Enum "Sales Document Type";
        DocumentNo: Code[20];
        InJournal: Boolean;
        TemplateName: Code[10];
        BatchName: Code[10];
        LineNo: Integer): Code[20]
    var
        Customer: Record Customer;
        ShipToAddress: Record "Ship-to Address";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GenJournalLineToCheck: Record "Gen. Journal Line";
        GenJournalLineCopy: Record "Gen. Journal Line";
    begin
        if not InJournal then
            if DocumentNo <> '' then
                if SalesHeader.Get(SalesDocType, DocumentNo) then begin
                    SalesLine.Reset();
                    SalesLine.SetRange("Document Type", SalesDocType);
                    SalesLine.SetRange("Document No.", DocumentNo);
                    SalesLine.SetFilter(Type, '<>%1', SalesLine.Type::" ");
                    if SalesLine.FindFirst() then
                        case SalesLine."GST Place of Supply" of
                            SalesLine."GST Place of Supply"::" ", SalesLine."GST Place of Supply"::"Bill-to Address", SalesLine."GST Place of Supply"::"Location Address":
                                begin
                                    if SalesHeader."Customer GST Reg. No." = '' then
                                        if Customer.Get(SalesLine."Sell-to Customer No.") and (Customer."ARN No." <> '') then
                                            SalesHeader.TestField("Customer GST Reg. No.");

                                    exit(SalesHeader."Customer GST Reg. No.");
                                end;
                            SalesLine."GST Place of Supply"::"Ship-to Address":
                                begin
                                    SalesHeader.TestField("Ship-to Code");
                                    if SalesHeader."Ship-to GST Reg. No." = '' then
                                        if ShipToAddress.Get(SalesHeader."Sell-to Customer No.", SalesHeader."Ship-to Code") and (ShipToAddress."ARN No." <> '') then
                                            SalesHeader.TestField("Ship-to GST Reg. No.");

                                    exit(SalesHeader."Ship-to GST Reg. No.");
                                end;
                        end;
                end else begin
                    GenJournalLineCopy.Get(TemplateName, BatchName, LineNo);
                    Customer.Get(GetCustomerNo(GenJournalLineCopy));

                    RefGenJournalLine.Reset();
                    RefGenJournalLine.SetRange("Journal Template Name", TemplateName);
                    RefGenJournalLine.SetRange("Journal Batch Name", BatchName);
                    RefGenJournalLine.SetRange("Document No.", GenJournalLineCopy."Old Document No.");
                    RefGenJournalLine.SetFilter("GST Group Code", '<>%1', '');
                    RefGenJournalLine.FindFirst();

                    case RefGenJournalLine."GST Place of Supply" of
                        RefGenJournalLine."GST Place of Supply"::"Bill-to Address", RefGenJournalLine."GST Place of Supply"::"Location Address":
                            begin
                                if (Customer."GST Registration No." = '') and (Customer."ARN No." <> '') then
                                    GenJournalLineCopy.TestField("Customer GST Reg. No.");

                                exit(Customer."GST Registration No.");
                            end;
                        RefGenJournalLine."GST Place of Supply"::"Ship-to Address":
                            begin
                                GenJournalLineToCheck.SetRange("Document No.", RefGenJournalLine."Document No.");
                                GenJournalLineToCheck.SetFilter("Ship-to Code", '<>%1', '');
                                if GenJournalLineToCheck.FindFirst() then begin
                                    ShipToAddress.Get(GenJournalLineToCheck."Account No.", GenJournalLineToCheck."Ship-to Code");
                                    if (GenJournalLineToCheck."Ship-to GST Reg. No." = '') and (ShipToAddress."ARN No." <> '') then
                                        GenJournalLineToCheck.TestField("Ship-to GST Reg. No.");

                                    exit(GenJournalLineToCheck."Ship-to GST Reg. No.");
                                end;
                            end;
                    end;
                end;

        if InJournal then begin
            GenJournalLineCopy.Get(TemplateName, BatchName, LineNo);
            Customer.Get(GetCustomerNo(GenJournalLineCopy));

            RefGenJournalLine.Reset();
            RefGenJournalLine.SetRange("Journal Template Name", TemplateName);
            RefGenJournalLine.SetRange("Journal Batch Name", BatchName);
            RefGenJournalLine.SetRange("Document No.", GenJournalLineCopy."Document No.");
            RefGenJournalLine.SetFilter("GST Group Code", '<>%1', '');
            RefGenJournalLine.FindFirst();

            case RefGenJournalLine."GST Place of Supply" of
                RefGenJournalLine."GST Place of Supply"::"Bill-to Address", RefGenJournalLine."GST Place of Supply"::"Location Address":
                    begin
                        if (Customer."GST Registration No." = '') and (Customer."ARN No." <> '') then
                            GenJournalLineCopy.TestField("Customer GST Reg. No.");

                        exit(Customer."GST Registration No.");
                    end;
                RefGenJournalLine."GST Place of Supply"::"Ship-to Address":
                    begin
                        GenJournalLineToCheck.SetRange("Document No.", RefGenJournalLine."Document No.");
                        GenJournalLineToCheck.SetFilter("Ship-to Code", '<>%1', '');
                        if GenJournalLineToCheck.FindFirst() then begin
                            ShipToAddress.Get(GenJournalLineToCheck."Account No.", GenJournalLineToCheck."Ship-to Code");

                            if (GenJournalLineToCheck."Ship-to GST Reg. No." = '') and (ShipToAddress."ARN No." <> '') then
                                GenJournalLineToCheck.TestField("Ship-to GST Reg. No.");

                            exit(GenJournalLineToCheck."Ship-to GST Reg. No.");
                        end;
                    end;
            end;
        end;
    end;

    local procedure GetVendorNo(GenJournalLine: Record "Gen. Journal Line"): Code[20]
    begin
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor then
            exit(GenJournalLine."Account No.");

        if GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::Vendor then
            exit(GenJournalLine."Bal. Account No.");
    end;

    local procedure GetCustomerNo(GenJournalLine: Record "Gen. Journal Line"): Code[20]
    begin
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer then
            exit(GenJournalLine."Account No.");

        if GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::Customer then
            exit(GenJournalLine."Bal. Account No.");
    end;

    local procedure GetPlaceOfSupplyRegistrationNoPurchase(
        PurchDocType: Enum "Purchase Document Type";
        DocumentNo: Code[20];
        IsInJournal: Boolean;
        TemplateName: Code[10];
        BatchName: Code[10];
        LineNo: Integer) GSTRegistrationNo: Code[20]
    var
        Vendor: Record Vendor;
        OrderAddress: Record "Order Address";
        PurchaseHeader: Record "Purchase Header";
    begin
        if not IsInJournal then
            if DocumentNo <> '' then begin
                PurchaseHeader.Get(PurchDocType, DocumentNo);
                if PurchaseHeader."Order Address Code" <> '' then begin
                    GSTRegistrationNo := PurchaseHeader."Order Address GST Reg. No.";
                    if GSTRegistrationNo = '' then
                        if OrderAddress.Get(PurchaseHeader."Buy-from Vendor No.", PurchaseHeader."Order Address Code") and (OrderAddress."ARN No." <> '') then
                            PurchaseHeader.TestField("Order Address GST Reg. No.");
                end else begin
                    GSTRegistrationNo := PurchaseHeader."Vendor GST Reg. No.";
                    if GSTRegistrationNo = '' then
                        if Vendor.Get(PurchaseHeader."Buy-from Vendor No.") and (Vendor."ARN No." <> '') then
                            PurchaseHeader.TestField("Vendor GST Reg. No.");
                end;
            end;

        if IsInJournal then begin
            RefGenJournalLine.Get(TemplateName, BatchName, LineNo);
            Vendor.Get(GetVendorNo(RefGenJournalLine));
            if RefGenJournalLine."Order Address Code" <> '' then begin
                GSTRegistrationNo := RefGenJournalLine."Order Address GST Reg. No.";
                if GSTRegistrationNo = '' then
                    if OrderAddress.Get(Vendor."No.", RefGenJournalLine."Order Address Code") and (OrderAddress."ARN No." <> '') then
                        RefGenJournalLine.TestField("Order Address GST Reg. No.");
            end else begin
                GSTRegistrationNo := Vendor."GST Registration No.";
                if GSTRegistrationNo = '' then
                    if Vendor."ARN No." <> '' then
                        RefGenJournalLine.TestField("Vendor GST Reg. No.");
            end;
        end;

        exit(GSTRegistrationNo);
    end;

    local procedure CheckGSTAppliedDocumentPurchase(
        AppliedDocumentNo: Code[20];
        IsInJournal: Boolean;
        PurchDocType: Enum "Purchase Document Type";
        DocumentNo: Code[20];
        TemplateName: Code[10];
        Batchname: Code[10];
        LineNo: Integer)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        GenJnlLine: Record "Gen. Journal Line";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GenJnlAccType: Enum "Gen. Journal Account Type";
    begin
        if not IsInJournal then begin
            if not PurchInvHeader.Get(AppliedDocumentNo) then
                Error(PurchaseDocumentErr);
            if PurchaseHeader.Get(PurchDocType, DocumentNo) then begin
                if PurchaseHeader."Posting Date" < PurchInvHeader."Posting Date" then
                    Error(PostingDateErr, PurchInvHeader."No.", PurchaseHeader."No.");

                CheckGSTAccountingPeriod(DocumentNo, PurchaseHeader."Posting Date", PurchInvHeader."Posting Date");
            end else begin
                GenJnlLine.Get(TemplateName, Batchname, LineNo);
                if GenJnlLine."Posting Date" < PurchInvHeader."Posting Date" then
                    Error(PostingDateErr, DocumentNo, GenJnlLine."Document No.");

                CheckGSTAccountingPeriod(DocumentNo, GenJnlLine."Posting Date", PurchInvHeader."Posting Date");
            end;
        end else begin
            DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
            DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
            DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
            DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
            DetailedGSTLedgerEntry.SetRange("Source No.", GetSourceNo(GenJnlAccType::Vendor, GenJnlLine));
            DetailedGSTLedgerEntry.SetRange("Journal Entry", true);
            if DetailedGSTLedgerEntry.FindFirst() then begin
                GenJnlLine.Get(TemplateName, Batchname, LineNo);
                if GenJnlLine."Posting Date" < DetailedGSTLedgerEntry."Posting Date" then
                    Error(PostingDateErr, DocumentNo, GenJnlLine."Document No.");

                CheckGSTAccountingPeriod(DocumentNo, GenJnlLine."Posting Date", DetailedGSTLedgerEntry."Posting Date");
            end;
        end;
    end;

    local procedure CheckGSTAppliedDocumentSales(
        AppliedDocumentNo: Code[20];
        InJournal: Boolean;
        SalesDocType: Enum "Sales Document Type";
        DocumentNo: Code[20];
        TemplateName: Code[10];
        Batchname: Code[10];
        LineNo: Integer)
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        GenJnlLine: Record "Gen. Journal Line";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GenJnlAccType: Enum "Gen. Journal Account Type";
        PurchDocType: Enum "Purchase Document Type";
    begin
        if not InJournal then begin
            if not SalesInvoiceHeader.Get(AppliedDocumentNo) then
                Error(SalesDocumentErr);

            if SalesHeader.Get(SalesDocType, DocumentNo) then begin
                if SalesHeader."Posting Date" < SalesInvoiceHeader."Posting Date" then
                    Error(PostingDateErr, SalesInvoiceHeader."No.", SalesHeader."No.");

                if IsGSTApplicable("Transaction Type Enum"::Sales, PurchDocType, SalesHeader."Document Type", SalesHeader."No.") then
                    if IsGSTApplicable("Transaction Type Enum"::Sales, PurchDocType, SalesDocType, SalesInvoiceHeader."No.") then begin
                        CheckGSTAccountingPeriod(DocumentNo, SalesHeader."Posting Date", SalesInvoiceHeader."Posting Date");

                        if SalesInvoiceHeader."GST Without Payment of Duty" <> SalesHeader."GST Without Payment of Duty" then
                            Error(DiffGSTWithoutPaymentOfDutyErr);
                    end;
            end else
                if GenJnlLine.Get(TemplateName, Batchname, LineNo) then begin
                    if GenJnlLine."Posting Date" < SalesInvoiceHeader."Posting Date" then
                        Error(PostingDateErr, DocumentNo, GenJnlLine."Document No.");

                    CheckGSTAccountingPeriod(DocumentNo, GenJnlLine."Posting Date", SalesInvoiceHeader."Posting Date");
                    if SalesInvoiceHeader."GST Without Payment of Duty" <> GenJnlLine."GST Without Payment of Duty" then
                        Error(DiffGSTWithoutPaymentOfDutyErr);
                end;
        end else begin
            GenJnlLine.Get(TemplateName, Batchname, LineNo);
            DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);
            DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
            DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
            DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
            DetailedGSTLedgerEntry.SetRange("Source No.", GetSourceNo(genjnlacctype::Customer, GenJnlLine));
            DetailedGSTLedgerEntry.SetRange("Journal Entry", true);
            if DetailedGSTLedgerEntry.FindFirst() then begin
                GenJnlLine.Get(TemplateName, Batchname, LineNo);
                if GenJnlLine."Posting Date" < DetailedGSTLedgerEntry."Posting Date" then
                    Error(PostingDateErr, DocumentNo, GenJnlLine."Document No.");

                CheckGSTAccountingPeriod(DocumentNo, GenJnlLine."Posting Date", DetailedGSTLedgerEntry."Posting Date");
                if GenJnlLine."GST Without Payment of Duty" <> DetailedGSTLedgerEntry."GST Without Payment of Duty" then
                    Error(DiffGSTWithoutPaymentOfDutyErr);
            end;
        end;
    end;

    local procedure GetSourceNo(
        GenJnlAccType: Enum "Gen. Journal Account Type";
        GenJournalLine: Record "Gen. Journal Line"): Code[20]
    begin
        if GenJournalLine."Account Type" = GenJnlAccType then
            exit(GenJournalLine."Account No.");

        if GenJournalLine."Bal. Account Type" = GenJnlAccType then
            exit(GenJournalLine."Bal. Account No.");
    end;

    local procedure GetLocationRegistrationNo(
        TransType: Enum "Transaction Type Enum";
        PurchDocType: Enum "Purchase Document Type";
        SalesDocType: Enum "Sales Document Type";
        DocumentNo: Code[20];
        CurrentDocument: Boolean;
        IsInJournal: Boolean): Code[20]
    begin
        exit(
            GetLocationRegistrationNo(
                TransType,
                PurchDocType,
                SalesDocType,
                DocumentNo,
                CurrentDocument,
                IsInJournal,
                '',
                '',
                0));
    end;

    local procedure GetLocationRegistrationNo(
        TransType: Enum "Transaction Type Enum";
        PurchDocType: Enum "Purchase Document Type";
        SalesDocType: Enum "Sales Document Type";
        DocumentNo: Code[20];
        CurrentDocument: Boolean;
        InJournal: Boolean;
        TemplateName: Code[10];
        BatchName: Code[10];
        LineNo: Integer): Code[20]
    var
        SalesHeader: Record "Sales Header";
        ServiceHeader: Record "Service Header";
        PurchaseHeader: Record "Purchase Header";
        GenJournalLine: Record "Gen. Journal Line";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        ServiceDocType: Enum "Service Document Type";
    begin
        if CurrentDocument then
            case TransType of
                "Transaction Type Enum"::Purchase:
                    if DocumentNo <> '' then
                        if not InJournal then begin
                            PurchaseHeader.Get(PurchDocType, DocumentNo);
                            exit(PurchaseHeader."Location GST Reg. No.");
                        end else begin
                            GenJournalLine.Get(TemplateName, BatchName, LineNo);
                            exit(GenJournalLine."Location GST Reg. No.");
                        end;
                "Transaction Type Enum"::Sales:
                    if DocumentNo <> '' then begin
                        if not InJournal then
                            if SalesHeader.Get(SalesDocType, DocumentNo) then
                                exit(SalesHeader."Location GST Reg. No.")
                            else begin
                                GenJournalLine.Get(TemplateName, BatchName, LineNo);
                                exit(GenJournalLine."Location GST Reg. No.");
                            end;

                        if InJournal then begin
                            GenJournalLine.Get(TemplateName, BatchName, LineNo);
                            exit(GenJournalLine."Location GST Reg. No.");
                        end;
                    end;
                TransType::Service:
                    if DocumentNo <> '' then begin
                        ServiceDocType := SalesDocumentType2ServiceDocumentTypeEnum(SalesDocType);
                        if ServiceHeader.Get(ServiceDocType, DocumentNo) then
                            exit(ServiceHeader."Location GST Reg. No.");
                    end;
            end
        else begin
            DetailedGSTLedgerEntry.SetCurrentKey("Transaction Type", "Entry Type", "Document No.", "Document Line No.");
            if TransType = "Transaction Type Enum"::Purchase then
                DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase)
            else
                DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);

            DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
            DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
            DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
            DetailedGSTLedgerEntry.SetRange("Journal Entry", InJournal);
            DetailedGSTLedgerEntry.FindFirst();

            exit(DetailedGSTLedgerEntry."Location  Reg. No.");
        end;
    end;

    local procedure GetGSTJurisdiction(
        TransType: Enum "Transaction Type Enum";
        PurchDocType: Enum "Purchase Document Type";
        SalesDocType: Enum "Sales Document Type";
        DocumentNo: Code[20];
        CurrentDocument: Boolean;
        InJournal: Boolean): Enum "GST Jurisdiction Type"
    begin
        exit(
            GetGSTJurisdiction(
                TransType,
                PurchDocType,
                SalesDocType,
                DocumentNo,
                CurrentDocument,
                InJournal,
                '',
                '',
                0));
    end;

    local procedure GetGSTJurisdiction(
        TransType: Enum "Transaction Type Enum";
        PurchDocType: Enum "Purchase Document Type";
        SalesDocType: Enum "Sales Document Type";
        DocumentNo: Code[20];
        CurrentDocument: Boolean;
        InJournal: Boolean;
        TemplateName: Code[10];
        BatchName: Code[10];
        LineNo: Integer): Enum "GST Jurisdiction Type"
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GenJournalLine: Record "Gen. Journal Line";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTDocType: Enum "GST Document Type";
        ServiceDocType: Enum "Service Document Type";
    begin
        if CurrentDocument then
            case TransType of
                "Transaction Type Enum"::Purchase:
                    if not InJournal then begin
                        if DocumentNo <> '' then
                            PurchaseHeader.Get(PurchDocType, DocumentNo);

                        PurchaseLine.Reset();
                        PurchaseLine.SetRange("Document Type", PurchDocType);
                        PurchaseLine.SetRange("Document No.", DocumentNo);
                        PurchaseLine.SetFilter(Type, '<>%1', Type::" ");
                        PurchaseLine.SetRange("Non-GST Line", false);
                        if PurchaseLine.FindFirst() then
                            exit(PurchaseLine."GST Jurisdiction Type");
                    end else
                        if InJournal and (DocumentNo <> '') then begin
                            GenJournalLine.Get(TemplateName, BatchName, LineNo);

                            exit(GenJournalLine."GST Jurisdiction Type");
                        end;
                "Transaction Type Enum"::Sales:
                    begin
                        if not InJournal and (DocumentNo <> '') then
                            if SalesHeader.Get(SalesDocType, DocumentNo) then begin
                                SalesLine.Reset();
                                SalesLine.SetRange("Document Type", SalesDocType);
                                SalesLine.SetRange("Document No.", DocumentNo);
                                SalesLine.SetFilter(Type, '<>%1', SalesLine.Type::" ");
                                SalesLine.SetRange("Non-GST Line", false);
                                if SalesLine.FindFirst() then
                                    exit(SalesLine."GST Jurisdiction Type");
                            end else begin
                                GenJournalLine.Get(TemplateName, BatchName, LineNo);
                                exit(GenJournalLine."GST Jurisdiction Type");
                            end;

                        if InJournal and (DocumentNo <> '') then begin
                            GenJournalLine.Get(TemplateName, BatchName, LineNo);
                            exit(GenJournalLine."GST Jurisdiction Type");
                        end;
                    end;
                "Transaction Type Enum"::Service:
                    begin
                        ServiceDocType := SalesDocumentType2ServiceDocumentTypeEnum(SalesDocType);
                        if DocumentNo <> '' then
                            ServiceHeader.Get(ServiceDocType, DocumentNo);

                        ServiceLine.Reset();
                        ServiceLine.SetRange("Document Type", ServiceDocType);
                        ServiceLine.SetRange("Document No.", DocumentNo);
                        ServiceLine.SetFilter(Type, '<>%1', ServiceLine.Type::" ");
                        ServiceLine.SetRange("Non-GST Line", false);
                        if ServiceLine.FindFirst() then
                            exit(ServiceLine."GST Jurisdiction Type");
                    end;
            end
        else begin
            DetailedGSTLedgerEntry.Reset();
            if TransType = "Transaction Type Enum"::Purchase then begin
                GSTDocType := PurchDocumentType2GSTDocumentType(PurchDocType);

                DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
                DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocType);
            end else begin
                GSTDocType := SalesDocumentType2GSTDocumentType(SalesDocType);

                DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);
                DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocType);
            end;

            DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
            DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
            DetailedGSTLedgerEntry.SetRange("Journal Entry", InJournal);
            DetailedGSTLedgerEntry.FindFirst();

            exit(DetailedGSTLedgerEntry."GST Jurisdiction Type");
        end;
    end;

    local procedure IsGSTFromJournal(
        TransType: Enum "Transaction Type Enum";
        DocumentNo: Code[20];
        VendorNo: Code[20]): Boolean
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailLedgerTransactioType: Enum "Detail Ledger Transaction Type";
    begin
        DetailLedgerTransactioType := TransactionTypeEnum2DetailLedgerTransactionType(TransType);

        DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailLedgerTransactioType);
        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
        DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
        DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
        DetailedGSTLedgerEntry.SetRange("Source No.", VendorNo);
        if DetailedGSTLedgerEntry.FindFirst() then
            exit(DetailedGSTLedgerEntry."Journal Entry");
    end;

    local procedure GetCurrencyCode(
        TransType: Enum "Transaction Type Enum";
        GenJnlDocType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
        PartyNo: Code[20]): Code[10]
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        case TransType of
            "Transaction Type Enum"::Purchase:
                begin
                    VendorLedgerEntry.SetCurrentKey("Vendor No.", "Document Type", "Document No.", "GST on Advance Payment");
                    VendorLedgerEntry.SetRange("Vendor No.", PartyNo);
                    VendorLedgerEntry.SetRange("Document Type", GenJnlDocType);
                    VendorLedgerEntry.SetRange("Document No.", DocumentNo);
                    if VendorLedgerEntry.FindFirst() then
                        exit(VendorLedgerEntry."Currency Code");
                end;
            "Transaction Type Enum"::Sales,
            "Transaction Type Enum"::Service:
                begin
                    CustLedgerEntry.SetCurrentKey("Customer No.", "Document Type", "Document No.", "GST on Advance Payment");
                    CustLedgerEntry.SetRange("Customer No.", PartyNo);
                    CustLedgerEntry.SetRange("Document Type", GenJnlDocType);
                    CustLedgerEntry.SetRange("Document No.", DocumentNo);
                    if CustLedgerEntry.FindFirst() then
                        exit(CustLedgerEntry."Currency Code");
                end;
        end;
    end;

    local procedure CheckGSTAccountingPeriod(DocumentNo: Code[20]; PostingDate: Date; InvoicePostingDate: Date)
    var
        GSTAccountingPeriod: Record "Tax Accounting Period";
    begin
        GSTAccountingPeriod.Reset();
        GSTAccountingPeriod.SetRange("Tax Type Code", 'GST');
        GSTAccountingPeriod.SetFilter("Starting Date", '<=%1', InvoicePostingDate);
        GSTAccountingPeriod.SetFilter("Ending Date", '>=%1', InvoicePostingDate);
        GSTAccountingPeriod.FindLast();

        if (GSTAccountingPeriod."Credit Memo Locking Date" = 0D) and (GSTAccountingPeriod."Annual Return Filed Date" = 0D) then
            Error(
                DateErr,
                GSTAccountingPeriod.FieldCaption("Credit Memo Locking Date"),
                GSTAccountingPeriod.FieldCaption("Annual Return Filed Date"));

        if (GSTAccountingPeriod."Annual Return Filed Date" <> 0D) and (GSTAccountingPeriod."Credit Memo Locking Date" <> 0D) then begin
            if (GSTAccountingPeriod."Annual Return Filed Date" = GSTAccountingPeriod."Credit Memo Locking Date") and
                (PostingDate >= GSTAccountingPeriod."Credit Memo Locking Date")
            then
                Error(
                    EqualDateLockErr,
                    DocumentNo,
                    GSTAccountingPeriod.FieldCaption("Credit Memo Locking Date"),
                    GSTAccountingPeriod.FieldCaption("Annual Return Filed Date"),
                    GSTAccountingPeriod."Credit Memo Locking Date");

            if (GSTAccountingPeriod."Annual Return Filed Date" > GSTAccountingPeriod."Credit Memo Locking Date") and
                (PostingDate >= GSTAccountingPeriod."Credit Memo Locking Date")
            then
                Error(
                    DateLockErr,
                    DocumentNo,
                    GSTAccountingPeriod.FieldCaption("Credit Memo Locking Date"),
                    GSTAccountingPeriod."Credit Memo Locking Date");

            if (GSTAccountingPeriod."Annual Return Filed Date" < GSTAccountingPeriod."Credit Memo Locking Date") and
                (PostingDate >= GSTAccountingPeriod."Annual Return Filed Date")
            then
                Error(
                    DateLockErr,
                    DocumentNo,
                    GSTAccountingPeriod.FieldCaption("Annual Return Filed Date"),
                    GSTAccountingPeriod."Annual Return Filed Date");
        end;

        if (GSTAccountingPeriod."Annual Return Filed Date" = 0D) and (GSTAccountingPeriod."Credit Memo Locking Date" <> 0D) then
            if PostingDate >= GSTAccountingPeriod."Credit Memo Locking Date" then
                Error(
                    DateLockErr,
                    DocumentNo,
                    GSTAccountingPeriod.FieldCaption("Credit Memo Locking Date"),
                    GSTAccountingPeriod."Credit Memo Locking Date");

        if (GSTAccountingPeriod."Annual Return Filed Date" <> 0D) and (GSTAccountingPeriod."Credit Memo Locking Date" = 0D) then
            if PostingDate >= GSTAccountingPeriod."Annual Return Filed Date" then
                Error(
                    DateLockErr,
                    DocumentNo,
                    GSTAccountingPeriod.FieldCaption("Annual Return Filed Date"),
                    GSTAccountingPeriod."Annual Return Filed Date");
    end;

    local procedure CheckGSTAppliedDocumentPurchDocToJournals(
        AppliedDocumentNo: Code[20];
        DocumentNo: Code[20];
        PurchDocType: Enum "Purchase Document Type")
    var
        PurchaseHeader: Record "Purchase Header";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTDocumentType: Enum "GST Document Type";
        SalesDocType: Enum "Sales Document Type";
    begin
        GSTDocumentType := PurchDocumentType2GSTDocumentType(PurchDocType);

        DetailedGSTLedgerEntry.Reset();
        DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
        DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocumentType);
        DetailedGSTLedgerEntry.SetRange("Document No.", AppliedDocumentNo);
        DetailedGSTLedgerEntry.SetRange("Journal Entry", true);
        DetailedGSTLedgerEntry.FindFirst();

        if PurchaseHeader.Get(PurchDocType, DocumentNo) then begin
            if PurchaseHeader."Posting Date" < DetailedGSTLedgerEntry."Posting Date" then
                Error(PostingDateErr, DetailedGSTLedgerEntry."No.", PurchaseHeader."No.");

            if IsGSTApplicable("Transaction Type Enum"::Purchase, PurchaseHeader."Document Type", SalesDocType, PurchaseHeader."No.") then
                CheckGSTAccountingPeriod(DocumentNo, PurchaseHeader."Posting Date", DetailedGSTLedgerEntry."Posting Date");
        end;
    end;

    local procedure CheckGSTAppliedDocumentSalesDocToJournals(
        AppliedDocumentNo: Code[20];
        DocumentNo: Code[20];
        SalesDocType: Enum "Sales Document Type")
    var
        SalesHeader: Record "Sales Header";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTDocType: Enum "GST Document Type";
        PurchDocType: Enum "Purchase Document Type";
    begin
        GSTDocType := SalesDocumentType2GSTDocumentType(SalesDocType);

        DetailedGSTLedgerEntry.Reset();
        DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);
        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
        DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocType);
        DetailedGSTLedgerEntry.SetRange("Document No.", AppliedDocumentNo);
        DetailedGSTLedgerEntry.SetRange("Journal Entry", true);
        DetailedGSTLedgerEntry.FindFirst();

        if SalesHeader.Get(SalesDocType, DocumentNo) then begin
            if SalesHeader."Posting Date" < DetailedGSTLedgerEntry."Posting Date" then
                Error(PostingDateErr, DetailedGSTLedgerEntry."No.", SalesHeader."No.");

            if IsGSTApplicable("Transaction Type Enum"::Sales, PurchDocType, SalesHeader."Document Type", SalesHeader."No.") then
                CheckGSTAccountingPeriod(DocumentNo, SalesHeader."Posting Date", DetailedGSTLedgerEntry."Posting Date");

            if DetailedGSTLedgerEntry."GST Without Payment of Duty" <> SalesHeader."GST Without Payment of Duty" then
                Error(DiffGSTWithoutPaymentOfDutyErr);
        end;
    end;

    local procedure GetPlaceOfSupplyRegistrationNoDocToJournals(
        TransType: Enum "Transaction Type Enum";
        PurchDocType: Enum "Purchase Document Type";
        SalesDocType: Enum "Sales Document Type";
        DocumentNo: Code[20];
        CurrentDocument: Boolean;
        IsInJournal: Boolean): Code[20]
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        ServiceDocType: Enum "Service Document Type";
        GSTDocType: Enum "GST Document Type";
    begin
        if CurrentDocument then
            case TransType of
                "Transaction Type Enum"::Sales:
                    exit(GetPlaceOfSupplyRegistrationNoSales(SalesDocType, DocumentNo, IsInJournal, '', '', 0));
                "Transaction Type Enum"::Purchase:
                    exit(GetPlaceOfSupplyRegistrationNoPurchase(PurchDocType, DocumentNo, IsInJournal, '', '', 0));
                "Transaction Type Enum"::Service:
                    begin
                        ServiceDocType := SalesDocumentType2ServiceDocumentTypeEnum(SalesDocType);
                        exit(GetPlaceOfSupplyRegistrationNoService(ServiceDocType, DocumentNo));
                    end;
            end
        else begin
            DetailedGSTLedgerEntry.Reset();
            if TransType = "Transaction Type Enum"::Purchase then begin
                GSTDocType := PurchDocumentType2GSTDocumentType(PurchDocType);
                DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
            end else begin
                GSTDocType := SalesDocumentType2GSTDocumentType(SalesDocType);
                DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);
            end;

            DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
            DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocType);
            DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
            DetailedGSTLedgerEntry.SetRange("Journal Entry", true);
            DetailedGSTLedgerEntry.FindFirst();

            if (DetailedGSTLedgerEntry."Buyer/Seller Reg. No." = '') and (DetailedGSTLedgerEntry."ARN No." <> '') then
                Error(UpdateGSTNosErr, DetailedGSTLedgerEntry."Document No.");

            exit(DetailedGSTLedgerEntry."Buyer/Seller Reg. No.");
        end;
    end;

    local procedure GetLocationRegistrationNoDocToJournals(
        TransType: Enum "Transaction Type Enum";
        PurchDocType: Enum "Purchase Document Type";
        SalesDocType: Enum "Sales Document Type";
        DocumentNo: Code[20];
        CurrentDocument: Boolean;
        IsInJournal: Boolean): Code[20]
    begin
        exit(
            GetLocationRegistrationNoDocToJournals(
                TransType,
                PurchDocType,
                SalesDocType,
                DocumentNo,
                CurrentDocument,
                IsInJournal,
                '',
                '',
                0));
    end;

    local procedure GetLocationRegistrationNoDocToJournals(
        TransType: Enum "Transaction Type Enum";
        PurchDocType: Enum "Purchase Document Type";
        SalesDocType: Enum "Sales Document Type";
        DocumentNo: Code[20];
        CurrentDocument: Boolean;
        InJournal: Boolean;
        TemplateName: Code[10];
        BatchName: Code[10];
        LineNo: Integer): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        ServiceHeader: Record "Service Header";
        GenJournalLine: Record "Gen. Journal Line";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        ServiceDocType: Enum "Service Document Type";
    begin
        if CurrentDocument then
            case TransType of
                "Transaction Type Enum"::Purchase:
                    if DocumentNo <> '' then
                        if not InJournal then begin
                            PurchaseHeader.Get(PurchDocType, DocumentNo);
                            exit(PurchaseHeader."Location GST Reg. No.");
                        end else begin
                            GenJournalLine.Get(TemplateName, BatchName, LineNo);
                            exit(GenJournalLine."Location GST Reg. No.");
                        end;
                "Transaction Type Enum"::Sales:
                    if DocumentNo <> '' then
                        if not InJournal then begin
                            if SalesHeader.Get(SalesDocType, DocumentNo) then
                                exit(SalesHeader."Location GST Reg. No.")
                            else begin
                                GenJournalLine.Get(TemplateName, BatchName, LineNo);
                                exit(GenJournalLine."Location GST Reg. No.");
                            end;
                        end else begin
                            GenJournalLine.Get(TemplateName, BatchName, LineNo);
                            exit(GenJournalLine."Location GST Reg. No.");
                        end;
                "Transaction Type Enum"::Service:
                    if DocumentNo <> '' then begin
                        ServiceDocType := SalesDocumentType2ServiceDocumentTypeEnum(SalesDocType);
                        if ServiceHeader.Get(ServiceDocType, DocumentNo) then
                            exit(ServiceHeader."Location GST Reg. No.");
                    end;
            end
        else begin
            DetailedGSTLedgerEntry.SetCurrentKey("Transaction Type", "Entry Type", "Document No.", "Document Line No.");
            if TransType = "Transaction Type Enum"::Purchase then
                DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase)
            else
                DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);

            DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
            DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
            DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
            DetailedGSTLedgerEntry.SetRange("Journal Entry", true);
            DetailedGSTLedgerEntry.FindFirst();

            exit(DetailedGSTLedgerEntry."Location  Reg. No.");
        end;
    end;

    local procedure GetGSTJurisdictionDocToJournals(
        TransType: Enum "Transaction Type Enum";
        PurchDocType: Enum "Purchase Document Type";
        SalesDocType: Enum "Sales Document Type";
        DocumentNo: Code[20];
        CurrentDocument: Boolean;
        IsInJournal: Boolean): Enum "GST Jurisdiction Type"
    begin
        exit(
            GetGSTJurisdictionDocToJournals(
                TransType,
                PurchDocType,
                SalesDocType,
                DocumentNo,
                CurrentDocument,
                IsInJournal,
                '',
                '',
                0
                ));
    end;

    local procedure GetGSTJurisdictionDocToJournals(
        TransType: Enum "Transaction Type Enum";
        PurchDocType: Enum "Purchase Document Type";
        SalesDocType: Enum "Sales Document Type";
        DocumentNo: Code[20];
        CurrentDocument: Boolean;
        InJournal: Boolean;
        TemplateName: Code[10];
        BatchName: Code[10];
        LineNo: Integer): Enum "GST Jurisdiction Type"
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GenJournalLine: Record "Gen. Journal Line";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        ServiceDocType: Enum "Service Document Type";
        GSTDocType: Enum "GST Document Type";
    begin
        if CurrentDocument then
            case TransType of
                "Transaction Type Enum"::Sales:
                    if DocumentNo <> '' then
                        if not InJournal then begin
                            if SalesHeader.Get(SalesDocType, DocumentNo) then begin
                                SalesLine.Reset();
                                SalesLine.SetRange("Document Type", SalesDocType);
                                SalesLine.SetRange("Document No.", DocumentNo);
                                SalesLine.SetFilter(Type, '<>%1', SalesLine.Type::" ");
                                if SalesLine.FindFirst() then
                                    exit(SalesLine."GST Jurisdiction Type");
                            end else begin
                                GenJournalLine.Get(TemplateName, BatchName, LineNo);
                                exit(GenJournalLine."GST Jurisdiction Type");
                            end;
                        end else begin
                            GenJournalLine.Get(TemplateName, BatchName, LineNo);
                            exit(GenJournalLine."GST Jurisdiction Type");
                        end;
                "Transaction Type Enum"::Purchase:
                    if DocumentNo <> '' then
                        if not InJournal then begin
                            PurchaseHeader.Get(PurchDocType, DocumentNo);

                            PurchaseLine.Reset();
                            PurchaseLine.SetRange("Document Type", PurchDocType);
                            PurchaseLine.SetRange("Document No.", DocumentNo);
                            PurchaseLine.SetFilter(Type, '<>%1', Type::" ");
                            if PurchaseLine.FindFirst() then
                                exit(PurchaseLine."GST Jurisdiction Type");
                        end else begin
                            GenJournalLine.Get(TemplateName, BatchName, LineNo);
                            exit(GenJournalLine."GST Jurisdiction Type");
                        end;
                "Transaction Type Enum"::Service:
                    if DocumentNo <> '' then
                        if ServiceHeader.Get(ServiceDocType, DocumentNo) then begin
                            ServiceDocType := SalesDocumentType2ServiceDocumentTypeEnum(SalesDocType);
                            ServiceLine.Reset();
                            ServiceLine.SetRange("Document Type", ServiceDocType);
                            ServiceLine.SetRange("Document No.", DocumentNo);
                            ServiceLine.SetFilter(Type, '<>%1', ServiceLine.Type::" ");
                            if ServiceLine.FindFirst() then
                                exit(ServiceLine."GST Jurisdiction Type");
                        end;
            end
        else begin
            DetailedGSTLedgerEntry.Reset();
            if TransType = "Transaction Type Enum"::Purchase then begin
                GSTDocType := PurchDocumentType2GSTDocumentType(PurchDocType);
                DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase)
            end else begin
                GSTDocType := SalesDocumentType2GSTDocumentType(SalesDocType);
                DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);
            end;

            DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
            DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocType);
            DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
            DetailedGSTLedgerEntry.SetRange("Journal Entry", true);
            DetailedGSTLedgerEntry.FindFirst();

            exit(DetailedGSTLedgerEntry."GST Jurisdiction Type");
        end;
    end;

    local procedure CheckGSTSalesCrMemoJournalValidationReference(GenJournalLine: Record "Gen. Journal Line"; ReferenceInvoiceNo: Code[20])
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesLine: Record "Sales Line";
        CurrCustNo: Code[20];
        CurrDocumentGSTRegNo: Code[20];
        PostedDocumentGSTRegNo: Code[20];
        CurrDocLocRegNo: Code[20];
        PostedDocLocRegNo: Code[20];
        CurrDocGSTJurisdiction: Enum "GST Jurisdiction Type";
        PostedDocGSTJurisdiction: Enum "GST Jurisdiction Type";
        PostedCurrencyCode: Code[10];
        InJournal: Boolean;
        SalesDocType: Enum "Sales Document Type";
        PurchDocType: Enum "Purchase Document Type";
    begin
        if not (GenJournalLine."Document Type" in [
            GenJournalLine."Document Type"::"Credit Memo",
            GenJournalLine."Document Type"::Invoice])
        then
            exit;

        CurrCustNo := GetCustomerNo(GenJournalLine);
        SalesDocType := GenJnlDocumentType2DocumentTypeEnum(GenJournalLine."Document Type");

        if IsGSTApplicableJournal(GenJournalLine) then
            if ReferenceInvoiceNo <> '' then begin
                InJournal := IsGSTFromJournal("Transaction Type Enum"::Sales, ReferenceInvoiceNo, CurrCustNo);

                if not InJournal and
                    SalesInvoiceHeader.Get(ReferenceInvoiceNo) and
                    IsGSTApplicable("Transaction Type Enum"::Sales, PurchDocType, SalesDocType, SalesInvoiceHeader."No.") or
                    InJournal
                then begin
                    CheckGSTAppliedDocument(
                        "Transaction Type Enum"::Sales,
                        PurchDocType,
                        SalesDocType,
                        GenJournalLine."Document No.",
                        ReferenceInvoiceNo,
                        InJournal,
                        GenJournalLine."Journal Template Name",
                        GenJournalLine."Journal Batch Name",
                        GenJournalLine."Line No.");

                    CurrDocumentGSTRegNo := GetPlaceOfSupplyRegistrationNo(
                        "Transaction Type Enum"::Sales,
                        PurchDocType,
                        SalesDocType,
                        GenJournalLine."Document No.",
                        true,
                        InJournal,
                        GenJournalLine."Journal Template Name",
                        GenJournalLine."Journal Batch Name",
                        GenJournalLine."Line No.");

                    PostedDocumentGSTRegNo := GetPlaceOfSupplyRegistrationNo(
                        "Transaction Type Enum"::Sales,
                        PurchDocType,
                        SalesDocType::Invoice,
                        ReferenceInvoiceNo,
                        false,
                        InJournal);

                    CurrDocLocRegNo := GetLocationRegistrationNo(
                        "Transaction Type Enum"::Sales,
                        PurchDocType,
                        SalesDocType,
                        GenJournalLine."Document No.",
                        true,
                        InJournal,
                        GenJournalLine."Journal Template Name",
                        GenJournalLine."Journal Batch Name",
                        GenJournalLine."Line No.");

                    PostedDocLocRegNo := GetLocationRegistrationNo(
                        "Transaction Type Enum"::Sales,
                        PurchDocType,
                        SalesDocType,
                        ReferenceInvoiceNo,
                        false,
                        InJournal);

                    CurrDocGSTJurisdiction := GetGSTJurisdiction(
                        "Transaction Type Enum"::Sales,
                        PurchDocType,
                        SalesDocType,
                        GenJournalLine."Document No.",
                        true,
                        InJournal,
                        GenJournalLine."Journal Template Name",
                        GenJournalLine."Journal Batch Name",
                        GenJournalLine."Line No.");

                    PostedDocGSTJurisdiction := GetGSTJurisdiction(
                        "Transaction Type Enum"::Sales,
                        PurchDocType,
                        SalesDocType::Invoice,
                        ReferenceInvoiceNo,
                        false,
                        InJournal);

                    PostedCurrencyCode := GetCurrencyCode(
                        "Transaction Type Enum"::Sales,
                        SalesDocType::Invoice,
                        ReferenceInvoiceNo,
                        CurrCustNo);

                    if CurrDocumentGSTRegNo <> PostedDocumentGSTRegNo then
                        Error(DiffGSTRegNoErr, SalesLine.FieldCaption("GST Place of Supply"), ReferenceInvoiceNo);

                    if CurrDocLocRegNo <> PostedDocLocRegNo then
                        Error(DiffGSTRegNoErr, SalesLine.FieldCaption("Location Code"), ReferenceInvoiceNo);

                    if CurrDocGSTJurisdiction <> PostedDocGSTJurisdiction then
                        Error(DiffJurisdictionErr, SalesLine.FieldCaption("GST Jurisdiction Type"));

                    if PostedCurrencyCode <> GenJournalLine."Currency Code" then
                        Error(DiffCurrencyCodeErr, SalesLine.FieldCaption("Currency Code"));
                end;
            end;
    end;

    local procedure CheckGSTSalesCrMemoValidationsOffline(
        CustLedgerEntry: Record "Cust. Ledger Entry";
        ApplyingCustLedgerEntry: Record "Cust. Ledger Entry";
        Entrys: Integer;
        ReferenceInvoiceNo: Code[20])
    var
        CustLedgerEntryInv: Record "Cust. Ledger Entry";
        CustLedgerEntryCrMemo: Record "Cust. Ledger Entry";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvHeader: Record "Sales Invoice Header";
        OriginalInvNo: Code[20];
        InvoiceFromJournal: Boolean;
        CrMemoFromJournal: Boolean;
        PurchDocType: Enum "Purchase Document Type";
        SalesDocType: Enum "Sales Document Type";
    begin
        if CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Invoice then begin
            CustLedgerEntryInv.Copy(CustLedgerEntry);
            CustLedgerEntryCrMemo.Copy(ApplyingCustLedgerEntry);
        end else begin
            CustLedgerEntryInv.Copy(ApplyingCustLedgerEntry);
            CustLedgerEntryCrMemo.Copy(CustLedgerEntry);
        end;

        InvoiceFromJournal := CustLedgerEntryInv."Journal Entry";
        CrMemoFromJournal := CustLedgerEntryCrMemo."Journal Entry";

        if not InvoiceFromJournal then
            if SalesInvoiceHeader.Get(CustLedgerEntryInv."Document No.") then;

        if not CrMemoFromJournal then
            if SalesCrMemoHeader.Get(CustLedgerEntryCrMemo."Document No.") then;

        if (SalesCrMemoHeader."No." = '') and not CrMemoFromJournal then
            SalesInvHeader.Get(CustLedgerEntryCrMemo."Document No.");

        if not InvoiceFromJournal then begin
            if SalesCrMemoHeader."No." <> '' then
                CheckSalesAppliedEntries(
                    CustLedgerEntryInv,
                    CustLedgerEntryCrMemo,
                    Database::"Sales Cr.Memo Header",
                    SalesInvHeader,
                    SalesCrMemoHeader,
                    Entrys,
                    CrMemoFromJournal)
            else
                CheckSalesAppliedEntries(
                    CustLedgerEntryInv,
                    CustLedgerEntryCrMemo,
                    Database::"Sales Invoice Header",
                    SalesInvHeader,
                    SalesCrMemoHeader,
                    Entrys,
                    CrMemoFromJournal);

            if IsGSTApplicable("Transaction Type Enum"::Sales, PurchDocType, SalesDocType, SalesInvoiceHeader."No.") then
                if SalesCrMemoHeader."No." <> '' then
                    CheckGSTSalesCrMemoValOfflineSales(
                        CustLedgerEntryCrMemo,
                        CustLedgerEntryInv,
                        Database::"Sales Cr.Memo Header",
                        SalesInvHeader,
                        SalesCrMemoHeader,
                        InvoiceFromJournal,
                        ReferenceInvoiceNo,
                        CrMemoFromJournal)
                else
                    CheckGSTSalesCrMemoValOfflineSales(
                        CustLedgerEntryCrMemo,
                        CustLedgerEntryInv,
                        Database::"Sales Invoice Header",
                        SalesInvHeader,
                        SalesCrMemoHeader,
                        InvoiceFromJournal,
                        ReferenceInvoiceNo,
                        CrMemoFromJournal);
        end;

        if InvoiceFromJournal then begin
            if SalesCrMemoHeader."No." <> '' then
                CheckSalesAppliedEntries(
                    CustLedgerEntryInv,
                    CustLedgerEntryCrMemo,
                    Database::"Sales Cr.Memo Header",
                    SalesInvHeader,
                    SalesCrMemoHeader,
                    Entrys,
                    CrMemoFromJournal)
            else
                CheckSalesAppliedEntries(
                    CustLedgerEntryInv,
                    CustLedgerEntryCrMemo,
                    Database::"Sales Invoice Header",
                    SalesInvHeader,
                    SalesCrMemoHeader,
                    Entrys,
                    CrMemoFromJournal);

            if CheckInvoiceNoFromDetGST(CustLedgerEntryCrMemo."Document No.", OriginalInvNo) then
                Error(InvoiceNoBlankErr, CustLedgerEntryCrMemo."Document No.", OriginalInvNo);

            if CustLedgerEntryInv."GST in Journal" then
                if SalesCrMemoHeader."No." <> '' then
                    CheckGSTSalesCrMemoValOfflineSales(
                        CustLedgerEntryCrMemo,
                        CustLedgerEntryInv,
                        Database::"Sales Cr.Memo Header",
                        SalesInvHeader,
                        SalesCrMemoHeader,
                        InvoiceFromJournal,
                        ReferenceInvoiceNo,
                        CrMemoFromJournal)
                else
                    CheckGSTSalesCrMemoValOfflineSales(
                        CustLedgerEntryCrMemo,
                        CustLedgerEntryInv,
                        Database::"Sales Invoice Header",
                        SalesInvHeader,
                        SalesCrMemoHeader,
                        InvoiceFromJournal,
                        ReferenceInvoiceNo,
                        CrMemoFromJournal);
        end;

        CheckGSTServiceValidation(CustLedgerEntry, ApplyingCustLedgerEntry, CustLedgerEntryInv, CustLedgerEntryCrMemo, ReferenceInvoiceNo, Entrys)
    end;

    local procedure CheckPurchAppliedEntries(
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntryCrMemo: Record "Vendor Ledger Entry";
        TableID: Integer;
        PurchInvoiceHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        Entrys: Integer;
        CrMemoFromJournal: Boolean)
    begin
        if (VendorLedgerEntry."Document Type" = VendorLedgerEntry."Document Type"::Invoice) and
           (Entrys > 1) and (not CrMemoFromJournal)
        then
            if (TableID = Database::"Purch. Inv. Header") and (IsGSTApplicablePostedPurchaseInvoice(PurchInvoiceHeader."No.")) then
                Error(OneDocumentErr, VendorLedgerEntryCrMemo."Document Type", VendorLedgerEntryCrMemo."Document No.")
            else
                if (TableID = Database::"Purch. Cr. Memo Hdr.") and (IsGSTApplicablePostedPurchaseCrMemo(PurchCrMemoHeader."No.")) then
                    Error(OneDocumentErr, VendorLedgerEntryCrMemo."Document Type", VendorLedgerEntryCrMemo."Document No.");

        if (VendorLedgerEntry."Document Type" = VendorLedgerEntry."Document Type"::Invoice) and
           (Entrys > 1) and
           CrMemoFromJournal and
           VendorLedgerEntryCrMemo."GST in Journal"
        then
            Error(OneDocumentErr, VendorLedgerEntryCrMemo."Document Type", VendorLedgerEntryCrMemo."Document No.");
    end;

    local procedure CheckSalesAppliedEntries(
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntryCrMemo: Record "Cust. Ledger Entry";
        TableID: Integer;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        NumberOfEntries: Integer;
        CrMemoFromJournal: Boolean)
    var
        GSTApplicable: Boolean;
    begin
        if (CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Invoice) and
            (NumberOfEntries > 1) and
            (not CrMemoFromJournal)
        then begin
            if TableID = Database::"Sales Invoice Header" then
                GSTApplicable := IsGSTApplicablePostedSalesInvoice(SalesInvoiceHeader."No.")
            else
                if TableID = Database::"Sales Cr.Memo Header" then
                    GSTApplicable := IsGSTApplicablePostedSalesCrMemo(SalesCrMemoHeader."No.");

            if GSTApplicable then
                Error(OneDocumentErr, CustLedgerEntryCrMemo."Document Type", CustLedgerEntryCrMemo."Document No.");
        end;

        if (CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Invoice) and
           (NumberOfEntries > 1) and CrMemoFromJournal
        then
            if CustLedgerEntryCrMemo."GST in Journal" then
                Error(OneDocumentErr, CustLedgerEntryCrMemo."Document Type", CustLedgerEntryCrMemo."Document No.");
    end;

    local procedure CheckGSTSalesCrMemoValOfflineSales(
        CustLedgerEntryCrMemo: Record "Cust. Ledger Entry";
        CustLedgerEntryInv: Record "Cust. Ledger Entry";
        TableID: Integer;
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        InvoiceFromJournal: Boolean;
        ReferenceInvoiceNo: Code[20];
        CrMemoFromJournal: Boolean)
    var
        InvSellerRegNo: Code[20];
        InvGSTJurisdiction: Enum "GST Jurisdiction Type";
        CrMemoSellerRegNo: Code[20];
        CrMemoGSTJuridiction: Enum "GST Jurisdiction Type";
        PurchDocType: Enum "Purchase Document Type";
        GSTApplicable: Boolean;
    begin
        CheckGSTAppliedDocumentPosted(
            CustLedgerEntryCrMemo."Posting Date",
            CustLedgerEntryInv."Posting Date",
            CustLedgerEntryCrMemo."Document No.",
            CustLedgerEntryInv."Document No.");

        if TableID = Database::"Sales Invoice Header" then
            GSTApplicable := IsGSTApplicablePostedSalesInvoice(SalesInvHeader."No.")
        else
            if TableID = Database::"Sales Cr.Memo Header" then
                GSTApplicable := IsGSTApplicablePostedSalesCrMemo(SalesCrMemoHeader."No.");

        if GSTApplicable or CustLedgerEntryCrMemo."GST in Journal" then begin
            if CustLedgerEntryInv."Location GST Reg. No." <> CustLedgerEntryCrMemo."Location GST Reg. No." then
                Error(DiffLocationGSTRegErr);

            InvSellerRegNo := GetPlaceOfSupplyRegistrationNo(
                "Transaction Type Enum"::Sales,
                PurchDocType,
                CustLedgerEntryInv."Document Type",
                CustLedgerEntryInv."Document No.",
                false,
                InvoiceFromJournal);

            CrMemoSellerRegNo := GetPlaceOfSupplyRegistrationNo(
                "Transaction Type Enum"::Sales,
                PurchDocType,
                CustLedgerEntryCrMemo."Document Type",
                CustLedgerEntryCrMemo."Document No.",
                false,
                CrMemoFromJournal);

            if InvSellerRegNo <> CrMemoSellerRegNo then
                Error(DiffGSTRegNoErr, CustLedgerEntryInv.FieldCaption("Seller GST Reg. No."), ReferenceInvoiceNo);

            InvGSTJurisdiction := GetGSTJurisdiction(
                "Transaction Type Enum"::Sales,
                PurchDocType,
                CustLedgerEntryInv."Document Type",
                CustLedgerEntryInv."Document No.",
                false,
                InvoiceFromJournal);

            CrMemoGSTJuridiction := GetGSTJurisdiction(
                "Transaction Type Enum"::Sales,
                PurchDocType,
                CustLedgerEntryCrMemo."Document Type",
                CustLedgerEntryCrMemo."Document No.",
                false,
                CrMemoFromJournal);

            if InvGSTJurisdiction <> CrMemoGSTJuridiction then
                Error(DiffJurisdictionErr, CustLedgerEntryInv.FieldCaption("GST Jurisdiction Type"));

            if CustLedgerEntryInv."Currency Code" <> CustLedgerEntryCrMemo."Currency Code" then
                Error(DiffCurrencyCodeErr, CustLedgerEntryInv.FieldCaption("Currency Code"));
        end;
    end;

    local procedure CheckGSTAppliedDocumentPosted(CrMemoDate: Date; InvDate: Date; CrMemoDocNo: Code[20]; InvDocNo: Code[20])
    begin
        if CrMemoDate < InvDate then
            Error(PostingDateErr, InvDocNo, CrMemoDocNo);

        CheckGSTAccountingPeriod(CrMemoDocNo, CrMemoDate, InvDate);
    end;

    local procedure CheckInvoiceNoFromDetGST(CrMemoDocNo: Code[20]; var InvDocNo: Code[20]): Boolean
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
        DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::"Credit Memo");
        DetailedGSTLedgerEntry.SetRange("Document No.", CrMemoDocNo);
        if DetailedGSTLedgerEntry.FindFirst() then
            if DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.") then begin
                InvDocNo := DetailedGSTLedgerEntry."Original Invoice No.";
                if (DetailedGSTLedgerEntry."Original Invoice No." <> '') and (DetailedGSTLedgerEntryInfo."Original Invoice Date" <> 0D) then
                    exit(true);
            end;
    end;

    local procedure IsGSTApplicable(
        TransType: Enum "Transaction Type Enum";
        PurchDocType: Enum "Purchase Document Type";
        SalesDocType: Enum "Sales Document Type";
        DocNo: Code[20]): Boolean
    var
        GSTSetup: Record "GST Setup";
        PurchLine: Record "Purchase Line";
        SalesLine: Record "Sales Line";
        ServiceLine: Record "Service Line";
        ServiceDocType: Enum "Service Document Type";
        TaxTransactionFound: Boolean;
    begin
        if not GSTSetup.Get() then
            exit;

        case TransType of
            "Transaction Type Enum"::Purchase:
                begin
                    PurchLine.Reset();
                    PurchLine.SetRange("Document Type", PurchDocType);
                    PurchLine.SetRange("Document No.", DocNo);
                    PurchLine.SetFilter(Type, '<>%1', PurchLine.Type::" ");
                    if PurchLine.FindSet() then
                        repeat
                            GSTSetup.TestField("GST Tax Type");
                            TaxTransactionFound := FilterTaxTransactionValue(GSTSetup."GST Tax Type", PurchLine.RecordId);
                        until PurchLine.Next() = 0
                    else
                        exit(false);
                end;
            "Transaction Type Enum"::Sales:
                begin
                    SalesLine.Reset();
                    SalesLine.SetRange("Document Type", SalesDocType);
                    SalesLine.SetRange("Document No.", DocNo);
                    SalesLine.SetFilter(Type, '<>%1', SalesLine.Type::" ");
                    if SalesLine.FindSet() then
                        repeat
                            GSTSetup.TestField("GST Tax Type");
                            TaxTransactionFound := FilterTaxTransactionValue(GSTSetup."GST Tax Type", SalesLine.RecordId);
                        until SalesLine.Next() = 0
                    else
                        exit(false);
                end;
            "Transaction Type Enum"::Service:
                begin
                    ServiceDocType := SalesDocumentType2ServiceDocumentTypeEnum(SalesDocType);
                    ServiceLine.Reset();
                    ServiceLine.SetRange("Document Type", ServiceDocType);
                    ServiceLine.SetRange("Document No.", DocNo);
                    ServiceLine.SetFilter(Type, '<>%1', ServiceLine.Type::" ");
                    if ServiceLine.FindSet() then
                        repeat
                            GSTSetup.TestField("GST Tax Type");
                            TaxTransactionFound := FilterTaxTransactionValue(GSTSetup."GST Tax Type", ServiceLine.RecordId);
                        until ServiceLine.Next() = 0
                    else
                        exit(false);
                end;
        end;

        if not TaxTransactionFound then
            exit(false);

        CheckCompanyInfoGSTDetails();

        exit(true);
    end;

    local procedure FilterTaxTransactionValue(
        TaxTypeSetupCode: Code[10];
        RecordId: RecordId): Boolean
    var
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        TaxTransactionValue.SetLoadFields("Tax Record ID", "Tax Type", Percent);
        TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
        TaxTransactionValue.SetRange("Tax Type", TaxTypeSetupCode);
        TaxTransactionValue.SetRange("Tax Record ID", RecordId);
        TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
        if not TaxTransactionValue.IsEmpty() then
            exit(true);
    end;

    local procedure IsGSTApplicableJournal(GenJournalLine: Record "Gen. Journal Line"): Boolean
    var
        CompanyInformation: Record "Company Information";
        GenJournalLineToCheck: Record "Gen. Journal Line";
    begin
        CompanyInformation.Get();
        CompanyInformation.TestField("GST Registration No.");
        if CompanyInformation."GST Registration No." <> '' then begin
            GenJournalLineToCheck.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
            GenJournalLineToCheck.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
            if GenJournalLine."Old Document No." <> '' then
                GenJournalLineToCheck.SetRange("Document No.", GenJournalLine."Old Document No.")
            else
                GenJournalLineToCheck.SetRange("Document No.", GenJournalLine."Document No.");
            GenJournalLineToCheck.SetRange("GST in Journal", true);
            if not GenJournalLineToCheck.IsEmpty() then
                exit(true);
        end;
    end;

    local procedure CheckRefInvNoPurchHeader(var PurchaseHeader: Record "Purchase Header")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        SalesDocType: Enum "Sales Document Type";
        GSTDocumentType: Enum "Document Type Enum";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckRefInvNoPurchaseHeader(PurchaseHeader, IsHandled);
        if IsHandled then
            exit;

        if not IsGSTApplicable("Transaction Type Enum"::Purchase, PurchaseHeader."Document Type", SalesDocType, PurchaseHeader."No.") then
            exit;

        if (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Credit Memo") or
            (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Return Order") or
            (PurchaseHeader."Invoice Type" in [PurchaseHeader."Invoice Type"::"Debit Note", PurchaseHeader."Invoice Type"::Supplementary])
        then begin
            GSTDocumentType := PurchDocumentType2DocumentTypeEnum(PurchaseHeader."Document Type");

            ReferenceInvoiceNo.SetRange("Document Type", GSTDocumentType);
            ReferenceInvoiceNo.SetRange("Document No.", PurchaseHeader."No.");
            ReferenceInvoiceNo.SetRange("Source No.", PurchaseHeader."Pay-to Vendor No.");
            if ReferenceInvoiceNo.FindSet() then
                repeat
                    VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
                    VendorLedgerEntry.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
                    if VendorLedgerEntry.FindFirst() then
                        CheckGSTAccountingPeriod(PurchaseHeader."No.", PurchaseHeader."Posting Date", VendorLedgerEntry."Posting Date");
                until ReferenceInvoiceNo.Next() = 0
            else
                Error(ReferenceInvNoPurchErr, PurchaseHeader."Document Type", PurchaseHeader."No.");
        end;
    end;

    local procedure CheckRefInvNoSalesHeader(var SalesHeader: Record "Sales Header")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        GSTDocumentType: Enum "Document Type Enum";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckRefInvoiceNoSalesHeader(SalesHeader, IsHandled);
        if IsHandled then
            exit;

        if not IsGSTApplicable("Transaction Type Enum"::Sales, SalesHeader."Document Type", SalesHeader."Document Type", SalesHeader."No.") then
            exit;

        if (SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo") or
            (SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order") or
            (SalesHeader."Invoice Type" in [SalesHeader."Invoice Type"::"Debit Note", SalesHeader."Invoice Type"::Supplementary])
        then begin
            GSTDocumentType := SalesDocumentType2DocumentTypeEnum(SalesHeader."Document Type");

            ReferenceInvoiceNo.SetRange("Document Type", GSTDocumentType);
            ReferenceInvoiceNo.SetRange("Document No.", SalesHeader."No.");
            ReferenceInvoiceNo.SetRange("Source No.", SalesHeader."Bill-to Customer No.");
            if ReferenceInvoiceNo.FindSet() then
                repeat
                    CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
                    CustLedgerEntry.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
                    if CustLedgerEntry.FindFirst() then
                        CheckGSTAccountingPeriod(SalesHeader."No.", SalesHeader."Posting Date", CustLedgerEntry."Posting Date");
                until ReferenceInvoiceNo.Next() = 0
            else
                Error(ReferenceInvNoSalesErr, SalesHeader."Document Type", SalesHeader."No.");
        end;
    end;

    local procedure CreatePostedReferenceInvoiceNoPurch(
        var PurchaseHeader: Record "Purchase Header";
        PurchInvHdrNo: Code[20];
        PurchCrMemoHdrNo: Code[20])
    var
        PurchaseHeaderToCheck: Record "Purchase Header";
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        PostedReferenceInvoiceNo: Record "Reference Invoice No.";
        DocumentType: Enum "Document Type Enum";
        PostedRefInvCreated: Boolean;
    begin
        DocumentType := PurchDocumentType2DocumentTypeEnum(PurchaseHeader."Document Type");

        ReferenceInvoiceNo.SetRange("Document Type", DocumentType);
        ReferenceInvoiceNo.SetRange("Document No.", PurchaseHeader."No.");
        ReferenceInvoiceNo.SetRange("Source No.", PurchaseHeader."Buy-from Vendor No.");
        if ReferenceInvoiceNo.FindSet() then begin
            repeat
                if PurchInvHdrNo <> '' then begin
                    PostedReferenceInvoiceNo.Init();
                    PostedReferenceInvoiceNo := ReferenceInvoiceNo;
                    PostedReferenceInvoiceNo."Document Type" := PostedReferenceInvoiceNo."Document Type"::Invoice;
                    PostedReferenceInvoiceNo."Document No." := PurchInvHdrNo;
                    PostedReferenceInvoiceNo.Insert();
                    PostedRefInvCreated := true;
                end;

                if (PurchCrMemoHdrNo <> '') and (PurchCrMemoHdrNo <> PurchaseHeader."No.") then begin
                    PostedReferenceInvoiceNo.Init();
                    PostedReferenceInvoiceNo := ReferenceInvoiceNo;
                    PostedReferenceInvoiceNo."Document Type" := PostedReferenceInvoiceNo."Document Type"::"Credit Memo";
                    PostedReferenceInvoiceNo."Document No." := PurchCrMemoHdrNo;
                    PostedReferenceInvoiceNo.Insert();
                    PostedRefInvCreated := true;
                end;
            until ReferenceInvoiceNo.Next() = 0;

            if PostedRefInvCreated and (not PurchaseHeaderToCheck.Get(PurchaseHeader."Document Type", PurchaseHeader."No.")) then
                ReferenceInvoiceNo.DeleteAll();
        end;
    end;

    local procedure CreatePostedReferenceInvoiceNoSales(
        var SalesHeader: Record "Sales Header";
        SalesInvHdrNo: Code[20];
        SalesCrMemoHdrNo: Code[20])
    var
        SalesHeaderToCheck: Record "Sales Header";
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        PostedReferenceInvoiceNo: Record "Reference Invoice No.";
        DocumentType: Enum "Document Type Enum";
        PostedRefInvCreated: Boolean;
    begin
        DocumentType := SalesDocumentType2DocumentTypeEnum(SalesHeader."Document Type");

        ReferenceInvoiceNo.SetRange("Document Type", DocumentType);
        ReferenceInvoiceNo.SetRange("Document No.", SalesHeader."No.");
        ReferenceInvoiceNo.SetRange("Source No.", SalesHeader."Sell-to Customer No.");
        if ReferenceInvoiceNo.FindSet() then begin
            repeat
                if SalesInvHdrNo <> '' then begin
                    PostedReferenceInvoiceNo.Init();
                    PostedReferenceInvoiceNo := ReferenceInvoiceNo;
                    PostedReferenceInvoiceNo."Document Type" := PostedReferenceInvoiceNo."Document Type"::Invoice;
                    PostedReferenceInvoiceNo."Document No." := SalesInvHdrNo;
                    PostedReferenceInvoiceNo.Insert();
                    PostedRefInvCreated := true;
                end;

                if SalesCrMemoHdrNo <> '' then begin
                    PostedReferenceInvoiceNo.Init();
                    PostedReferenceInvoiceNo := ReferenceInvoiceNo;
                    PostedReferenceInvoiceNo."Document Type" := PostedReferenceInvoiceNo."Document Type"::"Credit Memo";
                    PostedReferenceInvoiceNo."Document No." := SalesCrMemoHdrNo;
                    PostedReferenceInvoiceNo.Insert();
                    PostedRefInvCreated := true;
                end;
            until ReferenceInvoiceNo.Next() = 0;

            if PostedRefInvCreated and (not SalesHeaderToCheck.Get(SalesHeader."Document Type", SalesHeader."No.")) then
                ReferenceInvoiceNo.DeleteAll();
        end;
    end;

    local procedure CheckReferenceInvPurchJnl(GenJournalLine: Record "Gen. Journal Line")
    var
        GenJournalLineToCheck: Record "Gen. Journal Line";
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        DocumentType: Enum "Document Type Enum";
    begin
        if GenJournalLineToCheck.Get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name", GenJournalLine."Line No.") then begin
            if not GenJournalLineToCheck."GST in Journal" then
                exit;

            if ((GenJournalLine."Document Type" = GenJournalLine."Document Type"::Invoice) and
                (GenJournalLine."Purch. Invoice Type" in [
                    GenJournalLine."Purch. Invoice Type"::"Debit Note",
                    GenJournalLine."Purch. Invoice Type"::Supplementary])) or
               (GenJournalLine."Document Type" = GenJournalLine."Document Type"::"Credit Memo") and
               (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor)
            then begin
                DocumentType := GenJnlDocumentType2DocumentTypeEnum(GenJournalLine."Document Type");

                ReferenceInvoiceNo.SetRange("Document No.", GenJournalLineToCheck."Document No.");
                ReferenceInvoiceNo.SetRange("Document Type", DocumentType);
                ReferenceInvoiceNo.SetRange("Source No.", GenJournalLine."Account No.");
                ReferenceInvoiceNo.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
                ReferenceInvoiceNo.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
                if ReferenceInvoiceNo.IsEmpty() then
                    Error(ReferenceNoJnlErr, GenJournalLine."Document Type", GenJournalLine."Document No.");
            end;
        end;
    end;

    local procedure CheckReferenceInvSalesJnl(GenJournalLine: Record "Gen. Journal Line")
    var
        GenJournalLineToCheck: Record "Gen. Journal Line";
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        DocumentType: Enum "Document Type Enum";
    begin
        if GenJournalLineToCheck.Get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name", GenJournalLine."Line No.") then begin
            if not GenJournalLineToCheck."GST in Journal" then
                exit;

            if ((GenJournalLine."Document Type" = GenJournalLine."Document Type"::Invoice) and
                (GenJournalLine."Sales Invoice Type" in [
                    GenJournalLine."Sales Invoice Type"::"Debit Note",
                    GenJournalLine."Sales Invoice Type"::Supplementary])) or
               (GenJournalLine."Document Type" = GenJournalLine."Document Type"::"Credit Memo") and
               (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer)
            then begin
                DocumentType := GenJnlDocumentType2DocumentTypeEnum(GenJournalLine."Document Type");

                ReferenceInvoiceNo.SetRange("Document No.", GenJournalLineToCheck."Document No.");
                ReferenceInvoiceNo.SetRange("Document Type", DocumentType);
                ReferenceInvoiceNo.SetRange("Source No.", GenJournalLine."Account No.");
                ReferenceInvoiceNo.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
                ReferenceInvoiceNo.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
                if ReferenceInvoiceNo.IsEmpty() then
                    Error(ReferenceNoJnlErr, GenJournalLine."Document Type", GenJournalLine."Document No.");
            end;
        end;
    end;

    local procedure CreatePostedReferenceInvoiceNoPurchJnl(GenJournalLine: Record "Gen. Journal Line")
    var
        GenJournalLineToCheck: Record "Gen. Journal Line";
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        PostedReferenceInvoiceNo: Record "Reference Invoice No.";
        DocumentType: Enum "Document Type Enum";
    begin
        if GenJournalLineToCheck.Get(
            GenJournalLine."Journal Template Name",
            GenJournalLine."Journal Batch Name",
            GenJournalLine."Line No.")
        then begin
            if not GenJournalLineToCheck."GST in Journal" then
                exit;

            DocumentType := GenJnlDocumentType2DocumentTypeEnum(GenJournalLine."Document Type");

            ReferenceInvoiceNo.SetRange("Document Type", DocumentType);
            ReferenceInvoiceNo.SetRange("Document No.", GenJournalLineToCheck."Document No.");
            ReferenceInvoiceNo.SetRange("Source No.", GenJournalLine."Account No.");
            ReferenceInvoiceNo.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
            ReferenceInvoiceNo.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
            if ReferenceInvoiceNo.FindSet() then
                repeat
                    if not PostedReferenceInvoiceNo.Get(
                        GenJournalLine."Document No.",
                        ReferenceInvoiceNo."Document Type",
                        ReferenceInvoiceNo."Source No.",
                        ReferenceInvoiceNo."Reference Invoice Nos.",
                        ReferenceInvoiceNo."Journal Template Name",
                        ReferenceInvoiceNo."Journal Batch Name")
                    then begin
                        PostedReferenceInvoiceNo.Init();
                        PostedReferenceInvoiceNo := ReferenceInvoiceNo;
                        PostedReferenceInvoiceNo."Document No." := GenJournalLine."Document No.";
                        PostedReferenceInvoiceNo.Insert();
                    end;
                until ReferenceInvoiceNo.Next() = 0;
        end;
    end;

    local procedure CreatePostedReferenceInvoiceNoSalesJnl(GenJournalLine: Record "Gen. Journal Line")
    var
        GenJournalLineToCheck: Record "Gen. Journal Line";
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        PostedReferenceInvoiceNo: Record "Reference Invoice No.";
        DocumentType: Enum "Document Type Enum";
    begin
        if GenJournalLineToCheck.Get(
            GenJournalLine."Journal Template Name",
            GenJournalLine."Journal Batch Name",
            GenJournalLine."Line No.")
        then begin
            if not GenJournalLineToCheck."GST in Journal" then
                exit;

            DocumentType := GenJnlDocumentType2DocumentTypeEnum(GenJournalLine."Document Type");

            ReferenceInvoiceNo.SetRange("Document Type", DocumentType);
            ReferenceInvoiceNo.SetRange("Document No.", GenJournalLineToCheck."Document No.");
            ReferenceInvoiceNo.SetRange("Source No.", GenJournalLine."Account No.");
            ReferenceInvoiceNo.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
            ReferenceInvoiceNo.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
            if ReferenceInvoiceNo.FindSet() then
                repeat
                    if not PostedReferenceInvoiceNo.Get(
                        GenJournalLine."Document No.",
                        ReferenceInvoiceNo."Document Type",
                        ReferenceInvoiceNo."Source No.",
                        ReferenceInvoiceNo."Reference Invoice Nos.",
                        ReferenceInvoiceNo."Journal Template Name",
                        ReferenceInvoiceNo."Journal Batch Name")
                    then begin
                        PostedReferenceInvoiceNo.Init();
                        PostedReferenceInvoiceNo := ReferenceInvoiceNo;
                        PostedReferenceInvoiceNo."Document No." := GenJournalLine."Document No.";
                        PostedReferenceInvoiceNo.Insert();
                    end;
                until ReferenceInvoiceNo.Next() = 0;
        end;
    end;

    local procedure CreatePostedReferenceInvoiceNoService(
        var ServiceHeader: Record "Service Header";
        ServInvoiceNo: Code[20];
        ServCrMemoNo: Code[20])
    var
        ServiceHeaderToCheck: Record "Service Header";
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        PostedReferenceInvoiceNo: Record "Reference Invoice No.";
        DocumentType: Enum "Document Type Enum";
        PostedRefInvCreated: Boolean;
    begin
        DocumentType := ServiceDocumentType2DocumentTypeEnum(ServiceHeader."Document Type");

        ReferenceInvoiceNo.SetRange("Document Type", DocumentType);
        ReferenceInvoiceNo.SetRange("Document No.", ServiceHeader."No.");
        ReferenceInvoiceNo.SetRange("Source No.", ServiceHeader."Bill-to Customer No.");
        if ReferenceInvoiceNo.FindSet() then begin
            repeat
                if (ServInvoiceNo <> '') and (ServInvoiceNo <> ServiceHeader."No.") then begin
                    PostedReferenceInvoiceNo.Init();
                    PostedReferenceInvoiceNo := ReferenceInvoiceNo;
                    PostedReferenceInvoiceNo."Document Type" := PostedReferenceInvoiceNo."Document Type"::Invoice;
                    PostedReferenceInvoiceNo."Document No." := ServInvoiceNo;
                    PostedReferenceInvoiceNo.Insert();
                    PostedRefInvCreated := true;
                end;

                if (ServCrMemoNo <> '') and (ServCrMemoNo <> ServiceHeader."No.") then begin
                    PostedReferenceInvoiceNo.Init();
                    PostedReferenceInvoiceNo := ReferenceInvoiceNo;
                    PostedReferenceInvoiceNo."Document Type" := PostedReferenceInvoiceNo."Document Type"::"Credit Memo";
                    PostedReferenceInvoiceNo."Document No." := ServCrMemoNo;
                    PostedReferenceInvoiceNo.Insert();
                    PostedRefInvCreated := true;
                end;
            until ReferenceInvoiceNo.Next() = 0;

            if PostedRefInvCreated and (not ServiceHeaderToCheck.Get(ServiceHeader."Document Type", ServiceHeader."No.")) then
                ReferenceInvoiceNo.DeleteAll();
        end;
    end;

    local procedure SalesDocumentType2DocumentTypeEnum(SalesDocumentType: Enum "Sales Document Type"): Enum "Document Type Enum"
    var
        ConversionErr: Label 'Document Type %1 is not a valid option.', Comment = '%1 = Sales Document Type';
    begin
        case SalesDocumentType of
            SalesDocumentType::"Blanket Order":
                exit("Document Type Enum"::"Blanket Order");
            SalesDocumentType::"Credit Memo":
                exit("Document Type Enum"::"Credit Memo");
            SalesDocumentType::Invoice:
                exit("Document Type Enum"::Invoice);
            SalesDocumentType::Order:
                exit("Document Type Enum"::Order);
            SalesDocumentType::Quote:
                exit("Document Type Enum"::Quote);
            SalesDocumentType::"Return Order":
                exit("Document Type Enum"::"Return Order");
            else
                Error(ConversionErr, SalesDocumentType);
        end;
    end;

    local procedure SalesDocumentType2GSTDocumentType(SalesDocumentType: Enum "Sales Document Type"): Enum "GST Document Type"
    var
        ConversionErr: Label 'Document Type %1 is not a valid option.', Comment = '%1 = Sales Document Type';
    begin
        case SalesDocumentType of
            SalesDocumentType::"Credit Memo":
                exit("GST Document Type"::"Credit Memo");
            SalesDocumentType::Invoice:
                exit("GST Document Type"::Invoice);
            else
                Error(ConversionErr, SalesDocumentType);
        end;
    end;

    local procedure PurchDocumentType2GSTDocumentType(PurchaseDocumentType: Enum "Purchase Document Type"): Enum "GST Document Type"
    var
        ConversionErr: Label 'Document Type %1 is not a valid option.', Comment = '%1 = Purchase Document Type';
    begin
        case PurchaseDocumentType of
            PurchaseDocumentType::"Credit Memo":
                exit("GST Document Type"::"Credit Memo");
            PurchaseDocumentType::Invoice:
                exit("GST Document Type"::Invoice);
            else
                Error(ConversionErr, PurchaseDocumentType);
        end;
    end;

    local procedure PurchDocumentType2DocumentTypeEnum(PurchaseDocumentType: Enum "Purchase Document Type"): Enum "Document Type Enum"
    var
        ConversionErr: Label 'Document Type %1 is not a valid option.', Comment = '%1 = Sales Document Type';
    begin
        case PurchaseDocumentType of
            PurchaseDocumentType::"Blanket Order":
                exit("Document Type Enum"::"Blanket Order");
            PurchaseDocumentType::"Credit Memo":
                exit("Document Type Enum"::"Credit Memo");
            PurchaseDocumentType::Invoice:
                exit("Document Type Enum"::Invoice);
            PurchaseDocumentType::Order:
                exit("Document Type Enum"::Order);
            PurchaseDocumentType::Quote:
                exit("Document Type Enum"::Quote);
            PurchaseDocumentType::"Return Order":
                exit("Document Type Enum"::"Return Order");
            else
                Error(ConversionErr, PurchaseDocumentType);
        end;
    end;

    local procedure GenJnlDocumentType2GSTDocumentType(GenJournalDocumentType: Enum "Gen. Journal Document Type"): Enum "GST Document Type"
    var
        ConversionErr: Label 'Document Type %1 is not a valid option.', Comment = '%1 = Gen. Journal Document Type';
    begin
        case GenJournalDocumentType of
            GenJournalDocumentType::" ":
                exit("GST Document Type"::" ");
            GenJournalDocumentType::"Credit Memo":
                exit("GST Document Type"::"Credit Memo");
            GenJournalDocumentType::Invoice:
                exit("GST Document Type"::Invoice);
            GenJournalDocumentType::Payment:
                exit("GST Document Type"::Payment);
            GenJournalDocumentType::Refund:
                exit("GST Document Type"::Refund);
            else
                Error(ConversionErr, GenJournalDocumentType);
        end;
    end;

    local procedure GenJnlDocumentType2DocumentTypeEnum(GenJournalDocumentType: Enum "Gen. Journal Document Type"): Enum "Document Type Enum"
    var
        ConversionErr: Label 'Document Type %1 is not a valid option.', Comment = '%1 = Gen. Journal Document Type';
    begin
        case GenJournalDocumentType of
            GenJournalDocumentType::"Credit Memo":
                exit("Document Type Enum"::"Credit Memo");
            GenJournalDocumentType::Invoice:
                exit("Document Type Enum"::Invoice);
            else
                Error(ConversionErr, GenJournalDocumentType);
        end;
    end;

    local procedure TransactionTypeEnum2DetailLedgerTransactionType(TransType: Enum "Transaction Type Enum"): Enum "Detail Ledger Transaction Type"
    var
        ConversionErr: Label 'Transaction Type %1 is not a valid option.', Comment = '%1 = Transaction Type Enum';
    begin
        case TransType of
            "Transaction Type Enum"::Purchase:
                exit("Detail Ledger Transaction Type"::Purchase);
            "Transaction Type Enum"::Sales:
                exit("Detail Ledger Transaction Type"::Sales);
            "Transaction Type Enum"::Transfer:
                exit("Detail Ledger Transaction Type"::Transfer);
            else
                Error(ConversionErr, TransType);
        end;
    end;

    local procedure ServiceDocumentType2DocumentTypeEnum(ServiceDocumentType: Enum "Service Document Type"): Enum "Document Type Enum"
    var
        ConversionErr: Label 'Document Type %1 is not a valid option.', Comment = '%1 = Service Document Type';
    begin
        case ServiceDocumentType of
            ServiceDocumentType::Quote:
                exit("Document Type Enum"::Quote);
            ServiceDocumentType::Order:
                exit("Document Type Enum"::Order);
            ServiceDocumentType::Invoice:
                exit("Document Type Enum"::Invoice);
            ServiceDocumentType::"Credit Memo":
                exit("Document Type Enum"::"Credit Memo");
            else
                Error(ConversionErr, ServiceDocumentType);
        end;
    end;

    local procedure SalesDocumentType2ServiceDocumentTypeEnum(SalesDocumentType: Enum "Sales Document Type"): Enum "Service Document Type"
    var
        ConversionErr: Label 'Document Type %1 is not a valid option.', Comment = '%1 = Sales Document Type';
    begin
        case SalesDocumentType of
            SalesDocumentType::Quote:
                exit("Service Document Type"::Quote);
            SalesDocumentType::Order:
                exit("Service Document Type"::Order);
            SalesDocumentType::Invoice:
                exit("Service Document Type"::Invoice);
            SalesDocumentType::"Credit Memo":
                exit("Service Document Type"::"Credit Memo");
            else
                Error(ConversionErr, SalesDocumentType);
        end;
    end;

    local procedure ServiceDocumentType2SalesDocumentTypeEnum(ServiceDocumentType: Enum "Service Document Type"): Enum "Sales Document Type"
    var
        ConversionErr: Label 'Document Type %1 is not a valid option.', Comment = '%1 = Service Document Type';
    begin
        case ServiceDocumentType of
            ServiceDocumentType::Quote:
                exit("Service Document Type"::Quote);
            ServiceDocumentType::Order:
                exit("Service Document Type"::Order);
            ServiceDocumentType::Invoice:
                exit("Service Document Type"::Invoice);
            ServiceDocumentType::"Credit Memo":
                exit("Service Document Type"::"Credit Memo");
            else
                Error(ConversionErr, ServiceDocumentType);
        end;
    end;

    local procedure CheckGSTAppliedDocumentService(
        AppliedDocumentNo: Code[20];
        ServiceDocType: Enum "Service Document Type";
        DocumentNo: Code[20])
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ServiceHeader: Record "Service Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        if ServiceInvoiceHeader.Get(AppliedDocumentNo) then begin
            if not ServiceInvoiceHeader.Get(AppliedDocumentNo) then
                Error(SalesDocumentErr);

            ServiceHeader.Get(ServiceDocType, DocumentNo);
            if ServiceHeader."Posting Date" < ServiceInvoiceHeader."Posting Date" then
                Error(PostingDateErr, ServiceInvoiceHeader."No.", ServiceHeader."No.");

            CheckGSTAccountingPeriod(DocumentNo, ServiceHeader."Posting Date", ServiceInvoiceHeader."Posting Date");
            if ServiceInvoiceHeader."GST Without Payment of Duty" <> ServiceHeader."GST Without Payment of Duty" then
                Error(DiffGSTWithoutPaymentOfDutyErr);
        end;

        if SalesInvoiceHeader.Get(AppliedDocumentNo) then begin
            if not SalesInvoiceHeader.Get(AppliedDocumentNo) then
                Error(SalesDocumentErr);

            ServiceHeader.Get(ServiceDocType, DocumentNo);
            if ServiceHeader."Posting Date" < SalesInvoiceHeader."Posting Date" then
                Error(PostingDateErr, SalesInvoiceHeader."No.", ServiceHeader."No.");

            CheckGSTAccountingPeriod(DocumentNo, ServiceHeader."Posting Date", SalesInvoiceHeader."Posting Date");
            if SalesInvoiceHeader."GST Without Payment of Duty" <> ServiceHeader."GST Without Payment of Duty" then
                Error(DiffGSTWithoutPaymentOfDutyErr);
        end;

        if (ServiceInvoiceHeader."No." = '') and (SalesInvoiceHeader."No." = '') then begin
            DetailedGSTLedgerEntry.SetRange("Document No.", AppliedDocumentNo);
            if DetailedGSTLedgerEntry.FindFirst() then begin
                ServiceHeader.Get(ServiceDocType, DocumentNo);
                if ServiceHeader."Posting Date" < DetailedGSTLedgerEntry."Posting Date" then
                    Error(PostingDateErr, DetailedGSTLedgerEntry."No.", ServiceHeader."No.");

                CheckGSTAccountingPeriod(DocumentNo, ServiceHeader."Posting Date", DetailedGSTLedgerEntry."Posting Date");
                if DetailedGSTLedgerEntry."GST Without Payment of Duty" <> ServiceHeader."GST Without Payment of Duty" then
                    Error(DiffGSTWithoutPaymentOfDutyErr);
            end;
        end;
    end;

    local procedure GetPlaceOfSupplyRegistrationNoService(
        ServiceDocType: Enum "Service Document Type";
        DocumentNo: Code[20]): Code[20]
    var
        Customer: Record Customer;
        ShipToAddress: Record "Ship-to Address";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
    begin
        if DocumentNo <> '' then
            ServiceHeader.Get(ServiceDocType, DocumentNo);

        ServiceLine.Reset();
        ServiceLine.SetRange("Document Type", ServiceDocType);
        ServiceLine.SetRange("Document No.", DocumentNo);
        ServiceLine.SetFilter(Type, '<>%1', Type::" ");
        if ServiceLine.FindFirst() then
            Case ServiceLine."GST Place of Supply" of
                ServiceLine."GST Place of Supply"::" ", ServiceLine."GST Place of Supply"::"Bill-to Address", ServiceLine."GST Place of Supply"::"Location Address":
                    begin
                        if ServiceHeader."Customer GST Reg. No." = '' then
                            if Customer.Get(ServiceLine."Customer No.") and (Customer."ARN No." <> '') then
                                ServiceHeader.TestField("Customer GST Reg. No.");

                        exit(ServiceHeader."Customer GST Reg. No.");
                    end;
                ServiceLine."GST Place of Supply"::"Ship-to Address":
                    begin
                        ServiceHeader.TestField("Ship-to Code");
                        if ServiceHeader."Ship-to GST Reg. No." = '' then
                            if ShipToAddress.Get(ServiceLine."Customer No.", ServiceHeader."Ship-to Code") and (ShipToAddress."ARN No." <> '') then
                                ServiceHeader.TestField("Ship-to GST Reg. No.");

                        exit(ServiceHeader."Ship-to GST Reg. No.");
                    end;
            end;
    end;

    local procedure CheckGSTServiceValidation(
        CustLedgerEntry: Record "Cust. Ledger Entry";
        ApplyingCustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntryInv: Record "Cust. Ledger Entry";
        CustLedgerEntryCrMemo: Record "Cust. Ledger Entry";
        ReferenceInvoiceNo: Code[20];
        Entrys: Integer)
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ServiceInvoiceHeaderRef: Record "Service Invoice Header";
        ServiceInvoiceHeaderNo: Code[20];
        ServiceCrMemoHeaderNo: Code[20];
        InvGSTJurisdiction: Enum "GST Jurisdiction Type";
        CrMemoGSTJuridiction: Enum "GST Jurisdiction Type";
        DummyGSTInJournal: Boolean;
        PurchDocType: Enum "Purchase Document Type";
    begin
        if ServiceInvoiceHeader.Get(CustLedgerEntryInv."Document No.") then
            ServiceInvoiceHeaderNo := ServiceInvoiceHeader."No.";

        if ServiceCrMemoHeader.Get(CustLedgerEntryCrMemo."Document No.") then
            ServiceCrMemoHeaderNo := ServiceCrMemoHeader."No.";

        if (ServiceCrMemoHeaderNo = '') and ServiceInvoiceHeaderRef.Get(CustLedgerEntryCrMemo."Document No.") then;

        if CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Invoice then
            if (Entrys >= 1) and IsGSTApplicablePostedServiceCrMemo(ServiceCrMemoHeaderNo) then
                Error(OneDocumentErr, ApplyingCustLedgerEntry."Document Type", ApplyingCustLedgerEntry."Document No.");

        if ServiceCrMemoHeaderNo = '' then
            if (Entrys >= 1) and IsGSTApplicablePostedServiceInvoice(ServiceInvoiceHeaderRef."No.") then
                Error(OneDocumentErr, ApplyingCustLedgerEntry."Document Type", ApplyingCustLedgerEntry."Document No.");

        if IsGSTApplicablePostedServiceInvoice(ServiceInvoiceHeaderNo) then begin
            CheckGSTAppliedDocumentPosted(
                CustLedgerEntryCrMemo."Posting Date",
                CustLedgerEntryInv."Posting Date",
                CustLedgerEntryCrMemo."Document No.",
                CustLedgerEntryInv."Document No.");

            if IsGSTApplicablePostedServiceCrMemo(ServiceCrMemoHeaderNo) or
                IsGSTApplicablePostedServiceInvoice(ServiceInvoiceHeaderRef."No.")
            then begin
                if CustLedgerEntryInv."Location GST Reg. No." <> CustLedgerEntryCrMemo."Location GST Reg. No." then
                    Error(DiffLocationGSTRegErr);

                if CustLedgerEntryInv."Seller GST Reg. No." <> CustLedgerEntryCrMemo."Seller GST Reg. No." then
                    Error(DiffGSTRegNoErr, CustLedgerEntryInv.FieldCaption("Seller GST Reg. No."), ReferenceInvoiceNo);

                InvGSTJurisdiction := GetGSTJurisdiction(
                    "Transaction Type Enum"::Sales,
                    PurchDocType,
                    CustLedgerEntryInv."Document Type",
                    CustLedgerEntryInv."Document No.",
                    false,
                    DummyGSTinJournal);

                CrMemoGSTJuridiction := GetGSTJurisdiction(
                    "Transaction Type Enum"::Sales,
                    PurchDocType,
                    CustLedgerEntryCrMemo."Document Type",
                    CustLedgerEntryCrMemo."Document No.",
                    false,
                    DummyGSTinJournal);

                if InvGSTJurisdiction <> CrMemoGSTJuridiction then
                    Error(DiffJurisdictionErr, CustLedgerEntryInv.FieldCaption("GST Jurisdiction Type"));

                if CustLedgerEntryInv."Currency Code" <> CustLedgerEntryCrMemo."Currency Code" then
                    Error(DiffCurrencyCodeErr, CustLedgerEntryInv.FieldCaption("Currency Code"));
            end;
        end;
    end;

    local procedure CheckGSTServiceCrMemoValidationReference(ServiceHeader: Record "Service Header"; ReferenceInvoiceNo: Code[20])
    var
        ServiceLine: Record "Service Line";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CurrDocumentGSTRegNo: Code[20];
        PostedDocumentGSTRegNo: Code[20];
        CurrDocLocRegNo: Code[20];
        PostedDocLocRegNo: Code[20];
        CurrDocGSTJurisdiction: Enum "GST Jurisdiction Type";
        PostedDocGSTJurisdiction: Enum "GST Jurisdiction Type";
        PostedCurrencyCode: Code[10];
        IsDummy: Boolean;
        PurchDocType: Enum "Purchase Document Type";
        SalesDocType: Enum "Sales Document Type";
    begin
        if not (ServiceHeader."Document Type" in [
            ServiceHeader."Document Type"::"Credit Memo",
            ServiceHeader."Document Type"::Order,
            ServiceHeader."Document Type"::Invoice])
        then
            exit;

        SalesDocType := ServiceDocumentType2SalesDocumentTypeEnum(ServiceHeader."Document Type");
        if IsGSTApplicable("Transaction Type Enum"::Service, PurchDocType, SalesDocType, ServiceHeader."No.") then
            if ReferenceInvoiceNo <> '' then
                if ServiceInvoiceHeader.Get(ReferenceInvoiceNo) and
                    IsGSTApplicablePostedServiceInvoice(ServiceInvoiceHeader."No.")
                then begin
                    CheckGSTAppliedDocument(
                        "Transaction Type Enum"::Service,
                        PurchDocType,
                        SalesDocType,
                        ServiceHeader."No.",
                        ReferenceInvoiceNo,
                        IsDummy,
                        '',
                        '',
                        0);

                    CurrDocumentGSTRegNo := GetPlaceOfSupplyRegistrationNo(
                        "Transaction Type Enum"::Service,
                        PurchDocType,
                        SalesDocType,
                        ServiceHeader."No.",
                        true,
                        IsDummy);

                    PostedDocumentGSTRegNo := GetPlaceOfSupplyRegistrationNo(
                        "Transaction Type Enum"::Service,
                        PurchDocType,
                        SalesDocType::Invoice,
                        ReferenceInvoiceNo,
                        false,
                        IsDummy);

                    CurrDocLocRegNo := GetLocationRegistrationNo(
                        "Transaction Type Enum"::Service,
                        PurchDocType,
                        SalesDocType,
                        ServiceHeader."No.",
                        true,
                        IsDummy);

                    PostedDocLocRegNo := GetLocationRegistrationNo(
                        "Transaction Type Enum"::Service,
                        PurchDocType,
                        SalesDocType::Invoice,
                        ReferenceInvoiceNo,
                        false,
                        IsDummy);

                    CurrDocGSTJurisdiction := GetGSTJurisdiction(
                        "Transaction Type Enum"::Service,
                        PurchDocType,
                        SalesDocType,
                        ServiceHeader."No.",
                        true,
                        IsDummy);

                    PostedDocGSTJurisdiction := GetGSTJurisdiction(
                        "Transaction Type Enum"::Service,
                        PurchDocType,
                        SalesDocType::Invoice,
                        ReferenceInvoiceNo,
                        false,
                        IsDummy);

                    PostedCurrencyCode := GetCurrencyCode(
                        "Transaction Type Enum"::Service,
                        "Gen. Journal Document Type"::Invoice,
                        ReferenceInvoiceNo,
                        ServiceHeader."Customer No.");

                    if CurrDocGSTJurisdiction <> PostedDocGSTJurisdiction then
                        Error(DiffJurisdictionErr, ServiceLine.FieldCaption("GST Jurisdiction Type"));

                    if CurrDocumentGSTRegNo <> PostedDocumentGSTRegNo then
                        Error(DiffGSTRegNoErr, ServiceLine.FieldCaption("GST Place Of Supply"), ReferenceInvoiceNo);

                    if CurrDocLocRegNo <> PostedDocLocRegNo then
                        Error(DiffGSTRegNoErr, ServiceLine.FieldCaption("Location Code"), ReferenceInvoiceNo);

                    if ServiceHeader."Currency Code" <> PostedCurrencyCode then
                        Error(DiffCurrencyCodeErr, ServiceHeader."Currency Code");
                end else
                    if SalesInvoiceHeader.Get(ReferenceInvoiceNo) and IsGSTApplicablePostedSalesInvoice(SalesInvoiceHeader."No.") then begin
                        CheckGSTAppliedDocument("Transaction Type Enum"::Service,
                            PurchDocType,
                            SalesDocType,
                            ServiceHeader."No.",
                            ReferenceInvoiceNo,
                            IsDummy,
                            '',
                            '',
                            0);

                        CurrDocumentGSTRegNo := GetPlaceOfSupplyRegistrationNo(
                            "Transaction Type Enum"::Service,
                            PurchDocType,
                            SalesDocType,
                            ServiceHeader."No.",
                            true,
                            IsDummy);

                        PostedDocumentGSTRegNo := GetPlaceOfSupplyRegistrationNo(
                            "Transaction Type Enum"::Sales,
                            PurchDocType,
                            SalesDocType::Invoice,
                            ReferenceInvoiceNo,
                            false,
                            IsDummy);

                        CurrDocLocRegNo := GetLocationRegistrationNo(
                            "Transaction Type Enum"::Service,
                            PurchDocType,
                            SalesDocType,
                            ServiceHeader."No.",
                            true,
                            IsDummy);

                        PostedDocLocRegNo := GetLocationRegistrationNo(
                            "Transaction Type Enum"::Sales,
                            PurchDocType,
                            SalesDocType,
                            ReferenceInvoiceNo,
                            false,
                            IsDummy);

                        CurrDocGSTJurisdiction := GetGSTJurisdiction(
                            "Transaction Type Enum"::Service,
                            PurchDocType,
                            SalesDocType,
                            ServiceHeader."No.",
                            true,
                            IsDummy);

                        PostedDocGSTJurisdiction := GetGSTJurisdiction(
                            "Transaction Type Enum"::Sales,
                            PurchDocType,
                            SalesDocType::Invoice,
                            ReferenceInvoiceNo,
                            false,
                            IsDummy);

                        PostedCurrencyCode := GetCurrencyCode(
                            "Transaction Type Enum"::Sales,
                            "Gen. Journal Document Type"::Invoice,
                            ReferenceInvoiceNo,
                            ServiceHeader."Customer No.");

                        if CurrDocumentGSTRegNo <> PostedDocumentGSTRegNo then
                            Error(DiffGSTRegNoErr, SalesInvoiceHeader.FieldCaption("No."), ReferenceInvoiceNo);

                        if CurrDocLocRegNo <> PostedDocLocRegNo then
                            Error(DiffGSTRegNoErr, SalesInvoiceHeader.FieldCaption("Location Code"), ReferenceInvoiceNo);

                        if CurrDocGSTJurisdiction <> PostedDocGSTJurisdiction then
                            Error(DiffJurisdictionErr, ServiceLine.FieldCaption("GST Jurisdiction Type"));

                        if PostedCurrencyCode <> ServiceHeader."Currency Code" then
                            Error(DiffCurrencyCodeErr, SalesInvoiceHeader.FieldCaption("Currency Code"));
                    end else
                        IsDummy := IsGSTFromJournal("Transaction Type Enum"::Sales, ReferenceInvoiceNo, ServiceHeader."Customer No.");

        if IsGSTApplicable("Transaction Type Enum"::Service, PurchDocType, SalesDocType, ServiceHeader."No.") and (ReferenceInvoiceNo <> '') and IsDummy then begin
            CheckGSTAppliedDocument(
                "Transaction Type Enum"::Service,
                PurchDocType,
                SalesDocType,
                ServiceHeader."No.",
                ReferenceInvoiceNo,
                IsDummy,
                '',
                '',
                0);

            CurrDocumentGSTRegNo := GetPlaceOfSupplyRegistrationNo(
                "Transaction Type Enum"::Service,
                PurchDocType,
                SalesDocType,
                ServiceHeader."No.",
                true,
                IsDummy);

            PostedDocumentGSTRegNo := GetPlaceOfSupplyRegistrationNo(
                "Transaction Type Enum"::Service,
                PurchDocType,
                SalesDocType::Invoice,
                ReferenceInvoiceNo,
                false,
                IsDummy);

            CurrDocLocRegNo := GetLocationRegistrationNo(
                "Transaction Type Enum"::Service,
                PurchDocType,
                SalesDocType,
                ServiceHeader."No.",
                true,
                IsDummy);

            PostedDocLocRegNo := GetLocationRegistrationNo(
                "Transaction Type Enum"::Service,
                PurchDocType,
                SalesDocType,
                ReferenceInvoiceNo,
                false,
                IsDummy);

            CurrDocGSTJurisdiction := GetGSTJurisdiction(
                "Transaction Type Enum"::Service,
                PurchDocType,
                SalesDocType,
                ServiceHeader."No.",
                true,
                IsDummy);

            PostedDocGSTJurisdiction := GetGSTJurisdiction(
                "Transaction Type Enum"::Service,
                PurchDocType,
                SalesDocType::Invoice,
                ReferenceInvoiceNo,
                false,
                IsDummy);

            PostedCurrencyCode := GetCurrencyCode(
                "Transaction Type Enum"::Service,
                "Gen. Journal Document Type"::Invoice,
                ReferenceInvoiceNo,
                ServiceHeader."Customer No.");

            if CurrDocGSTJurisdiction <> PostedDocGSTJurisdiction then
                Error(DiffJurisdictionErr, ServiceLine.FieldCaption("GST Jurisdiction Type"));

            if CurrDocumentGSTRegNo <> PostedDocumentGSTRegNo then
                Error(DiffGSTRegNoErr, ServiceLine.FieldCaption("GST Place Of Supply"), ReferenceInvoiceNo);

            if CurrDocLocRegNo <> PostedDocLocRegNo then
                Error(DiffGSTRegNoErr, ServiceLine.FieldCaption("Location Code"), ReferenceInvoiceNo);

            if ServiceHeader."Currency Code" <> PostedCurrencyCode then
                Error(DiffCurrencyCodeErr, ServiceHeader."Currency Code");
        end;
    end;

    local procedure IsGSTApplicablePostedPurchaseInvoice(DocNo: Code[20]): Boolean
    var
        PurchInvLine: Record "Purch. Inv. Line";
        GSTSetup: Record "GST Setup";
        TaxTransactionValue: Record "Tax Transaction Value";
        TaxTransactionFound: Boolean;
    begin
        if not GSTSetup.Get() then
            exit;

        PurchInvLine.Reset();
        PurchInvLine.SetRange("Document No.", DocNo);
        PurchInvLine.SetFilter(Type, '<>%1', PurchInvLine.Type::" ");
        if PurchInvLine.FindSet() then
            repeat
                GSTSetup.TestField("GST Tax Type");

                TaxTransactionValue.SetLoadFields("Tax Record ID", "Tax Type", Percent);
                TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
                TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
                TaxTransactionValue.SetRange("Tax Record ID", PurchInvLine.RecordId);
                TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
                if not TaxTransactionValue.IsEmpty() then
                    TaxTransactionFound := true;
            until PurchInvLine.Next() = 0;

        if not TaxTransactionFound then
            exit(false);

        CheckCompanyInfoGSTDetails();

        exit(true);
    end;

    local procedure IsGSTApplicablePostedPurchaseCrMemo(DocNo: Code[20]): Boolean
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        GSTSetup: Record "GST Setup";
        TaxTransactionValue: Record "Tax Transaction Value";
        TaxTransactionFound: Boolean;
    begin
        if not GSTSetup.Get() then
            exit;

        PurchCrMemoLine.Reset();
        PurchCrMemoLine.SetRange("Document No.", DocNo);
        PurchCrMemoLine.SetFilter(Type, '<>%1', PurchCrMemoLine.Type::" ");
        if PurchCrMemoLine.FindSet() then
            repeat
                GSTSetup.TestField("GST Tax Type");

                TaxTransactionValue.SetLoadFields("Tax Record ID", "Tax Type", Percent);
                TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
                TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
                TaxTransactionValue.SetRange("Tax Record ID", PurchCrMemoLine.RecordId);
                TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
                if not TaxTransactionValue.IsEmpty() then
                    TaxTransactionFound := true;
            until PurchCrMemoLine.Next() = 0;

        if not TaxTransactionFound then
            exit(false);

        CheckCompanyInfoGSTDetails();

        exit(true);
    end;

    local procedure IsGSTApplicablePostedSalesInvoice(DocNo: Code[20]): Boolean
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        GSTSetup: Record "GST Setup";
        TaxTransactionValue: Record "Tax Transaction Value";
        TaxTransactionFound: Boolean;
    begin
        if not GSTSetup.Get() then
            exit;

        SalesInvoiceLine.Reset();
        SalesInvoiceLine.SetRange("Document No.", DocNo);
        SalesInvoiceLine.SetFilter(Type, '<>%1', SalesInvoiceLine.Type::" ");
        if SalesInvoiceLine.FindSet() then
            repeat
                GSTSetup.TestField("GST Tax Type");

                TaxTransactionValue.SetLoadFields("Tax Record ID", "Tax Type", "Percent");
                TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
                TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
                TaxTransactionValue.SetRange("Tax Record ID", SalesInvoiceLine.RecordId);
                TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
                if not TaxTransactionValue.IsEmpty() then
                    TaxTransactionFound := true;
            until SalesInvoiceLine.Next() = 0;

        if not TaxTransactionFound then
            exit(false);

        CheckCompanyInfoGSTDetails();

        exit(true);
    end;

    local procedure IsGSTApplicablePostedSalesCrMemo(DocNo: Code[20]): Boolean
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        GSTSetup: Record "GST Setup";
        TaxTransactionValue: Record "Tax Transaction Value";
        TaxTransactionFound: Boolean;
    begin
        if not GSTSetup.Get() then
            exit;

        SalesCrMemoLine.Reset();
        SalesCrMemoLine.SetRange("Document No.", DocNo);
        SalesCrMemoLine.SetFilter(Type, '<>%1', SalesCrMemoLine.Type::" ");
        if SalesCrMemoLine.FindSet() then
            repeat
                GSTSetup.TestField("GST Tax Type");
                TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
                TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
                TaxTransactionValue.SetRange("Tax Record ID", SalesCrMemoLine.RecordId);
                TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
                if not TaxTransactionValue.IsEmpty() then
                    TaxTransactionFound := true;
            until SalesCrMemoLine.Next() = 0;

        if not TaxTransactionFound then
            exit(false);

        CheckCompanyInfoGSTDetails();

        exit(true);
    end;

    local procedure IsGSTApplicablePostedServiceInvoice(DocNo: Code[20]): Boolean
    var
        ServiceInvoiceLine: Record "Service Invoice Line";
        GSTSetup: Record "GST Setup";
        TaxTransactionValue: Record "Tax Transaction Value";
        TaxTransactionFound: Boolean;
    begin
        if not GSTSetup.Get() then
            exit;

        ServiceInvoiceLine.Reset();
        ServiceInvoiceLine.SetRange("Document No.", DocNo);
        ServiceInvoiceLine.SetFilter(Type, '<>%1', ServiceInvoiceLine.Type::" ");
        if ServiceInvoiceLine.FindSet() then
            repeat
                GSTSetup.TestField("GST Tax Type");

                TaxTransactionValue.SetLoadFields("Tax Record ID", "Tax Type", Percent);
                TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
                TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
                TaxTransactionValue.SetRange("Tax Record ID", ServiceInvoiceLine.RecordId);
                TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
                if not TaxTransactionValue.IsEmpty() then
                    TaxTransactionFound := true;
            until ServiceInvoiceLine.Next() = 0;

        if not TaxTransactionFound then
            exit(false);

        CheckCompanyInfoGSTDetails();

        exit(true);
    end;

    local procedure IsGSTApplicablePostedServiceCrMemo(DocNo: Code[20]): Boolean
    var
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
        GSTSetup: Record "GST Setup";
        TaxTransactionValue: Record "Tax Transaction Value";
        TaxTransactionFound: Boolean;
    begin
        if not GSTSetup.Get() then
            exit;

        ServiceCrMemoLine.Reset();
        ServiceCrMemoLine.SetRange("Document No.", DocNo);
        ServiceCrMemoLine.SetFilter(Type, '<>%1', ServiceCrMemoLine.Type::" ");
        if ServiceCrMemoLine.FindSet() then
            repeat
                GSTSetup.TestField("GST Tax Type");

                TaxTransactionValue.SetLoadFields("Tax Record ID", "Tax Type", Percent);
                TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
                TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
                TaxTransactionValue.SetRange("Tax Record ID", ServiceCrMemoLine.RecordId);
                TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
                if not TaxTransactionValue.IsEmpty() then
                    TaxTransactionFound := true;

            until ServiceCrMemoLine.Next() = 0;

        if not TaxTransactionFound then
            exit(false);

        CheckCompanyInfoGSTDetails();

        exit(true);
    end;

    local procedure CheckCompanyInfoGSTDetails()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        if (CompanyInformation."GST Registration No." = '') and (CompanyInformation."ARN No." = '') then
            Error(CompGSTRegNoARNNoErr);
    end;

    local procedure CheckRefInvNoServiceHeader(var ServiceHeader: Record "Service Header")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        GSTDocumentType: Enum "Document Type Enum";
    begin
        if not IsGSTApplicable("Transaction Type Enum"::Service, ServiceHeader."Document Type", ServiceHeader."Document Type", ServiceHeader."No.") then
            exit;

        if (ServiceHeader."Document Type" = ServiceHeader."Document Type"::"Credit Memo") or
            (ServiceHeader."Invoice Type" in [ServiceHeader."Invoice Type"::"Debit Note", ServiceHeader."Invoice Type"::Supplementary])
        then begin
            GSTDocumentType := ServiceDocumentType2DocumentTypeEnum(ServiceHeader."Document Type");

            ReferenceInvoiceNo.SetRange("Document Type", GSTDocumentType);
            ReferenceInvoiceNo.SetRange("Document No.", ServiceHeader."No.");
            ReferenceInvoiceNo.SetRange("Source No.", ServiceHeader."Bill-to Customer No.");
            if ReferenceInvoiceNo.FindSet() then
                repeat
                    CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
                    CustLedgerEntry.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
                    if CustLedgerEntry.FindFirst() then
                        CheckGSTAccountingPeriod(ServiceHeader."No.", ServiceHeader."Posting Date", CustLedgerEntry."Posting Date");
                until ReferenceInvoiceNo.Next() = 0
            else
                Error(ReferenceInvNoServiceErr, ServiceHeader."Document Type", ServiceHeader."No.");
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Credit Memo", 'OnAfterActionEvent', 'Update Reference Invoice No.', false, false)]
    local procedure PurchCrMemoOnAfterUpdateRefInvNo(var Rec: Record "Purchase Header")
    begin
        UpdateReferenceInvoiceNoPurchHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Invoice", 'OnAfterActionEvent', 'Update Reference Invoice No.', false, false)]
    local procedure PurchInvOnAfterUpdateRefInvNo(var Rec: Record "Purchase Header")
    begin
        UpdateReferenceInvoiceNoPurchHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order", 'OnAfterActionEvent', 'Update Reference Invoice No.', false, false)]
    local procedure PurchOrdOnAfterUpdateRefInvNo(var Rec: Record "Purchase Header")
    begin
        UpdateReferenceInvoiceNoPurchHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Return Order", 'OnAfterActionEvent', 'Update Reference Invoice No.', false, false)]
    local procedure PurchRetOrdOnAfterUpdateRefInvNo(var Rec: Record "Purchase Header")
    begin
        UpdateReferenceInvoiceNoPurchHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Credit Memo", 'OnAfterActionEvent', 'Update Reference Invoice No.', false, false)]
    local procedure SalesCrMemoOnAfterUpdateRefInvNo(var Rec: Record "Sales Header")
    begin
        UpdateReferenceInvoiceNoSalesHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice", 'OnAfterActionEvent', 'Update Reference Invoice No.', false, false)]
    local procedure SalesInvOnAfterUpdateRefInvNo(var Rec: Record "Sales Header")
    begin
        UpdateReferenceInvoiceNoSalesHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order", 'OnAfterActionEvent', 'Update Reference Invoice No.', false, false)]
    local procedure SalesOrdOnAfterUpdateRefInvNo(var Rec: Record "Sales Header")
    begin
        UpdateReferenceInvoiceNoSalesHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Return Order", 'OnAfterActionEvent', 'Update Reference Invoice No.', false, false)]
    local procedure SalesRetOrdOnAfterUpdateRefInvNo(var Rec: Record "Sales Header")
    begin
        UpdateReferenceInvoiceNoSalesHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"General Journal", 'OnAfterActionEvent', 'Update Reference Invoice No.', false, false)]
    local procedure GenJnlOnAfterUpdateRefInvNo(var Rec: Record "Gen. Journal Line")
    begin
        UpdateReferenceInvoiceNoGenJournal(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Journal Voucher", 'OnAfterActionEvent', 'Update Reference Invoice No.', false, false)]
    local procedure JnlVoucherOnAfterUpdateRefInvNo(var Rec: Record "Gen. Journal Line")
    begin
        UpdateReferenceInvoiceNoGenJournal(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Journal", 'OnAfterActionEvent', 'Update Reference Invoice No.', false, false)]
    local procedure PurchJnlOnAfterUpdateRefInvNo(var Rec: Record "Gen. Journal Line")
    begin
        UpdateReferenceInvoiceNoGenJournal(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Journal", 'OnAfterActionEvent', 'Update Reference Invoice No.', false, false)]
    local procedure SalesJnlOnAfterUpdateRefInvNo(var Rec: Record "Gen. Journal Line")
    begin
        UpdateReferenceInvoiceNoGenJournal(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Fixed Asset G/L Journal", 'OnAfterActionEvent', 'Update Reference Invoice No.', false, false)]
    local procedure FAGLJnlOnAfterUpdateRefInvNo(var Rec: Record "Gen. Journal Line")
    begin
        UpdateReferenceInvoiceNoGenJournal(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Reference Invoice No.", 'OnAfterValidateEvent', 'Reference Invoice Nos.', false, false)]
    local procedure OnAfterValidateReferenceInvoiceNo(
        var Rec: Record "Reference Invoice No.";
        var xRec: Record "Reference Invoice No.")
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntryToCheck: Record "Vendor Ledger Entry";
        VendorLedgerEntryCopy: Record "Vendor Ledger Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GenJnlLine: Record "Gen. Journal Line";
    begin
        if (xRec."Reference Invoice Nos." <> '') and (xRec."Reference Invoice Nos." <> Rec."Reference Invoice Nos.") and Rec.Verified then
            Error(RefNoAlterErr);

        if Rec.Verified then
            Error(ReferenceVerifyErr);

        if Rec."Reference Invoice Nos." <> '' then
            if Purchaseheader.Get(Rec."Document Type", Rec."Document No.") then begin
                VendorLedgerEntryToCheck.LoadFields("Document No.");
                VendorLedgerEntryToCheck.SetRange("Document No.", Rec."Reference Invoice Nos.");
                if VendorLedgerEntryToCheck.IsEmpty() then
                    Error(VendInvNoErr, Rec."Reference Invoice Nos.");
            end else
                if SalesHeader.Get(Rec."Document Type", Rec."Document No.") then begin
                    CustLedgerEntry.LoadFields("Document No.");
                    CustLedgerEntry.SetRange("Document No.", Rec."Reference Invoice Nos.");
                    if CustLedgerEntry.IsEmpty() then
                        Error(CustInvNoErr, Rec."Reference Invoice Nos.");
                end;

        if Rec."Source Type" <> "Source Type"::Customer then begin
            if PurchaseHeader.Get(Rec."Document Type", Rec."Document No.") then begin
                VendorLedgerEntryToCheck.SetRange("Document No.", Rec."Reference Invoice Nos.");
                if VendorLedgerEntryToCheck.FindFirst() then
                    if not (VendorLedgerEntryToCheck."Document Type" = VendorLedgerEntryToCheck."Document Type"::Invoice) then
                        Error(DocumentTypeErr);

                DetailedGSTLedgerEntry.SetRange("Document No.", Rec."Reference Invoice Nos.");
                DetailedGSTLedgerEntry.SetRange("Source No.", VendorLedgerEntryToCheck."Vendor No.");
                if DetailedGSTLedgerEntry.IsEmpty() then
                    Error(ReferenceInvoiceErr);

                CheckGSTPurchCrMemoValidationReference(PurchaseHeader, Rec."Reference Invoice Nos.");
            end else begin
                GenJnlLine.SetRange("Journal Template Name", Rec."Journal Template Name");
                GenJnlLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                GenJnlLine.SetRange("Document No.", Rec."Document No.");
                if GenJnlLine.FindFirst() then begin
                    VendorLedgerEntryToCheck.SetRange("Document No.", Rec."Reference Invoice Nos.");
                    if VendorLedgerEntryToCheck.FindFirst() then
                        if not (VendorLedgerEntryToCheck."Document Type" = VendorLedgerEntryToCheck."Document Type"::Invoice) then
                            Error(DocumentTypeErr);

                    DetailedGSTLedgerEntry.SetRange("Document No.", Rec."Reference Invoice Nos.");
                    DetailedGSTLedgerEntry.SetRange("Source No.", VendorLedgerEntryToCheck."Vendor No.");
                    if DetailedGSTLedgerEntry.IsEmpty() then
                        Error(ReferenceInvoiceErr);

                    CheckGSTPurchCrMemoValidationsJournalReference(GenJnlLine, Rec."Reference Invoice Nos.");
                end;
            end;

            VendorLedgerEntryToCheck.SetRange("Document No.", Rec."Document No.");
            if VendorLedgerEntryToCheck.FindFirst() then begin
                VendorLedgerEntryCopy.Copy(VendorLedgerEntryToCheck);
                VendorLedgerEntry.SetRange("Document No.", Rec."Reference Invoice Nos.");
                if VendorLedgerEntry.FindFirst() then begin
                    if not (VendorLedgerEntry."Document Type" = VendorLedgerEntry."Document Type"::Invoice) then
                        Error(DocumentTypeErr);

                    if VendorLedgerEntryToCheck."Vendor No." <> Rec."Source No." then
                        Error(DiffVendNoErr);

                    DetailedGSTLedgerEntry.SetRange("Document No.", Rec."Reference Invoice Nos.");
                    DetailedGSTLedgerEntry.SetRange("Source No.", VendorLedgerEntry."Vendor No.");
                    if DetailedGSTLedgerEntry.IsEmpty() then
                        Error(ReferenceInvoiceErr);

                    CheckGSTPurchCrMemoValidationsOffline(VendorLedgerEntryCopy, VendorLedgerEntry, 0, Rec."Reference Invoice Nos.");
                end;
            end;
        end;

        UpdateCustomerValidations(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterValidatePostingAndDocumentDate', '', false, false)]
    local procedure PurchPostOnAfterValidatePostingAndDocumentDate(var PurchaseHeader: Record "Purchase Header")
    begin
        CheckRefInvNoPurchHeader(PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterValidatePostingAndDocumentDate', '', false, false)]
    local procedure SalesPostOnAfterValidatePostingAndDocumentDate(var SalesHeader: Record "Sales Header")
    begin
        CheckRefInvNoSalesHeader(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', false, false)]
    local procedure PurchPostOnAfterPostPurchaseDoc(
        var PurchaseHeader: Record "Purchase Header";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        PurchRcpHdrNo: Code[20];
        RetShptHdrNo: Code[20];
        PurchInvHdrNo: Code[20];
        PurchCrMemoHdrNo: Code[20];
        CommitIsSupressed: Boolean)
    begin
        CreatePostedReferenceInvoiceNoPurch(PurchaseHeader, PurchInvHdrNo, PurchCrMemoHdrNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure SalesPostOnAfterPostSalesDoc(
        var SalesHeader: Record "Sales Header";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        SalesShptHdrNo: Code[20];
        RetRcpHdrNo: Code[20];
        SalesInvHdrNo: Code[20];
        SalesCrMemoHdrNo: Code[20];
        CommitIsSuppressed: Boolean;
        InvtPickPutaway: Boolean;
        var CustLedgerEntry: Record "Cust. Ledger Entry";
        WhseShip: Boolean;
        WhseReceiv: Boolean)
    begin
        CreatePostedReferenceInvoiceNoSales(SalesHeader, SalesInvHdrNo, SalesCrMemoHdrNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforePostVend', '', false, false)]
    local procedure GenJnlPostLineOnBeforePostVend(var GenJournalLine: Record "Gen. Journal Line")
    begin
        if not GenJournalLine."GST in Journal" then
            exit;

        CheckReferenceInvPurchJnl(GenJournalLine);
        CreatePostedReferenceInvoiceNoPurchJnl(GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostCustOnBeforeInitCustLedgEntry', '', false, false)]
    local procedure GenJnlPostLineOnBeforePostCust(var GenJournalLine: Record "Gen. Journal Line")
    begin
        if not GenJournalLine."GST in Journal" then
            exit;

        CheckReferenceInvSalesJnl(GenJournalLine);
        CreatePostedReferenceInvoiceNoSalesJnl(GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Tax", 'OnAfterValidateGenJnlLineFields', '', false, false)]
    local procedure UpdateGenJnlLineGSTInJournal(var GenJnlLine: Record "Gen. Journal Line")
    var
        GSTSetup: Record "GST Setup";
    begin
        if GenJnlLine."GST Group Code" = '' then
            exit;

        if (GenJnlLine."Journal Template Name" <> '') and (GenJnlLine."Journal Batch Name" <> '') and (GenJnlLine."Line No." <> 0) then begin
            if not GSTSetup.Get() then
                exit;

            GSTSetup.TestField("GST Tax Type");
            if not (GenJnlLine."Document Type" in [GenJnlLine."Document Type"::Invoice, GenJnlLine."Document Type"::"Credit Memo"]) then
                GenJnlLine."GST in Journal" := false
            else
                GenJnlLine."GST in Journal" := FilterTaxTransactionValue(GSTSetup."GST Tax Type", GenJnlLine.RecordId);
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Service Order", 'OnActionUpdateRefInvNo', '', false, false)]
    local procedure ServiceOrdOnAfterUpdateRefInvNo(Rec: Record "Service Header")
    begin
        UpdateReferenceInvoiceNoServiceHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Service Invoice", 'OnActionUpdateRefInvNo', '', false, false)]
    local procedure ServiceInvOnAfterUpdateRefInvNo(Rec: Record "Service Header")
    begin
        UpdateReferenceInvoiceNoServiceHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Service Credit Memo", 'OnActionUpdateRefInvNo', '', false, false)]
    local procedure ServiceCrMemoOnAfterUpdateRefInvNo(Rec: Record "Service Header")
    begin
        UpdateReferenceInvoiceNoServiceHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnAfterValidatePostingAndDocumentDate', '', false, false)]
    local procedure ServicePostOnAfterValidatePostingAndDocumentDate(var ServiceHeader: Record "Service Header")
    begin
        CheckRefInvNoServiceHeader(ServiceHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnAfterPostServiceDoc', '', false, false)]
    local procedure ServicePostOnAfterPostServiceDoc(
        var ServiceHeader: Record "Service Header";
        ServInvoiceNo: Code[20];
        ServCrMemoNo: Code[20])
    begin
        CreatePostedReferenceInvoiceNoService(ServiceHeader, ServInvoiceNo, ServCrMemoNo);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckRefInvNoPurchaseHeader(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateReferenceInvoiceNoPurchaseHeader(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckRefInvoiceNoSalesHeader(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateRefInvoiceNoSalesHeader(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

}
