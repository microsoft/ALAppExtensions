// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.DirectDebit;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;

table 10837 "Payment Line FR"
{
    Caption = 'Payment Line';
    DrillDownPageID = "Payment Lines List FR";
    LookupPageID = "Payment Lines List FR";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = "Payment Header FR";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; Amount; Decimal)
        {
            Caption = 'Amount';
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";

            trigger OnValidate()
            var
                CurrExchRate: Record "Currency Exchange Rate";
                PaymentSubscribers: Codeunit "PaymentMgt Subscribers FR";
            begin
                if ((Amount > 0) and (not Correction)) or
                   ((Amount < 0) and Correction)
                then begin
                    "Debit Amount" := Amount;
                    "Credit Amount" := 0
                end else begin
                    "Debit Amount" := 0;
                    "Credit Amount" := -Amount;
                end;
                if "Currency Code" = '' then
                    "Amount (LCY)" := Amount
                else
                    "Amount (LCY)" := Round(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                          "Posting Date", "Currency Code",
                          Amount, "Currency Factor"));
                if Amount <> xRec.Amount then
                    PaymentSubscribers.PmtTolPaymentLine(Rec);
            end;
        }
        field(4; "Account Type"; enum "Gen. Journal Account Type")
        {
            Caption = 'Account Type';

            trigger OnValidate()
            begin
                UpdateEntry(false);
            end;
        }
        field(5; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = if ("Account Type" = const("G/L Account")) "G/L Account"
            else
            if ("Account Type" = const(Customer)) Customer
            else
            if ("Account Type" = const(Vendor)) Vendor
            else
            if ("Account Type" = const("Bank Account")) "Bank Account"
            else
            if ("Account Type" = const("Fixed Asset")) "Fixed Asset";

            trigger OnValidate()
            begin
                UpdateEntry(false);
            end;
        }
        field(6; "Posting Group"; Code[20])
        {
            Caption = 'Posting Group';
            Editable = false;
            TableRelation = if ("Account Type" = const(Customer)) "Customer Posting Group"
            else
            if ("Account Type" = const(Vendor)) "Vendor Posting Group"
            else
            if ("Account Type" = const("Fixed Asset")) "FA Posting Group";
        }
        field(7; "Copied To No."; Code[20])
        {
            Caption = 'Copied To No.';
        }
        field(8; "Copied To Line"; Integer)
        {
            Caption = 'Copied To Line';
        }
        field(9; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(10; "Acc. Type Last Entry Debit"; enum "Gen. Journal Account Type")
        {
            Caption = 'Acc. Type Last Entry Debit';
            Editable = false;
        }
        field(11; "Acc. No. Last Entry Debit"; Code[20])
        {
            Caption = 'Acc. No. Last Entry Debit';
            Editable = false;
            TableRelation = if ("Acc. Type Last Entry Debit" = const("G/L Account")) "G/L Account"
            else
            if ("Acc. Type Last Entry Debit" = const(Customer)) Customer
            else
            if ("Acc. Type Last Entry Debit" = const(Vendor)) Vendor
            else
            if ("Acc. Type Last Entry Debit" = const("Bank Account")) "Bank Account"
            else
            if ("Acc. Type Last Entry Debit" = const("Fixed Asset")) "Fixed Asset";
        }
        field(12; "Acc. Type Last Entry Credit"; enum "Gen. Journal Account Type")
        {
            Caption = 'Acc. Type Last Entry Credit';
            Editable = false;
        }
        field(13; "Acc. No. Last Entry Credit"; Code[20])
        {
            Caption = 'Acc. No. Last Entry Credit';
            Editable = false;
            TableRelation = if ("Acc. Type Last Entry Credit" = const("G/L Account")) "G/L Account"
            else
            if ("Acc. Type Last Entry Credit" = const(Customer)) Customer
            else
            if ("Acc. Type Last Entry Credit" = const(Vendor)) Vendor
            else
            if ("Acc. Type Last Entry Credit" = const("Bank Account")) "Bank Account"
            else
            if ("Acc. Type Last Entry Credit" = const("Fixed Asset")) "Fixed Asset";
        }
        field(14; "P. Group Last Entry Debit"; Code[20])
        {
            Caption = 'P. Group Last Entry Debit';
            Editable = false;
        }
        field(15; "P. Group Last Entry Credit"; Code[20])
        {
            Caption = 'P. Group Last Entry Credit';
            Editable = false;
        }
        field(16; "Payment Class"; Text[30])
        {
            Caption = 'Payment Class';
            TableRelation = "Payment Class FR";
        }
        field(17; "Status No."; Integer)
        {
            Caption = 'Status No.';
            Editable = false;
            TableRelation = "Payment Status FR".Line where("Payment Class" = field("Payment Class"));

            trigger OnValidate()
            var
                PaymentStatus: Record "Payment Status FR";
            begin
                PaymentStatus.Get("Payment Class", "Status No.");
                "Payment in Progress" := PaymentStatus."Payment in Progress";
            end;
        }
        field(18; "Status Name"; Text[50])
        {
            CalcFormula = lookup("Payment Status FR".Name where("Payment Class" = field("Payment Class"),
                                                              Line = field("Status No.")));
            Caption = 'Status Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(19; IsCopy; Boolean)
        {
            Caption = 'IsCopy';
        }
        field(20; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(21; "Entry No. Debit"; Integer)
        {
            Caption = 'Entry No. Debit';
            Editable = false;
        }
        field(22; "Entry No. Credit"; Integer)
        {
            Caption = 'Entry No. Credit';
            Editable = false;
        }
        field(23; "Entry No. Debit Memo"; Integer)
        {
            Caption = 'Entry No. Debit Memo';
            Editable = false;
        }
        field(24; "Entry No. Credit Memo"; Integer)
        {
            Caption = 'Entry No. Credit Memo';
            Editable = false;
        }
        field(25; "Bank Account Code"; Code[20])
        {
            Caption = 'Bank Account Code';
            TableRelation = if ("Account Type" = const(Customer)) "Customer Bank Account".Code where("Customer No." = field("Account No."))
            else
            if ("Account Type" = const(Vendor)) "Vendor Bank Account".Code where("Vendor No." = field("Account No."));

            trigger OnValidate()
            var
                SEPADirectDebitMandate: Record "SEPA Direct Debit Mandate";
            begin
                if "Bank Account Code" <> '' then begin
                    if "Account Type" = "Account Type"::Customer then begin
                        if SEPADirectDebitMandate.Get("Direct Debit Mandate ID") then
                            if "Bank Account Code" <> SEPADirectDebitMandate."Customer Bank Account Code" then
                                Error(BankAccErr, SEPADirectDebitMandate."Customer Bank Account Code");
                        CustomerBank.Get("Account No.", "Bank Account Code");
                        "Bank Branch No." := CustomerBank."Bank Branch No.";
                        "Bank Account No." := CustomerBank."Bank Account No.";
                        IBAN := CustomerBank.IBAN;
                        "SWIFT Code" := CustomerBank."SWIFT Code";
                        "Agency Code" := CustomerBank."Agency Code FR";
                        "Bank Account Name" := CustomerBank.Name;
                        "RIB Key" := CustomerBank."RIB Key FR";
                        "RIB Checked" := RibKey.Check("Bank Branch No.", "Agency Code", "Bank Account No.", "RIB Key");
                        "Bank City" := CustomerBank.City;
                    end else
                        if "Account Type" = "Account Type"::Vendor then begin
                            VendorBank.Get("Account No.", "Bank Account Code");
                            "Bank Branch No." := VendorBank."Bank Branch No.";
                            "Bank Account No." := VendorBank."Bank Account No.";
                            IBAN := VendorBank.IBAN;
                            "SWIFT Code" := VendorBank."SWIFT Code";
                            "Agency Code" := VendorBank."Agency Code FR";
                            "Bank Account Name" := VendorBank.Name;
                            "RIB Key" := VendorBank."RIB Key FR";
                            "RIB Checked" := RibKey.Check("Bank Branch No.", "Agency Code", "Bank Account No.", "RIB Key");
                            "Bank City" := VendorBank.City;
                        end;
                end else
                    InitBankAccount();
            end;
        }
        field(26; "Bank Branch No."; Text[20])
        {
            Caption = 'Bank Branch No.';

            trigger OnValidate()
            begin
                "RIB Checked" := RibKey.Check("Bank Branch No.", "Agency Code", "Bank Account No.", "RIB Key");
            end;
        }
        field(27; "Bank Account No."; Text[30])
        {
            Caption = 'Bank Account No.';

            trigger OnValidate()
            begin
                "RIB Checked" := RibKey.Check("Bank Branch No.", "Agency Code", "Bank Account No.", "RIB Key");
            end;
        }
        field(28; "Agency Code"; Text[5])
        {
            Caption = 'Agency Code';

            trigger OnValidate()
            begin
                "RIB Checked" := RibKey.Check("Bank Branch No.", "Agency Code", "Bank Account No.", "RIB Key");
            end;
        }
        field(29; "RIB Key"; Integer)
        {
            Caption = 'RIB Key';

            trigger OnValidate()
            begin
                "RIB Checked" := RibKey.Check("Bank Branch No.", "Agency Code", "Bank Account No.", "RIB Key");
            end;
        }
        field(30; "RIB Checked"; Boolean)
        {
            Caption = 'RIB Checked';
            Editable = false;
        }
        field(31; "Acceptation Code"; Option)
        {
            Caption = 'Acceptation Code';
            InitValue = No;
            OptionCaption = 'LCR,No,BOR,LCR NA';
            OptionMembers = LCR,No,BOR,"LCR NA";
        }
        field(32; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(33; "Debit Amount"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Debit Amount';

            trigger OnValidate()
            begin
                GetCurrency();
                "Debit Amount" := Round("Debit Amount", Currency."Amount Rounding Precision");
                Correction := "Debit Amount" < 0;
                Validate(Amount, "Debit Amount");
            end;
        }
        field(34; "Credit Amount"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Credit Amount';

            trigger OnValidate()
            begin
                GetCurrency();
                "Credit Amount" := Round("Credit Amount", Currency."Amount Rounding Precision");
                Correction := "Credit Amount" < 0;
                Validate(Amount, -"Credit Amount");
            end;
        }
        field(35; "Applies-to ID"; Code[50])
        {
            Caption = 'Applies-to ID';
        }
        field(36; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
        }
        field(37; Posted; Boolean)
        {
            Caption = 'Posted';
        }
        field(38; Correction; Boolean)
        {
            Caption = 'Correction';

            trigger OnValidate()
            begin
                Validate(Amount);
            end;
        }
        field(39; "Bank Account Name"; Text[100])
        {
            Caption = 'Bank Account Name';
        }
        field(40; "Payment Address Code"; Code[10])
        {
            Caption = 'Payment Address Code';
            TableRelation = "Payment Address FR".Code where("Account Type" = field("Account Type"),
                                                          "Account No." = field("Account No."));
        }
        field(41; "Applies-to Doc. Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Applies-to Doc. Type';
            Editable = false;
        }
        field(42; "Applies-to Doc. No."; Code[20])
        {
            Caption = 'Applies-to Doc. No.';
            Editable = false;
        }
        field(43; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(44; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            Editable = false;
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
        }
        field(45; "Drawee Reference"; Text[10])
        {
            Caption = 'Drawee Reference';
        }
        field(46; "Bank City"; Text[30])
        {
            Caption = 'Bank City';
        }
        field(47; Marked; Boolean)
        {
            Caption = 'Marked';
            Editable = false;
        }
        field(48; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            Editable = false;
        }
        field(50; "Payment in Progress"; Boolean)
        {
            Caption = 'Payment in Progress';
            Editable = false;
        }
        field(51; "Created from No."; Code[20])
        {
            Caption = 'Created from No.';
        }
        field(55; IBAN; Code[50])
        {
            Caption = 'IBAN', Locked = true;

            trigger OnValidate()
            var
                CompanyInfo: Record "Company Information";
            begin
                CompanyInfo.CheckIBAN(IBAN);
            end;
        }
        field(56; "SWIFT Code"; Code[20])
        {
            Caption = 'SWIFT Code';
        }
        field(291; "Has Payment Export Error"; Boolean)
        {
            CalcFormula = exist("Payment Jnl. Export Error Text" where("Document No." = field("No."),
                                                                        "Journal Line No." = field("Line No.")));
            Caption = 'Has Payment Export Error';
            Editable = false;
            FieldClass = FlowField;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                Rec.ShowDimensions();
            end;
        }
        field(1230; "Direct Debit Mandate ID"; Code[35])
        {
            Caption = 'Direct Debit Mandate ID';
            TableRelation = if ("Account Type" = const(Customer)) "SEPA Direct Debit Mandate" where("Customer No." = field("Account No."));

            trigger OnValidate()
            var
                SEPADirectDebitMandate: Record "SEPA Direct Debit Mandate";
            begin
                if SEPADirectDebitMandate.Get("Direct Debit Mandate ID") then
                    Validate("Bank Account Code", SEPADirectDebitMandate."Customer Bank Account Code");
            end;
        }
    }

    keys
    {
        key(Key1; "No.", "Line No.")
        {
            Clustered = true;
            SumIndexFields = Amount;
        }
        key(Key2; "Copied To No.", "Copied To Line")
        {
        }
        key(Key3; "Account Type", "Account No.", "Copied To Line", "Payment in Progress")
        {
            SumIndexFields = "Amount (LCY)";
        }
        key(Key4; "No.", "Account No.", "Bank Branch No.", "Agency Code", "Bank Account No.", "Payment Address Code")
        {
        }
        key(Key5; "Posting Date", "Document No.")
        {
        }
        key(Key6; "Payment Class")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        PaymentApply: Codeunit "Payment-Apply FR";
    begin
        if "Copied To No." <> '' then
            Error(Text001Lbl);
        PaymentApply.DeleteApply(Rec);
        DeletePaymentFileErrors();
    end;

    trigger OnInsert()
    var
        Statement: Record "Payment Header FR";
    begin
        Statement.Get("No.");
        Statement.TestField("File Export Completed", false);
        "Payment Class" := Statement."Payment Class";
        if (Statement."Currency Code" <> "Currency Code") and IsCopy then
            Error(Text000Lbl);
        "Currency Code" := Statement."Currency Code";
        "Currency Factor" := Statement."Currency Factor";
        "Posting Date" := Statement."Posting Date";
        Validate(Amount);
        Validate("Status No.");
        PaymentClass.Get(Statement."Payment Class");
        if PaymentClass."Line No. Series" = '' then
            "Document No." := Statement."No."
        else
            if "Document No." = '' then
                "Document No." := NoSeries.GetNextNo(PaymentClass."Line No. Series", "Posting Date");
        UpdateEntry(true);
    end;

    trigger OnModify()
    begin
        ModifyCheck();
    end;

    var
        Currency: Record Currency;
        CustomerBank: Record "Customer Bank Account";
        VendorBank: Record "Vendor Bank Account";
        PaymentClass: Record "Payment Class FR";
        Customer: Record Customer;
        Vendor: Record Vendor;
        DefaultDimension: Record "Default Dimension";
        RibKey: Codeunit "RIB Key FR";
        NoSeries: Codeunit "No. Series";
        DimMgt: Codeunit DimensionManagement;
        Text000Lbl: Label 'You cannot use different currencies on the same payment header.';
        Text001Lbl: Label 'You cannot delete this payment line.';
        Text002Lbl: Label 'You cannot modify this payment line.';
        BankAccErr: Label 'You must use customer bank account, %1, which you specified in the selected direct debit mandate.', Comment = '%1 = Code';

    local procedure AddDocumentNoToList(var List: Text; DocumentNo: Code[35]; LenToCut: Integer)
    var
        Delimiter: Text[2];
        PrevLen: Integer;
    begin
        PrevLen := StrLen(List);
        if PrevLen <> 0 then
            Delimiter := ', ';
        List += Delimiter + DocumentNo;
        if (PrevLen <= LenToCut) and (StrLen(List) > LenToCut) then
            List := CopyStr(List, 1, PrevLen) + PadStr('', LenToCut - PrevLen) + CopyStr(List, PrevLen + StrLen(Delimiter) + 1);
    end;

    procedure SetUpNewLine(LastGenJnlLine: Record "Payment Line FR"; BottomLine: Boolean)
    var
        Statement: Record "Payment Header FR";
    begin
        "Account Type" := LastGenJnlLine."Account Type";
        if "No." <> '' then begin
            Statement.Get("No.");
            PaymentClass.Get(Statement."Payment Class");
            if PaymentClass."Line No. Series" = '' then
                "Document No." := Statement."No."
            else
                if "Document No." = '' then
                    "Document No." := NoSeries.GetNextNo(PaymentClass."Line No. Series", "Posting Date");
        end;
        "Due Date" := Statement."Posting Date";

        OnAfterSetUpNewLine(Rec);
    end;

    procedure ShowDimensions()
    begin
        "Dimension Set ID" :=
        DimMgt.EditDimensionSet("Dimension Set ID", CopyStr(StrSubstNo('%1 %2 %3', TableCaption(), "No.", "Line No."), 1, 250));
    end;

    procedure GetAppliedDocNoList(LenToCut: Integer) List: Text
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
        DocumentNo: Code[35];
    begin
        if ("Applies-to Doc. No." = '') and ("Applies-to ID" = '') then
            exit('');
        case "Account Type" of
            "Account Type"::Customer:
                begin
                    CustLedgEntry.SetRange("Customer No.", "Account No.");
                    if "Applies-to Doc. No." <> '' then begin
                        CustLedgEntry.SetRange("Document Type", "Applies-to Doc. Type");
                        CustLedgEntry.SetRange("Document No.", "Applies-to Doc. No.");
                    end else
                        CustLedgEntry.SetRange("Applies-to ID", "Applies-to ID");
                    if CustLedgEntry.FindSet() then
                        repeat
                            AddDocumentNoToList(List, CustLedgEntry."Document No.", LenToCut);
                        until CustLedgEntry.Next() = 0;
                end;
            "Account Type"::Vendor:
                begin
                    VendLedgEntry.SetRange("Vendor No.", "Account No.");
                    if "Applies-to Doc. No." <> '' then begin
                        VendLedgEntry.SetRange("Document Type", "Applies-to Doc. Type");
                        VendLedgEntry.SetRange("Document No.", "Applies-to Doc. No.");
                    end else
                        VendLedgEntry.SetRange("Applies-to ID", "Applies-to ID");
                    if VendLedgEntry.FindSet() then
                        repeat
                            if VendLedgEntry."External Document No." = '' then
                                DocumentNo := VendLedgEntry."Document No."
                            else
                                DocumentNo := VendLedgEntry."External Document No.";
                            AddDocumentNoToList(List, DocumentNo, LenToCut);
                        until VendLedgEntry.Next() = 0;
                end;
            else
                exit('');
        end;
        exit(List);
    end;

    procedure GetAppliesToDocCustLedgEntry(var CustLedgEntry: Record "Cust. Ledger Entry")
    begin
        if "Account Type" <> "Account Type"::Customer then
            exit;

        CustLedgEntry.SetRange("Customer No.", "Account No.");
        CustLedgEntry.SetRange(Open, true);
        if "Applies-to Doc. No." <> '' then begin
            CustLedgEntry.SetRange("Document Type", "Applies-to Doc. Type");
            CustLedgEntry.SetRange("Document No.", "Applies-to Doc. No.");
            if CustLedgEntry.FindFirst() then;
        end else
            if "Applies-to ID" <> '' then begin
                CustLedgEntry.SetRange("Applies-to ID", "Applies-to ID");
                if CustLedgEntry.FindSet() then;
            end;
    end;

    procedure GetCurrency()
    var
        Header: Record "Payment Header FR";
    begin
        Header.Get("No.");
        if Header."Currency Code" = '' then begin
            Clear(Currency);
            Currency.InitRoundingPrecision();
        end else
            Currency.Get(Header."Currency Code");
    end;

    procedure InitBankAccount()
    begin
        "Bank Account Code" := '';
        "Bank Branch No." := '';
        "Bank Account No." := '';
        "Agency Code" := '';
        "RIB Key" := 0;
        "RIB Checked" := false;
        "Bank Account Name" := '';
        "Bank City" := '';
        IBAN := '';
        "SWIFT Code" := '';
    end;

    procedure DimensionSetup()
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        if "Line No." <> 0 then begin
            Clear(DefaultDimension);
            DefaultDimension.SetRange("Table ID", DimensionManagement.TypeToTableID1("Account Type".AsInteger()));
            DimensionCreate();
        end;
    end;

    procedure DimensionCreate()
    var
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimSetEntry: Record "Dimension Set Entry";
        DimValue: Record "Dimension Value";
        PaymentHeader: Record "Payment Header FR";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeDimensionCreate(Rec, DefaultDimension, IsHandled);
        if IsHandled then
            exit;

        DefaultDimension.SetRange("No.", "Account No.");
        DefaultDimension.SetFilter("Dimension Value Code", '<>%1', '');
        if DefaultDimension.Find('-') then
            repeat
                DimValue.Get(DefaultDimension."Dimension Code", DefaultDimension."Dimension Value Code");
                TempDimSetEntry."Dimension Code" := DimValue."Dimension Code";
                TempDimSetEntry."Dimension Value Code" := DimValue.Code;
                TempDimSetEntry."Dimension Value ID" := DimValue."Dimension Value ID";
                TempDimSetEntry.Insert();
            until DefaultDimension.Next() = 0;

        PaymentHeader.SetRange("No.", "No.");
        PaymentHeader.FindFirst();

        DimSetEntry.SetRange("Dimension Set ID", PaymentHeader."Dimension Set ID");
        if DimSetEntry.FindSet() then
            repeat
                TempDimSetEntry := DimSetEntry;
                TempDimSetEntry."Dimension Set ID" := 0;
                if not TempDimSetEntry.Modify() then
                    TempDimSetEntry.Insert();
            until DimSetEntry.Next() = 0;

        "Dimension Set ID" := DimMgt.GetDimensionSetID(TempDimSetEntry);
    end;

    procedure DeletePaymentFileErrors()
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine."Journal Template Name" := '';
        GenJnlLine."Journal Batch Name" := Format(DATABASE::"Payment Header FR");
        GenJnlLine."Document No." := "No.";
        GenJnlLine."Line No." := "Line No.";
        GenJnlLine.DeletePaymentFileErrors();
    end;

    procedure UpdateDueDate(DocumentDate: Date)
    var
        PaymentTerms: Record "Payment Terms";
        PaymentHeader: Record "Payment Header FR";
    begin
        if "Status No." > 0 then
            exit;
        if DocumentDate = 0D then begin
            PaymentHeader.Get("No.");
            DocumentDate := PaymentHeader."Posting Date";
            if DocumentDate = 0D then
                exit;
        end;
        Clear(PaymentTerms);
        if "Account Type" = "Account Type"::Customer then begin
            if "Account No." <> '' then begin
                Customer.Get("Account No.");
                if not PaymentTerms.Get(Customer."Payment Terms Code") then
                    "Due Date" := PaymentHeader."Posting Date";
            end
        end else
            if "Account Type" = "Account Type"::Vendor then
                if "Account No." <> '' then begin
                    Vendor.Get("Account No.");
                    if not PaymentTerms.Get(Vendor."Payment Terms Code") then
                        "Due Date" := PaymentHeader."Posting Date";
                end;
        if PaymentTerms.Code <> '' then
            "Due Date" := CalcDate(PaymentTerms."Due Date Calculation", DocumentDate);
    end;

    procedure UpdateEntry(InsertRecord: Boolean)
    var
        PaymentAddress: Record "Payment Address FR";
        GLAccount: Record "G/L Account";
        BankAccount: Record "Bank Account";
        FixedAsset: Record "Fixed Asset";
    begin
        if (xRec."Line No." <> 0) and ("Account Type" <> xRec."Account Type") then begin
            if not InsertRecord then begin
                "Account No." := '';
                InitBankAccount();
                "Due Date" := 0D;
            end;
            "Dimension Set ID" := 0;
        end;
        if "Account No." = '' then begin
            InitBankAccount();
            "Due Date" := 0D;
            "Dimension Set ID" := 0;
            exit;
        end;
        if (xRec."Line No." = "Line No.") and (xRec."Account No." <> '') and ("Account No." <> xRec."Account No.") then begin
            InitBankAccount();
            "Dimension Set ID" := 0;
        end;
        if (xRec."Line No." = "Line No.") and (xRec."Account Type" = "Account Type") and (xRec."Account No." = "Account No.") then
            exit;
        case "Account Type" of
            "Account Type"::"G/L Account":
                begin
                    GLAccount.Get("Account No.");
                    GLAccount.TestField("Account Type", GLAccount."Account Type"::Posting);
                    GLAccount.TestField(Blocked, false);
                end;
            "Account Type"::Customer:
                begin
                    Customer.Get("Account No.");
                    if Customer."Privacy Blocked" then
                        Customer.FieldError("Privacy Blocked");

                    if Customer.Blocked in [Customer.Blocked::All] then
                        Customer.FieldError(Blocked);
                    if "Bank Account Code" = '' then
                        if Customer."Preferred Bank Account Code" <> '' then
                            Validate("Bank Account Code", Customer."Preferred Bank Account Code");
                    if not InsertRecord then
                        UpdateDueDate(0D);
                end;
            "Account Type"::Vendor:
                begin
                    Vendor.Get("Account No.");
                    Vendor.TestField(Blocked, Vendor.Blocked::" ");
                    Vendor.TestField("Privacy Blocked", false);
                    if "Bank Account Code" = '' then
                        if Vendor."Preferred Bank Account Code" <> '' then
                            Validate("Bank Account Code", Vendor."Preferred Bank Account Code");
                    if not InsertRecord then
                        UpdateDueDate(0D);
                end;
            "Account Type"::"Bank Account":
                begin
                    BankAccount.Get("Account No.");
                    BankAccount.TestField(Blocked, false);
                end;
            "Account Type"::"Fixed Asset":
                begin
                    FixedAsset.Get("Account No.");
                    FixedAsset.TestField(Blocked, false);
                end;
        end;
        OnUpdateEntryOnBeforeDimensionSetup(Rec);
        DimensionSetup();
        PaymentAddress.SetRange("Account Type", "Account Type");
        PaymentAddress.SetRange("Account No.", "Account No.");
        PaymentAddress.SetRange("Default Value", true);
        if PaymentAddress.FindFirst() then
            "Payment Address Code" := PaymentAddress.Code
        else
            "Payment Address Code" := '';

        OnAfterUpdateEntry(Rec);
    end;

    procedure ModifyCheck()
    begin
        if Posted then
            Error(Text002Lbl);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetUpNewLine(var PaymentLine: Record "Payment Line FR")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateEntry(var PaymentLine: Record "Payment Line FR")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDimensionCreate(var PaymentLine: Record "Payment Line FR"; var DefaultDimension: Record "Default Dimension"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateEntryOnBeforeDimensionSetup(var PaymentLine: Record "Payment Line FR")
    begin
    end;
}

