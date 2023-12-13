// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Ledger;
using Microsoft.Bank.Reconciliation;
using Microsoft.Bank.Setup;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.Attachment;
using Microsoft.Foundation.NoSeries;
using Microsoft.Sales.History;
using System.Utilities;

table 31252 "Bank Statement Header CZB"
{
    Caption = 'Bank Statement Header';
    DataCaptionFields = "No.", "Bank Account No.", "Bank Account Name";
    DrillDownPageID = "Bank Statements CZB";
    LookupPageID = "Bank Statements CZB";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("No." <> xRec."No.") and ("Bank Account No." <> '') then begin
                    BankAccount.Get("Bank Account No.");
                    NoSeriesManagement.TestManual(BankAccount."Bank Statement Nos. CZB");
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
            TableRelation = "Bank Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                BankAccount: Record "Bank Account";
                SearchRuleCZB: Record "Search Rule CZB";
            begin
                if not BankAccount.Get("Bank Account No.") then
                    BankAccount.Init();
                "Account No." := BankAccount."Bank Account No.";
                BankAccount.Testfield(Blocked, false);
                IBAN := BankAccount.IBAN;
                "SWIFT Code" := BankAccount."SWIFT Code";
                Validate("Currency Code", BankAccount."Currency Code");

                "Search Rule Code" := '';
                if BankAccount."Search Rule Code CZB" <> '' then
                    Validate("Search Rule Code", BankAccount."Search Rule Code CZB")
                else begin
                    SearchRuleCZB.SetRange(Default, true);
                    if SearchRuleCZB.FindFirst() then
                        Validate("Search Rule Code", SearchRuleCZB.Code);
                end;

                CalcFields("Bank Account Name");
            end;
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

            trigger OnValidate()
            begin
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
                if CurrFieldNo <> FieldNo("Currency Code") then
                    UpdateCurrencyFactor()
                else
                    if "Currency Code" <> xRec."Currency Code" then begin
                        UpdateCurrencyFactor();
                        UpdateBankStatementLine(FieldCaption("Currency Code"), false);
                    end else
                        if "Currency Code" <> '' then begin
                            UpdateCurrencyFactor();
                            if "Currency Factor" <> xRec."Currency Factor" then
                                ConfirmUpdateCurrencyFactor();
                        end;
                Validate("Bank Statement Currency Code", "Currency Code");
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
                if "Currency Code" = "Bank Statement Currency Code" then
                    "Bank Statement Currency Factor" := "Currency Factor";
                if "Currency Factor" <> xRec."Currency Factor" then
                    UpdateBankStatementLine(FieldCaption("Currency Factor"), false);
            end;
        }
#pragma warning disable AA0232
        field(9; Amount; Decimal)
        {
            CalcFormula = sum("Bank Statement Line CZB".Amount where("Bank Statement No." = field("No.")));
            Caption = 'Amount';
            Editable = false;
            FieldClass = FlowField;
        }
