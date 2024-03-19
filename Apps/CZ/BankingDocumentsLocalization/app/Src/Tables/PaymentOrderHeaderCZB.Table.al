// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Currency;
using Microsoft.Foundation.Attachment;
using Microsoft.Foundation.NoSeries;
using Microsoft.Sales.History;
using System.Automation;
using System.Utilities;

table 31256 "Payment Order Header CZB"
{
    Caption = 'Payment Order Header';
    DataCaptionFields = "No.", "Bank Account No.", "Bank Account Name";
    DrillDownPageID = "Payment Orders CZB";
    LookupPageID = "Payment Orders CZB";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NoSeries: Codeunit "No. Series";
            begin
                if ("No." <> xRec."No.") and ("Bank Account No." <> '') then begin
                    BankAccount.Get("Bank Account No.");
                    NoSeries.TestManual(BankAccount."Payment Order Nos. CZB");
                    "No. Series" := '';
                end;
            end;
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
            NotBlank = true;
            TableRelation = "Bank Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                BankAccount: Record "Bank Account";
            begin
                TestStatusOpen();
                if not BankAccount.Get("Bank Account No.") then
                    BankAccount.Init();
                "Account No." := BankAccount."Bank Account No.";
                BankAccount.Testfield(Blocked, false);
                IBAN := BankAccount.IBAN;
                "SWIFT Code" := BankAccount."SWIFT Code";
                Validate("Currency Code", BankAccount."Currency Code");
                "Foreign Payment Order" := BankAccount."Foreign Payment Orders CZB";
                CalcFields("Bank Account Name");
            end;
        }
        field(4; "Bank Account Name"; Text[100])
        {
            Caption = 'Bank Account Name';
            CalcFormula = lookup("Bank Account".Name where("No." = field("Bank Account No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "Account No."; Text[30])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(6; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
                if "Currency Code" <> '' then begin
                    UpdateCurrencyFactor();
                    if "Currency Factor" <> xRec."Currency Factor" then
                        ConfirmUpdateCurrencyFactor();
                end;
            end;
        }
        field(7; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
                if CurrFieldNo <> FieldNo("Currency Code") then
                    UpdateCurrencyFactor()
                else
                    if "Currency Code" <> xRec."Currency Code" then begin
                        UpdateCurrencyFactor();
                        UpdatePaymentOrderLine(FieldCaption("Currency Code"));
                    end else
                        if "Currency Code" <> '' then begin
                            UpdateCurrencyFactor();
                            if "Currency Factor" <> xRec."Currency Factor" then
                                ConfirmUpdateCurrencyFactor();
                        end;

                Validate("Payment Order Currency Code", "Currency Code");
            end;
        }
        field(8; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Currency Code" = "Payment Order Currency Code" then
                    "Payment Order Currency Factor" := "Currency Factor";
                if "Currency Factor" <> xRec."Currency Factor" then
                    UpdatePaymentOrderLine(FieldCaption("Currency Factor"));
            end;
        }
#pragma warning disable AA0232
        field(9; Amount; Decimal)
        {
            CalcFormula = sum("Payment Order Line CZB".Amount where("Payment Order No." = field("No."), "Skip Payment" = const(false)));
            Caption = 'Amount';
            Editable = false;
            FieldClass = FlowField;
        }
#pragma warning restore
        field(10; "Amount (LCY)"; Decimal)
        {
            CalcFormula = sum("Payment Order Line CZB"."Amount (LCY)" where("Payment Order No." = field("No."), "Skip Payment" = const(false)));
            Caption = 'Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; Debit; Decimal)
        {
            CalcFormula = sum("Payment Order Line CZB".Amount where("Payment Order No." = field("No."), Positive = const(true), "Skip Payment" = const(false)));
            Caption = 'Debit';
            Editable = false;
            FieldClass = FlowField;
        }
        field(12; "Debit (LCY)"; Decimal)
        {
            CalcFormula = sum("Payment Order Line CZB"."Amount (LCY)" where("Payment Order No." = field("No."), Positive = const(true), "Skip Payment" = const(false)));
            Caption = 'Debit (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; Credit; Decimal)
        {
            CalcFormula = - sum("Payment Order Line CZB".Amount where("Payment Order No." = field("No."), Positive = const(false), "Skip Payment" = const(false)));
            Caption = 'Credit';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Credit (LCY)"; Decimal)
        {
            CalcFormula = - sum("Payment Order Line CZB"."Amount (LCY)" where("Payment Order No." = field("No."), Positive = const(false), "Skip Payment" = const(false)));
            Caption = 'Credit (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "No. of Lines"; Integer)
        {
            CalcFormula = Count("Payment Order Line CZB" where("Payment Order No." = field("No.")));
            Caption = 'No. of Lines';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Payment Order Currency Code"; Code[10])
        {
            Caption = 'Payment Order Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
                if CurrFieldNo <> FieldNo("Payment Order Currency Code") then
                    UpdateOrderCurrencyFactor()
                else
                    if "Payment Order Currency Code" <> xRec."Payment Order Currency Code" then begin
                        UpdateOrderCurrencyFactor();
                        UpdatePaymentOrderLine(FieldCaption("Payment Order Currency Code"));
                    end else
                        if "Payment Order Currency Code" <> '' then begin
                            UpdateOrderCurrencyFactor();
                            if "Payment Order Currency Factor" <> xRec."Payment Order Currency Factor" then
                                ConfUpdateOrderCurrencyFactor();
                        end;
            end;
        }
        field(21; "Payment Order Currency Factor"; Decimal)
        {
            Caption = 'Payment Order Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Currency Code" = "Payment Order Currency Code" then
                    "Currency Factor" := "Payment Order Currency Factor";
                if "Payment Order Currency Factor" <> xRec."Payment Order Currency Factor" then
                    UpdatePaymentOrderLine(FieldCaption("Payment Order Currency Factor"));
            end;
        }
        field(25; "Amount (Pay.Order Curr.)"; Decimal)
        {
            CalcFormula = sum("Payment Order Line CZB"."Amount (Paym. Order Currency)" where("Payment Order No." = field("No."), "Skip Payment" = const(false)));
            Caption = 'Amount (Payment Order Currency)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(30; "Last Issuing No."; Code[20])
        {
            Caption = 'Last Issuing No.';
            Editable = false;
            TableRelation = "Sales Invoice Header";
        }
        field(35; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
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

            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(90; IBAN; Code[50])
        {
            Caption = 'IBAN';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(95; "SWIFT Code"; Code[20])
        {
            Caption = 'SWIFT Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(100; "Unreliable Pay. Check DateTime"; DateTime)
        {
            Caption = 'Unreliable Payer Check Date and Time';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(120; Status; Enum "Payment Order Head. Status CZB")
        {
            Caption = 'Status';
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
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
    begin
        DeleteRecordInApprovalRequest();

        PaymentOrderLineCZB.SetRange("Payment Order No.", "No.");
        if PaymentOrderLineCZB.FindSet(true) then
            repeat
                PaymentOrderLineCZB.SuspendStatusCheck(StatusCheckSuspended);
                PaymentOrderLineCZB.Delete(true);
            until PaymentOrderLineCZB.Next() = 0;
    end;

    trigger OnInsert()
    var
        PaymentOrderHeader: Record "Payment Order Header CZB";
        NoSeries: Codeunit "No. Series";
#if not CLEAN24
        IsHandled: Boolean;
#endif
    begin
        if "No." = '' then begin
            BankAccount.Get("Bank Account No.");
            BankAccount.Testfield("Payment Order Nos. CZB");
#if not CLEAN24
            NoSeriesManagement.RaiseObsoleteOnBeforeInitSeries(BankAccount."Payment Order Nos. CZB", xRec."No. Series", 0D, "No.", "No. Series", IsHandled);
            if not IsHandled then begin
#endif
                "No. Series" := BankAccount."Payment Order Nos. CZB";
                if NoSeries.AreRelated("No. Series", xRec."No. Series") then
                    "No. Series" := xRec."No. Series";
                "No." := NoSeries.GetNextNo("No. Series");
                PaymentOrderHeader.ReadIsolation(ReadIsolation::ReadUncommitted);
                PaymentOrderHeader.SetLoadFields("No.");
                while PaymentOrderHeader.Get("No.") do
                    "No." := NoSeries.GetNextNo("No. Series");
#if not CLEAN24
                NoSeriesManagement.RaiseObsoleteOnAfterInitSeries("No. Series", BankAccount."Payment Order Nos. CZB", 0D, "No.");
            end;
#endif
        end;
    end;

    trigger OnRename()
    var
        RenameErr: Label 'You cannot rename a %1.', Comment = '%1 = TableCaption';
    begin
        Error(RenameErr, TableCaption);
    end;

    var
        BankAccount: Record "Bank Account";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
#if not CLEAN24
        NoSeriesManagement: Codeunit NoSeriesManagement;
#endif
        BankingApprovalsMgtCZB: Codeunit "Banking Approvals Mgt. CZB";
        ConfirmManagement: Codeunit "Confirm Management";
        UpdateCurrFactorQst: Label 'Do you want to update the exchange rate?';
        StatusCheckSuspended: Boolean;

    procedure AssistEdit(OldPaymentOrderHeaderCZB: Record "Payment Order Header CZB"): Boolean
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        NoSeries: Codeunit "No. Series";
    begin
        PaymentOrderHeaderCZB := Rec;
        BankAccount.Get(PaymentOrderHeaderCZB."Bank Account No.");
        BankAccount.Testfield("Payment Order Nos. CZB");
        if NoSeries.LookupRelatedNoSeries(BankAccount."Payment Order Nos. CZB", OldPaymentOrderHeaderCZB."No. Series", PaymentOrderHeaderCZB."No. Series") then begin
            PaymentOrderHeaderCZB."No." := NoSeries.GetNextNo(PaymentOrderHeaderCZB."No. Series");
            Rec := PaymentOrderHeaderCZB;
            exit(true);
        end;

    end;

    local procedure UpdateCurrencyFactor()
    begin
        if "Currency Code" <> '' then
            "Currency Factor" := CurrencyExchangeRate.ExchangeRate("Document Date", "Currency Code")
        else
            "Currency Factor" := 0;
    end;

    local procedure ConfirmUpdateCurrencyFactor()
    begin
        if ConfirmManagement.GetResponseOrDefault(UpdateCurrFactorQst, false) then
            Validate("Currency Factor")
        else
            "Currency Factor" := xRec."Currency Factor";
    end;

    procedure UpdatePaymentOrderLine(ChangedFieldName: Text)
    var
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
        UpdateOrderLineQst: Label 'You have modified %1.\\Do you want to update the lines?', Comment = '%1 = Changed Field Name';
    begin
        Modify();
        if PaymentOrderLinesExist() then
            if ConfirmManagement.GetResponseOrDefault(StrSubstNo(UpdateOrderLineQst, ChangedFieldName), true) then begin
                PaymentOrderLineCZB.LockTable();
                Modify();

                PaymentOrderLineCZB.SetRange("Payment Order No.", "No.");
                if PaymentOrderLineCZB.FindSet(true) then
                    repeat
                        case ChangedFieldName of
                            FieldCaption("Currency Code"):
                                begin
                                    PaymentOrderLineCZB.Validate("Currency Code", "Currency Code");
                                    PaymentOrderLineCZB.Validate("Amount (Paym. Order Currency)");
                                end;
                            FieldCaption("Currency Factor"):
                                begin
                                    if "Currency Code" = "Payment Order Currency Code" then
                                        PaymentOrderLineCZB."Payment Order Currency Factor" := "Payment Order Currency Factor";
                                    PaymentOrderLineCZB.Validate("Amount (Paym. Order Currency)");
                                end;
                            FieldCaption("Payment Order Currency Code"):
                                begin
                                    PaymentOrderLineCZB."Payment Order Currency Factor" := "Payment Order Currency Factor";
                                    PaymentOrderLineCZB."Payment Order Currency Code" := "Payment Order Currency Code";
                                    case true of
                                        (PaymentOrderLineCZB."Applies-to C/V/E Entry No." <> 0):
                                            begin
                                                PaymentOrderLineCZB.Amount := 0;
                                                PaymentOrderLineCZB.Validate("Applies-to C/V/E Entry No.");
                                            end
                                        else
                                            PaymentOrderLineCZB.Validate("Amount (LCY)");
                                    end;
                                end;
                            FieldCaption("Payment Order Currency Factor"):
                                begin
                                    PaymentOrderLineCZB."Payment Order Currency Factor" := "Payment Order Currency Factor";
                                    if PaymentOrderLineCZB."Payment Order Currency Code" = PaymentOrderLineCZB."Applied Currency Code" then
                                        PaymentOrderLineCZB.Validate("Amount (Paym. Order Currency)")
                                    else
                                        PaymentOrderLineCZB.Validate("Amount (LCY)");
                                end;
                        end;
                        PaymentOrderLineCZB.Modify(true);
                    until PaymentOrderLineCZB.Next() = 0;
            end;
    end;

    procedure PaymentOrderLinesExist(): Boolean
    var
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
    begin
        PaymentOrderLineCZB.SetRange("Payment Order No.", "No.");
        exit(not PaymentOrderLineCZB.IsEmpty());
    end;

    local procedure UpdateOrderCurrencyFactor()
    begin
        if "Payment Order Currency Code" <> '' then
            "Payment Order Currency Factor" := CurrencyExchangeRate.ExchangeRate("Document Date", "Payment Order Currency Code")
        else
            "Payment Order Currency Factor" := 0;

        if "Currency Code" = "Payment Order Currency Code" then
            "Currency Factor" := "Payment Order Currency Factor";
    end;

    local procedure ConfUpdateOrderCurrencyFactor()
    begin
        if ConfirmManagement.GetResponseOrDefault(UpdateCurrFactorQst, false) then
            Validate("Payment Order Currency Factor")
        else
            "Payment Order Currency Factor" := xRec."Payment Order Currency Factor";
    end;

    procedure ImportPaymentOrder()
    var
        PaymentImportCodeunitId: Integer;
    begin
        BankAccount.Get("Bank Account No.");
        PaymentImportCodeunitId := BankAccount.GetPaymentImportCodeunitIdCZB();
        if PaymentImportCodeunitId > 0 then
            Codeunit.Run(PaymentImportCodeunitId, Rec)
        else
            Codeunit.Run(Codeunit::"Imp. Launch Payment Order CZB", Rec);
    end;

    procedure TestPrintRecords(ShowRequestForm: Boolean)
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
    begin
        PaymentOrderHeaderCZB.Copy(Rec);
        Report.RunModal(Report::"Payment Order - Test CZB", ShowRequestForm, false, PaymentOrderHeaderCZB);
    end;

    procedure PrintToDocumentAttachment()
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
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
        PaymentOrderHeaderCZB := Rec;
        PaymentOrderHeaderCZB.SetRecFilter();
        RecordRef.GetTable(PaymentOrderHeaderCZB);
        if not RecordRef.FindFirst() then
            exit;
        if not Report.RdlcLayout(Report::"Payment Order - Test CZB", DummyInStream) then
            exit;

        Clear(TempBlob);
        TempBlob.CreateOutStream(ReportOutStream);
        Report.SaveAs(Report::"Payment Order - Test CZB", '', ReportFormat::Pdf, ReportOutStream, RecordRef);

        Clear(DocumentAttachment);
        DocumentAttachment.InitFieldsFromRecRef(RecordRef);
        FileName := DocumentAttachment.FindUniqueFileName(StrSubstNo(DocumentAttachmentFileNameLbl, PaymentOrderHeaderCZB."No."), 'pdf');
        TempBlob.CreateInStream(DocumentInStream);
        DocumentAttachment.SaveAttachmentFromStream(DocumentInStream, RecordRef, FileName);
        DocumentAttachmentMgmt.ShowNotification(RecordRef, 1, true);
    end;

    local procedure TestStatusOpen()
    begin
        if StatusCheckSuspended then
            exit;
        Testfield(Status, Status::Open);
    end;

    procedure SuspendStatusCheck(Suspend: Boolean)
    begin
        StatusCheckSuspended := Suspend;
    end;

    local procedure IsApprovedForIssuing(): Boolean
    begin
        if BankingApprovalsMgtCZB.PreIssueApprovalCheckPaymentOrder(Rec) then
            exit(true);
    end;

    procedure SendToIssuing(IssuingCodeunitID: Integer)
    begin
        if not IsApprovedForIssuing() then
            exit;
        Codeunit.Run(IssuingCodeunitID, Rec);
    end;

    procedure ImportUnreliablePayerStatus()
    var
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
        UnreliablePayerMgtCZB: Codeunit "Unreliable Payer Mgt. CZB";
        UnreliablePayerStatusNotLoadedMsg: Label 'Unreliable Payer Status was not loaded.';
        UnreliabilityCheckDoneMsg: Label 'Unreliabile Payer Check was done.';
    begin
        UnreliablePayerMgtCZB.NotifyUnreliablePayerServiceSetup();

        ClearLastError();
        if not UnreliablePayerMgtCZB.ImportUnreliablePayerStatusForPaymentOrder(Rec) then begin
            if GetLastErrorText <> '' then
                Error(GetLastErrorText);
            Message(UnreliablePayerStatusNotLoadedMsg);
            exit;
        end;

        "Unreliable Pay. Check DateTime" := CurrentDateTime();
        Modify();

        PaymentOrderLineCZB.SetRange("Payment Order No.", "No.");
        PaymentOrderLineCZB.SetRange(Type, PaymentOrderLineCZB.Type::Vendor);
        PaymentOrderLineCZB.SetRange("Skip Payment", false);
        if PaymentOrderLineCZB.FindSet() then
            repeat
                if PaymentOrderLineCZB.IsUnreliablePayerCheckPossible() then begin
                    PaymentOrderLineCZB."VAT Unreliable Payer" := PaymentOrderLineCZB.HasUnreliablePayer();
                    PaymentOrderLineCZB."Public Bank Account" := PaymentOrderLineCZB.HasPublicBankAccount();
                    PaymentOrderLineCZB.Modify();
                end;
            until PaymentOrderLineCZB.Next() = 0;
        Message(UnreliabilityCheckDoneMsg);
    end;

    procedure UnreliablePayerCheckExpired(): Boolean
    begin
        if "Unreliable Pay. Check DateTime" = 0DT then
            exit(true);

        exit(Today() - DT2Date("Unreliable Pay. Check DateTime") >= 2);
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

    procedure CheckPaymentOrderIssueRestrictions()
    begin
        OnCheckPaymentOrderIssueRestrictions();
    end;

    local procedure DeleteRecordInApprovalRequest()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeDeleteRecordInApprovalRequest(Rec, IsHandled);
        if IsHandled then
            exit;

        ApprovalsMgmt.OnDeleteRecordInApprovalRequest(RecordId);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnCheckPaymentOrderIssueRestrictions()
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeDeleteRecordInApprovalRequest(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB"; var IsHandled: Boolean);
    begin
    end;
}
