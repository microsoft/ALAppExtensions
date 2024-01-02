// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Bank.BankAccount;
using Microsoft.CRM.Team;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.VAT.Setup;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Maintenance;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Enums;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Utilities;

table 11738 "Posted Cash Document Line CZP"
{
    Caption = 'Posted Cash Document Line';
    DrillDownPageID = "Posted Cash Document Lines CZP";
    LookupPageID = "Posted Cash Document Lines CZP";

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
            TableRelation = "Posted Cash Document Hdr. CZP"."No." where("Cash Desk No." = field("Cash Desk No."));
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
            DataClassification = CustomerContent;
        }
        field(5; "Account Type"; Enum "Cash Document Account Type CZP")
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;
        }
        field(6; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = if ("Account Type" = const("G/L Account")) "G/L Account"."No." else
            if ("Account Type" = const(Customer)) Customer."No." else
            if ("Account Type" = const(Vendor)) Vendor."No." else
            if ("Account Type" = const("Bank Account")) "Bank Account"."No." where("Account Type CZP" = const("Bank Account")) else
            if ("Account Type" = const("Fixed Asset")) "Fixed Asset"."No.";
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                GLAcc: Record "G/L Account";
                Customer: Record Customer;
                Vendor: Record Vendor;
                BankAcc: Record "Bank Account";
                StdText: Record "Standard Text";
                FA: Record "Fixed Asset";
            begin
                case "Account Type" of
                    "Account Type"::" ":
                        begin
                            if not StdText.Get("Account No.") then
                                Clear(StdText);
                            if Page.RunModal(0, StdText) = Action::LookupOK then;
                        end;
                    "Account Type"::"G/L Account":
                        begin
                            if not GLAcc.Get("Account No.") then
                                Clear(GLAcc);
                            if Page.RunModal(0, GLAcc) = Action::LookupOK then;
                        end;
                    "Account Type"::Customer:
                        begin
                            if not Customer.Get("Account No.") then
                                Clear(Customer);
                            if Page.RunModal(0, Customer) = Action::LookupOK then;
                        end;
                    "Account Type"::Vendor:
                        begin
                            if not Vendor.Get("Account No.") then
                                Clear(Vendor);
                            if Page.RunModal(0, Vendor) = Action::LookupOK then;
                        end;
                    "Account Type"::"Bank Account":
                        begin
                            if not BankAcc.Get("Account No.") then
                                Clear(BankAcc);
                            if Page.RunModal(Page::"Bank Account List", BankAcc) = Action::LookupOK then;
                        end;
                    "Account Type"::"Fixed Asset":
                        begin
                            if not FA.Get("Account No.") then
                                Clear(FA);
                            if Page.RunModal(0, FA) = Action::LookupOK then;
                        end;
                end;
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
        }
        field(21; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(24; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
            DataClassification = CustomerContent;
        }
        field(25; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
            DataClassification = CustomerContent;
        }
        field(26; "Document Type"; Enum "Cash Document Type CZP")
        {
            Caption = 'Cash Document Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(27; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(40; "Cash Desk Event"; Code[10])
        {
            Caption = 'Cash Desk Event';
            TableRelation = "Cash Desk Event CZP".Code where("Document Type" = field("Document Type"));
            DataClassification = CustomerContent;
        }
        field(42; "Salespers./Purch. Code"; Code[20])
        {
            Caption = 'Salespers./Purch. Code';
            TableRelation = "Salesperson/Purchaser";
            DataClassification = CustomerContent;
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
        }
        field(52; "Amount Including VAT"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount Including VAT';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(53; "VAT Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Amount';
            DataClassification = CustomerContent;
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
        }
        field(72; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
            DataClassification = CustomerContent;
        }
        field(75; "Use Tax"; Boolean)
        {
            Caption = 'Use Tax';
            DataClassification = CustomerContent;
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
        }
        field(93; "Duplicate in Depreciation Book"; Code[10])
        {
            Caption = 'Duplicate in Depreciation Book';
            TableRelation = "Depreciation Book";
            DataClassification = CustomerContent;
        }
        field(94; "Use Duplication List"; Boolean)
        {
            Caption = 'Use Duplication List';
            DataClassification = CustomerContent;
        }
        field(98; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            Editable = false;
            TableRelation = "Responsibility Center";
            DataClassification = CustomerContent;
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
        key(Key3; "Cash Desk No.", "Document Type")
        {
        }
    }

    var
        DimensionManagement: Codeunit DimensionManagement;

    procedure ShowDimensions()
    var
        ThreePlaceholdersTok: Label '%1 %2 %3', Locked = true;
    begin
        DimensionManagement.ShowDimensionSet("Dimension Set ID", StrSubstNo(ThreePlaceholdersTok, TableCaption, "Cash Document No.", "Line No."));
    end;

    procedure ExtStatistics()
    var
        PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP";
    begin
        TestField("Cash Desk No.");
        TestField("Cash Document No.");
        TestField("Line No.");

        PostedCashDocumentLineCZP.SetRange("Cash Desk No.", "Cash Desk No.");
        PostedCashDocumentLineCZP.SetRange("Cash Document No.", "Cash Document No.");
        PostedCashDocumentLineCZP.SetRange("Line No.", "Line No.");
        Page.RunModal(Page::"Posted Cash Document Stat. CZP", PostedCashDocumentLineCZP);
    end;
}
