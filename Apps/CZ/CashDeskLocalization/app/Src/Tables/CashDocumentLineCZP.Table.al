// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Bank.BankAccount;
using Microsoft.CRM.Team;
using Microsoft.Finance;
using Microsoft.Finance.AllocationAccount;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Setup;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Maintenance;
using Microsoft.FixedAssets.Setup;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Enums;
using Microsoft.HumanResources.Employee;
using Microsoft.HumanResources.Payables;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using Microsoft.Utilities;
using System.Utilities;

#pragma warning disable AL0432
table 11733 "Cash Document Line CZP"
{
    Caption = 'Cash Document Line';
    DrillDownPageID = "Cash Document Lines CZP";
    LookupPageID = "Cash Document Lines CZP";

    fields
    {
        field(1; "Cash Desk No."; Code[20])
        {
            Caption = 'Cash Desk No.';
            TableRelation = "Cash Desk CZP";
            DataClassification = CustomerContent;
        }
        field(2; "Cash Document No."; Code[20])
        {
            Caption = 'Cash Document No.';
            TableRelation = "Cash Document Header CZP"."No." where("Cash Desk No." = field("Cash Desk No."));
            DataClassification = CustomerContent;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(4; "Gen. Document Type"; Enum "Cash Document Gen.Doc.Type CZP")
        {
            Caption = 'Gen. Document Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(5; "Account Type"; Enum "Cash Document Account Type CZP")
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                GetCashDeskEventCZP();
                if CashDeskEventCZP."Account Type" <> CashDeskEventCZP."Account Type"::" " then
                    CashDeskEventCZP.TestField("Account Type", "Account Type");

                GetCashDocumentHeaderCZP();

                TempCashDocumentLineCZP := Rec;
                Init();
                "Document Type" := CashDocumentHeaderCZP."Document Type";
                "Account Type" := TempCashDocumentLineCZP."Account Type";
                "Cash Desk Event" := TempCashDocumentLineCZP."Cash Desk Event";
                UpdateAmounts();
                UpdateDocumentType();
            end;
        }
        field(6; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = if ("Account Type" = const(" ")) "Standard Text" else
            if ("Account Type" = const("G/L Account")) "G/L Account" where("Account Type" = const(Posting)) else
            if ("Account Type" = const(Customer)) Customer else
            if ("Account Type" = const(Vendor)) Vendor else
            if ("Account Type" = const(Employee)) Employee else
            if ("Account Type" = const("Bank Account")) "Bank Account" where("Account Type CZP" = const("Bank Account")) else
            if ("Account Type" = const("Fixed Asset")) "Fixed Asset" else
            if ("Account Type" = const("Allocation Account")) "Allocation Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                StandardText: Record "Standard Text";
                GLAccount: Record "G/L Account";
                Customer: Record Customer;
                Vendor: Record Vendor;
                CashDeskCZP: Record "Bank Account";
                Employee: Record Employee;
                IsHandled: Boolean;
                BreakValidation: Boolean;
            begin
                GetCashDeskEventCZP();
                if CashDeskEventCZP."Account No." <> '' then
                    CashDeskEventCZP.TestField("Account No.", "Account No.");

                GetCashDocumentHeaderCZP();
                if ("Account Type" in ["Account Type"::Customer, "Account Type"::Vendor]) and ("Account No." <> '') then
                    if CashDocumentHeaderCZP."Partner No." = '' then begin
                        case "Account Type" of
                            "Account Type"::Customer:
                                CashDocumentHeaderCZP."Partner Type" := CashDocumentHeaderCZP."Partner Type"::Customer;
                            "Account Type"::Vendor:
                                CashDocumentHeaderCZP."Partner Type" := CashDocumentHeaderCZP."Partner Type"::Vendor;
                        end;
                        CashDocumentHeaderCZP.SetSkipLineNoToUpdateLine("Line No.");
                        CashDocumentHeaderCZP.Validate("Partner No.", "Account No.");
                        CashDocumentHeaderCZP.Modify();
                        CashDocumentHeaderCZP.SetSkipLineNoToUpdateLine(0);
                        CashDocumentHeaderCZP.Get("Cash Desk No.", "Cash Document No.");
                    end;

                OnValidateAccountNoOnBeforeInitRec(Rec, xRec, CurrFieldNo);

                TempCashDocumentLineCZP := Rec;
                Init();
                "Document Type" := CashDocumentHeaderCZP."Document Type";
                "External Document No." := TempCashDocumentLineCZP."External Document No.";
                "Cash Desk Event" := TempCashDocumentLineCZP."Cash Desk Event";
                "Account Type" := TempCashDocumentLineCZP."Account Type";
                "Account No." := TempCashDocumentLineCZP."Account No.";
                "Gen. Document Type" := TempCashDocumentLineCZP."Gen. Document Type";

                IsHandled := false;
                BreakValidation := false;
                OnValidateAccountNoOnAfterInitRec(Rec, xRec, TempCashDocumentLineCZP, IsHandled, BreakValidation);
                if BreakValidation then
                    exit;
                if not IsHandled then
                    if "Account No." = '' then
                        exit;

                "Currency Code" := CashDocumentHeaderCZP."Currency Code";
                Validate("Salespers./Purch. Code", CashDocumentHeaderCZP."Salespers./Purch. Code");
                Validate("Responsibility Center", CashDocumentHeaderCZP."Responsibility Center");
                if "External Document No." = '' then
                    "External Document No." := CashDocumentHeaderCZP."External Document No.";
                "Reason Code" := CashDocumentHeaderCZP."Reason Code";

                IsHandled := false;
                OnValidateAccountNoOnBeforeProcessingAccountType(Rec, xRec, TempCashDocumentLineCZP, IsHandled);
                if not IsHandled then
                    case "Account Type" of
                        "Account Type"::" ":
                            begin
                                StandardText.Get("Account No.");
                                Description := StandardText.Description;
                            end;
                        "Account Type"::"G/L Account":
                            begin
                                GLAccount.Get("Account No.");
                                GLAccount.CheckGLAcc();
                                Description := GLAccount.Name;
                                if not "System-Created Entry" then
                                    GLAccount.TestField("Direct Posting", true);
                                if (GLAccount."VAT Bus. Posting Group" <> '') or
                                   (GLAccount."VAT Prod. Posting Group" <> '')
                                then
                                    GLAccount.TestField("Gen. Posting Type");
                                Description := GLAccount.Name;
                                "Gen. Posting Type" := GLAccount."Gen. Posting Type";
                                "VAT Bus. Posting Group" := GLAccount."VAT Bus. Posting Group";
                                "VAT Prod. Posting Group" := GLAccount."VAT Prod. Posting Group";
                            end;
                        "Account Type"::Customer:
                            begin
                                Customer.Get("Account No.");
                                Description := Customer.Name;
                                "Posting Group" := Customer."Customer Posting Group";
                                "Gen. Posting Type" := "Gen. Posting Type"::" ";
                                "VAT Bus. Posting Group" := '';
                                "VAT Prod. Posting Group" := '';
                            end;
                        "Account Type"::Vendor:
                            begin
                                Vendor.Get("Account No.");
                                Description := Vendor.Name;
                                "Posting Group" := Vendor."Vendor Posting Group";
                                "Gen. Posting Type" := "Gen. Posting Type"::" ";
                                "VAT Bus. Posting Group" := '';
                                "VAT Prod. Posting Group" := '';
                            end;
                        "Account Type"::"Bank Account":
                            begin
                                CashDeskCZP.Get("Account No.");
                                CashDeskCZP.TestField(Blocked, false);
                                Description := CashDeskCZP.Name;
                                "Gen. Posting Type" := "Gen. Posting Type"::" ";
                                "VAT Bus. Posting Group" := '';
                                "VAT Prod. Posting Group" := '';
                            end;
                        "Account Type"::"Fixed Asset":
                            begin
                                FixedAsset.Get("Account No.");
                                FixedAsset.TestField(Blocked, false);
                                FixedAsset.TestField(Inactive, false);
                                FixedAsset.TestField("Budgeted Asset", false);
                                GetFAPostingGroup();
                                Description := FixedAsset.Description;
                            end;
                        "Account Type"::Employee:
                            begin
                                Employee.Get("Account No.");
                                Description := CopyStr(Employee.FullName(), 1, MaxStrLen(Description));
                                "Posting Group" := Employee."Employee Posting Group";
                                "Gen. Posting Type" := "Gen. Posting Type"::" ";
                                "VAT Bus. Posting Group" := '';
                                "VAT Prod. Posting Group" := '';
                            end;
                    end;

                if not ("Account Type" in ["Account Type"::" ", "Account Type"::"Fixed Asset"]) then
                    Validate("VAT Prod. Posting Group");

                IsHandled := false;
                OnValidateAccountNoOnBeforeCreateDim(Rec, xRec, TempCashDocumentLineCZP, IsHandled);
                if not IsHandled then
                    CreateDimFromDefaultDim(Rec.FieldNo("Account No."));
            end;
        }
        field(7; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(8; "Posting Group"; Code[20])
        {
            Caption = 'Posting Group';
            TableRelation = if ("Account Type" = const("Fixed Asset")) "FA Posting Group" else
            if ("Account Type" = const("Bank Account")) "Bank Account Posting Group" else
            if ("Account Type" = const(Customer)) "Customer Posting Group" else
            if ("Account Type" = const(Vendor)) "Vendor Posting Group";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                PostingGroupChange: Codeunit "Posting Group Change";
            begin
                if CurrFieldNo = FieldNo("Posting Group") then
                    PostingGroupChange.ChangePostingGroup("Posting Group", xRec."Posting Group", Rec);
            end;
        }
        field(14; "Applies-To Doc. Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Applies-To Doc. Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Applies-To Doc. Type" <> xRec."Applies-To Doc. Type" then
                    Validate("Applies-To Doc. No.", '');
            end;
        }
        field(15; "Applies-To Doc. No."; Code[20])
        {
            Caption = 'Applies-To Doc. No.';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                GenJournalLine: Record "Gen. Journal Line";
                CashDocumentPostCZP: Codeunit "Cash Document-Post CZP";
                PaymentToleranceManagement: Codeunit "Payment Tolerance Management";
                AccountNo: Code[20];
                AccountType: Enum "Gen. Journal Account Type";
                PreviousAmount: Decimal;
                IsHandled: Boolean;
            begin
                GetCashDocumentHeaderCZP();
                CashDocumentPostCZP.InitGenJnlLine(CashDocumentHeaderCZP, Rec);
                CashDocumentPostCZP.GetGenJnlLine(GenJournalLine);
                PreviousAmount := GenJournalLine.Amount;

                if GenJournalLine."Bal. Account Type" in [GenJournalLine."Bal. Account Type"::Customer,
                                                      GenJournalLine."Bal. Account Type"::Vendor,
                                                      GenJournalLine."Bal. Account Type"::Employee]
                then begin
                    AccountNo := GenJournalLine."Bal. Account No.";
                    AccountType := GenJournalLine."Bal. Account Type";
                end else begin
                    AccountNo := GenJournalLine."Account No.";
                    AccountType := GenJournalLine."Account Type";
                end;

                if (AccountType.AsInteger() <> GenJournalLine."Account Type"::Customer.AsInteger()) and
                   (AccountType.AsInteger() <> GenJournalLine."Account Type"::Vendor.AsInteger()) and
                   (AccountType.AsInteger() <> GenJournalLine."Account Type"::Employee.AsInteger())
                then begin
                    AccountType := GenJournalLine."Bal. Account Type";
                    AccountNo := GenJournalLine."Bal. Account No.";
                end;
                case AccountType of
                    AccountType::Customer:
                        LookupApplyCustEntry(GenJournalLine, AccountNo);
                    AccountType::Vendor:
                        LookupApplyVendEntry(GenJournalLine, AccountNo);
                    AccountType::Employee:
                        LookupApplyEmplEntry(GenJournalLine, AccountNo);
                end;
                if GenJournalLine."Applies-to Doc. No." = '' then
                    exit;

                OnLookupAppliesToDocNoOnBeforeValidateAccountNo(GenJournalLine, Rec);
                if AccountNo = '' then
                    Validate("Account No.", GenJournalLine."Account No.");
                "Applies-To Doc. Type" := GenJournalLine."Applies-to Doc. Type";
                "Applies-To Doc. No." := GenJournalLine."Applies-to Doc. No.";
                "Applies-to ID" := GenJournalLine."Applies-to ID";
                OnLookupAppliesToDocNoOnAfterFillAppliesToDocNo(Rec, GenJournalLine);
                OnLookupAppliesToDocNoOnBeforeValidateAmount(Rec, GenJournalLine, IsHandled);
                if not IsHandled then
                    Validate(Amount, SignAmount() * GenJournalLine.Amount);
                if PreviousAmount <> 0 then begin
                    PaymentToleranceManagement.SetSuppressCommit(true);
                    if not PaymentToleranceManagement.PmtTolGenJnl(GenJournalLine) then
                        exit;
                end;
            end;

            trigger OnValidate()
            var
                GenJournalLine: Record "Gen. Journal Line";
                GenJournalBatch: Record "Gen. Journal Batch";
                CustLedgEntry: Record "Cust. Ledger Entry";
                VendorLedgEntry: Record "Vendor Ledger Entry";
                EmployeeLedgEntry: Record "Employee Ledger Entry";
                CashDocumentPostCZP: Codeunit "Cash Document-Post CZP";
                PaymentToleranceManagement: Codeunit "Payment Tolerance Management";
                IsHandled: Boolean;
            begin
                GetCashDocumentHeaderCZP();
                CashDocumentPostCZP.InitGenJnlLine(CashDocumentHeaderCZP, Rec);
                CashDocumentPostCZP.GetGenJnlLine(GenJournalLine);
                GenJournalLine.SetSuppressCommit(true);
                PaymentToleranceManagement.SetSuppressCommit(true);
                GenJournalBatch.Insert(); // only for "Applies-to Doc. No." validation
                GenJournalLine.Validate("Applies-to Doc. No.");
                GenJournalBatch.Delete();

                if ("Applies-To Doc. No." = '') and (xRec."Applies-To Doc. No." <> '') then begin
                    PaymentToleranceManagement.DelPmtTolApllnDocNo(GenJournalLine, xRec."Applies-To Doc. No.");

                    case "Account Type" of
                        "Account Type"::Customer:
                            begin
                                CustLedgEntry.SetCurrentKey("Document No.");
                                CustLedgEntry.SetRange("Document No.", xRec."Applies-To Doc. No.");
                                if not (xRec."Applies-To Doc. Type" = "Gen. Document Type"::" ") then
                                    CustLedgEntry.SetRange("Document Type", xRec."Applies-To Doc. Type");
                                CustLedgEntry.SetRange("Customer No.", "Account No.");
                                CustLedgEntry.SetRange(Open, true);
                                if CustLedgEntry.FindFirst() then
                                    if CustLedgEntry."Amount to Apply" <> 0 then begin
                                        CustLedgEntry."Amount to Apply" := 0;
                                        Codeunit.Run(Codeunit::"Cust. Entry-Edit", CustLedgEntry);
                                    end;
                            end;
                        "Account Type"::Vendor:
                            begin
                                VendorLedgEntry.SetCurrentKey("Document No.");
                                VendorLedgEntry.SetRange("Document No.", xRec."Applies-To Doc. No.");
                                if not (xRec."Applies-To Doc. Type" = "Gen. Document Type"::" ") then
                                    VendorLedgEntry.SetRange("Document Type", xRec."Applies-To Doc. Type");
                                VendorLedgEntry.SetRange("Vendor No.", "Account No.");
                                VendorLedgEntry.SetRange(Open, true);
                                if VendorLedgEntry.FindFirst() then
                                    if VendorLedgEntry."Amount to Apply" <> 0 then begin
                                        VendorLedgEntry."Amount to Apply" := 0;
                                        Codeunit.Run(Codeunit::"Vend. Entry-Edit", VendorLedgEntry);
                                    end;
                            end;
                        "Account Type"::Employee:
                            begin
                                EmployeeLedgEntry.SetCurrentKey("Document No.");
                                EmployeeLedgEntry.SetRange("Document No.", xRec."Applies-To Doc. No.");
                                if not (xRec."Applies-To Doc. Type" = "Gen. Document Type"::" ") then
                                    EmployeeLedgEntry.SetRange("Document Type", xRec."Applies-To Doc. Type");
                                EmployeeLedgEntry.SetRange("Employee No.", "Account No.");
                                EmployeeLedgEntry.SetRange(Open, true);
                                if EmployeeLedgEntry.FindFirst() then
                                    if EmployeeLedgEntry."Amount to Apply" <> 0 then begin
                                        EmployeeLedgEntry."Amount to Apply" := 0;
                                        Codeunit.Run(Codeunit::"Empl. Entry-Edit", EmployeeLedgEntry);
                                    end;
                            end;
                    end;
                end;

                if (Amount = 0) and ("Applies-To Doc. No." <> '') then begin
                    TestField("Currency Code", GenJournalLine."Currency Code");
                    Validate("Account No.", GenJournalLine."Account No.");

                    case "Account Type" of
                        "Account Type"::Customer:
                            GenJournalLine.Validate(Amount, GetAmtToApplyCust(GenJournalLine));
                        "Account Type"::Vendor:
                            GenJournalLine.Validate(Amount, GetAmtToApplyVend(GenJournalLine));
                        "Account Type"::Employee:
                            GenJournalLine.Validate(Amount, GetAmtToApplyEmpl(GenJournalLine));
                    end;
                    OnValidateAppliesToDocNoOnBeforeValidateAmount(Rec, GenJournalLine, IsHandled);
                    if not IsHandled then
                        Validate(Amount, SignAmount() * GenJournalLine.Amount);
                    "Applies-To Doc. Type" := GenJournalLine."Applies-to Doc. Type";
                    "Applies-To Doc. No." := GenJournalLine."Applies-to Doc. No.";
                    "Applies-to ID" := GenJournalLine."Applies-to ID";
                    OnValidateAppliesToDocNoOnAfterFillAppliesToDocNo(Rec, GenJournalLine);
                end;

                if ("Applies-To Doc. No." <> xRec."Applies-To Doc. No.") and (Amount <> 0) then begin
                    if xRec."Applies-To Doc. No." <> '' then
                        PaymentToleranceManagement.DelPmtTolApllnDocNo(GenJournalLine, xRec."Applies-To Doc. No.");
                    PaymentToleranceManagement.PmtTolGenJnl(GenJournalLine);
                end;
            end;
        }
        field(16; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(17; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
        }
        field(20; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckEmptyAccount();
                UpdateAmounts();
            end;
        }
        field(21; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                CurrExchRate: Record "Currency Exchange Rate";
            begin
                GetCashDocumentHeaderCZP();
                if CashDocumentHeaderCZP."Currency Code" = '' then
                    Validate(Amount, "Amount (LCY)")
                else
                    Validate(Amount, Round(CurrExchRate.ExchangeAmtLCYToFCY(CashDocumentHeaderCZP."Posting Date", CashDocumentHeaderCZP."Currency Code",
                          "Amount (LCY)", CashDocumentHeaderCZP."Currency Factor"), Currency."Amount Rounding Precision"));
            end;
        }
        field(24; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          Blocked = const(false));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(25; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(26; "Document Type"; Enum "Cash Document Type CZP")
        {
            Caption = 'Cash Document Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(28; "Applies-to ID"; Code[50])
        {
            Caption = 'Applies-to ID';
            DataClassification = CustomerContent;
        }
        field(36; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(40; "Cash Desk Event"; Code[10])
        {
            Caption = 'Cash Desk Event';
            TableRelation = "Cash Desk Event CZP";
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                CashDeskEventCZP: Record "Cash Desk Event CZP";
            begin
                GetCashDocumentHeaderCZP();
                CashDeskEventCZP.FilterGroup(2);
                CashDeskEventCZP.SetFilter("Document Type", '%1|%2', CashDocumentHeaderCZP."Document Type"::" ", CashDocumentHeaderCZP."Document Type");
                CashDeskEventCZP.SetFilter("Cash Desk No.", '%1|%2', '', CashDocumentHeaderCZP."Cash Desk No.");
                CashDeskEventCZP.FilterGroup(0);
                CashDeskEventCZP.Code := "Cash Desk Event";
                if Page.RunModal(0, CashDeskEventCZP) = Action::LookupOK then
                    Validate("Cash Desk Event", CashDeskEventCZP.Code);
            end;

            trigger OnValidate()
            begin
                if "Cash Desk Event" <> xRec."Cash Desk Event" then
                    if "Cash Desk Event" <> '' then begin
                        CashDeskCZP.Get("Cash Desk No.");
                        GetCashDeskEventCZP();
                        GetCashDocumentHeaderCZP();
                        case CashDocumentHeaderCZP."Document Type" of
                            CashDocumentHeaderCZP."Document Type"::Receipt:
                                CashDeskEventCZP.TestField("Document Type", CashDeskEventCZP."Document Type"::Receipt);
                            CashDocumentHeaderCZP."Document Type"::Withdrawal:
                                CashDeskEventCZP.TestField("Document Type", CashDeskEventCZP."Document Type"::Withdrawal);
                        end;
                        TempCashDocumentLineCZP := Rec;
                        Init();
                        "External Document No." := TempCashDocumentLineCZP."External Document No.";
                        "Cash Desk Event" := TempCashDocumentLineCZP."Cash Desk Event";
                        Validate("Account Type", CashDeskEventCZP."Account Type");
                        Validate("System-Created Entry", true);
                        if CashDeskEventCZP."Account No." <> '' then
                            Validate("Account No.", CashDeskEventCZP."Account No.");
                        Validate(Description, CashDeskEventCZP.Description);
                        Validate("Gen. Posting Type", CashDeskEventCZP."Gen. Posting Type");
                        if CashDeskEventCZP."VAT Bus. Posting Group" <> '' then
                            Validate("VAT Bus. Posting Group", CashDeskEventCZP."VAT Bus. Posting Group");
                        if CashDeskEventCZP."VAT Prod. Posting Group" <> '' then
                            Validate("VAT Prod. Posting Group", CashDeskEventCZP."VAT Prod. Posting Group");
                        if CashDeskEventCZP."Global Dimension 1 Code" <> '' then
                            Validate("Shortcut Dimension 1 Code", CashDeskEventCZP."Global Dimension 1 Code");
                        if CashDeskEventCZP."Global Dimension 2 Code" <> '' then
                            Validate("Shortcut Dimension 2 Code", CashDeskEventCZP."Global Dimension 2 Code");
                        Validate("Gen. Document Type", CashDeskEventCZP."Gen. Document Type".AsInteger());
                        "Currency Code" := CashDocumentHeaderCZP."Currency Code";

                        CreateDimFromDefaultDim(Rec.FieldNo("Cash Desk Event"));
                    end;
            end;
        }
        field(42; "Salespers./Purch. Code"; Code[20])
        {
            Caption = 'Salespers./Purch. Code';
            TableRelation = "Salesperson/Purchaser";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CreateDimFromDefaultDim(Rec.FieldNo("Salespers./Purch. Code"));
            end;
        }
        field(43; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
            DataClassification = CustomerContent;
        }
        field(51; "VAT Base Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Base Amount';
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                TotalCashDocumentLineCZP: Record "Cash Document Line CZP";
            begin
                GetCashDocumentHeaderCZP();
                CalcTotalAmounts(TotalCashDocumentLineCZP);
                "VAT Base Amount" := Round("VAT Base Amount", Currency."Amount Rounding Precision");

                case "VAT Calculation Type" of
                    "VAT Calculation Type"::"Normal VAT",
                  "VAT Calculation Type"::"Reverse Charge VAT":
                        "VAT Amount" :=
                            Round(
                                (TotalCashDocumentLineCZP."VAT Base Amount" + "VAT Base Amount") * ("VAT %" / 100),
                                Currency."Amount Rounding Precision", Currency.VATRoundingDirection()) -
                            TotalCashDocumentLineCZP."VAT Amount";
                    "VAT Calculation Type"::"Full VAT":
                        if "VAT Base Amount" <> 0 then
                            FieldError("VAT Base Amount", StrSubstNo(MustBeZeroErr, FieldCaption("VAT Calculation Type"),
                                "VAT Calculation Type"));
                end;

                if CashDocumentHeaderCZP."Currency Code" = '' then begin
                    "VAT Base Amount (LCY)" := "VAT Base Amount";
                    "VAT Amount (LCY)" := "VAT Amount";
                end else begin
                    "VAT Base Amount (LCY)" := Round("VAT Base Amount" / CashDocumentHeaderCZP."Currency Factor");
                    "VAT Amount (LCY)" := Round("VAT Amount" / CashDocumentHeaderCZP."Currency Factor");
                end;

                "Amount Including VAT" := "VAT Base Amount" + "VAT Amount";
                "Amount Including VAT (LCY)" := "VAT Base Amount (LCY)" + "VAT Amount (LCY)";
                "VAT Difference" := 0;
            end;
        }
        field(52; "Amount Including VAT"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount Including VAT';
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                TotalCashDocumentLineCZP: Record "Cash Document Line CZP";
            begin
                GetCashDocumentHeaderCZP();
                CalcTotalAmounts(TotalCashDocumentLineCZP);
                "Amount Including VAT" := Round("Amount Including VAT", Currency."Amount Rounding Precision");

                case "VAT Calculation Type" of
                    "VAT Calculation Type"::"Normal VAT",
                  "VAT Calculation Type"::"Reverse Charge VAT":
                        "VAT Amount" :=
                            Round(
                                (TotalCashDocumentLineCZP."Amount Including VAT" + "Amount Including VAT") * "VAT %" / (100 + "VAT %"),
                                Currency."Amount Rounding Precision", Currency.VATRoundingDirection()) -
                            TotalCashDocumentLineCZP."VAT Amount";
                    "VAT Calculation Type"::"Full VAT":
                        "VAT Base Amount" := 0;
                end;

                if CashDocumentHeaderCZP."Currency Code" = '' then begin
                    "Amount Including VAT (LCY)" := "Amount Including VAT";
                    "VAT Amount (LCY)" := "VAT Amount";
                end else begin
                    "Amount Including VAT (LCY)" := Round("Amount Including VAT" / CashDocumentHeaderCZP."Currency Factor");
                    "VAT Amount (LCY)" := Round("VAT Amount" / CashDocumentHeaderCZP."Currency Factor");
                end;

                "VAT Base Amount" := "Amount Including VAT" - "VAT Amount";
                "VAT Base Amount (LCY)" := "Amount Including VAT (LCY)" - "VAT Amount (LCY)";
                "VAT Difference" := 0;
            end;
        }
        field(53; "VAT Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                GeneralLedgerSetup.Get();
                GetCashDocumentHeaderCZP();
                CashDeskCZP.Get("Cash Desk No.");

                if CurrFieldNo = FieldNo("VAT Amount") then
                    CashDeskCZP.TestField("Allow VAT Difference");

                if not ("VAT Calculation Type" in
                        ["VAT Calculation Type"::"Normal VAT", "VAT Calculation Type"::"Reverse Charge VAT"])
                then
                    Error(
                      MustBeErr, FieldCaption("VAT Calculation Type"),
                      "VAT Calculation Type"::"Normal VAT", "VAT Calculation Type"::"Reverse Charge VAT");
                if "VAT Amount" <> 0 then begin
                    TestField("VAT %");
                    TestField("VAT Base Amount");
                end;

                "VAT Amount" := Round("VAT Amount", Currency."Amount Rounding Precision", Currency.VATRoundingDirection());
                if "VAT Amount" * "VAT Base Amount" < 0 then begin
                    if "VAT Amount" > 0 then
                        Error(MustBeNegativeErr, FieldCaption("VAT Amount"));
                    Error(MustBePositiveErr, FieldCaption("VAT Amount"));
                end;

                if CashDocumentHeaderCZP."Currency Code" = '' then begin
                    "VAT Amount (LCY)" := "VAT Amount";
                    if CashDocumentHeaderCZP."Amounts Including VAT" then
                        "Amount Including VAT (LCY)" := "Amount Including VAT"
                    else
                        "VAT Base Amount (LCY)" := "VAT Base Amount";
                end else begin
                    "VAT Amount (LCY)" := Round("VAT Amount" / CashDocumentHeaderCZP."Currency Factor");
                    if CashDocumentHeaderCZP."Amounts Including VAT" then
                        "Amount Including VAT (LCY)" := Round("Amount Including VAT" / CashDocumentHeaderCZP."Currency Factor")
                    else
                        "VAT Base Amount (LCY)" := Round("VAT Base Amount" / CashDocumentHeaderCZP."Currency Factor");
                end;

                if CashDocumentHeaderCZP."Amounts Including VAT" then begin
                    "VAT Base Amount" := "Amount Including VAT" - "VAT Amount";
                    "VAT Base Amount (LCY)" := "Amount Including VAT (LCY)" - "VAT Amount (LCY)";
                end else begin
                    "Amount Including VAT" := "VAT Base Amount" + "VAT Amount";
                    "Amount Including VAT (LCY)" := "VAT Base Amount (LCY)" + "VAT Amount (LCY)";
                end;
                "VAT Difference" := "VAT Amount" - CalcVATAmount();

                ValidateNonDeductibleVATPct();

                if CurrFieldNo = FieldNo("VAT Amount") then
                    if Abs("VAT Difference") > Currency."Max. VAT Difference Allowed" then
                        Error(MustNotBeMoreThanErr, FieldCaption("VAT Difference"), Currency."Max. VAT Difference Allowed");
            end;
        }
        field(55; "VAT Base Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'VAT Base Amount (LCY)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(56; "Amount Including VAT (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount Including VAT (LCY)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(57; "VAT Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'VAT Amount (LCY)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(59; "VAT Difference"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Difference';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(60; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DecimalPlaces = 0 : 5;
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(61; "VAT Identifier"; Code[20])
        {
            Caption = 'VAT Identifier';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(62; "VAT Difference (LCY)"; Decimal)
        {
            Caption = 'VAT Difference (LCY)';
            DataClassification = CustomerContent;
            ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
#if CLEAN25
            ObsoleteState = Removed;
            ObsoleteTag = '28.0';
#else
            ObsoleteState = Pending;
            ObsoleteTag = '18.0';
#endif
        }
        field(63; "System-Created Entry"; Boolean)
        {
            Caption = 'System-Created Entry';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(65; "Gen. Posting Type"; Enum "General Posting Type")
        {
            Caption = 'Gen. Posting Type';
            DataClassification = CustomerContent;
        }
        field(70; "VAT Calculation Type"; Enum "Tax Calculation Type")
        {
            Caption = 'VAT Calculation Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(71; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate("VAT Prod. Posting Group");
            end;
        }
        field(72; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if VATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group") then begin
                    "VAT %" := VATPostingSetup."VAT %";
                    "VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
                    "VAT Identifier" := VATPostingSetup."VAT Identifier";
                    case "VAT Calculation Type" of
                        "VAT Calculation Type"::"Reverse Charge VAT",
                        "VAT Calculation Type"::"Sales Tax":
                            "VAT %" := 0;
                        "VAT Calculation Type"::"Full VAT":
                            begin
                                TestField("Account Type", "Account Type"::"G/L Account");
                                VATPostingSetup.TestField("Sales VAT Account");
                                TestField("Account No.", VATPostingSetup."Sales VAT Account");
                            end;
                    end;
                end else begin
                    "VAT %" := 0;
                    "VAT Calculation Type" := "VAT Calculation Type"::"Normal VAT";
                    "VAT Identifier" := '';
                end;
                Validate(Amount);
            end;
        }
        field(75; "Use Tax"; Boolean)
        {
            Caption = 'Use Tax';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Gen. Posting Type", "Gen. Posting Type"::Purchase);
            end;
        }
        field(90; "FA Posting Type"; Enum "Cash Document FA Post.Type CZP")
        {
            Caption = 'FA Posting Type';
            DataClassification = CustomerContent;
        }
        field(91; "Depreciation Book Code"; Code[10])
        {
            Caption = 'Depreciation Book Code';
            TableRelation = "Depreciation Book";
            DataClassification = CustomerContent;
        }
        field(92; "Maintenance Code"; Code[10])
        {
            Caption = 'Maintenance Code';
            TableRelation = Maintenance;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Maintenance Code" <> '' then
                    TestField("FA Posting Type", "FA Posting Type"::Maintenance);
            end;
        }
        field(93; "Duplicate in Depreciation Book"; Code[10])
        {
            Caption = 'Duplicate in Depreciation Book';
            TableRelation = "Depreciation Book";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Use Duplication List" := false;
            end;
        }
        field(94; "Use Duplication List"; Boolean)
        {
            Caption = 'Use Duplication List';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Duplicate in Depreciation Book" := '';
            end;
        }
        field(98; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            Editable = false;
            TableRelation = "Responsibility Center";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CreateDimFromDefaultDim(Rec.FieldNo("Responsibility Center"));
            end;
        }
        field(101; "EET Transaction"; Boolean)
        {
            Caption = 'EET Transaction';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(110; "Non-Deductible VAT %"; Decimal)
        {
            Caption = 'Non-Deductible VAT %';
            DecimalPlaces = 0 : 5;
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateNonDeductibleVAT();
            end;
        }
        field(111; "Non-Deductible VAT Base"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Non-Deductible VAT Base';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(112; "Non-Deductible VAT Amount"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Non-Deductible VAT Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(113; "Non-Deductible VAT Base LCY"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Non-Deductible VAT Base LCY';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(114; "Non-Deductible VAT Amount LCY"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Non-Deductible VAT Amount LCY';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(115; "Non-Deductible VAT Base ACY"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Non-Deductible VAT Base ACY';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(116; "Non-Deductible VAT Amount ACY"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Non-Deductible VAT Amount ACY';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(117; "Non-Deductible VAT Diff."; Decimal)
        {
            Caption = 'Non-Deductible VAT Difference';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                ShowDimensions();
            end;

            trigger OnValidate()
            begin
                DimensionManagement.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            end;
        }
        field(2675; "Selected Alloc. Account No."; Code[20])
        {
            Caption = 'Allocation Account No.';
            DataClassification = CustomerContent;
            TableRelation = "Allocation Account";
        }
        field(2677; "Alloc. Acc. Modified by User"; Boolean)
        {
            Caption = 'Allocation Account Distributions Modified';
            FieldClass = FlowField;
            CalcFormula = exist("Alloc. Acc. Manual Override" where("Parent System Id" = field(SystemId), "Parent Table Id" = const(Database::"Cash Document Line CZP")));
        }
        field(2678; "Allocation Account No."; Code[20])
        {
            Caption = 'Posting Allocation Account No.';
            DataClassification = CustomerContent;
            TableRelation = "Allocation Account";
        }
        field(31001; "Advance Letter Link Code"; Code[30])
        {
            Caption = 'Advance Letter Link Code';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Remove after Advance Payment Localization for Czech will be implemented.';
            ObsoleteTag = '22.0';

            trigger OnValidate()
            begin
                UpdateEETTransaction();
            end;
        }
    }

    keys
    {
        key(Key1; "Cash Desk No.", "Cash Document No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Cash Desk No.", "Cash Document No.", "External Document No.", "VAT Identifier")
        {
            SumIndexFields = Amount, "Amount (LCY)", "Amount Including VAT", "Amount Including VAT (LCY)", "VAT Base Amount", "VAT Base Amount (LCY)", "VAT Amount", "VAT Amount (LCY)";
        }
    }

    trigger OnInsert()
    begin
        LockTable();
        InitRecord();
        UpdateEETTransaction();
    end;

    trigger OnModify()
    begin
        UpdateEETTransaction();
    end;

    trigger OnRename()
    begin
        Error(RenameErr, TableCaption);
    end;

    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        Currency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        CashDeskCZP: Record "Cash Desk CZP";
        CashDeskEventCZP: Record "Cash Desk Event CZP";
        TempCashDocumentLineCZP: Record "Cash Document Line CZP" temporary;
        FixedAsset: Record "Fixed Asset";
        DimensionManagement: Codeunit DimensionManagement;
        ConfirmManagement: Codeunit "Confirm Management";
        RenameErr: Label 'You cannot rename a %1.', Comment = '%1 = TableCaption';
        LookupConfirmQst: Label 'The %1 in the %2 will be changed from %3 to %4.\Do you wish to continue?', Comment = '%1 = Currency Code FieldCaption, %2 = Gen. Jnl. Line TableCaption, %3 = Old Currency Code, %4 = New Currency Code';
        UpdateInteruptedErr: Label 'The update has been interrupted to respect the warning.';
        MustBeNegativeErr: Label '%1 must be negative.', Comment = '%1 = VAT Amount FieldCaption';
        MustBePositiveErr: Label '%1 must be positive.', Comment = '%1 = VAT Amount FieldCaption';
        MustBeErr: Label '%1 must be %2 or %3.', Comment = '%1 = VAT Calculation Type FiledCaption, %2 = "VAT Calculation Type"::"Normal VAT", %3 = "VAT Calculation Type"::"Reverse Charge VAT"';
        MustNotBeMoreThanErr: Label 'The %1 must not be more than %2.', Comment = '%1 = VAT Difference FieldCaption, %2 = Max. VAT Difference Allowed';
        MustBeZeroErr: Label ' must be 0 when %1 is %2.', Comment = ' %1 = "VAT Calculation Type FieldCaption, %2 = VAT Calculation Type';
        HideValidationDialog: Boolean;

    procedure InitRecord()
    begin
        GetCashDocumentHeaderCZP();
        "Cash Desk No." := CashDocumentHeaderCZP."Cash Desk No.";
        "Document Type" := CashDocumentHeaderCZP."Document Type";
    end;

    procedure ShowDimensions()
    var
        IsHandled: Boolean;
        ThreePlacehodersTok: Label '%1 %2 %3', Locked = true;
    begin
        IsHandled := false;
        OnBeforeShowDimensions(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        "Dimension Set ID" := DimensionManagement.EditDimensionSet("Dimension Set ID", StrSubstNo(ThreePlacehodersTok, TableCaption, "Cash Document No.", "Line No."));
        DimensionManagement.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    procedure CreateDimFromDefaultDim(FieldNo: Integer)
    var
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        InitDefaultDimensionSources(DefaultDimSource, FieldNo);
        CreateDim(DefaultDimSource);
    end;

    local procedure InitDefaultDimensionSources(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; FieldNo: Integer)
    begin
        DimensionManagement.AddDimSource(DefaultDimSource, TypeToTableID("Account Type".AsInteger()), Rec."Account No.", FieldNo = Rec.FieldNo("Account No."));
        DimensionManagement.AddDimSource(DefaultDimSource, Database::"Salesperson/Purchaser", Rec."Salespers./Purch. Code", FieldNo = Rec.FieldNo("Salespers./Purch. Code"));
        DimensionManagement.AddDimSource(DefaultDimSource, Database::"Responsibility Center", Rec."Responsibility Center", FieldNo = Rec.FieldNo("Responsibility Center"));
        DimensionManagement.AddDimSource(DefaultDimSource, Database::"Cash Desk Event CZP", Rec."Cash Desk Event", FieldNo = Rec.FieldNo("Cash Desk Event"));

        OnAfterInitDefaultDimensionSources(Rec, DefaultDimSource);
    end;

    procedure CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    var
        SourceCodeSetup: Record "Source Code Setup";
        OldDimSetID: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateDim(Rec, IsHandled);
        if IsHandled then
            exit;

        SourceCodeSetup.Get();
        GetCashDocumentHeaderCZP();
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" := DimensionManagement.GetRecDefaultDimID(Rec, CurrFieldNo, DefaultDimSource, SourceCodeSetup."Cash Desk CZP",
                                "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", CashDocumentHeaderCZP."Dimension Set ID", 0);
        DimensionManagement.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");

        OnAfterCreateDim(Rec, xRec, CurrFieldNo, OldDimSetID);
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimensionManagement.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

    procedure LookupShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimensionManagement.LookupDimValueCode(FieldNumber, ShortcutDimCode);
        ValidateShortcutDimCode(FieldNumber, ShortcutDimCode);
    end;

    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    begin
        DimensionManagement.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode);
    end;

    procedure GetCashDocumentHeaderCZP()
    begin
        TestField("Cash Desk No.");
        TestField("Cash Document No.");
        if ("Cash Desk No." <> CashDocumentHeaderCZP."Cash Desk No.") or ("Cash Document No." <> CashDocumentHeaderCZP."No.") then begin
            CashDocumentHeaderCZP.Get("Cash Desk No.", "Cash Document No.");
            if CashDocumentHeaderCZP."Currency Code" = '' then
                Currency.InitRoundingPrecision()
            else begin
                CashDocumentHeaderCZP.TestField("Currency Factor");
                Currency.Get(CashDocumentHeaderCZP."Currency Code");
                Currency.TestField("Amount Rounding Precision");
            end;
        end;

        CashDocumentHeaderCZP.SetHideValidationDialog(HideValidationDialog);
    end;

    procedure UpdateAmounts()
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        GenJournalLine: Record "Gen. Journal Line";
        CashDocumentPostCZP: Codeunit "Cash Document-Post CZP";
        PaymentToleranceManagement: Codeunit "Payment Tolerance Management";
    begin
        GetCashDocumentHeaderCZP();

        if CashDocumentHeaderCZP."Currency Code" <> '' then
            "Amount (LCY)" := Round(CurrencyExchangeRate.ExchangeAmtFCYToLCY(CashDocumentHeaderCZP."Posting Date", CashDocumentHeaderCZP."Currency Code",
                  Amount, CashDocumentHeaderCZP."Currency Factor"))
        else
            "Amount (LCY)" := Round(Amount);

        if CashDocumentHeaderCZP."Amounts Including VAT" then
            Validate("Amount Including VAT", Amount)
        else
            Validate("VAT Base Amount", Amount);

        ValidateNonDeductibleVATPct();

        if (Amount <> xRec.Amount) and (xRec.Amount <> 0) or (xRec."Applies-To Doc. No." <> '') or (xRec."Applies-to ID" <> '') then begin
            CashDocumentPostCZP.InitGenJnlLine(CashDocumentHeaderCZP, Rec);
            CashDocumentPostCZP.GetGenJnlLine(GenJournalLine);
            PaymentToleranceManagement.SetSuppressCommit(true);
            PaymentToleranceManagement.PmtTolGenJnl(GenJournalLine);
        end;
    end;

    procedure UpdateDocumentType()
    var
        IsHandled: Boolean;
    begin
        OnBeforeUpdateDocumenType(Rec, IsHandled);
        if IsHandled then
            exit;
        "Gen. Document Type" := "Gen. Document Type"::" ";
        if not ("Account Type" in ["Account Type"::Customer, "Account Type"::Vendor]) then
            exit;
        if (("Document Type" = "Document Type"::Receipt) and ("Account Type" = "Account Type"::Customer)) or
           (("Document Type" = "Document Type"::Withdrawal) and ("Account Type" = "Account Type"::Vendor))
        then
            "Gen. Document Type" := "Gen. Document Type"::Payment;
        if (("Document Type" = "Document Type"::Withdrawal) and ("Account Type" = "Account Type"::Customer)) or
           (("Document Type" = "Document Type"::Receipt) and ("Account Type" = "Account Type"::Vendor))
        then
            "Gen. Document Type" := "Gen. Document Type"::Refund;
        OnAfterUpdateDocumentType(Rec);
    end;

    procedure SignAmount() Sign: Integer
    begin
        Sign := 1;
        if "Document Type" = "Document Type"::Receipt then
            Sign := -1;
        OnAfterSignAmount(Rec, Sign);
    end;

    procedure ApplyEntries()
    var
        GenJournalLine: Record "Gen. Journal Line";
        CashDocumentPostCZP: Codeunit "Cash Document-Post CZP";
        ManualCrossAppHandlerCZP: Codeunit "Manual Cross App. Handler CZP";
    begin
        CashDocumentHeaderCZP.Get("Cash Desk No.", "Cash Document No.");
        if "Account Type" = "Account Type"::Customer then
            CashDocumentHeaderCZP.TestNotEETCashRegister();
        CashDocumentPostCZP.InitGenJnlLine(CashDocumentHeaderCZP, Rec);
        CashDocumentPostCZP.GetGenJnlLine(GenJournalLine);
        BindSubscription(ManualCrossAppHandlerCZP);
        Codeunit.Run(Codeunit::"Gen. Jnl.-Apply", GenJournalLine);
        "Applies-to ID" := ManualCrossAppHandlerCZP.GetAppliesToID();
        UnbindSubscription(ManualCrossAppHandlerCZP);
        if "Applies-to ID" = '' then
            "Applies-to ID" := GenJournalLine."Applies-to ID";
        if Amount = 0 then
            if CashDocumentHeaderCZP."Amounts Including VAT" then
                Validate(Amount, SignAmount() * GenJournalLine.Amount)
            else
                Validate(Amount, SignAmount() * GenJournalLine.Amount * (1 - "VAT %" / (100 + "VAT %")));
        Modify();
    end;

    local procedure GetAmtToApplyCust(CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line"): Decimal
    var
        PaymentToleranceManagement: Codeunit "Payment Tolerance Management";
    begin
        CustLedgerEntry.CalcFields("Remaining Amount");
        if PaymentToleranceManagement.CheckCalcPmtDiscGenJnlCust(GenJournalLine, CustLedgerEntry, 0, false) then
            if (CustLedgerEntry."Amount to Apply" = 0) or
               (Abs(CustLedgerEntry."Amount to Apply") >= Abs(CustLedgerEntry."Remaining Amount" - CustLedgerEntry."Remaining Pmt. Disc. Possible"))
            then
                exit(-CustLedgerEntry."Remaining Amount" + CustLedgerEntry."Remaining Pmt. Disc. Possible");
        if CustLedgerEntry."Amount to Apply" = 0 then
            exit(-CustLedgerEntry."Remaining Amount");
        exit(-CustLedgerEntry."Amount to Apply");
    end;

    local procedure GetAmtToApplyCust(GenJournalLine: Record "Gen. Journal Line"): Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PaymentToleranceManagement: Codeunit "Payment Tolerance Management";
    begin
        CustLedgerEntry.SetRange("Document No.", GenJournalLine."Applies-to Doc. No.");
        CustLedgerEntry.SetRange(Open, true);
        if not CustLedgerEntry.FindFirst() then
            exit(0);

        CustLedgerEntry.CalcFields("Remaining Amount");
        if PaymentToleranceManagement.CheckCalcPmtDiscGenJnlCust(GenJournalLine, CustLedgerEntry, 0, false) then
            if (CustLedgerEntry."Amount to Apply" = 0) or
               (Abs(CustLedgerEntry."Amount to Apply") >= Abs(CustLedgerEntry."Remaining Amount" - CustLedgerEntry."Remaining Pmt. Disc. Possible"))
            then
                exit(-CustLedgerEntry."Remaining Amount" + CustLedgerEntry."Remaining Pmt. Disc. Possible");
        if CustLedgerEntry."Amount to Apply" = 0 then
            exit(-CustLedgerEntry."Remaining Amount");
        exit(-CustLedgerEntry."Amount to Apply");
    end;

    local procedure GetAmtToApplyVend(VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line"): Decimal
    var
        PaymentToleranceManagement: Codeunit "Payment Tolerance Management";
    begin
        VendorLedgerEntry.CalcFields("Remaining Amount");
        if PaymentToleranceManagement.CheckCalcPmtDiscGenJnlVend(GenJournalLine, VendorLedgerEntry, 0, false) then
            if (VendorLedgerEntry."Amount to Apply" = 0) or
               (Abs(VendorLedgerEntry."Amount to Apply") >= Abs(VendorLedgerEntry."Remaining Amount" - VendorLedgerEntry."Remaining Pmt. Disc. Possible"))
            then
                exit(-VendorLedgerEntry."Remaining Amount" + VendorLedgerEntry."Remaining Pmt. Disc. Possible");
        if VendorLedgerEntry."Amount to Apply" = 0 then
            exit(-VendorLedgerEntry."Remaining Amount");
        exit(-VendorLedgerEntry."Amount to Apply");
    end;

    local procedure GetAmtToApplyVend(GenJournalLine: Record "Gen. Journal Line"): Decimal
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PaymentToleranceManagement: Codeunit "Payment Tolerance Management";
    begin
        VendorLedgerEntry.SetRange("Document No.", GenJournalLine."Applies-to Doc. No.");
        VendorLedgerEntry.SetRange(Open, true);
        if not VendorLedgerEntry.FindFirst() then
            exit(0);

        VendorLedgerEntry.CalcFields("Remaining Amount");
        if PaymentToleranceManagement.CheckCalcPmtDiscGenJnlVend(GenJournalLine, VendorLedgerEntry, 0, false) then
            if (VendorLedgerEntry."Amount to Apply" = 0) or
               (Abs(VendorLedgerEntry."Amount to Apply") >= Abs(VendorLedgerEntry."Remaining Amount" - VendorLedgerEntry."Remaining Pmt. Disc. Possible"))
            then
                exit(-VendorLedgerEntry."Remaining Amount" + VendorLedgerEntry."Remaining Pmt. Disc. Possible");
        if VendorLedgerEntry."Amount to Apply" = 0 then
            exit(-VendorLedgerEntry."Remaining Amount");
        exit(-VendorLedgerEntry."Amount to Apply");
    end;

    local procedure GetAmtToApplyEmpl(EmployeeLedgerEntry: Record "Employee Ledger Entry"): Decimal
    begin
        EmployeeLedgerEntry.CalcFields("Remaining Amount");
        if EmployeeLedgerEntry."Amount to Apply" = 0 then
            exit(-EmployeeLedgerEntry."Remaining Amount");
        exit(-EmployeeLedgerEntry."Amount to Apply");
    end;

    local procedure GetAmtToApplyEmpl(GenJournalLine: Record "Gen. Journal Line"): Decimal
    var
        EmployeeLedgerEntry: Record "Employee Ledger Entry";
    begin
        EmployeeLedgerEntry.SetRange("Document No.", GenJournalLine."Applies-to Doc. No.");
        EmployeeLedgerEntry.SetRange(Open, true);
        if not EmployeeLedgerEntry.FindFirst() then
            exit(0);

        EmployeeLedgerEntry.CalcFields("Remaining Amount");
        if EmployeeLedgerEntry."Amount to Apply" = 0 then
            exit(-EmployeeLedgerEntry."Remaining Amount");
        exit(-EmployeeLedgerEntry."Amount to Apply");
    end;

    local procedure SetAppliesToFiltersCust(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line"; AccNo: Code[20])
    begin
        CustLedgerEntry.SetCurrentKey("Customer No.", Open, Positive, "Due Date");
        if AccNo <> '' then
            CustLedgerEntry.SetRange("Customer No.", AccNo);
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetRange("Currency Code", GenJournalLine."Currency Code");
        if GenJournalLine."Applies-to Doc. No." <> '' then begin
            CustLedgerEntry.SetRange("Document Type", GenJournalLine."Applies-to Doc. Type");
            CustLedgerEntry.SetRange("Document No.", GenJournalLine."Applies-to Doc. No.");
            if not CustLedgerEntry.FindFirst() then begin
                CustLedgerEntry.SetRange("Document Type");
                CustLedgerEntry.SetRange("Document No.");
            end;
        end;
        if GenJournalLine."Applies-to ID" <> '' then begin
            CustLedgerEntry.SetRange("Applies-to ID", GenJournalLine."Applies-to ID");
            if not CustLedgerEntry.FindFirst() then
                CustLedgerEntry.SetRange("Applies-to ID");
        end;
        if GenJournalLine."Applies-to Doc. Type" <> GenJournalLine."Applies-to Doc. Type"::" " then begin
            CustLedgerEntry.SetRange("Document Type", GenJournalLine."Applies-to Doc. Type");
            if not CustLedgerEntry.FindFirst() then
                CustLedgerEntry.SetRange("Document Type");
        end;
        if GenJournalLine."Applies-to Doc. No." <> '' then begin
            CustLedgerEntry.SetRange("Document No.", GenJournalLine."Applies-to Doc. No.");
            if not CustLedgerEntry.FindFirst() then
                CustLedgerEntry.SetRange("Document No.");
        end;
        if GenJournalLine.Amount <> 0 then begin
            CustLedgerEntry.SetRange(Positive, GenJournalLine.Amount < 0);
            if CustLedgerEntry.FindFirst() then;
            CustLedgerEntry.SetRange(Positive);
        end;
    end;

    local procedure SetAppliesToFiltersVend(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line"; AccNo: Code[20])
    begin
        VendorLedgerEntry.SetCurrentKey("Vendor No.", Open, Positive, "Due Date");
        if AccNo <> '' then
            VendorLedgerEntry.SetRange("Vendor No.", AccNo);
        VendorLedgerEntry.SetRange(Open, true);
        VendorLedgerEntry.SetRange("Currency Code", GenJournalLine."Currency Code");
        if GenJournalLine."Applies-to Doc. No." <> '' then begin
            VendorLedgerEntry.SetRange("Document Type", GenJournalLine."Applies-to Doc. Type");
            VendorLedgerEntry.SetRange("Document No.", GenJournalLine."Applies-to Doc. No.");
            if not VendorLedgerEntry.FindFirst() then begin
                VendorLedgerEntry.SetRange("Document Type");
                VendorLedgerEntry.SetRange("Document No.");
            end;
        end;
        if GenJournalLine."Applies-to ID" <> '' then begin
            VendorLedgerEntry.SetRange("Applies-to ID", GenJournalLine."Applies-to ID");
            if not VendorLedgerEntry.FindFirst() then
                VendorLedgerEntry.SetRange("Applies-to ID");
        end;
        if GenJournalLine."Applies-to Doc. Type" <> GenJournalLine."Applies-to Doc. Type"::" " then begin
            VendorLedgerEntry.SetRange("Document Type", GenJournalLine."Applies-to Doc. Type");
            if not VendorLedgerEntry.FindFirst() then
                VendorLedgerEntry.SetRange("Document Type");
        end;
        if GenJournalLine."Applies-to Doc. No." <> '' then begin
            VendorLedgerEntry.SetRange("Document No.", GenJournalLine."Applies-to Doc. No.");
            if not VendorLedgerEntry.FindFirst() then
                VendorLedgerEntry.SetRange("Document No.");
        end;
        if GenJournalLine.Amount <> 0 then begin
            VendorLedgerEntry.SetRange(Positive, GenJournalLine.Amount < 0);
            if VendorLedgerEntry.FindFirst() then;
            VendorLedgerEntry.SetRange(Positive);
        end;
    end;

    local procedure SetAppliesToFiltersEmpl(var EmployeeLedgerEntry: Record "Employee Ledger Entry"; GenJournalLine: Record "Gen. Journal Line"; AccNo: Code[20])
    begin
        EmployeeLedgerEntry.SetCurrentKey("Employee No.", "Applies-to ID", Open, Positive);
        if AccNo <> '' then
            EmployeeLedgerEntry.SetRange("Employee No.", AccNo);
        EmployeeLedgerEntry.SetRange(Open, true);
        EmployeeLedgerEntry.SetRange("Currency Code", GenJournalLine."Currency Code");
        if GenJournalLine."Applies-to Doc. No." <> '' then begin
            EmployeeLedgerEntry.SetRange("Document Type", GenJournalLine."Applies-to Doc. Type");
            EmployeeLedgerEntry.SetRange("Document No.", GenJournalLine."Applies-to Doc. No.");
            if not EmployeeLedgerEntry.FindFirst() then begin
                EmployeeLedgerEntry.SetRange("Document Type");
                EmployeeLedgerEntry.SetRange("Document No.");
            end;
        end;
        if GenJournalLine."Applies-to ID" <> '' then begin
            EmployeeLedgerEntry.SetRange("Applies-to ID", GenJournalLine."Applies-to ID");
            if not EmployeeLedgerEntry.FindFirst() then
                EmployeeLedgerEntry.SetRange("Applies-to ID");
        end;
        if GenJournalLine."Applies-to Doc. Type" <> GenJournalLine."Applies-to Doc. Type"::" " then begin
            EmployeeLedgerEntry.SetRange("Document Type", GenJournalLine."Applies-to Doc. Type");
            if not EmployeeLedgerEntry.FindFirst() then
                EmployeeLedgerEntry.SetRange("Document Type");
        end;
        if GenJournalLine."Applies-to Doc. No." <> '' then begin
            EmployeeLedgerEntry.SetRange("Document No.", GenJournalLine."Applies-to Doc. No.");
            if not EmployeeLedgerEntry.FindFirst() then
                EmployeeLedgerEntry.SetRange("Document No.");
        end;
        if GenJournalLine.Amount <> 0 then begin
            EmployeeLedgerEntry.SetRange(Positive, GenJournalLine.Amount < 0);
            if EmployeeLedgerEntry.FindFirst() then;
            EmployeeLedgerEntry.SetRange(Positive);
        end;
    end;

    local procedure LookupApplyCustEntry(var GenJournalLine: Record "Gen. Journal Line"; AccNo: Code[20])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GenJnlApply: Codeunit "Gen. Jnl.-Apply";
        ApplyCustomerEntries: Page "Apply Customer Entries";
    begin
        Clear(CustLedgerEntry);
        SetAppliesToFiltersCust(CustLedgerEntry, GenJournalLine, AccNo);
        ApplyCustomerEntries.SetGenJnlLine(GenJournalLine, GenJournalLine.FieldNo("Applies-to Doc. No."));
        ApplyCustomerEntries.SetTableView(CustLedgerEntry);
        ApplyCustomerEntries.SetRecord(CustLedgerEntry);
        ApplyCustomerEntries.LookupMode(true);
        if ApplyCustomerEntries.RunModal() = Action::LookupOK then begin
            ApplyCustomerEntries.GetRecord(CustLedgerEntry);
            if GenJournalLine."Currency Code" <> CustLedgerEntry."Currency Code" then
                if GenJournalLine.Amount = 0 then begin
                    if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(LookupConfirmQst,
                                                                    GenJournalLine.FieldCaption("Currency Code"), GenJournalLine.TableCaption,
                                                                    GenJournalLine.GetShowCurrencyCode(GenJournalLine."Currency Code"),
                                                                    GenJournalLine.GetShowCurrencyCode(CustLedgerEntry."Currency Code")), true)
                    then
                        Error(UpdateInteruptedErr);
                    GenJournalLine.Validate("Currency Code", CustLedgerEntry."Currency Code");
                end else
                    GenJnlApply.CheckAgainstApplnCurrency(
                      GenJournalLine."Currency Code", CustLedgerEntry."Currency Code",
                      GenJournalLine."Account Type"::Customer, true);
            if Amount = 0 then
                GenJournalLine.Validate(Amount, GetAmtToApplyCust(CustLedgerEntry, GenJournalLine));
            if AccNo = '' then
                GenJournalLine.Validate("Account No.", CustLedgerEntry."Customer No.");
            GenJournalLine."Applies-to Doc. Type" := CustLedgerEntry."Document Type";
            GenJournalLine."Applies-to Doc. No." := CustLedgerEntry."Document No.";
            GenJournalLine."Applies-to ID" := '';
        end;
        Clear(ApplyCustomerEntries);
    end;

    local procedure LookupApplyVendEntry(var GenJournalLine: Record "Gen. Journal Line"; AccNo: Code[20])
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        GenJnlApply: Codeunit "Gen. Jnl.-Apply";
        ApplyVendorEntries: Page "Apply Vendor Entries";
    begin
        Clear(VendorLedgerEntry);
        SetAppliesToFiltersVend(VendorLedgerEntry, GenJournalLine, AccNo);
        ApplyVendorEntries.SetGenJnlLine(GenJournalLine, GenJournalLine.FieldNo("Applies-to Doc. No."));
        ApplyVendorEntries.SetTableView(VendorLedgerEntry);
        ApplyVendorEntries.SetRecord(VendorLedgerEntry);
        ApplyVendorEntries.LookupMode(true);
        if ApplyVendorEntries.RunModal() = Action::LookupOK then begin
            ApplyVendorEntries.GetRecord(VendorLedgerEntry);
            if GenJournalLine."Currency Code" <> VendorLedgerEntry."Currency Code" then
                if GenJournalLine.Amount = 0 then begin
                    if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(LookupConfirmQst,
                                                                    GenJournalLine.FieldCaption("Currency Code"), GenJournalLine.TableCaption,
                                                                    GenJournalLine.GetShowCurrencyCode(GenJournalLine."Currency Code"),
                                                                    GenJournalLine.GetShowCurrencyCode(VendorLedgerEntry."Currency Code")), true)
                    then
                        Error(UpdateInteruptedErr);
                    GenJournalLine.Validate("Currency Code", VendorLedgerEntry."Currency Code");
                end else
                    GenJnlApply.CheckAgainstApplnCurrency(
                      GenJournalLine."Currency Code", VendorLedgerEntry."Currency Code",
                      GenJournalLine."Account Type"::Vendor, true);
            if Amount = 0 then
                GenJournalLine.Validate(Amount, GetAmtToApplyVend(VendorLedgerEntry, GenJournalLine));
            if AccNo = '' then
                GenJournalLine.Validate("Account No.", VendorLedgerEntry."Vendor No.");
            GenJournalLine."Applies-to Doc. Type" := VendorLedgerEntry."Document Type";
            GenJournalLine."Applies-to Doc. No." := VendorLedgerEntry."Document No.";
            GenJournalLine."Applies-to ID" := '';
        end;
        Clear(ApplyVendorEntries);
    end;

    local procedure LookupApplyEmplEntry(var GenJournalLine: Record "Gen. Journal Line"; AccNo: Code[20])
    var
        EmployeeLedgerEntry: Record "Employee Ledger Entry";
        GenJnlApply: Codeunit "Gen. Jnl.-Apply";
        ApplyEmployeeEntries: Page "Apply Employee Entries";
    begin
        Clear(EmployeeLedgerEntry);
        SetAppliesToFiltersEmpl(EmployeeLedgerEntry, GenJournalLine, AccNo);
        ApplyEmployeeEntries.SetGenJnlLine(GenJournalLine, GenJournalLine.FieldNo("Applies-to Doc. No."));
        ApplyEmployeeEntries.SetTableView(EmployeeLedgerEntry);
        ApplyEmployeeEntries.SetRecord(EmployeeLedgerEntry);
        ApplyEmployeeEntries.LookupMode(true);
        if ApplyEmployeeEntries.RunModal() = Action::LookupOK then begin
            ApplyEmployeeEntries.GetRecord(EmployeeLedgerEntry);
            if GenJournalLine."Currency Code" <> EmployeeLedgerEntry."Currency Code" then
                if GenJournalLine.Amount = 0 then begin
                    if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(LookupConfirmQst,
                                                                    GenJournalLine.FieldCaption("Currency Code"), GenJournalLine.TableCaption,
                                                                    GenJournalLine.GetShowCurrencyCode(GenJournalLine."Currency Code"),
                                                                    GenJournalLine.GetShowCurrencyCode(EmployeeLedgerEntry."Currency Code")), true)
                    then
                        Error(UpdateInteruptedErr);
                    GenJournalLine.Validate("Currency Code", EmployeeLedgerEntry."Currency Code");
                end else
                    GenJnlApply.CheckAgainstApplnCurrency(
                      GenJournalLine."Currency Code", EmployeeLedgerEntry."Currency Code",
                      GenJournalLine."Account Type"::Employee, true);
            if Amount = 0 then
                GenJournalLine.Validate(Amount, GetAmtToApplyEmpl(EmployeeLedgerEntry));
            if AccNo = '' then
                GenJournalLine.Validate("Account No.", EmployeeLedgerEntry."Employee No.");
            GenJournalLine."Applies-to Doc. Type" := EmployeeLedgerEntry."Document Type";
            GenJournalLine."Applies-to Doc. No." := EmployeeLedgerEntry."Document No.";
            GenJournalLine."Applies-to ID" := '';
        end;
        Clear(ApplyEmployeeEntries);
    end;

    procedure TypeToTableID(Type: Option " ","G/L Account",Customer,Vendor,"Bank Account","Fixed Asset",Employee): Integer
    begin
        case Type of
            Type::" ":
                exit(0);
            Type::"G/L Account":
                exit(Database::"G/L Account");
            Type::Customer:
                exit(Database::Customer);
            Type::Vendor:
                exit(Database::Vendor);
            Type::"Bank Account":
                exit(Database::"Bank Account");
            Type::"Fixed Asset":
                exit(Database::"Fixed Asset");
            Type::Employee:
                exit(Database::Employee);
        end;
    end;

    local procedure GetFAPostingGroup()
    var
        PostedGLAccount: Record "G/L Account";
        FAPostingGroup: Record "FA Posting Group";
        FASetup: Record "FA Setup";
        FADepreciationBook: Record "FA Depreciation Book";
        SetFADeprBook: Record "FA Depreciation Book";
        FADeprBook: Record "FA Depreciation Book";
    begin
        if ("Account Type" <> "Account Type"::"Fixed Asset") or ("Account No." = '') then
            exit;
        if "Depreciation Book Code" = '' then begin
            FASetup.Get();
            FADepreciationBook.Reset();
            FADepreciationBook.SetRange("FA No.", "Account No.");
            FADepreciationBook.SetRange("Default FA Depreciation Book", true);

            SetFADeprBook.SetRange("FA No.", "Account No.");

            case true of
                SetFADeprBook.Count = 1:
                    begin
                        SetFADeprBook.FindFirst();
                        "Depreciation Book Code" := SetFADeprBook."Depreciation Book Code";
                    end;
                FADepreciationBook.FindFirst():
                    "Depreciation Book Code" := FADepreciationBook."Depreciation Book Code";
                FADeprBook.Get("Account No.", FASetup."Default Depr. Book"):
                    "Depreciation Book Code" := FASetup."Default Depr. Book"
                else
                    "Depreciation Book Code" := '';
            end;

            if "Depreciation Book Code" = '' then
                exit;
        end;
        if "FA Posting Type" = "FA Posting Type"::" " then
            "FA Posting Type" := "FA Posting Type"::"Acquisition Cost";
        FADepreciationBook.Get("Account No.", "Depreciation Book Code");
        FADepreciationBook.TestField("FA Posting Group");
        FAPostingGroup.Get(FADepreciationBook."FA Posting Group");
        if "FA Posting Type" = "FA Posting Type"::"Custom 2" then begin
            FAPostingGroup.TestField("Custom 2 Account");
            PostedGLAccount.Get(FAPostingGroup."Custom 2 Account");
        end else
            if "FA Posting Type" = "FA Posting Type"::"Acquisition Cost" then begin
                FAPostingGroup.TestField("Acquisition Cost Account");
                PostedGLAccount.Get(FAPostingGroup."Acquisition Cost Account");
            end;
        PostedGLAccount.CheckGLAcc();
        PostedGLAccount.TestField("Gen. Prod. Posting Group");
        "Posting Group" := FADepreciationBook."FA Posting Group";
        Validate("Gen. Posting Type", PostedGLAccount."Gen. Posting Type");
        Validate("VAT Bus. Posting Group", PostedGLAccount."VAT Bus. Posting Group");
        Validate("VAT Prod. Posting Group", PostedGLAccount."VAT Prod. Posting Group");
    end;

    procedure ExtStatistics()
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        TestField("Cash Desk No.");
        TestField("Cash Document No.");

        GetCashDocumentHeaderCZP();
        if CashDocumentHeaderCZP.Status = CashDocumentHeaderCZP.Status::Open then begin
            CashDocumentHeaderCZP.VATRounding();
            Commit();
        end;

        CashDocumentLineCZP.SetRange("Cash Desk No.", "Cash Desk No.");
        CashDocumentLineCZP.SetRange("Cash Document No.", "Cash Document No.");
        CashDocumentLineCZP.SetRange("Line No.", "Line No.");
        Page.RunModal(Page::"Cash Document Statistics CZP", CashDocumentLineCZP);
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    local procedure CalcVATAmount(): Decimal
    begin
        GetCashDocumentHeaderCZP();
        if CashDocumentHeaderCZP."Amounts Including VAT" then
            exit(Round("Amount Including VAT" * "VAT %" / (100 + "VAT %"), Currency."Amount Rounding Precision", Currency.VATRoundingDirection()));
        exit(Round("VAT Base Amount" * "VAT %" / 100, Currency."Amount Rounding Precision", Currency.VATRoundingDirection()));
    end;

    local procedure GetCashDeskEventCZP()
    begin
        if "Cash Desk Event" = '' then begin
            Clear(CashDeskEventCZP);
            exit;
        end;

        if "Cash Desk Event" <> CashDeskEventCZP.Code then
            CashDeskEventCZP.Get("Cash Desk Event");
    end;

    local procedure IsEETTransaction() EETTransaction: Boolean
    var
        IsHandled: Boolean;
    begin
        OnBeforeIsEETTransaction(Rec, EETTransaction, IsHandled);
        if IsHandled then
            exit;

        if not IsEETCashRegister() then
            exit(false);

        if "Cash Desk Event" <> '' then begin
            GetCashDeskEventCZP();
            EETTransaction := CashDeskEventCZP."EET Transaction";
        end else
            EETTransaction := IsInvoicePayment() or IsCreditMemoRefund();

        OnAfterIsEETTransaction(Rec, EETTransaction);
    end;

    local procedure IsEETCashRegister() EETCashRegister: Boolean
    var
        EETCashRegisterCZL: Record "EET Cash Register CZL";
    begin
        EETCashRegister := EETCashRegisterCZL.FindByCashRegisterNo("EET Cash Register Type CZL"::"Cash Desk", "Cash Desk No.");
        OnAfterIsEETCashRegister(Rec, EETCashRegister);
    end;

    procedure UpdateEETTransaction()
    begin
        if not "System-Created Entry" then
            "EET Transaction" := IsEETTransaction();
    end;

    procedure IsInvoicePayment(): Boolean
    begin
        exit(
            ("Document Type" = "Document Type"::Receipt) and
            ("Account Type" = "Account Type"::Customer) and
            ("Gen. Document Type" = "Gen. Document Type"::Payment) and
            ("Applies-To Doc. Type" = "Applies-To Doc. Type"::Invoice) and
            ("Applies-To Doc. No." <> ''));
    end;

    procedure IsCreditMemoRefund(): Boolean
    begin
        exit(
            ("Document Type" = "Document Type"::Withdrawal) and
            ("Account Type" = "Account Type"::Customer) and
            ("Gen. Document Type" = "Gen. Document Type"::Refund) and
            ("Applies-To Doc. Type" = "Applies-To Doc. Type"::"Credit Memo") and
            ("Applies-To Doc. No." <> ''));
    end;

    procedure CalcRelatedAmountToApply(): Decimal
    var
        CrossApplicationBufferCZL: Record "Cross Application Buffer CZL";
    begin
        CollectSuggestedApplication(CrossApplicationBufferCZL);
        CrossApplicationBufferCZL.CalcSums("Amount (LCY)");
        exit(SignAmount() * -CrossApplicationBufferCZL."Amount (LCY)");
    end;

    procedure DrillDownRelatedAmountToApply()
    var
        CrossApplicationBufferCZL: Record "Cross Application Buffer CZL";
    begin
        CollectSuggestedApplication(CrossApplicationBufferCZL);
        Page.Run(Page::"Cross Application CZL", CrossApplicationBufferCZL);
    end;

    local procedure CollectSuggestedApplication(var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        EmployeeLedgerEntry: Record "Employee Ledger Entry";
#if not CLEAN25
        CrossApplicationMgtCZL: Codeunit "Cross Application Mgt. CZL";
        AppliesToAdvanceLetterNo: Code[20];
#endif
    begin
        if "Account No." = '' then
            exit;

        if "Applies-to Doc. No." <> '' then
            case "Account Type" of
                "Account Type"::Customer:
                    begin
                        CustLedgerEntry.SetCurrentKey("Customer No.");
                        CustLedgerEntry.SetRange("Customer No.", "Account No.");
                        CustLedgerEntry.SetRange("Document Type", "Applies-to Doc. Type");
                        CustLedgerEntry.SetRange("Document No.", "Applies-to Doc. No.");
                        if CustLedgerEntry.FindFirst() then
                            CustLedgerEntry.CollectSuggestedApplicationCZL(Rec, CrossApplicationBufferCZL);
                    end;
                "Account Type"::Vendor:
                    begin
                        VendorLedgerEntry.SetCurrentKey("Vendor No.");
                        VendorLedgerEntry.SetRange("Vendor No.", "Account No.");
                        VendorLedgerEntry.SetRange("Document Type", "Applies-to Doc. Type");
                        VendorLedgerEntry.SetRange("Document No.", "Applies-to Doc. No.");
                        if VendorLedgerEntry.FindFirst() then
                            VendorLedgerEntry.CollectSuggestedApplicationCZL(Rec, CrossApplicationBufferCZL);
                    end;
                "Account Type"::Employee:
                    begin
                        EmployeeLedgerEntry.SetCurrentKey("Employee No.");
                        EmployeeLedgerEntry.SetRange("Employee No.", "Account No.");
                        EmployeeLedgerEntry.SetRange("Document Type", "Applies-to Doc. Type");
                        EmployeeLedgerEntry.SetRange("Document No.", "Applies-to Doc. No.");
                        if EmployeeLedgerEntry.FindFirst() then
                            EmployeeLedgerEntry.CollectSuggestedApplicationCZL(Rec, CrossApplicationBufferCZL);
                    end;
            end;
#if not CLEAN25
#pragma warning disable AL0432
        if "Account Type" = "Account Type"::Vendor then begin
            OnBeforeFindRelatedAmoutToApply(Rec, AppliesToAdvanceLetterNo);
            if AppliesToAdvanceLetterNo <> '' then
                CrossApplicationMgtCZL.OnGetSuggestedAmountForPurchAdvLetterHeader(
                    AppliesToAdvanceLetterNo, CrossApplicationBufferCZL,
                    Database::"Cash Document Line CZP", "Cash Document No.", "Line No.");
        end;
#pragma warning restore AL0432
#endif

        OnAfterCollectSuggestedApplication(Rec, CrossApplicationBufferCZL);
    end;

    local procedure ValidateNonDeductibleVATPct()
    var
        GenJournalLine: Record "Gen. Journal Line";
        NonDeductibleVAT: Codeunit "Non-Deductible VAT";
    begin
        GetCashDocumentHeaderCZP();
        InitGenJournalLine(GenJournalLine);
        NonDeductibleVAT.ValidateNonDedVATPctInGenJnlLine(GenJournalLine);
        CopyNonDeductibleVATFromGenJournalLine(GenJournalLine);
    end;

    local procedure CalculateNonDeductibleVAT()
    var
        GenJournalLine: Record "Gen. Journal Line";
        NonDeductibleVAT: Codeunit "Non-Deductible VAT";
    begin
        GetCashDocumentHeaderCZP();
        InitGenJournalLine(GenJournalLine);
        NonDeductibleVAT.Calculate(GenJournalLine, Currency);
        CopyNonDeductibleVATFromGenJournalLine(GenJournalLine);
    end;

    local procedure CopyNonDeductibleVATFromGenJournalLine(GenJournalLine: Record "Gen. Journal Line")
    begin
        "Non-Deductible VAT %" := GenJournalLine."Non-Deductible VAT %";
        "Non-Deductible VAT Base" := GenJournalLine."Non-Deductible VAT Base";
        "Non-Deductible VAT Amount" := GenJournalLine."Non-Deductible VAT Amount";
        "Non-Deductible VAT Base LCY" := GenJournalLine."Non-Deductible VAT Base LCY";
        "Non-Deductible VAT Amount LCY" := GenJournalLine."Non-Deductible VAT Amount LCY";
        "Non-Deductible VAT Base ACY" := GenJournalLine."Non-Deductible VAT Base ACY";
        "Non-Deductible VAT Amount ACY" := GenJournalLine."Non-Deductible VAT Amount ACY";
        "Non-Deductible VAT Diff." := GenJournalLine."Non-Deductible VAT Diff.";
    end;

    local procedure InitGenJournalLine(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GetCashDocumentHeaderCZP();
        GenJournalLine.Init();
        GenJournalLine."VAT Calculation Type" := "VAT Calculation Type";
        GenJournalLine."VAT Bus. Posting Group" := "VAT Bus. Posting Group";
        GenJournalLine."VAT Prod. Posting Group" := "VAT Prod. Posting Group";
        GenJournalLine."Gen. Posting Type" := "Gen. Posting Type";
        GenJournalLine."Currency Code" := CashDocumentHeaderCZP."Currency Code";
        GenJournalLine."Currency Factor" := CashDocumentHeaderCZP."Currency Factor";
        GenJournalLine."Posting Date" := CashDocumentHeaderCZP."Posting Date";
        GenJournalLine."VAT Reporting Date" := CashDocumentHeaderCZP."VAT Date";
        GenJournalLine.Amount := "Amount Including VAT";
        GenJournalLine."VAT Amount" := "VAT Amount";
        GenJournalLine."VAT Base Amount" := "VAT Base Amount";
        GenJournalLine."Non-Deductible VAT %" := "Non-Deductible VAT %";
        OnAfterInitGenJournalLine(GenJournalLine);
    end;

    local procedure CheckEmptyAccount()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckEmptyAccount(Rec, IsHandled);
        if IsHandled then
            exit;

        TestField("Account Type");
        TestField("Account No.");
    end;

    procedure GetAllocationAccount(var AllocationAccount: Record "Allocation Account"): Boolean
    begin
        if "Selected Alloc. Account No." <> '' then
            exit(AllocationAccount.Get("Selected Alloc. Account No."));

        if "Account Type" = "Account Type"::"Allocation Account" then
            exit(AllocationAccount.Get("Account No."));

        exit(false);
    end;

    local procedure CalcTotalAmounts(var TotalCashDocumentLineCZP: Record "Cash Document Line CZP")
    begin
        TotalCashDocumentLineCZP.Init();
        if ("VAT Calculation Type" = "VAT Calculation Type"::"Sales Tax") or
           (("VAT Calculation Type" in
            ["VAT Calculation Type"::"Normal VAT", "VAT Calculation Type"::"Reverse Charge VAT"]) and ("VAT %" <> 0))
        then begin
            TotalCashDocumentLineCZP.SetRange("Cash Desk No.", "Cash Desk No.");
            TotalCashDocumentLineCZP.SetRange("Cash Document No.", "Cash Document No.");
            TotalCashDocumentLineCZP.SetFilter("Line No.", '<>%1', "Line No.");
            TotalCashDocumentLineCZP.SetRange("VAT Identifier", "VAT Identifier");
            TotalCashDocumentLineCZP.SetFilter("VAT %", '<>%1', 0);
            if not TotalCashDocumentLineCZP.IsEmpty() then
                TotalCashDocumentLineCZP.CalcSums("VAT Base Amount", "Amount Including VAT", "VAT Amount");
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsEETTransaction(CashDocumentLineCZP: Record "Cash Document Line CZP"; var EETTransaction: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsEETTransaction(CashDocumentLineCZP: Record "Cash Document Line CZP"; var EETTransaction: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsEETCashRegister(CashDocumentLineCZP: Record "Cash Document Line CZP"; var EETCashRegister: Boolean)
    begin
    end;
#if not CLEAN25
    [Obsolete('The event is obsolete and will be removed in the future version. Use OnAfterCollectSuggestedApplication instead.', '25.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindRelatedAmoutToApply(CashDocumentLineCZP: Record "Cash Document Line CZP"; var AppliesToAdvanceLetterNo: Code[20]);
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateDim(var CashDocumentLineCZP: Record "Cash Document Line CZP"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDim(var CashDocumentLineCZP: Record "Cash Document Line CZP"; xCashDocumentLineCZP: Record "Cash Document Line CZP"; CurrentFieldNo: Integer; OldDimSetID: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitDefaultDimensionSources(var CashDocumentLineCZP: Record "Cash Document Line CZP"; var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnLookupAppliesToDocNoOnBeforeValidateAccountNo(var GenJournalLine: Record "Gen. Journal Line"; var CashDocumentLineCZP: Record "Cash Document Line CZP")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnValidateAppliesToDocNoOnAfterFillAppliesToDocNo(var CashDocumentLineCZP: Record "Cash Document Line CZP"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnLookupAppliesToDocNoOnAfterFillAppliesToDocNo(var CashDocumentLineCZP: Record "Cash Document Line CZP"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnValidateAccountNoOnBeforeInitRec(var Rec: Record "Cash Document Line CZP"; var xRec: Record "Cash Document Line CZP"; CurrFieldNo: Integer);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnValidateAccountNoOnAfterInitRec(var Rec: Record "Cash Document Line CZP"; var xRec: Record "Cash Document Line CZP"; TempCashDocumentLineCZP: Record "Cash Document Line CZP" temporary; var IsHandled: Boolean; var BreakValidation: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnValidateAccountNoOnBeforeProcessingAccountType(var Rec: Record "Cash Document Line CZP"; var xRec: Record "Cash Document Line CZP"; TempCashDocumentLineCZP: Record "Cash Document Line CZP" temporary; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnValidateAccountNoOnBeforeCreateDim(var Rec: Record "Cash Document Line CZP"; var xRec: Record "Cash Document Line CZP"; TempCashDocumentLineCZP: Record "Cash Document Line CZP" temporary; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLookupAppliesToDocNoOnBeforeValidateAmount(var CashDocumentLineCZP: Record "Cash Document Line CZP"; var GenJournalLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateAppliesToDocNoOnBeforeValidateAmount(var CashDocumentLineCZP: Record "Cash Document Line CZP"; var GenJournalLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateDocumenType(var CashDocumentLineCZP: Record "Cash Document Line CZP"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateDocumentType(var CashDocumentLineCZP: Record "Cash Document Line CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSignAmount(var CashDocumentLineCZP: Record "Cash Document Line CZP"; var Sign: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitGenJournalLine(var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCollectSuggestedApplication(CashDocumentLineCZP: Record "Cash Document Line CZP"; var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckEmptyAccount(CashDocumentLineCZP: Record "Cash Document Line CZP"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowDimensions(var CashDocumentLineCZP: Record "Cash Document Line CZP"; xCashDocumentLineCZP: Record "Cash Document Line CZP"; var IsHandled: Boolean)
    begin
    end;
}