#pragma warning restore
        field(10; "Amount (LCY)"; Decimal)
        {
            CalcFormula = sum("Bank Statement Line CZB"."Amount (LCY)" where("Bank Statement No." = field("No.")));
            Caption = 'Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; Debit; Decimal)
        {
            CalcFormula = - sum("Bank Statement Line CZB".Amount where("Bank Statement No." = field("No."), Positive = const(false)));
            Caption = 'Debit';
            Editable = false;
            FieldClass = FlowField;
        }
        field(12; "Debit (LCY)"; Decimal)
        {
            CalcFormula = - sum("Bank Statement Line CZB"."Amount (LCY)" where("Bank Statement No." = field("No."), Positive = const(false)));
            Caption = 'Debit (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; Credit; Decimal)
        {
            CalcFormula = sum("Bank Statement Line CZB".Amount where("Bank Statement No." = field("No."), Positive = const(true)));
            Caption = 'Credit';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Credit (LCY)"; Decimal)
        {
            CalcFormula = sum("Bank Statement Line CZB"."Amount (LCY)" where("Bank Statement No." = field("No."), Positive = const(true)));
            Caption = 'Credit (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "No. of Lines"; Integer)
        {
            CalcFormula = Count("Bank Statement Line CZB" where("Bank Statement No." = field("No.")));
            Caption = 'No. of Lines';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Bank Statement Currency Code"; Code[10])
        {
            Caption = 'Bank Statement Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if CurrFieldNo <> FieldNo("Bank Statement Currency Code") then
                    UpdateOrderCurrencyFactor()
                else
                    if "Bank Statement Currency Code" <> xRec."Bank Statement Currency Code" then begin
                        UpdateOrderCurrencyFactor();
                        UpdateBankStatementLine(FieldCaption("Bank Statement Currency Code"), CurrFieldNo <> 0);
                    end else
                        if "Bank Statement Currency Code" <> '' then begin
                            UpdateOrderCurrencyFactor();
                            if "Bank Statement Currency Factor" <> xRec."Bank Statement Currency Factor" then
                                ConfUpdateOrderCurrencyFactor();
                        end;
            end;
        }
        field(21; "Bank Statement Currency Factor"; Decimal)
        {
            Caption = 'Bank Statement Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Currency Code" = "Bank Statement Currency Code" then
                    "Currency Factor" := "Bank Statement Currency Factor";
                if "Bank Statement Currency Factor" <> xRec."Bank Statement Currency Factor" then
                    UpdateBankStatementLine(FieldCaption("Bank Statement Currency Factor"), CurrFieldNo <> 0);
            end;
        }
        field(30; "Last Issuing No."; Code[20])
        {
            Caption = 'Last Issuing No.';
            Editable = false;
            TableRelation = "Sales Invoice Header";
            DataClassification = CustomerContent;
        }
        field(35; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                BankStmtHeader: Record "Bank Statement Header CZB";
                IssBankStamtementHeaderCZB: Record "Iss. Bank Statement Header CZB";
                ExternalDocMsg: Label 'The %1 field in the %2 table already exists, field %3 = %4.', Comment = '%1 = FieldCaption, %2 = TableCaption, %3 = FieldCaption, %4 = Field Value';
            begin
                BankStmtHeader.SetFilter("Bank Account No.", "Bank Account No.");
                BankStmtHeader.SetFilter("No.", '<>%1', "No.");
                BankStmtHeader.SetRange("External Document No.", "External Document No.");
                BankAccount.Get("Bank Account No.");
                if BankAccount."Check Ext. No. Curr. Year CZB" then begin
                    Testfield("Document Date");
                    BankStmtHeader.SetRange("Document Date", CalcDate('<CY>-<1Y>+<1D>', "Document Date"), CalcDate('<CY>', "Document Date"));
                end;
                if BankStmtHeader.FindFirst() then begin
                    Message(ExternalDocMsg, BankStmtHeader.FieldCaption("External Document No."), BankStmtHeader.TableCaption,
                      BankStmtHeader.FieldCaption("No."), BankStmtHeader."No.");
                    exit;
                end;

                IssBankStamtementHeaderCZB.SetFilter("Bank Account No.", "Bank Account No.");
                IssBankStamtementHeaderCZB.SetRange("External Document No.", "External Document No.");
                if BankAccount."Check Ext. No. Curr. Year CZB" then begin
                    Testfield("Document Date");
                    IssBankStamtementHeaderCZB.SetRange("Document Date", CalcDate('<CY>-<1Y>+<1D>', "Document Date"), CalcDate('<CY>', "Document Date"));
                end;
                if IssBankStamtementHeaderCZB.FindFirst() then begin
                    Message(ExternalDocMsg, IssBankStamtementHeaderCZB.FieldCaption("External Document No."), IssBankStamtementHeaderCZB.TableCaption,
                      IssBankStamtementHeaderCZB.FieldCaption("No."), IssBankStamtementHeaderCZB."No.");
                    exit;
                end;
            end;
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
            TableRelation = "SWIFT Code";
            DataClassification = CustomerContent;
        }
        field(110; "Search Rule Code"; Code[10])
        {
            Caption = 'Search Rule Code';
            TableRelation = "Search Rule CZB";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SearchRuleLineCZB: Record "Search Rule Line CZB";
                GenJournalLine: Record "Gen. Journal Line";
                BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
                BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
                SearchRuleEmptyErr: Label 'Search Rule must have %1.', Comment = '%1 = Search Rule Line TableCaption';
                ChangeSearchRuleErr: Label 'You cannot change %1, because %2 for bank statement %3 exists.', Comment = '%1 = Search Rule Code FieldCaption, %2 = TabeCaption, %3 = No.';
            begin
                if ("Search Rule Code" = '') or ("Search Rule Code" = xRec."Search Rule Code") then
                    exit;

                SearchRuleLineCZB.SetRange("Search Rule Code", Rec."Search Rule Code");
                if SearchRuleLineCZB.IsEmpty() then
                    Error(SearchRuleEmptyErr, SearchRuleLineCZB.TableCaption());

                if CurrFieldNo = 0 then
                    exit;

                GenJournalLine.SetCurrentKey("Document No.");
                GenJournalLine.Setrange("Document No.", "No.");
                if not GenJournalLine.IsEmpty() then
                    Error(ChangeSearchRuleErr, FieldCaption("Search Rule Code"), GenJournalLine.TableCaption(), "No.");

                BankAccReconciliationLine.Setrange("Document No.", "No.");
                if not BankAccReconciliationLine.IsEmpty() then
                    Error(ChangeSearchRuleErr, FieldCaption("Search Rule Code"), BankAccReconciliationLine.TableCaption(), "No.");

                BankAccountLedgerEntry.SetCurrentKey("Document No.");
                BankAccountLedgerEntry.Setrange("Document No.", "No.");
                if not GenJournalLine.IsEmpty() then
                    Error(ChangeSearchRuleErr, FieldCaption("Search Rule Code"), BankAccountLedgerEntry.TableCaption(), "No.");
            end;
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
        BankStatementLineCZB: Record "Bank Statement Line CZB";
    begin
        BankStatementLineCZB.SetRange("Bank Statement No.", "No.");
        BankStatementLineCZB.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        if "No." = '' then begin
            BankAccount.Get("Bank Account No.");
            BankAccount.Testfield("Bank Statement Nos. CZB");
            NoSeriesManagement.InitSeries(BankAccount."Bank Statement Nos. CZB", xRec."No. Series", 0D, "No.", "No. Series");
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
        NoSeriesManagement: Codeunit NoSeriesManagement;
        ConfirmManagement: Codeunit "Confirm Management";
        HideValidationDialog: Boolean;
        Confirmed: Boolean;
        UpdateCurrExchQst: Label 'Do you want to update Exchange Rate?';

    procedure AssistEdit(OldBankStatementHeaderCZB: Record "Bank Statement Header CZB"): Boolean
    var
        BankStatementHeaderCZB: Record "Bank Statement Header CZB";
    begin
        BankStatementHeaderCZB := Rec;
        BankAccount.Get(BankStatementHeaderCZB."Bank Account No.");
        BankAccount.Testfield("Bank Statement Nos. CZB");
        if NoSeriesManagement.SelectSeries(BankAccount."Bank Statement Nos. CZB", OldBankStatementHeaderCZB."No. Series", BankStatementHeaderCZB."No. Series") then begin
            BankAccount.Get(BankStatementHeaderCZB."Bank Account No.");
            BankAccount.Testfield("Bank Account No.");
            NoSeriesManagement.SetSeries(BankStatementHeaderCZB."No.");
            Rec := BankStatementHeaderCZB;
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
        if HideValidationDialog then
            Confirmed := true
        else
            Confirmed := ConfirmManagement.GetResponseOrDefault(UpdateCurrExchQst, false);
        if Confirmed then
            Validate("Currency Factor")
        else
            "Currency Factor" := xRec."Currency Factor";
    end;

    procedure UpdateBankStatementLine(ChangedFieldName: Text; AskQuestion: Boolean)
    var
        BankStatementLineCZB: Record "Bank Statement Line CZB";
        UpdateLinesQst: Label 'You have modified %1.\Do you want update lines?', Comment = '%1 = FieldCaption';
    begin
        if not BankStmtLinesExist() then
            exit;
        if AskQuestion then
            if GuiAllowed and not ConfirmManagement.GetResponseOrDefault(StrSubstNo(UpdateLinesQst, ChangedFieldName), true) then
                exit;

        BankStatementLineCZB.LockTable();
        Modify();

        BankStatementLineCZB.Reset();
        BankStatementLineCZB.SetRange("Bank Statement No.", "No.");
        if BankStatementLineCZB.FindSet() then
            repeat
                case ChangedFieldName of
                    FieldCaption("Currency Code"):
                        begin
                            BankStatementLineCZB.Validate("Currency Code", "Currency Code");
                            BankStatementLineCZB.Validate("Amount (Bank Stat. Currency)");
                        end;
                    FieldCaption("Currency Factor"):
                        begin
                            if "Currency Code" = "Bank Statement Currency Code" then
                                BankStatementLineCZB."Bank Statement Currency Factor" := "Bank Statement Currency Factor";
                            BankStatementLineCZB.Validate("Amount (Bank Stat. Currency)");
                        end;
                    FieldCaption("Bank Statement Currency Code"):
                        begin
                            BankStatementLineCZB."Bank Statement Currency Factor" := "Bank Statement Currency Factor";
                            BankStatementLineCZB."Bank Statement Currency Code" := "Bank Statement Currency Code";
                            BankStatementLineCZB.Validate("Amount (Bank Stat. Currency)");
                        end;
                    FieldCaption("Bank Statement Currency Factor"):
                        begin
                            BankStatementLineCZB."Bank Statement Currency Factor" := "Bank Statement Currency Factor";
                            BankStatementLineCZB.Validate("Amount (Bank Stat. Currency)");
                        end;
                end;
                BankStatementLineCZB.Modify(true);
            until BankStatementLineCZB.Next() = 0;
    end;

    procedure BankStmtLinesExist(): Boolean
    var
        BankStatementLineCZB: Record "Bank Statement Line CZB";
    begin
        BankStatementLineCZB.Reset();
        BankStatementLineCZB.SetRange("Bank Statement No.", "No.");
        exit(not BankStatementLineCZB.IsEmpty);
    end;

    local procedure UpdateOrderCurrencyFactor()
    begin
        if "Bank Statement Currency Code" <> '' then
            "Bank Statement Currency Factor" := CurrencyExchangeRate.ExchangeRate("Document Date", "Bank Statement Currency Code")
        else
            "Bank Statement Currency Factor" := 0;

        if "Currency Code" = "Bank Statement Currency Code" then
            "Currency Factor" := "Bank Statement Currency Factor";
    end;

    local procedure ConfUpdateOrderCurrencyFactor()
    begin
        if HideValidationDialog then
            Confirmed := true
        else
            Confirmed := ConfirmManagement.GetResponseOrDefault(UpdateCurrExchQst, false);
        if Confirmed then
            Validate("Bank Statement Currency Factor")
        else
            "Bank Statement Currency Factor" := xRec."Bank Statement Currency Factor";
    end;

    procedure SetHideValidationDialog(HideValidationDialogNew: Boolean)
    begin
        HideValidationDialog := HideValidationDialogNew;
    end;

    procedure ImportBankStatement()
    var
        BankStatementImportCodeunitId: Integer;
        IsHandled: Boolean;
    begin
        OnBeforeImportBankStatement(Rec, IsHandled);
        if IsHandled then
            exit;

        BankAccount.Get("Bank Account No.");
        BankStatementImportCodeunitId := BankAccount.GetBankStatementImportCodeunitIdCZB();
        if BankStatementImportCodeunitId > 0 then
            Codeunit.Run(BankStatementImportCodeunitId, Rec)
        else
            Codeunit.Run(Codeunit::"Imp. Launch Bank Statement CZB", Rec);

        OnAfterImportBankStatement(Rec);
    end;

    procedure TestPrintRecords(ShowRequestForm: Boolean)
    var
        BankStatementHeaderCZB: Record "Bank Statement Header CZB";
    begin
        BankStatementHeaderCZB.Copy(Rec);
        Report.RunModal(Report::"Bank Statement - Test CZB", ShowRequestForm, false, BankStatementHeaderCZB);
    end;

    procedure PrintToDocumentAttachment()
    var
        BankStatementHeaderCZB: Record "Bank Statement Header CZB";
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
        BankStatementHeaderCZB := Rec;
        BankStatementHeaderCZB.SetRecFilter();
        RecordRef.GetTable(BankStatementHeaderCZB);
        if not RecordRef.FindFirst() then
            exit;
        if not Report.RdlcLayout(Report::"Bank Statement - Test CZB", DummyInStream) then
            exit;

        Clear(TempBlob);
        TempBlob.CreateOutStream(ReportOutStream);
        Report.SaveAs(Report::"Bank Statement - Test CZB", '', ReportFormat::Pdf, ReportOutStream, RecordRef);

        Clear(DocumentAttachment);
        DocumentAttachment.InitFieldsFromRecRef(RecordRef);
        FileName := DocumentAttachment.FindUniqueFileName(StrSubstNo(DocumentAttachmentFileNameLbl, BankStatementHeaderCZB."No."), 'pdf');
        TempBlob.CreateInStream(DocumentInStream);
        DocumentAttachment.SaveAttachmentFromStream(DocumentInStream, RecordRef, FileName);
        DocumentAttachmentMgmt.ShowNotification(RecordRef, 1, true);
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
    local procedure OnBeforeImportBankStatement(var BankStatementHeaderCZB: Record "Bank Statement Header CZB"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterImportBankStatement(var BankStatementHeaderCZB: Record "Bank Statement Header CZB")
    begin
    end;
}
