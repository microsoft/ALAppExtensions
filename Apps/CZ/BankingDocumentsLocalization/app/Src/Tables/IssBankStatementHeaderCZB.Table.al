// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Reconciliation;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.Attachment;
using Microsoft.Foundation.Navigate;
using Microsoft.Foundation.NoSeries;
using System.Security.AccessControl;
using System.Utilities;

table 31254 "Iss. Bank Statement Header CZB"
{
    Caption = 'Issued Bank Statement Header';
    DataCaptionFields = "No.", "Bank Account No.", "Bank Account Name";
    DrillDownPageID = "Iss. Bank Statements CZB";
    LookupPageID = "Iss. Bank Statements CZB";
    Permissions = tabledata "Iss. Bank Statement Header CZB" = m,
                  tabledata "Iss. Bank Statement Line CZB" = md;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(3; "Bank Account No."; Code[20])
        {
            Caption = 'Bank Account No.';
            TableRelation = "Bank Account";
            DataClassification = CustomerContent;
        }
        field(4; "Bank Account Name"; Text[100])
        {
            CalcFormula = lookup("Bank Account".Name where("No." = field("Bank Account No.")));
            Caption = 'Bank Account Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "Account No."; Text[30])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
        }
        field(6; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(7; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(8; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            DataClassification = CustomerContent;
        }
#pragma warning disable AA0232
        field(9; Amount; Decimal)
        {
            CalcFormula = sum("Iss. Bank Statement Line CZB".Amount where("Bank Statement No." = field("No.")));
            Caption = 'Amount';
            Editable = false;
            FieldClass = FlowField;
        }
#pragma warning restore
        field(10; "Amount (LCY)"; Decimal)
        {
            CalcFormula = sum("Iss. Bank Statement Line CZB"."Amount (LCY)" where("Bank Statement No." = field("No.")));
            Caption = 'Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; Debit; Decimal)
        {
            CalcFormula = - sum("Iss. Bank Statement Line CZB".Amount where("Bank Statement No." = field("No."), Positive = const(false)));
            Caption = 'Debit';
            Editable = false;
            FieldClass = FlowField;
        }
        field(12; "Debit (LCY)"; Decimal)
        {
            CalcFormula = - sum("Iss. Bank Statement Line CZB"."Amount (LCY)" where("Bank Statement No." = field("No."), Positive = const(false)));
            Caption = 'Debit (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; Credit; Decimal)
        {
            CalcFormula = sum("Iss. Bank Statement Line CZB".Amount where("Bank Statement No." = field("No."), Positive = const(true)));
            Caption = 'Credit';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Credit (LCY)"; Decimal)
        {
            CalcFormula = sum("Iss. Bank Statement Line CZB"."Amount (LCY)" where("Bank Statement No." = field("No."), Positive = const(true)));
            Caption = 'Credit (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "No. of Lines"; Integer)
        {
            CalcFormula = Count("Iss. Bank Statement Line CZB" where("Bank Statement No." = field("No.")));
            Caption = 'No. of Lines';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Bank Statement Currency Code"; Code[10])
        {
            Caption = 'Bank Statement Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(21; "Bank Statement Currency Factor"; Decimal)
        {
            Caption = 'Bank Statement Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(25; "Pre-Assigned No. Series"; Code[20])
        {
            Caption = 'Pre-Assigned No. Series';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(26; "Pre-Assigned No."; Code[20])
        {
            Caption = 'Pre-Assigned No.';
            DataClassification = CustomerContent;
        }
        field(30; "Pre-Assigned User ID"; Code[50])
        {
            Caption = 'Pre-Assigned User ID';
            TableRelation = User."User Name";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(35; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(55; "File Name"; Text[250])
        {
            Caption = 'File Name';
            DataClassification = CustomerContent;
        }
        field(60; "Check Amount"; Decimal)
        {
            Caption = 'Check Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(65; "Check Amount (LCY)"; Decimal)
        {
            Caption = 'Check Amount (LCY)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(70; "Check Debit"; Decimal)
        {
            Caption = 'Check Debit';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(75; "Check Debit (LCY)"; Decimal)
        {
            Caption = 'Check Debit (LCY)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(80; "Check Credit"; Decimal)
        {
            Caption = 'Check Credit';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(85; "Check Credit (LCY)"; Decimal)
        {
            Caption = 'Check Credit (LCY)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(90; IBAN; Code[50])
        {
            Caption = 'IBAN';
            DataClassification = CustomerContent;
        }
        field(95; "SWIFT Code"; Code[20])
        {
            Caption = 'SWIFT Code';
            DataClassification = CustomerContent;
        }
        field(100; "Payment Reconciliation Status"; Enum "Journal Status CZB")
        {
            Caption = 'Payment Reconciliation Status';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(101; "Payment Journal Status"; Enum "Journal Status CZB")
        {
            Caption = 'Payment Journal Status';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(110; "Search Rule Code"; Code[10])
        {
            Caption = 'Search Rule Code';
            TableRelation = "Search Rule CZB";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        IssBankStatementLineCZB: Record "Iss. Bank Statement Line CZB";
    begin
        IssBankStatementLineCZB.SetRange("Bank Statement No.", "No.");
        IssBankStatementLineCZB.DeleteAll(true);
    end;

    trigger OnRename()
    var
        RenameErr: Label 'You cannot rename a %1.', Comment = '%1 = TableCaption';
    begin
        Error(RenameErr, TableCaption);
    end;

    procedure PrintRecords(ShowRequestForm: Boolean)
    var
        IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB";
    begin
        IssBankStatementHeaderCZB.Copy(Rec);
        Report.RunModal(Report::"Iss. Bank Statement CZB", ShowRequestForm, false, IssBankStatementHeaderCZB);
    end;

    procedure PrintToDocumentAttachment()
    var
        IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB";
        DocumentAttachment: Record "Document Attachment";
        DocumentAttachmentMgmt: Codeunit "Document Attachment Mgmt";
        TempBlob: Codeunit "Temp Blob";
        RecordRef: RecordRef;
        DummyInStream: InStream;
        ReportOutStream: OutStream;
        DocumentInStream: InStream;
        FileName: Text[250];
        DocumentAttachmentFileNameLbl: Label '%1', Comment = '%1 = No.';
    begin
        IssBankStatementHeaderCZB := Rec;
        IssBankStatementHeaderCZB.SetRecFilter();
        RecordRef.GetTable(IssBankStatementHeaderCZB);
        if not RecordRef.FindFirst() then
            exit;
        if not Report.RdlcLayout(Report::"Iss. Bank Statement CZB", DummyInStream) then
            exit;

        Clear(TempBlob);
        TempBlob.CreateOutStream(ReportOutStream);
        Report.SaveAs(Report::"Iss. Bank Statement CZB", '', ReportFormat::Pdf, ReportOutStream, RecordRef);

        Clear(DocumentAttachment);
        DocumentAttachment.InitFieldsFromRecRef(RecordRef);
        FileName := DocumentAttachment.FindUniqueFileName(StrSubstNo(DocumentAttachmentFileNameLbl, IssBankStatementHeaderCZB."No."), 'pdf');
        TempBlob.CreateInStream(DocumentInStream);
        DocumentAttachment.SaveAttachmentFromStream(DocumentInStream, RecordRef, FileName);
        DocumentAttachmentMgmt.ShowNotification(RecordRef, 1, true);
    end;

    procedure Navigate()
    var
        NavigateForm: Page Navigate;
    begin
        NavigateForm.SetDoc("Document Date", "No.");
        NavigateForm.Run();
    end;

    procedure CheckPaymentReconciliationExists()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        PostedPaymentReconHdr: Record "Posted Payment Recon. Hdr";
        ExistErr: Label '%1 %2 already exist.', Comment = '%1 = TableCaption, %2 = No.';
    begin
        if PaymentReconciliationExist() then
            Error(ExistErr, BankAccReconciliation.TableCaption(), "No.");
        if PostedPaymentReconciliationExist() then
            Error(ExistErr, PostedPaymentReconHdr.TableCaption(), "No.");
    end;

    local procedure PaymentReconciliationExist(): Boolean
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
    begin
        SetBankAccReconFilter(BankAccReconciliation);
        exit(not BankAccReconciliation.IsEmpty());
    end;

    local procedure PostedPaymentReconciliationExist(): Boolean
    var
        PostedPaymentReconHdr: Record "Posted Payment Recon. Hdr";
    begin
        SetPostedPaymentReconHdrFilter(PostedPaymentReconHdr);
        exit(not PostedPaymentReconHdr.IsEmpty());
    end;

    procedure CheckGeneralJournalExists()
    var
        GenJournalLine: Record "Gen. Journal Line";
        ExistErr: Label '%1 %2 already exist.', Comment = '%1 = TableCaption, %2 = No.';
    begin
        if GeneralJournalExist() then
            Error(ExistErr, GenJournalLine.TableCaption(), "No.");
    end;

    local procedure GeneralJournalExist(): Boolean
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        SetGeneralJournalLineFilter(GenJournalLine, "No.");
        exit(not GenJournalLine.IsEmpty());
    end;

    procedure LinesExist(): Boolean
    var
        IssBankStatementLineCZB: Record "Iss. Bank Statement Line CZB";
    begin
        IssBankStatementLineCZB.SetRange("Bank Statement No.", "No.");
        exit(not IssBankStatementLineCZB.IsEmpty());
    end;

    local procedure SetBankAccReconFilter(var BankAccReconciliation: Record "Bank Acc. Reconciliation")
    begin
        BankAccReconciliation.Reset();
        BankAccReconciliation.SetRange("Statement Type", BankAccReconciliation."Statement Type"::"Payment Application");
        BankAccReconciliation.SetRange("Bank Account No.", "Bank Account No.");
        BankAccReconciliation.SetRange("Statement No.", "No.");
    end;

    local procedure SetBankAccReconLineFilter(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    begin
        BankAccReconciliationLine.Reset();
        BankAccReconciliationLine.SetRange("Statement Type", BankAccReconciliationLine."Statement Type"::"Payment Application");
        BankAccReconciliationLine.SetRange("Bank Account No.", "Bank Account No.");
        BankAccReconciliationLine.SetRange("Statement No.", "No.");
    end;

    local procedure SetPostedPaymentReconHdrFilter(var PostedPaymentReconHdr: Record "Posted Payment Recon. Hdr")
    begin
        PostedPaymentReconHdr.Reset();
        PostedPaymentReconHdr.SetRange("Bank Account No.", "Bank Account No.");
        PostedPaymentReconHdr.SetRange("Statement No.", "No.");
    end;

    local procedure SetGeneralJournalLineFilter(var GenJournalLine: Record "Gen. Journal Line"; DocumentNo: Code[20])
    var
        BankAccount: Record "Bank Account";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSetGeneralJournalLineFilter(GenJournalLine, DocumentNo, IsHandled);
        if IsHandled then
            exit;

        TestField("Bank Account No.");
        BankAccount.Get("Bank Account No.");
        BankAccount.TestField("Payment Jnl. Template Name CZB");
        BankAccount.TestField("Payment Jnl. Batch Name CZB");

        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", BankAccount."Payment Jnl. Template Name CZB");
        GenJournalLine.SetRange("Journal Batch Name", BankAccount."Payment Jnl. Batch Name CZB");
        GenJournalLine.SetRange("Document No.", DocumentNo);
        GenJournalLine.SetFilter(Amount, '<>0');
    end;

    procedure OpenReconciliationOrJournal()
    var
        PaymentReconciliationJournalNotExistErr: Label 'Payment Reconciliation Journal %1 does not exist.', Comment = '%1 = No.';
        GeneralJournalNotExistErr: Label 'Payment Payment Journal %1 does not exist.', Comment = '%1 = No.';
    begin
        if Rec."Search Rule Code" = '' then
            case true of
                PaymentReconciliationExist():
                    OpenPaymentReconciliation();
                PostedPaymentReconciliationExist():
                    OpenPostedPaymentReconciliation();
                else
                    Error(PaymentReconciliationJournalNotExistErr, "No.");
            end
        else
            if GeneralJournalExist() then
                OpenGeneralJournal()
            else
                Error(GeneralJournalNotExistErr, "No.");
    end;

    local procedure OpenPaymentReconciliation()
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    begin
        SetBankAccReconLineFilter(BankAccReconciliationLine);
        Page.Run(Page::"Payment Reconciliation Journal", BankAccReconciliationLine);
    end;

    local procedure OpenPostedPaymentReconciliation()
    var
        PostedPaymentReconHdr: Record "Posted Payment Recon. Hdr";
    begin
        SetPostedPaymentReconHdrFilter(PostedPaymentReconHdr);
        Page.Run(Page::"Posted Payment Reconciliation", PostedPaymentReconHdr);
    end;

    local procedure OpenGeneralJournal()
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        SetGeneralJournalLineFilter(GenJournalLine, "No.");
        Page.Run(Page::"Payment Journal", GenJournalLine);
    end;

    procedure CreateJournal(ShowRequestForm: Boolean)
    begin
        CreateJournal(ShowRequestForm, false);
    end;

    procedure CreateJournal(ShowRequestForm: Boolean; HideMessages: Boolean)
    begin
        OnBeforeCreateJournal(Rec);
        if Rec."Search Rule Code" = '' then
            RunPaymentReconciliationJournalCreation(ShowRequestForm, HideMessages)
        else
            RunGeneralJournalCreation(ShowRequestForm, HideMessages)
    end;

    procedure UpdatePaymentReconciliationStatus(PaymentReconciliationStatus: Enum "Journal Status CZB")
    begin
        Validate("Payment Reconciliation Status", PaymentReconciliationStatus);
        Modify();
    end;

    procedure UpdatePaymentJournalStatus(PaymentJournalStatus: Enum "Journal Status CZB")
    begin
        Validate("Payment Journal Status", PaymentJournalStatus);
        Modify();
    end;

    local procedure RunPaymentReconciliationJournalCreation(ShowRequestForm: Boolean; HideMessages: Boolean)
    var
        IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB";
        CreatePaymentReconJnlCZB: Report "Create Payment Recon. Jnl. CZB";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeRunPaymentReconJournalCreation(Rec, ShowRequestForm, HideMessages, IsHandled);
        if IsHandled then
            exit;

        IssBankStatementHeaderCZB.Copy(Rec);
        CreatePaymentReconJnlCZB.SetTableView(IssBankStatementHeaderCZB);
        CreatePaymentReconJnlCZB.UseRequestPage(ShowRequestForm);
        CreatePaymentReconJnlCZB.SetHideMessages(HideMessages);
        CreatePaymentReconJnlCZB.RunModal();
    end;

    local procedure RunGeneralJournalCreation(ShowRequestForm: Boolean; HideMessages: Boolean)
    var
        IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB";
        CreateGeneralJournalCZB: Report "Create General Journal CZB";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeRunGeneralJournalCreation(Rec, ShowRequestForm, HideMessages, IsHandled);
        if IsHandled then
            exit;

        IssBankStatementHeaderCZB.Copy(Rec);
        CreateGeneralJournalCZB.SetTableView(IssBankStatementHeaderCZB);
        CreateGeneralJournalCZB.UseRequestPage(ShowRequestForm);
        CreateGeneralJournalCZB.SetHideMessages(HideMessages);
        CreateGeneralJournalCZB.RunModal();
    end;

    procedure ShowStatistics()
    var
        BankingDocStatisticsCZB: Page "Banking Doc. Statistics CZB";
    begin
        TestField("Bank Account No.");
        TestField("Document Date");
        CalcFields(Amount);
        BankingDocStatisticsCZB.SetValues("Bank Account No.", "Document Date", Amount);
        BankingDocStatisticsCZB.Run();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateJournal(var IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunPaymentReconJournalCreation(var IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB"; var ShowRequestForm: Boolean; var HideMessages: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunGeneralJournalCreation(var IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB"; var ShowRequestForm: Boolean; var HideMessages: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSetGeneralJournalLineFilter(var GenJournalLine: Record "Gen. Journal Line"; DocumentNo: Code[20]; var IsHandled: Boolean)
    begin
    end;
}
