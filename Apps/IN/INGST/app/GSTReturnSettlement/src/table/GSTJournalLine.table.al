// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

using Microsoft.Bank.BankAccount;
using Microsoft.CRM.Campaign;
using Microsoft.CRM.Team;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.StockTransfer;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;
using Microsoft.Projects.Project.Job;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

table 18325 "GST Journal Line"
{
    Caption = 'GST Journal Line';

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "GST Journal Template";
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; "Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Account Type" in ["Account Type"::Customer, "Account Type"::Vendor]) and
                   ("Bal. Account Type" in ["Bal. Account Type"::Customer, "Bal. Account Type"::Vendor])
                then
                    Error(AccTypeErr, FieldCaption("Account Type"), FieldCaption("Bal. Account Type"));
                Validate("Account No.", '');
            end;
        }
        field(4; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = if ("Account Type" = const("G/L Account")) "G/L Account"
            else
            if ("Account Type" = const(Customer)) Customer
            else
            if ("Account Type" = const(Vendor)) Vendor
            else
            if ("Account Type" = const("Bank Account")) "Bank Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Account No." = '' then begin
                    CreateDimFromDefaultDim(FieldNo("Account No."));
                    exit;
                end;
                case "Account Type" OF
                    "Account Type"::"G/L Account":
                        begin
                            GLAcc.Get("Account No.");
                            CheckGLAcc();
                            if not ReplaceInfo then begin
                                GSTJournalBatch.Get("Journal Template Name", "Journal Batch Name");
                                ReplaceInfo := GSTJournalBatch."Bal. Account No." <> '';
                            end;
                            if ReplaceInfo then
                                Description := GLAcc.Name;
                        end;
                    "Account Type"::Customer:
                        begin
                            Cust.Get("Account No.");
                            Cust.CheckBlockedCustOnJnls(Cust, "Document Type", false);
                            Description := Cust.Name;
                            "Salespers./Purch. Code" := Cust."Salesperson Code";
                        end;
                    "Account Type"::Vendor:
                        begin
                            Vend.Get("Account No.");
                            Vend.CheckBlockedVendOnJnls(Vend, "Document Type", false);
                            Description := Vend.Name;
                            "Salespers./Purch. Code" := Vend."Purchaser Code";
                        end;
                    "Account Type"::"Bank Account":
                        begin
                            BankAcc.Get("Account No.");
                            BankAcc.TestField(Blocked, false);
                            ReplaceInfo := "Bal. Account No." = '';
                            if not ReplaceInfo then begin
                                GSTJournalBatch.Get("Journal Template Name", "Journal Batch Name");
                                ReplaceInfo := GSTJournalBatch."Bal. Account No." <> '';
                            end;
                            if ReplaceInfo then
                                Description := BankAcc.Name;
                        end;
                end;

                CreateDimFromDefaultDim(FieldNo("Account No."));
            end;
        }
        field(5; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            ClosingDates = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
            begin
                DetailedGSTLedgerEntry.SetRange("Document No.", "Document No.");
                DetailedGSTLedgerEntry.SetRange("Document Line No.", "Document Line No.");
                DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
                if DetailedGSTLedgerEntry.FindFirst() then
                    if "Posting Date" < DetailedGSTLedgerEntry."Posting Date" then
                        Error(PostingDateErr, "Posting Date", DetailedGSTLedgerEntry."Posting Date");
            end;
        }
        field(6; "Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Account No." <> '' then
                    case "Account Type" OF
                        "Account Type"::Customer:
                            begin
                                Cust.Get("Account No.");
                                Cust.CheckBlockedCustOnJnls(Cust, "Document Type", false);
                            end;
                        "Account Type"::Vendor:
                            begin
                                Vend.Get("Account No.");
                                Vend.CheckBlockedVendOnJnls(Vend, "Document Type", false);
                            end;
                    end;
                if "Bal. Account No." <> '' then
                    case "Bal. Account Type" OF
                        "Account Type"::Customer:
                            begin
                                Cust.Get("Bal. Account No.");
                                Cust.CheckBlockedCustOnJnls(Cust, "Document Type", false);
                            end;
                        "Account Type"::Vendor:
                            begin
                                Vend.Get("Bal. Account No.");
                                Vend.CheckBlockedVendOnJnls(Vend, "Document Type", false);
                            end;
                    end;
            end;
        }
        field(7; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(8; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = CustomerContent;
        }
        field(9; "Adjustment Type"; Enum "Adjustment Type")
        {
            Caption = 'Adjustment Type';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(11; "Bal. Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Bal. Account Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Account Type" in ["Account Type"::Customer, "Account Type"::Vendor]) and
                   ("Bal. Account Type" in ["Bal. Account Type"::Customer, "Bal. Account Type"::Vendor])
                then
                    Error(
                      AccTypeErr,
                      FieldCaption("Account Type"), FieldCaption("Bal. Account Type"));

                Validate("Bal. Account No.", '');
            end;
        }
        field(12; "Bal. Account No."; Code[20])
        {
            Caption = 'Bal. Account No.';
            TableRelation = if ("Bal. Account Type" = const("G/L Account")) "G/L Account"
            else
            if ("Bal. Account Type" = const(Customer)) Customer
            else
            if ("Bal. Account Type" = const(Vendor)) Vendor
            else
            if ("Bal. Account Type" = const("Bank Account")) "Bank Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Bal. Account No." = '' then begin
                    CreateDimFromDefaultDim(FieldNo("Bal. Account No."));
                    exit;
                end;

                case "Bal. Account Type" OF
                    "Bal. Account Type"::"G/L Account":
                        begin
                            GLAcc.Get("Bal. Account No.");
                            CheckGLAcc();
                            if "Account No." = '' then
                                Description := GLAcc.Name;
                        end;
                    "Bal. Account Type"::Customer:
                        begin
                            Cust.Get("Bal. Account No.");
                            Cust.CheckBlockedCustOnJnls(Cust, "Document Type", false);
                            if "Account No." = '' then
                                Description := Cust.Name;
                        end;
                    "Bal. Account Type"::Vendor:
                        begin
                            Vend.Get("Bal. Account No.");
                            Vend.CheckBlockedVendOnJnls(Vend, "Document Type", false);
                            if "Account No." = '' then
                                Description := Vend.Name;
                        end;
                    "Bal. Account Type"::"Bank Account":
                        begin
                            BankAcc.Get("Bal. Account No.");
                            BankAcc.TestField(Blocked, false);
                            if "Account No." = '' then
                                Description := BankAcc.Name;
                        end;
                end;

                CreateDimFromDefaultDim(FieldNo("Bal. Account No."));
            end;
        }
        field(13; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                GetCurrency();
                Amount := Round(Amount, Currency."Amount Rounding Precision");
            end;
        }
        field(14; "Debit Amount"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Debit Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                GetCurrency();
                "Debit Amount" := Round("Debit Amount", Currency."Amount Rounding Precision");
                Amount := "Debit Amount";
                Validate(Amount);
            end;
        }
        field(15; "Credit Amount"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Credit Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                GetCurrency();
                "Credit Amount" := Round("Credit Amount", Currency."Amount Rounding Precision");
                Amount := -"Credit Amount";
                Validate(Amount);
            end;
        }
        field(16; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(17; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(18; "Salespers./Purch. Code"; Code[20])
        {
            Caption = 'Salespers./Purch. Code';
            TableRelation = "Salesperson/Purchaser";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CreateDimFromDefaultDim(FieldNo("Salespers./Purch. Code"));
            end;
        }
        field(19; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Editable = false;
            TableRelation = "Source Code";
            DataClassification = CustomerContent;
        }
        field(20; "System-Created Entry"; Boolean)
        {
            Caption = 'System-Created Entry';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(21; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "GST Journal Batch".Name where("Journal Template Name" = field("Journal Template Name"));
            DataClassification = CustomerContent;
        }
        field(22; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(23; "Posting No. Series"; Code[10])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(24; "Template Type"; Enum "GST Adjustment Journal Type")
        {
            Caption = 'Template Type';
            DataClassification = CustomerContent;
        }
        field(25; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            DataClassification = CustomerContent;
        }
        field(26; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
            DataClassification = CustomerContent;
        }
        field(27; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(28; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
            DataClassification = SystemMetadata;

            trigger OnLookup()
            begin
                ShowDimensions();
            end;
        }
        field(29; "DGL From Entry No."; Integer)
        {
            Caption = 'DGL From Entry No.';
            DataClassification = CustomerContent;
        }
        field(30; "DGL From To No."; Integer)
        {
            Caption = 'DGL From To No.';
            DataClassification = CustomerContent;
        }
        field(31; "Original Location GSTIN"; Code[20])
        {
            Caption = 'Original Location GSTIN';
            DataClassification = CustomerContent;
        }
        field(32; "Original Location"; Code[10])
        {
            Caption = 'Original Location';
            Editable = false;
            TableRelation = Location;
            DataClassification = CustomerContent;
        }
        field(33; "Original Quantity"; Decimal)
        {
            Caption = 'Original Quantity';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(34; "GST Base Amount"; Decimal)
        {
            Caption = 'GST Base Amount';
            DataClassification = CustomerContent;
        }
        field(35; "GST Amount"; Decimal)
        {
            Caption = 'GST Amount';
            DataClassification = CustomerContent;
        }
        field(36; "Total GST Amount"; Decimal)
        {
            Caption = 'Total GST Amount';
            DataClassification = CustomerContent;
        }
        field(37; "Total ITC Amount Available"; Decimal)
        {
            Caption = 'Total ITC Amount Available';
            DataClassification = CustomerContent;
        }
        field(38; "Quantity to be Adjusted"; Decimal)
        {
            Caption = 'Quantity to be Adjusted';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                GSTTrackingEntry: Record "GST Tracking Entry";
                ItemLedgerEntry: Record "Item Ledger Entry";
            begin
                if "Quantity to be Adjusted" > "Original Quantity" then
                    Error(QtyToAdjErr);

                if "Quantity to be Adjusted" <> 0 then begin
                    "Amount of Adjustment" := ("Quantity to be Adjusted" / Quantity) * "GST Amount";
                    "Input Credit/Output Tax Amount" := ("Quantity to be Adjusted" / Quantity) * "Total ITC Amount Available";
                    "Amount to be Loaded on Invento" := "Amount of Adjustment" - "Input Credit/Output Tax Amount";
                end;

                GSTTrackingEntry.SetRange("From Entry No.", "DGL From Entry No.");
                GSTTrackingEntry.SetRange("From To No.", "DGL From To No.");
                GSTTrackingEntry.SetFilter("Remaining Quantity", '<>%1', 0);
                if GSTTrackingEntry.FindFirst() then
                    if ItemLedgerEntry.Get(GSTTrackingEntry."Item Ledger Entry No.") then
                        if (ItemLedgerEntry."Lot No." = '') or (ItemLedgerEntry."Serial No." = '') then
                            if "Quantity to be Adjusted" > ItemLedgerEntry."Remaining Quantity" then
                                Error(QuantyAjustedErr, ItemLedgerEntry."Remaining Quantity");

                GSTJournalPost.AdjustDetailedGSTEntry(false, Rec);
            end;
        }
        field(39; "Amount of Adjustment"; Decimal)
        {
            Caption = 'Amount of Adjustment';
            DataClassification = CustomerContent;
        }
        field(40; "Input Credit/Output Tax Amount"; Decimal)
        {
            Caption = 'Input Credit/Output Tax Amount';
            DataClassification = CustomerContent;
        }
        field(41; "Amount to be Loaded on Invento"; Decimal)
        {
            Caption = 'Amount to be Loaded on Invento';
            DataClassification = CustomerContent;
        }
        field(42; "GST Adjustment Entry"; Boolean)
        {
            Caption = 'GST Adjustment Entry';
            DataClassification = CustomerContent;
        }
        field(43; "GST Transaction No."; Integer)
        {
            Caption = 'GST Transaction No.';
            DataClassification = CustomerContent;
        }
        field(44; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Journal Template Name", "Journal Batch Name", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "GST Transaction No.", "Document No.", "Document Line No.")
        {
        }
    }

    trigger OnDelete()
    begin
        GSTAdjustmentBuffer.Reset();
        GSTAdjustmentBuffer.SetRange("Journal Template Name", "Journal Template Name");
        GSTAdjustmentBuffer.SetRange("Journal Batch Name", "Journal Batch Name");
        GSTAdjustmentBuffer.SetRange("Line No.", "Line No.");
        GSTAdjustmentBuffer.DeleteAll();
    end;

    trigger OnInsert()
    begin
        LockTable();
        GSTJournalTemplate.Get("Journal Template Name");
        GSTJournalBatch.Get("Journal Template Name", "Journal Batch Name");

        ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
        ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
    end;

    var
        GSTJournalTemplate: Record "GST Journal Template";
        GSTJournalBatch: Record "GST Journal Batch";
        GSTJournalLine: Record "GST Journal Line";
        GLAcc: Record "G/L Account";
        Cust: Record "Customer";
        Vend: Record "Vendor";
        Currency: Record "Currency";
        BankAcc: Record "Bank Account";
        GLSetup: Record "General Ledger Setup";
        GSTAdjustmentBuffer: Record "GST Adjustment Buffer";
        NoSeriesMgt: Codeunit "NoSeriesManagement";
        DimMgt: Codeunit "DimensionManagement";
        GSTJournalPost: Codeunit "GST Journal Post";
        ReplaceInfo: Boolean;
        AccTypeErr: Label '%1 or %2 must be G/L Account or Bank Account.', Comment = '%1  = G/L Account,%2 = Bank Account';
        QtyToAdjErr: Label 'Quantity to be Adjusted cannot be greater than Original Quantity.';
        PostingDateErr: Label 'Posting Date %1 for GST Adjustment cannot be earlier than the Invoice Date %2.', Comment = '%1  = Posting Date,%2 = Invoice Date';
        QuantyAjustedErr: Label 'Quantity to Adjustment should not be greater than Remaining quantity %1 present in Item Ledger entry.', Comment = '%1 = Remaining Quantity';

    procedure EmptyLine(): Boolean
    begin
        exit(
          ("Account No." = '') and (Amount = 0) and
          ("Bal. Account No." = ''));
    end;

    procedure SetUpNewLine(LastGSTJournalLine: Record "GST Journal Line"; Balance: Decimal; BottomLine: Boolean)
    begin
        GSTJournalTemplate.Get("Journal Template Name");
        GSTJournalBatch.Get("Journal Template Name", "Journal Batch Name");
        GSTJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        GSTJournalLine.SetRange("Journal Batch Name", "Journal Batch Name");
        if GSTJournalLine.FindFirst() then begin
            "Posting Date" := LastGSTJournalLine."Posting Date";
            "Document No." := LastGSTJournalLine."Document No.";
            if BottomLine and
               (Balance = 0) and
               not LastGSTJournalLine.EmptyLine()
            then
                "Document No." := IncStr("Document No.");
        end else begin
            "Posting Date" := WorkDate();
            if GSTJournalBatch."No. Series" <> '' then begin
                CLEAR(NoSeriesMgt);
                "Document No." := NoSeriesMgt.GetNextNo(GSTJournalBatch."No. Series", "Posting Date", false);
            end;
        end;

        "Account Type" := LastGSTJournalLine."Account Type";
        "Document Type" := LastGSTJournalLine."Document Type";
        "Source Code" := GSTJournalTemplate."No. Series";
        "Reason Code" := GSTJournalBatch."Reason Code";
        "Posting No. Series" := GSTJournalBatch."Posting No. Series";
        "Bal. Account Type" := GSTJournalBatch."Bal. Account Type";
        "Location Code" := GSTJournalBatch."Location Code";
        if ("Account Type" in ["Account Type"::Customer, "Account Type"::Vendor]) and
           ("Bal. Account Type" in ["Bal. Account Type"::Customer, "Bal. Account Type"::Vendor])
        then
            "Account Type" := "Account Type"::"G/L Account";
        Validate("Bal. Account No.", GSTJournalBatch."Bal. Account No.");
        Description := '';
    end;

    local procedure CheckGLAcc()
    begin
        GLAcc.CheckGLAcc();
        if GLAcc."Direct Posting" or ("Journal Template Name" = '') then
            exit;

        if "Posting Date" <> 0D then
            if "Posting Date" = ClosingDate("Posting Date") then
                exit;

        GLAcc.TestField("Direct Posting", true);
    end;

    procedure CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        "Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, "Source Code", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

    procedure LookupShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.LookupDimValueCode(FieldNumber, ShortcutDimCode);
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    begin
        DimMgt.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode);
    end;

    procedure ShowDimensions()
    begin
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            "Dimension Set ID", StrSubstNo('%1 %2 %3', "Journal Template Name", "Journal Batch Name", "Line No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    local procedure GetCurrency()
    begin
        GLSetup.Get();
        Currency.InitRoundingPrecision();
    end;

    procedure OpenTracking()
    begin
        GSTJournalPost.CallItemTracking(Rec);
    end;

    procedure CreateDimFromDefaultDim(FromFieldNo: Integer)
    var
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        InitDefaultDimensionSources(DefaultDimSource, FromFieldNo);
        CreateDim(DefaultDimSource);
    end;

    local procedure InitDefaultDimensionSources(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; FromFieldNo: Integer)
    begin
        DimMgt.AddDimSource(DefaultDimSource, DimMgt.TypeToTableID1("Account Type".AsInteger()), Rec."Account No.", FromFieldNo = Rec.Fieldno("Account No."));
        DimMgt.AddDimSource(DefaultDimSource, DimMgt.TypeToTableID1("Bal. Account Type".AsInteger()), Rec."Bal. Account No.", FromFieldNo = Rec.Fieldno("Bal. Account No."));
        DimMgt.AddDimSource(DefaultDimSource, Database::Job, '', false);
        DimMgt.AddDimSource(DefaultDimSource, Database::"Salesperson/Purchaser", Rec."Salespers./Purch. Code", FromFieldNo = Rec.FieldNo("Salespers./Purch. Code"));
        DimMgt.AddDimSource(DefaultDimSource, Database::Campaign, '', false);
    end;
}

