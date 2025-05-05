// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Service.Posting;
using Microsoft.Finance.GeneralLedger.Reports;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Reporting;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;
using Microsoft.Sales.Receivables;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using System.Email;
using System.Environment.Configuration;
using System.Media;
using System.Reflection;
using System.Utilities;

codeunit 5579 "Digital Voucher Impl."
{
    Permissions = TableData "Sales Invoice Header" = m,
                  Tabledata "Sales Cr.Memo Header" = m,
                  Tabledata "Service Invoice Header" = m,
                  Tabledata "Service Cr.Memo Header" = m,
                  Tabledata "Purch. Inv. Header" = m,
                  Tabledata "Purch. Cr. Memo Hdr." = m;

    var
        DigitalVoucherFeature: Codeunit "Digital Voucher Feature";
        DigitalVoucherEntry: Codeunit "Digital Voucher Entry";
        AssistedSetupTxt: Label 'Set up a digital voucher feature';
        AssistedSetupDescriptionTxt: Label 'In some countries authorities require to make sure that for every single general ledger register ther is a digital vouchers assigned.';
        AssistedSetupHelpTxt: Label 'https://learn.microsoft.com/en-us/dynamics365/business-central/across-how-setup-digital-vouchers', Locked = true;
        CannotRemoveReferenceRecordFromIncDocErr: Label 'Cannot remove the reference record from the incoming document because it is used for the enforced digital voucher functionality';
        CannotChangeIncomDocWithEnforcedDigitalVoucherErr: Label 'Cannot change incoming document with the enforced digital voucher functionality';
        DigitalVoucherFileTxt: Label 'DigitalVoucher_%1_%2_%3.pdf', Comment = '%1 = doc type; %2 = posting date; %3 = doc no.';

    procedure HandleDigitalVoucherForDocument(var ErrorMessageMgt: Codeunit "Error Message Management"; EntryType: Enum "Digital Voucher Entry Type"; Record: Variant)
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
    begin
        GetDigitalVoucherEntrySetup(DigitalVoucherEntrySetup, EntryType);
        HandleDigitalVoucherForEntryTypeAndDoc(ErrorMessageMgt, DigitalVoucherEntrySetup, Record);
    end;

    procedure HandleDigitalVoucherForEntryTypeAndDoc(var ErrorMessageMgt: Codeunit "Error Message Management"; DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup"; Record: Variant)
    var
        RecRef: RecordRef;
        DigitalVoucherCheck: Interface "Digital Voucher Check";
    begin
        if DigitalVoucherEntrySetup."Check Type" = DigitalVoucherEntrySetup."Check Type"::"No Check" then
            exit;
        DigitalVoucherCheck := DigitalVoucherEntrySetup."Check Type";
        RecRef.GetTable(Record);
        DigitalVoucherCheck.CheckVoucherIsAttachedToDocument(ErrorMessageMgt, DigitalVoucherEntrySetup."Entry Type", RecRef);
    end;

    procedure HandleDigitalVoucherForPostedDocument(EntryType: Enum "Digital Voucher Entry Type"; Record: Variant)
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
        RecRef: RecordRef;
        DigitalVoucherCheck: Interface "Digital Voucher Check";
    begin
        GetDigitalVoucherEntrySetup(DigitalVoucherEntrySetup, EntryType);
        if DigitalVoucherEntrySetup."Check Type" = DigitalVoucherEntrySetup."Check Type"::"No Check" then
            exit;
        DigitalVoucherCheck := DigitalVoucherEntrySetup."Check Type";
        RecRef.GetTable(Record);
        DigitalVoucherCheck.GenerateDigitalVoucherForPostedDocument(DigitalVoucherEntrySetup."Entry Type", RecRef);
    end;

    procedure HandleDigitalVoucherForPostedGLEntry(GLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line"; GenJournalSourceType: Enum "Gen. Journal Source Type")
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
        ConnectedGenJournalLine: Record "Gen. Journal Line";
        RecRef: RecordRef;
        DigitalVoucherCheck: Interface "Digital Voucher Check";
    begin
        if not GetDigitalVoucherEntrySetup(DigitalVoucherEntrySetup, DigitalVoucherEntry.GetVoucherTypeFromGLEntryOrSourceType(GLEntry, GenJournalSourceType)) then
            exit;
        if DigitalVoucherEntrySetup."Check Type" = DigitalVoucherEntrySetup."Check Type"::"No Check" then
            exit;
        DigitalVoucherCheck := DigitalVoucherEntrySetup."Check Type";
        FindGenJournalLineFromGLEntry(ConnectedGenJournalLine, GenJournalLine, GLEntry);
        if not ShouldGenJnlLineHasDigitalVoucher(ConnectedGenJournalLine, DigitalVoucherEntrySetup) then
            exit;
        RecRef.GetTable(ConnectedGenJournalLine);
        DigitalVoucherCheck.GenerateDigitalVoucherForPostedDocument(DigitalVoucherEntrySetup."Entry Type", RecRef);
    end;

    [CommitBehavior(CommitBehavior::Ignore)]
    procedure GenerateDigitalVoucherForDocument(RecRef: RecordRef)
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ServInvHeader: Record "Service Invoice Header";
        ServCrMemoHeader: Record "Service Cr.Memo Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        ReportSelections: Record "Report Selections";
    begin
        case RecRef.Number of
            Database::"Sales Invoice Header":
                begin
                    RecRef.SetTable(SalesInvHeader);
                    AttachDigitalVoucherFromReportPDF(
                        ReportSelections.Usage::"S.Invoice", RecRef, true,
                        SalesInvHeader."Posting Date", SalesInvHeader."No.", Database::Customer,
                        SalesInvHeader."Bill-to Customer No.", Report::"Standard Sales - Invoice");
                    RestoreNoPrintedToOriginal(RecRef, SalesInvHeader.FieldNo("No. Printed"), SalesInvHeader."No. Printed");
                end;
            Database::"Service Invoice Header":
                begin
                    RecRef.SetTable(ServInvHeader);
                    AttachDigitalVoucherFromReportPDF(
                        ReportSelections.Usage::"SM.Invoice", RecRef, true,
                        ServInvHeader."Posting Date", ServInvHeader."No.", Database::Customer,
                        ServInvHeader."Bill-to Customer No.", Report::"Service - Invoice");
                    RestoreNoPrintedToOriginal(RecRef, ServInvHeader.FieldNo("No. Printed"), ServInvHeader."No. Printed");
                end;
            Database::"Service Cr.Memo Header":
                begin
                    RecRef.SetTable(ServCrMemoHeader);
                    AttachDigitalVoucherFromReportPDF(
                        ReportSelections.Usage::"SM.Credit Memo", RecRef, false,
                        ServCrMemoHeader."Posting Date", ServCrMemoHeader."No.", Database::Customer,
                        ServCrMemoHeader."Bill-to Customer No.", Report::"Service - Credit Memo");
                    RestoreNoPrintedToOriginal(RecRef, ServCrMemoHeader.FieldNo("No. Printed"), ServCrMemoHeader."No. Printed");
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    RecRef.SetTable(SalesCrMemoHeader);
                    AttachDigitalVoucherFromReportPDF(
                        ReportSelections.Usage::"S.Cr.Memo", RecRef, false,
                        SalesCrMemoHeader."Posting Date", SalesCrMemoHeader."No.", Database::Customer,
                        SalesCrMemoHeader."Bill-to Customer No.", Report::"Standard Sales - Credit Memo");
                    RestoreNoPrintedToOriginal(RecRef, SalesCrMemoHeader.FieldNo("No. Printed"), SalesCrMemoHeader."No. Printed");
                end;
            Database::"Purch. Inv. Header":
                begin
                    RecRef.SetTable(PurchInvHeader);
                    AttachDigitalVoucherFromReportPDF(
                        ReportSelections.Usage::"P.Invoice", RecRef, true,
                        PurchInvHeader."Posting Date", PurchInvHeader."No.", Database::Vendor,
                        PurchInvHeader."Pay-to Vendor No.", report::"Purchase - Invoice");
                    RestoreNoPrintedToOriginal(RecRef, PurchInvHeader.FieldNo("No. Printed"), PurchInvHeader."No. Printed");
                end;
            Database::"Purch. Cr. Memo Hdr.":
                begin
                    RecRef.SetTable(PurchCrMemoHeader);
                    AttachDigitalVoucherFromReportPDF(
                        ReportSelections.Usage::"P.Cr.Memo", RecRef, false,
                        PurchCrMemoHeader."Posting Date", PurchCrMemoHeader."No.", Database::Vendor,
                        PurchCrMemoHeader."Pay-to Vendor No.", report::"Purchase - Credit Memo");
                    RestoreNoPrintedToOriginal(RecRef, PurchCrMemoHeader.FieldNo("No. Printed"), PurchCrMemoHeader."No. Printed");
                end;
            Database::"Gen. Journal Line":
                AttachGenJnlLinePDFToIncomingDocument(RecRef);
            else
                OnGenerateDigitalVoucherForDocumentOnCaseElse(RecRef);
        end;
    end;

    local procedure RestoreNoPrintedToOriginal(var RecRef: RecordRef; NoPrintedFieldNumber: Integer; OriginalNoPrinted: Integer)
    var
        FieldRef: FieldRef;
        CurrentNoPrinted: Integer;
    begin
        if not RecRef.Find() then
            exit;
        FieldRef := RecRef.Field(NoPrintedFieldNumber);
        if not Evaluate(CurrentNoPrinted, Format(FieldRef.Value())) then
            exit;
        if CurrentNoPrinted = OriginalNoPrinted then
            exit;
        FieldRef.Value := OriginalNoPrinted;
        RecRef.Modify();
    end;

    procedure AttachBlobToIncomingDocument(var TempBlob: Codeunit "Temp Blob"; DocType: Text; PostingDate: Date; DocNo: Code[20])
    var
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        ImportAttachmentIncDoc: Codeunit "Import Attachment - Inc. Doc.";
    begin
        IncomingDocumentAttachment.SetRange("Document No.", DocNo);
        IncomingDocumentAttachment.SetRange("Posting Date", PostingDate);
        IncomingDocumentAttachment.SetContentFromBlob(TempBlob);
        if not ImportAttachmentIncDoc.ImportAttachment(
            IncomingDocumentAttachment,
            StrSubstNo(
                DigitalVoucherFileTxt, DocType,
                Format(PostingDate, 0, '<Day,2><Month,2><Year4>'), DocNo), TempBlob)
        then
            exit;
        IncomingDocumentAttachment."Is Digital Voucher" := true;
        IncomingDocumentAttachment.Modify();
    end;

    procedure CheckDigitalVoucherForDocument(DigitalVoucherEntryType: Enum "Digital Voucher Entry Type"; RecRef: RecordRef): Boolean
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
        IncomingDocument: Record "Incoming Document";
        SourceCodeSetup: Record "Source Code Setup";
        VoucherAttached: Boolean;
    begin
        GetDigitalVoucherEntrySetup(DigitalVoucherEntrySetup, DigitalVoucherEntryType);
        VoucherAttached := GetIncomingDocumentRecordFromRecordRef(IncomingDocument, RecRef);
        if VoucherAttached then
            exit(true);
        if DigitalVoucherEntrySetup."Generate Automatically" then
            exit(true);
        SourceCodeSetup.Get();
        if IsPaymentReconciliationJournal(DigitalVoucherEntrySetup."Entry Type", RecRef) then
            exit(true);
        if IsGenJnlLineWithIncDocAttachedToAdjLine(DigitalVoucherEntrySetup."Entry Type", RecRef) then
            exit(true);
        exit(false);
    end;

    procedure CheckIncomingDocumentChange(Rec: Record "Incoming Document Attachment")
    var
        IncomingDocument: Record "Incoming Document";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
        RelatedRecord: Variant;
    begin
        if not DigitalVoucherFeature.IsFeatureEnabled() then
            exit;
        if not IncomingDocument.Get(Rec."Incoming Document Entry No.") then
            exit;
        if not IncomingDocument.Posted then
            exit;
        if not IncomingDocument.GetRecord(RelatedRecord) then
            exit;
        DataTypeManagement.GetRecordRef(RelatedRecord, RecRef);
        if DigitalVoucherFeature.IsDigitalVoucherEnabledForTableNumber(RecRef.Number) then
            error(CannotChangeIncomDocWithEnforcedDigitalVoucherErr);
    end;

    procedure GetDigitalVoucherEntrySetup(var DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup"; EntryType: Enum "Digital Voucher Entry Type"): Boolean
    begin
        if DigitalVoucherFeature.EnforceDigitalVoucherFunctionality() then
            OnHandleDigitalVoucherEntrySetupWhenEnforced(EntryType);
        exit(DigitalVoucherEntrySetup.Get(EntryType));
    end;

    procedure GetIncomingDocumentRecordFromRecordRef(var IncomingDocument: Record "Incoming Document"; MainRecordRef: RecordRef): Boolean
    var
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
    begin
        IncomingDocumentAttachment.ReadIsolation := IsolationLevel::ReadUncommitted;
        if not FilterIncomingDocumentRecordFromRecordRef(IncomingDocumentAttachment, IncomingDocument, MainRecordRef) then
            exit(false);
        exit(not IncomingDocumentAttachment.IsEmpty());
    end;

    local procedure FilterIncomingDocumentRecordFromRecordRef(var IncomingDocumentAttachment: Record "Incoming Document Attachment"; var IncomingDocument: Record "Incoming Document"; MainRecordRef: RecordRef): Boolean
    begin
        Clear(IncomingDocument);
        if not IncomingDocument.FindFromIncomingDocumentEntryNo(MainRecordRef, IncomingDocument) then
            IncomingDocument.FindByDocumentNoAndPostingDate(MainRecordRef, IncomingDocument);
        if IncomingDocument."Entry No." = 0 then
            exit(false);
        IncomingDocumentAttachment.SetRange("Incoming Document Entry No.", IncomingDocument."Entry No.");
        exit(true);
    end;

    local procedure AttachGenJnlLinePDFToIncomingDocument(RecRef: RecordRef)
    var
        GenJournalLine: Record "Gen. Journal Line";
        ReportSelections: Record "Report Selections";
        TempBlob: Codeunit "Temp Blob";
        DummyReportUsage: Enum "Report Selection Usage";
    begin
        RecRef.SetTable(GenJournalLine);
        GenJournalLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        GenJournalLine.SetRange("Posting Date", GenJournalLine."Posting Date");
        GenJournalLine.SetRange("Document No.", GenJournalLine."Document No.");
        ReportSelections.SaveReportAsPDFInTempBlob(TempBlob, Report::"General Journal - Test", GenJournalLine, '', DummyReportUsage);
        AttachBlobToIncomingDocument(TempBlob, Format(GenJournalLine."Document Type"), GenJournalLine."Posting Date", GenJournalLine."Document No.");
    end;

    local procedure FindGenJournalLineFromGLEntry(var ConnectedGenJnlLine: Record "Gen. Journal Line"; CurrGenJnlLine: Record "Gen. Journal Line"; GLEntry: Record "G/L Entry")
    begin
        ConnectedGenJnlLine.SetLoadFields("Journal Template Name", "Journal Batch Name", "Posting Date", "Document Type", "Document No.");
        ConnectedGenJnlLine.SetRange("Journal Template Name", CurrGenJnlLine."Journal Template Name");
        ConnectedGenJnlLine.SetRange("Journal Batch Name", CurrGenJnlLine."Journal Batch Name");
        ConnectedGenJnlLine.SetRange("Posting Date", GLEntry."Posting Date");
        ConnectedGenJnlLine.SetRange("Document No.", GLEntry."Document No.");
        if ConnectedGenJnlLine.FindFirst() then
            exit;
        ConnectedGenJnlLine := CurrGenJnlLine;
    end;

    local procedure CopyDigitalVoucherToCorrectiveDocument(DigitalVoucherEntryType: Enum "Digital Voucher Entry Type"; RecordVar: Variant; DocNo: Code[20]; PostingDate: Date): Integer
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
        InvIncomingDocument: Record "Incoming Document";
        InvIncomingDocumentAttachment: Record "Incoming Document Attachment";
        ImportAttachmentIncDoc: Codeunit "Import Attachment - Inc. Doc.";
        RecRef: RecordRef;
    begin
        if not DigitalVoucherFeature.IsFeatureEnabled() then
            exit;
        if not GetDigitalVoucherEntrySetup(DigitalVoucherEntrySetup, DigitalVoucherEntryType) then
            exit;
        if DigitalVoucherEntrySetup."Generate Automatically" then
            exit;
        RecRef.GetTable(RecordVar);
        if not FilterIncomingDocumentRecordFromRecordRef(InvIncomingDocumentAttachment, InvIncomingDocument, RecRef) then
            exit;
        if not InvIncomingDocumentAttachment.FindFirst() then
            exit;
        InvIncomingDocumentAttachment.Reset();
        InvIncomingDocumentAttachment.SetRange("Document No.", DocNo);
        InvIncomingDocumentAttachment.SetRange("Posting Date", PostingDate);
        ImportAttachmentIncDoc.CreateNewAttachment(InvIncomingDocumentAttachment);
        InvIncomingDocumentAttachment.Insert(true);
        exit(InvIncomingDocumentAttachment."Incoming Document Entry No.");
    end;

    local procedure IsPaymentReconciliationJournal(DigitalVoucherEntryType: Enum "Digital Voucher Entry Type"; RecRef: RecordRef): Boolean
    var
        SourceCodeSetup: Record "Source Code Setup";
        GenJournalLine: Record "Gen. Journal Line";
        FieldRef: FieldRef;
        SourceCodeValue: Text;
    begin
        if DigitalVoucherEntryType <> DigitalVoucherEntryType::"Purchase Journal" then
            exit(false);
        if not SourceCodeSetup.Get() then
            exit(false);
        FieldRef := RecRef.Field(GenJournalLine.FieldNo("Source Code"));
        if not Evaluate(SourceCodeValue, FieldRef.Value()) then
            exit(false);
        exit(SourceCodeValue = SourceCodeSetup."Payment Reconciliation Journal");
    end;

    local procedure IsGenJnlLineWithIncDocAttachedToAdjLine(DigitalVoucherEntryType: Enum "Digital Voucher Entry Type"; RecRef: RecordRef): Boolean
    var
        GenJournalLine: Record "Gen. Journal Line";
        AdjacentGenJournalLine: Record "Gen. Journal Line";
        IncomingDocument: Record "Incoming Document";
    begin
        if DigitalVoucherEntryType <> DigitalVoucherEntryType::"General Journal" then
            exit(false);
        RecRef.SetTable(GenJournalLine);
        AdjacentGenJournalLine.ReadIsolation(IsolationLevel::ReadCommitted);
        AdjacentGenJournalLine.SetLoadFields(AdjacentGenJournalLine."Incoming Document Entry No.");
        AdjacentGenJournalLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        AdjacentGenJournalLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        AdjacentGenJournalLine.SetRange("Posting Date", GenJournalLine."Posting Date");
        AdjacentGenJournalLine.SetRange("Document No.", GenJournalLine."Document No.");
        AdjacentGenJournalLine.SetFilter("Line No.", '<>%1', GenJournalLine."Line No.");
        AdjacentGenJournalLine.SetFilter("Incoming Document Entry No.", '<>0');
        if not AdjacentGenJournalLine.FindFirst() then
            exit(false);
        exit(IncomingDocument.Get(AdjacentGenJournalLine."Incoming Document Entry No."));
    end;

    local procedure AttachDigitalVoucherFromReportPDF(ReportUsage: Enum "Report Selection Usage"; RecRef: RecordRef; IsInvoice: Boolean; PostingDate: Date; DocNo: Code[20]; AccountTableNo: Integer; AccountNo: Code[20]; StandardReportID: Integer)
    var
        TempAttachReportSelections: Record "Report Selections" temporary;
        SalesHeader: Record "Sales Header";
        TempBlob: Codeunit "Temp Blob";
        DocType: Text;
    begin
        FindReportSelections(TempAttachReportSelections, ReportUsage, AccountTableNo, AccountNo, StandardReportID);
        RecRef.SetRecFilter();
        TempAttachReportSelections.SaveReportAsPDFInTempBlob(TempBlob, TempAttachReportSelections."Report ID", RecRef, TempAttachReportSelections."Custom Report Layout Code", ReportUsage);
        if IsInvoice then
            DocType := Format(SalesHeader."Document Type"::Invoice)
        else
            DocType := Format(SalesHeader."Document Type"::"Credit Memo");
        AttachBlobToIncomingDocument(TempBlob, DocType, PostingDate, DocNo);
    end;

    local procedure FindReportSelections(var TempAttachReportSelections: Record "Report Selections" temporary; ReportUsage: Enum "Report Selection Usage"; AccountTableNo: Integer; AccountNo: Code[20]; StandardReportID: Integer)
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.SetRange(Usage, ReportUsage);
        ReportSelections.SetFilter("Report ID", '<>0');
        ReportSelections.FindReportSelections(TempAttachReportSelections, AccountNo, AccountTableNo);
        TempAttachReportSelections.SetRange("Use for Email Body", false);
        TempAttachReportSelections.SetRange("Use for Email Attachment", false);
        if TempAttachReportSelections.FindFirst() then
            exit;
        TempAttachReportSelections.SetRange("Use for Email Body");
        TempAttachReportSelections.SetRange("Use for Email Attachment");
        if TempAttachReportSelections.FindFirst() then
            exit;
        Clear(TempAttachReportSelections);
        TempAttachReportSelections.Usage := ReportUsage;
        TempAttachReportSelections."Report ID" := StandardReportID;
        TempAttachReportSelections.Insert();
    end;

    local procedure ShouldGenJnlLineHasDigitalVoucher(GenJournalLine: Record "Gen. Journal Line"; DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup"): Boolean
    begin
        if GenJournalLine."Document Type" in [GenJournalLine."Document Type"::Invoice, GenJournalLine."Document Type"::"Credit Memo"] then
            exit(true);
        if DigitalVoucherEntrySetup."Consider Blank Doc. Type" and (GenJournalLine."Document Type" = GenJournalLine."Document Type"::" ") then
            exit(true);
        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', true, true)]
    local procedure InsertIntoAssistedSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
    begin
        if DigitalVoucherFeature.EnforceDigitalVoucherFunctionality() then
            exit;
        GuidedExperience.InsertAssistedSetup(AssistedSetupTxt, CopyStr(AssistedSetupTxt, 1, 50), AssistedSetupDescriptionTxt, 5, ObjectType::Page, Page::"Digital Voucher Guide", AssistedSetupGroup::FinancialReporting,
                                            '', VideoCategory::FinancialReporting, AssistedSetupHelpTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterCheckSalesDoc', '', true, true)]
    local procedure OnAfterCheckSalesDoc(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; WhseShip: Boolean; WhseReceive: Boolean; PreviewMode: Boolean; var ErrorMessageMgt: Codeunit "Error Message Management")
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
        RecRef: RecordRef;
        DigitalVoucherCheck: Interface "Digital Voucher Check";
    begin
        if PreviewMode then
            exit;
        if not DigitalVoucherFeature.IsFeatureEnabled() then
            exit;
        if not SalesHeader.Invoice then
            exit;
        GetDigitalVoucherEntrySetup(DigitalVoucherEntrySetup, DigitalVoucherEntrySetup."Entry Type"::"Sales Document");
        if DigitalVoucherEntrySetup."Check Type" = DigitalVoucherEntrySetup."Check Type"::"No Check" then
            exit;
        DigitalVoucherCheck := DigitalVoucherEntrySetup."Check Type";
        RecRef.GetTable(SalesHeader);
        DigitalVoucherCheck.CheckVoucherIsAttachedToDocument(ErrorMessageMgt, DigitalVoucherEntrySetup."Entry Type", RecRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnInitializeOnAfterCheckAndSetPostingConstants', '', true, true)]
    local procedure OnInitializeOnAfterCheckAndSetPostingConstants(var PassedServiceHeader: Record "Service Header"; var PassedInvoice: Boolean; PreviewMode: Boolean)
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
        DummyErrorMessageMgt: Codeunit "Error Message Management";
        RecRef: RecordRef;
        DigitalVoucherCheck: Interface "Digital Voucher Check";
    begin
        if PreviewMode then
            exit;
        if not DigitalVoucherFeature.IsFeatureEnabled() then
            exit;
        if not PassedInvoice then
            exit;
        if PreviewMode then
            exit;
        GetDigitalVoucherEntrySetup(DigitalVoucherEntrySetup, DigitalVoucherEntrySetup."Entry Type"::"Sales Document");
        if DigitalVoucherEntrySetup."Check Type" = DigitalVoucherEntrySetup."Check Type"::"No Check" then
            exit;
        DigitalVoucherCheck := DigitalVoucherEntrySetup."Check Type";
        RecRef.GetTable(PassedServiceHeader);
        DigitalVoucherCheck.CheckVoucherIsAttachedToDocument(DummyErrorMessageMgt, DigitalVoucherEntrySetup."Entry Type", RecRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Prepayments", 'OnAfterCheckPrepmtDoc', '', true, true)]
    local procedure OnAfterCheckSalesPrepmtDoc(SalesHeader: Record "Sales Header"; DocumentType: Option Invoice,"Credit Memo"; CommitIsSuppressed: Boolean; var ErrorMessageMgt: Codeunit "Error Message Management")
    begin
        if not DigitalVoucherFeature.IsFeatureEnabled() then
            exit;
        HandleDigitalVoucherForDocument(ErrorMessageMgt, "Digital Voucher Entry Type"::"Sales Document", SalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterCheckPurchDoc', '', true, true)]
    local procedure OnAfterCheckPurchDoc(var PurchHeader: Record "Purchase Header"; CommitIsSupressed: Boolean; WhseShip: Boolean; WhseReceive: Boolean; PreviewMode: Boolean; var ErrorMessageMgt: Codeunit "Error Message Management")
    begin
        if PreviewMode then
            exit;
        if not DigitalVoucherFeature.IsFeatureEnabled() then
            exit;
        if not PurchHeader.Invoice then
            exit;
        HandleDigitalVoucherForDocument(ErrorMessageMgt, "Digital Voucher Entry Type"::"Purchase Document", PurchHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Prepayments", 'OnAfterCheckPrepmtDoc', '', true, true)]
    local procedure OnAfterCheckPurchPrepmtDoc(PurchHeader: Record "Purchase Header"; DocumentType: Option Invoice,"Credit Memo"; var ErrorMessageMgt: Codeunit "Error Message Management")
    begin
        if not DigitalVoucherFeature.IsFeatureEnabled() then
            exit;
        HandleDigitalVoucherForDocument(ErrorMessageMgt, "Digital Voucher Entry Type"::"Purchase Document", PurchHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', true, true)]
    local procedure OnAfterCheckGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; var ErrorMessageMgt: Codeunit "Error Message Management")
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
    begin
        if not DigitalVoucherFeature.IsFeatureEnabled() then
            exit;
        if GenJournalLine."System-Created Entry" then
            exit;
        if not GetDigitalVoucherEntrySetup(DigitalVoucherEntrySetup, DigitalVoucherEntry.GetVoucherEntryTypeFromGenJnlLine(GenJournalLine)) then
            exit;
        if not ShouldGenJnlLineHasDigitalVoucher(GenJournalLine, DigitalVoucherEntrySetup) then
            exit;
        HandleDigitalVoucherForEntryTypeAndDoc(ErrorMessageMgt, DigitalVoucherEntrySetup, GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', true, true)]
    local procedure CheckSalesVoucherOnAfterFinalizePostingOnBeforeCommit(var SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var ReturnReceiptHeader: Record "Return Receipt Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; WhseShip: Boolean; WhseReceive: Boolean; var EverythingInvoiced: Boolean)
    begin
        if PreviewMode then
            exit;
        if not DigitalVoucherFeature.IsFeatureEnabled() then
            exit;
        if not SalesHeader.Invoice then
            exit;
        if SalesInvoiceHeader."No." <> '' then
            HandleDigitalVoucherForPostedDocument("Digital Voucher Entry Type"::"Sales Document", SalesInvoiceHeader);
        if SalesCrMemoHeader."No." <> '' then
            HandleDigitalVoucherForPostedDocument("Digital Voucher Entry Type"::"Sales Document", SalesCrMemoHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnAfterPostServiceDoc', '', true, true)]
    local procedure CheckServiceVoucherOnAfterPostServiceDoc(ServInvoiceNo: Code[20]; ServCrMemoNo: Code[20]; PassedInvoice: Boolean)
    var
        ServInvHeader: Record "Service Invoice Header";
        ServCrMemoHeader: Record "Service Cr.Memo Header";
        RecVar: Variant;
    begin
        if not DigitalVoucherFeature.IsFeatureEnabled() then
            exit;
        if not PassedInvoice then
            exit;
        if ServInvoiceNo = '' then begin
            ServCrMemoHeader.Get(ServCrMemoNo);
            RecVar := ServCrMemoHeader;
        end else begin
            ServInvHeader.Get(ServInvoiceNo);
            RecVar := ServInvHeader;
        end;
        HandleDigitalVoucherForPostedDocument("Digital Voucher Entry Type"::"Sales Document", RecVar);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Prepayments", 'OnAfterPostPrepayments', '', true, true)]
    local procedure CheckSalesVoucherOnAfterPostPrepayments(var SalesHeader: Record "Sales Header"; DocumentType: Option Invoice,"Credit Memo"; CommitIsSuppressed: Boolean; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        if not DigitalVoucherFeature.IsFeatureEnabled() then
            exit;
        if SalesInvoiceHeader."No." <> '' then
            HandleDigitalVoucherForPostedDocument("Digital Voucher Entry Type"::"Sales Document", SalesInvoiceHeader);
        if SalesCrMemoHeader."No." <> '' then
            HandleDigitalVoucherForPostedDocument("Digital Voucher Entry Type"::"Sales Document", SalesCrMemoHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', true, true)]
    local procedure CheckPurchVoucherOnAfterFinalizePostingOnBeforeCommit(var PurchHeader: Record "Purchase Header"; var PurchRcptHeader: Record "Purch. Rcpt. Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var ReturnShptHeader: Record "Return Shipment Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PreviewMode: Boolean; CommitIsSupressed: Boolean; EverythingInvoiced: Boolean)
    begin
        if PreviewMode then
            exit;
        if not DigitalVoucherFeature.IsFeatureEnabled() then
            exit;
        if not PurchHeader.Invoice then
            exit;
        if PurchInvHeader."No." <> '' then
            HandleDigitalVoucherForPostedDocument("Digital Voucher Entry Type"::"Purchase Document", PurchInvHeader);
        if PurchCrMemoHdr."No." <> '' then
            HandleDigitalVoucherForPostedDocument("Digital Voucher Entry Type"::"Purchase Document", PurchCrMemoHdr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Prepayments", 'OnAfterPostPrepayments', '', true, true)]
    local procedure CheckPurchVoucherOnAfterPostPrepayments(var PurchHeader: Record "Purchase Header"; DocumentType: Option Invoice,"Credit Memo"; CommitIsSuppressed: Boolean; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    begin
        if not DigitalVoucherFeature.IsFeatureEnabled() then
            exit;
        if PurchInvHeader."No." <> '' then
            HandleDigitalVoucherForPostedDocument("Digital Voucher Entry Type"::"Purchase Document", PurchInvHeader);
        if PurchCrMemoHdr."No." <> '' then
            HandleDigitalVoucherForPostedDocument("Digital Voucher Entry Type"::"Purchase Document", PurchCrMemoHdr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnProcessLinesOnAfterPostGenJnlLines', '', true, true)]
    local procedure OnProcessLinesOnAfterPostGenJnlLines(var GenJournalLine: Record "Gen. Journal Line"; GLRegister: Record "G/L Register"; var GLRegNo: Integer; PreviewMode: Boolean)
    var
        GLEntry: Record "G/L Entry";
        GLEntryToHandle: Record "G/L Entry";
        CurrPostingDateDocNoCode: Text;
        PostingDateDocNoCode: Text;
        GenJournalSourceType: Enum "Gen. Journal Source Type";
    begin
        if PreviewMode then
            exit;
        if not DigitalVoucherFeature.IsFeatureEnabled() then
            exit;
        GLRegister.Get(GLRegNo);
        GLEntry.SetCurrentKey("Document No.", "Posting Date");
        GLEntry.SetRange("Entry No.", GLRegister."From Entry No.", GLRegister."To Entry No.");
        if not GLEntry.FindSet() then
            exit;
        repeat
            PostingDateDocNoCode := Format(GLEntry."Posting Date") + GLEntry."Document No.";
            if PostingDateDocNoCode <> CurrPostingDateDocNoCode then begin
                if CurrPostingDateDocNoCode <> '' then
                    HandleDigitalVoucherForPostedGLEntry(GLEntryToHandle, GenJournalLine, GenJournalSourceType);
                CurrPostingDateDocNoCode := PostingDateDocNoCode;
                GenJournalSourceType := GenJournalSourceType::" ";
                GLEntryToHandle := GLEntry;
            end;
            if GLEntry."Source Type" <> GLEntry."Source Type"::" " then
                GenJournalSourceType := GLEntry."Source Type";
        until GLEntry.Next() = 0;
        if CurrPostingDateDocNoCode <> '' then
            HandleDigitalVoucherForPostedGLEntry(GLEntry, GenJournalLine, GenJournalSourceType);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document Attachment", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure CheckIncomingDocumentOnBeforeDeleteEvent(var Rec: Record "Incoming Document Attachment")
    begin
        if Rec.IsTemporary() then
            exit;
        CheckIncomingDocumentChange(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnBeforeCanReplaceMainAttachment', '', false, false)]
    local procedure CheckVoucherOnBeforeCanReplaceMainAttachment(var CanReplaceMainAttachment: Boolean; IncomingDocument: Record "Incoming Document"; var IsHandled: Boolean)
    var
        RecRef: RecordRef;
        RelatedRecordID: RecordId;
    begin
        RelatedRecordID := IncomingDocument."Related Record ID";
        if RelatedRecordID.TableNo = 0 then
            exit;
        RecRef := RelatedRecordID.GetRecord();
        CanReplaceMainAttachment := not DigitalVoucherFeature.IsDigitalVoucherEnabledForTableNumber(RecRef.Number);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnBeforeRemoveReferencedRecords', '', false, false)]
    local procedure CheckVoucherOnBeforeRemoveReferencedRecords(IncomingDocument: Record "Incoming Document"; var IsHandled: Boolean)
    var
        RecRef: RecordRef;
        RelatedRecordID: RecordId;
    begin
        if not DigitalVoucherFeature.IsFeatureEnabled() then
            exit;
        RelatedRecordID := IncomingDocument."Related Record ID";
        if RelatedRecordID.TableNo = 0 then
            exit;
        RecRef := RelatedRecordID.GetRecord();
        if DigitalVoucherFeature.IsDigitalVoucherEnabledForTableNumber(RecRef.Number) then
            error(CannotRemoveReferenceRecordFromIncDocErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Digital Voucher Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure CheckIfChangeIsAllowedOnModifyDigitalVoucherSetup(var Rec: Record "Digital Voucher Setup")
    begin
        if not Rec.Enabled then
            DigitalVoucherFeature.CheckIfDigitalVoucherSetupChangeIsAllowed();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Email Item", 'OnAttachIncomingDocumentsOnAfterSetFilter', '', false, false)]
    local procedure ExcludeDigitalVouchersOnAttachIncomingDocumentsOnAfterSetFilter(var IncomingDocumentAttachment: Record "Incoming Document Attachment")
    begin
        IncomingDocumentAttachment.SetRange("Is Digital Voucher", false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Digital Voucher Setup", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure CheckIfChangeIsAllowedOnDeleteDigitalVoucherSetup(var Rec: Record "Digital Voucher Setup"; RunTrigger: Boolean)
    begin
        DigitalVoucherFeature.CheckIfDigitalVoucherSetupChangeIsAllowed();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Correct Posted Purch. Invoice", 'OnAfterCreateCopyDocument', '', false, false)]
    local procedure CopyDigitalVoucherOnAfterCreateCopyPurchDocument(var PurchaseHeader: Record "Purchase Header"; PurchInvHeader: Record "Purch. Inv. Header")
    begin
        PurchaseHeader."Incoming Document Entry No." :=
            CopyDigitalVoucherToCorrectiveDocument("Digital Voucher Entry Type"::"Purchase Document", PurchInvHeader, PurchaseHeader."No.", PurchaseHeader."Posting Date");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Correct Posted Sales Invoice", 'OnAfterCreateCorrectiveSalesCrMemo', '', false, false)]
    local procedure CopyDigitalVoucherOnAfterCreateCorrectiveSalesCrMemo(SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesHeader: Record "Sales Header")
    begin
        SalesHeader."Incoming Document Entry No." :=
            CopyDigitalVoucherToCorrectiveDocument("Digital Voucher Entry Type"::"Sales Document", SalesInvoiceHeader, SalesHeader."No.", SalesHeader."Posting Date");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGenerateDigitalVoucherForDocumentOnCaseElse(RecRef: RecordRef)
    begin
    end;

    [InternalEvent(false, false)]
    internal procedure OnHandleDigitalVoucherEntrySetupWhenEnforced(EntryType: Enum "Digital Voucher Entry Type")
    begin
    end;
}
