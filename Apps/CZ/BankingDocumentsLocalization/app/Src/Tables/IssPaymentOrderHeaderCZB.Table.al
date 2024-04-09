// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.Attachment;
using Microsoft.Foundation.Navigate;
using Microsoft.Foundation.NoSeries;
using System.Security.AccessControl;
using System.Utilities;

table 31258 "Iss. Payment Order Header CZB"
{
    Caption = 'Issued Payment Order Header';
    DataCaptionFields = "No.", "Bank Account No.", "Bank Account Name";
    DrillDownPageID = "Iss. Payment Orders CZB";
    LookupPageID = "Iss. Payment Orders CZB";
    Permissions = tabledata "Iss. Payment Order Header CZB" = m,
                  tabledata "Iss. Payment Order Line CZB" = md;

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
            Editable = true;
            NotBlank = true;
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
            CalcFormula = sum("Iss. Payment Order Line CZB".Amount where("Payment Order No." = field("No."), Status = const(" ")));
            Caption = 'Amount';
            Editable = false;
            FieldClass = FlowField;
        }
#pragma warning restore
        field(10; "Amount (LCY)"; Decimal)
        {
            CalcFormula = sum("Iss. Payment Order Line CZB"."Amount (LCY)" where("Payment Order No." = field("No."), Status = const(" ")));
            Caption = 'Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; Debit; Decimal)
        {
            CalcFormula = sum("Iss. Payment Order Line CZB".Amount where("Payment Order No." = field("No."), Positive = const(true), Status = const(" ")));
            Caption = 'Debit';
            Editable = false;
            FieldClass = FlowField;
        }
        field(12; "Debit (LCY)"; Decimal)
        {
            CalcFormula = sum("Iss. Payment Order Line CZB"."Amount (LCY)" where("Payment Order No." = field("No."), Positive = const(true), Status = const(" ")));
            Caption = 'Debit (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; Credit; Decimal)
        {
            CalcFormula = - sum("Iss. Payment Order Line CZB".Amount where("Payment Order No." = field("No."), Positive = const(false), Status = const(" ")));
            Caption = 'Credit';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Credit (LCY)"; Decimal)
        {
            CalcFormula = - sum("Iss. Payment Order Line CZB"."Amount (LCY)" where("Payment Order No." = field("No."), Positive = const(false), Status = const(" ")));
            Caption = 'Credit (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "No. of Lines"; Integer)
        {
            CalcFormula = Count("Iss. Payment Order Line CZB" where("Payment Order No." = field("No.")));
            Caption = 'No. of Lines';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Payment Order Currency Code"; Code[10])
        {
            Caption = 'Payment Order Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(21; "Payment Order Currency Factor"; Decimal)
        {
            Caption = 'Payment Order Currency Factor';
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
        field(50; "No. Exported"; Integer)
        {
            Caption = 'No. Exported';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(55; "File Name"; Text[250])
        {
            Caption = 'File Name';
            DataClassification = CustomerContent;
        }
        field(60; "Foreign Payment Order"; Boolean)
        {
            Caption = 'Foreign Payment Order';
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
        field(100; "Unreliable Pay. Check DateTime"; DateTime)
        {
            Caption = 'Unreliable Payer Check Date and Time';
            Editable = false;
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
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
    begin
        IssPaymentOrderLineCZB.SetRange("Payment Order No.", "No.");
        IssPaymentOrderLineCZB.DeleteAll(true);
    end;

    trigger OnRename()
    var
        RenameErr: Label 'You cannot rename a %1.', Comment = '%1 = TableCaption';
    begin
        Error(RenameErr, TableCaption);
    end;

    procedure PrintRecords(ShowRequestForm: Boolean)
    var
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
        BankAccount: Record "Bank Account";
        ReportId: Integer;
    begin
        IssPaymentOrderHeaderCZB.Copy(Rec);
        BankAccount.Get("Bank Account No.");
        if IssPaymentOrderHeaderCZB."Foreign Payment Order" then begin
            BankAccount.Testfield("Foreign Payment Order ID CZB");
            ReportId := BankAccount."Foreign Payment Order ID CZB";
        end else begin
            BankAccount.Testfield("Domestic Payment Order ID CZB");
            ReportId := BankAccount."Domestic Payment Order ID CZB";
        end;
        Report.Run(ReportId, ShowRequestForm, false, IssPaymentOrderHeaderCZB);
    end;

    procedure PrintToDocumentAttachment()
    var
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
        BankAccount: Record "Bank Account";
        DocumentAttachment: Record "Document Attachment";
        DocumentAttachmentMgmt: Codeunit "Document Attachment Mgmt";
        TempBlob: Codeunit "Temp Blob";
        RecordRef: RecordRef;
        DummyInStream: InStream;
        ReportOutStream: OutStream;
        DocumentInStream: InStream;
        FileName: Text[250];
        ReportId: Integer;
        DocumentAttachmentFileNameLbl: Label '%1', Comment = '%1 = No.';
    begin
        IssPaymentOrderHeaderCZB := Rec;
        IssPaymentOrderHeaderCZB.SetRecFilter();
        RecordRef.GetTable(IssPaymentOrderHeaderCZB);
        if not RecordRef.FindFirst() then
            exit;

        BankAccount.Get(IssPaymentOrderHeaderCZB."Bank Account No.");
        if IssPaymentOrderHeaderCZB."Foreign Payment Order" then begin
            BankAccount.TestField("Foreign Payment Order ID CZB");
            ReportId := BankAccount."Foreign Payment Order ID CZB";
        end else begin
            BankAccount.TestField("Domestic Payment Order ID CZB");
            ReportId := BankAccount."Domestic Payment Order ID CZB";
        end;
        if not Report.RdlcLayout(ReportId, DummyInStream) then
            exit;

        Clear(TempBlob);
        TempBlob.CreateOutStream(ReportOutStream);
        Report.SaveAs(ReportID, '', ReportFormat::Pdf, ReportOutStream, RecordRef);

        Clear(DocumentAttachment);
        DocumentAttachment.InitFieldsFromRecRef(RecordRef);
        FileName := DocumentAttachment.FindUniqueFileName(StrSubstNo(DocumentAttachmentFileNameLbl, IssPaymentOrderHeaderCZB."No."), 'pdf');
        TempBlob.CreateInStream(DocumentInStream);
        DocumentAttachment.SaveAttachmentFromStream(DocumentInStream, RecordRef, FileName);
        DocumentAttachmentMgmt.ShowNotification(RecordRef, 1, true);
    end;

    procedure Navigate()
    var
        NavigatePage: Page Navigate;
    begin
        NavigatePage.SetDoc("Document Date", "No.");
        NavigatePage.Run();
    end;

    procedure IncreaseNoExported()
    begin
        "No. Exported" += 1;
        Modify();
    end;

    procedure ExportPaymentOrder()
    var
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
        BankAccount: Record "Bank Account";
        CodeunitID: Integer;
        IsHandled: Boolean;
        NothingToExportErr: Label 'There is nothing to export.';
    begin
        OnBeforeExportPmtOrd(Rec, IsHandled);
        if IsHandled then
            exit;

        IssPaymentOrderLineCZB.SetRange("Payment Order No.", "No.");
        if IssPaymentOrderLineCZB.IsEmpty() then
            Error(NothingToExportErr);

        BankAccount.Get("Bank Account No.");
        if "Foreign Payment Order" then
            CodeunitID := BankAccount.GetForeignPaymentExportCodeunitIdCZB()
        else
            CodeunitID := BankAccount.GetPaymentExportCodeunitID();

        if CodeunitID > 0 then
            Codeunit.Run(CodeunitID, Rec)
        else
            Codeunit.Run(Codeunit::"Exp. Launch Payment Order CZB", Rec);

        if Find() then
            IncreaseNoExported();

        OnAfterExportPmtOrd(Rec);
    end;

    procedure CreatePaymentJournal(JnlTemplateName: Code[10]; JnlBatchName: Code[10])
    var
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        LineNo: Integer;
    begin
        IssPaymentOrderLineCZB.SetRange("Payment Order No.", "No.");
        IssPaymentOrderLineCZB.SetRange(Status, IssPaymentOrderLineCZB.Status::" ");
        if IssPaymentOrderLineCZB.IsEmpty() then
            exit;

        GenJournalBatch.Get(JnlTemplateName, JnlBatchName);
        GenJournalBatch.Testfield("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"Bank Account");
        GenJournalBatch.Testfield("Bal. Account No.", "Bank Account No.");
        GenJournalBatch.Testfield("Allow Payment Export");
        GenJournalBatch.Testfield("No. Series", '');

        GenJournalLine.FilterGroup(2);
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        if GenJournalLine.FindLast() then
            LineNo := GenJournalLine."Line No.";
        GenJournalLine.SetRange("Document No.", "No.");
        GenJournalLine.FilterGroup(0);

        if GenJournalLine.IsEmpty() then begin
            IssPaymentOrderLineCZB.FindSet();
            repeat
                LineNo += 10000;
                GenJournalLine.Init();
                GenJournalLine."Journal Template Name" := GenJournalBatch."Journal Template Name";
                GenJournalLine."Journal Batch Name" := GenJournalBatch.Name;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine.Insert();

                GenJournalLine."Posting Date" := "Document Date";
                GenJournalLine."Document Date" := "Document Date";
#if not CLEAN22
#pragma warning disable AL0432
                GenJournalLine."VAT Date CZL" := "Document Date";
#pragma warning restore AL0432
#endif
                GenJournalLine."VAT Reporting Date" := "Document Date";

                case IssPaymentOrderLineCZB.Type of
                    IssPaymentOrderLineCZB.Type::Vendor, IssPaymentOrderLineCZB.Type::"Bank Account":
                        GenJournalLine."Document Type" := GenJournalLine."Document Type"::Payment;
                    IssPaymentOrderLineCZB.Type::Customer:
                        GenJournalLine."Document Type" := GenJournalLine."Document Type"::Refund;
                end;

                GenJournalLine."Document No." := "No.";
                GenJournalLine.Validate("Account Type", IssPaymentOrderLineCZB.ConvertTypeToGenJnlLineType());
                GenJournalLine.Validate("Account No.", IssPaymentOrderLineCZB."No.");
                GenJournalLine.Validate("Recipient Bank Account", IssPaymentOrderLineCZB."Cust./Vendor Bank Account Code");
                GenJournalLine.Validate(Amount, IssPaymentOrderLineCZB."Amount(Payment Order Currency)");
                GenJournalLine.Validate("Currency Code", "Payment Order Currency Code");
                GenJournalLine.Validate("Currency Factor", "Payment Order Currency Factor");
                GenJournalLine.Validate("Bal. Account Type", GenJournalBatch."Bal. Account Type");
                GenJournalLine.Validate("Bal. Account No.", GenJournalBatch."Bal. Account No.");
                GenJournalLine.Validate("Payment Method Code", IssPaymentOrderLineCZB."Payment Method Code");
                GenJournalLine."Variable Symbol CZL" := IssPaymentOrderLineCZB."Variable Symbol";
                GenJournalLine."Constant Symbol CZL" := IssPaymentOrderLineCZB."Constant Symbol";
                GenJournalLine."Specific Symbol CZL" := IssPaymentOrderLineCZB."Specific Symbol";
                if IssPaymentOrderLineCZB.Type = IssPaymentOrderLineCZB.Type::" " then begin
                    GenJournalLine."Bank Account No. CZL" := IssPaymentOrderLineCZB."Account No.";
                    GenJournalLine."IBAN CZL" := IssPaymentOrderLineCZB.IBAN;
                    GenJournalLine."SWIFT Code CZL" := IssPaymentOrderLineCZB."SWIFT Code";
                end;
                GenJournalLine.Modify();
            until IssPaymentOrderLineCZB.Next() = 0;
        end;
    end;

    procedure ShowStatistics()
    var
        BankingDocStatisticsCZB: Page "Banking Doc. Statistics CZB";
    begin
        TestField("Bank Account No.");
        TestField("Document Date");
        CalcFields(Amount);
        BankingDocStatisticsCZB.SetValues("Bank Account No.", "Document Date", -Amount);
        BankingDocStatisticsCZB.Run();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExportPmtOrd(var IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterExportPmtOrd(var IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB")
    begin
    end;
}
