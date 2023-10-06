// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSReturnAndSettlement;

using Microsoft.Projects.Project.Job;
using Microsoft.CRM.Campaign;
using Microsoft.CRM.Team;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;
using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Dimension;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Location;
using Microsoft.Finance.TaxBase;

table 18747 "TDS Journal Line"
{
    Caption = 'TDS Journal Line';
    Extensible = true;
    Access = Public;

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            DataClassification = CustomerContent;
            TableRelation = "TDS Journal Template";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Account Type"; Enum "TDS Account Type")
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Account Type" in ["Account Type"::Customer, "Account Type"::Vendor]) and
                   ("Bal. Account Type" in ["Bal. Account Type"::Customer, "Bal. Account Type"::Vendor])
                then
                    Error(
                      AccountTypeErr,
                      FieldCaption("Account Type"), FieldCaption("Bal. Account Type"));
                Validate("Account No.", '');
            end;
        }
        field(4; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Account Type" = const("G/L Account")) "G/L Account"
            else
            if ("Account Type" = const(Customer)) Customer
            else
            if ("Account Type" = const(Vendor)) Vendor
            else
            if ("Account Type" = const("Bank Account")) "Bank Account";

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
                GeneralLedgerSetup: Record "General Ledger Setup";
                Customer: Record Customer;
                Vendor: Record Vendor;
                TDSJournalBatch: Record "TDS Journal Batch";
                BankAccount: Record "Bank Account";
                ReplaceInfo: Boolean;
            begin
                if "Account No." = '' then begin
                    CreateDimFromDefaultDim(FieldNo("Account No."));
                    exit;
                end;
                case "Account Type" of
                    "Account Type"::"G/L Account":
                        begin
                            GLAccount.Get("Account No.");
                            CheckGLAcc();
                            GeneralLedgerSetup.Get();
                            ReplaceInfo := "Bal. Account No." = '';
                            if not ReplaceInfo then begin
                                TDSJournalBatch.Get("Journal Template Name", "Journal Batch Name");
                                ReplaceInfo := TDSJournalBatch."Bal. Account No." <> '';
                            end;
                            if ReplaceInfo then
                                Description := GLAccount.Name;

                        end;
                    "Account Type"::Customer:
                        begin
                            Customer.Get("Account No.");
                            Customer.CheckBlockedCustOnJnls(Customer, "Document Type", false);
                            Description := Customer.Name;
                            "Salespers./Purch. Code" := Customer."Salesperson Code";
                        end;
                    "Account Type"::Vendor:
                        begin
                            Vendor.Get("Account No.");
                            Vendor.CheckBlockedVendOnJnls(Vendor, "Document Type", false);
                            Description := Vendor.Name;
                            "Salespers./Purch. Code" := Vendor."Purchaser Code";
                        end;
                    "Account Type"::"Bank Account":
                        begin
                            BankAccount.Get("Account No.");
                            BankAccount.TestField(Blocked, false);
                            ReplaceInfo := "Bal. Account No." = '';
                            if not ReplaceInfo then begin
                                TDSJournalBatch.Get("Journal Template Name", "Journal Batch Name");
                                ReplaceInfo := TDSJournalBatch."Bal. Account No." <> '';
                            end;
                            if ReplaceInfo then
                                Description := BankAccount.Name;
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
            begin
                if "Posting Date" < xRec."Posting Date" then
                    Error(PostingDateErr, "Posting Date", xRec."Posting Date");
                Validate("Document Date", "Posting Date");
            end;
        }
        field(6; "Document Type"; Enum "Gen. Journal Document Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Document Type';

            trigger OnValidate()
            var
                Customer: Record Customer;
                Vendor: Record Vendor;
            begin
                if "Account No." <> '' then
                    case "Account Type" of
                        "Account Type"::Customer:
                            begin
                                Customer.Get("Account No.");
                                Customer.CheckBlockedCustOnJnls(Customer, "Document Type", false);
                            end;
                        "Account Type"::Vendor:
                            begin
                                Vendor.Get("Account No.");
                                Vendor.CheckBlockedVendOnJnls(Vendor, "Document Type", false);
                            end;
                    end;
            end;
        }
        field(7; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(9; "Bal. Account No."; Code[20])
        {
            Caption = 'Bal. Account No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Bal. Account Type" = const("G/L Account")) "G/L Account"
            else
            if ("Bal. Account Type" = const(Customer)) Customer
            else
            if ("Bal. Account Type" = const(Vendor)) Vendor
            else
            if ("Bal. Account Type" = const("Bank Account")) "Bank Account";

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
                GeneralLedgerSetup: Record "General Ledger Setup";
                Customer: Record Customer;
                Vendor: Record Vendor;
                BankAccount: Record "Bank Account";
            begin
                if "Bal. Account No." = '' then begin
                    CreateDimFromDefaultDim(FieldNo("Bal. Account No."));
                    exit;
                end;

                case "Bal. Account Type" of
                    "Bal. Account Type"::"G/L Account":
                        begin
                            GLAccount.Get("Bal. Account No.");
                            CheckGLAcc();
                            GeneralLedgerSetup.Get();
                            if "Account No." = '' then
                                Description := GLAccount.Name;
                        end;
                    "Bal. Account Type"::Customer:
                        begin
                            Customer.Get("Bal. Account No.");
                            Customer.CheckBlockedCustOnJnls(Customer, "Document Type", false);
                            if "Account No." = '' then
                                Description := Customer.Name;
                        end;
                    "Bal. Account Type"::Vendor:
                        begin
                            Vendor.Get("Bal. Account No.");
                            Vendor.CheckBlockedVendOnJnls(Vendor, "Document Type", false);
                            if "Account No." = '' then
                                Description := Vendor.Name;
                        end;
                    "Bal. Account Type"::"Bank Account":
                        begin
                            BankAccount.Get("Bal. Account No.");
                            BankAccount.TestField(Blocked, false);
                            if "Account No." = '' then
                                Description := BankAccount.Name;
                        end;
                end;
                CreateDimFromDefaultDim(FieldNo("Bal. Account No."));
            end;
        }
        field(10; "Salespers./Purch. Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(11; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Amount := TDSEntityManagement.RoundTDSAmount(Amount);
            end;
        }
        field(12; "Debit Amount"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Debit Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Debit Amount" := TDSEntityManagement.RoundTDSAmount("Debit Amount");
                Amount := "Debit Amount";
                Validate(Amount);
            end;
        }
        field(13; "Credit Amount"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Credit Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Credit Amount" := TDSEntityManagement.RoundTDSAmount("Credit Amount");
                Amount := -"Credit Amount";
                Validate(Amount);
            end;
        }
        field(14; "Balance (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Balance (LCY)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(15; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(16; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(17; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
        field(18; "System-Created Entry"; Boolean)
        {
            Caption = 'System-Created Entry';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(19; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            DataClassification = CustomerContent;
            TableRelation = "TDS Journal Batch".Name where("Journal Template Name" = field("Journal Template Name"));
        }
        field(20; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }
        field(21; "Bal. Account Type"; Enum "TDS Bal. Account Type")
        {
            Caption = 'Bal. Account Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Account Type" in ["Account Type"::Customer, "Account Type"::Vendor]) and
                   ("Bal. Account Type" in ["Bal. Account Type"::Customer, "Bal. Account Type"::Vendor])
                then
                    Error(AccountTypeErr, FieldCaption("Account Type"), FieldCaption("Bal. Account Type"));
                Validate("Bal. Account No.", '');
            end;
        }
        field(22; "Document Date"; Date)
        {
            Caption = 'Document Date';
            ClosingDates = true;
            DataClassification = CustomerContent;
        }
        field(23; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(24; "Posting No. Series"; Code[10])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(25; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions();
            end;
        }
        field(26; "State Code"; Code[10])
        {
            Caption = 'State Code';
            DataClassification = CustomerContent;
        }
        field(27; "TDS Amount"; Decimal)
        {
            Caption = 'TDS Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(28; "Tax Amount"; Decimal)
        {
            Caption = 'Tax Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 4;
        }
        field(29; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(30; "Assessee Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Assessee Code';
            Editable = false;
            TableRelation = "Assessee Code";
        }
        field(31; "TDS %"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'TDS %';
            Editable = false;

            trigger OnValidate()
            var
                TDSAmt: Decimal;
            begin
                if xRec."TDS %" > 0 then begin
                    if "Debit Amount" <> 0 then
                        TDSAmt := "Debit Amount"
                    else
                        TDSAmt := "Credit Amount";

                    if "Bal. TDS Including SHE CESS" <> 0 then
                        TDSAmt := "Bal. TDS Including SHE CESS";
                    "Bal. TDS Including SHE CESS" := TDSEntityManagement.RoundTDSAmount("TDS %" * TDSAmt / xRec."TDS %");
                    "TDS Amount" := TDSEntityManagement.RoundTDSAmount("TDS %" * TDSAmt / xRec."TDS %");
                end else begin
                    "Bal. TDS Including SHE CESS" := TDSEntityManagement.RoundTDSAmount(("TDS %" * (1 + "Surcharge %" / 100)) * Amount / 100);
                    "TDS Amount" := TDSEntityManagement.RoundTDSAmount("TDS %" * Amount / 100);
                end;
            end;
        }
        field(32; "TDS Amt Incl Surcharge"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'TDS Amt Incl Surcharge';
            Editable = false;
        }
        field(33; "Bal. TDS Including SHE CESS"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Bal. TDS Including SHE CESS';
            Editable = false;
        }
        field(34; "CESS Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'CESS Amount';

            trigger OnValidate()
            begin
                Validate(Amount,
                  "CESS Amount" + "Surcharge Amount" +
                  "eCess Amount" + "SHE Cess Amount");
            end;
        }
        field(35; "eCess Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'eCess Amount';

            trigger OnValidate()
            begin
                Validate(Amount,
                  "CESS Amount" + "Surcharge Amount" +
                  "eCess Amount" + "SHE Cess Amount");
            end;
        }
        field(36; "Surcharge %"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Surcharge %';
            Editable = false;
        }
        field(37; "Surcharge Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Surcharge Amount';
            Editable = false;
        }
        field(38; "Concessional Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Concessional Code';
            Editable = false;
            TableRelation = "Concessional Code";
        }
        field(39; "TDS Entry"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'TDS Entry';
        }
        field(40; "TDS % Applied"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'TDS % Applied';

            trigger OnValidate()
            begin
                "TDS Adjusted" := true;
                "Balance TDS Amount" := "TDS % Applied" * "TDS Base Amount" / 100;
                "Surcharge Base Amount" := "Balance TDS Amount";

                UpdateTDSJournalOnTDSApplied(Rec);
                RoundTDSAmounts(Rec);
                UpdateTDSAmount(Rec);

                if ("TDS % Applied" = 0) and "TDS Adjusted" then begin
                    Validate("Surcharge % Applied", 0);
                    Validate("eCESS % Applied", 0);
                    Validate("SHE Cess % Applied", 0);
                end;
            end;
        }
        field(41; "TDS Invoice No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'TDS Invoice No.';
            Editable = false;
        }
        field(42; "TDS Base Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'TDS Base Amount';
            Editable = false;
        }
        field(43; "Challan No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Challan No.';
        }
        field(44; "Challan Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Challan Date';
        }
        field(45; Adjustment; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Adjustment';
            Editable = false;
        }
        field(46; "TDS Transaction No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'TDS Transaction No.';
            Editable = false;
        }
        field(47; "E.C.C. No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'E.C.C. No.';
        }
        field(48; "Balance Surcharge Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Balance Surcharge Amount';
            Editable = false;
        }
        field(49; "Surcharge % Applied"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Surcharge % Applied';

            trigger OnValidate()
            begin
                UpdateAmountOnSurchargeApplied();
                RoundTDSAmounts(Rec);
                UpdateTDSAmount(Rec);
            end;
        }
        field(50; "Surcharge Base Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Surcharge Base Amount';
            Editable = false;
        }
        field(51; "Balance TDS Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Balance TDS Amount';
            Editable = false;
        }
        field(52; "eCESS %"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'eCESS %';
            Editable = false;
        }
        field(53; "eCESS on TDS Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'eCESS on TDS Amount';
            Editable = false;
        }
        field(54; "Total TDS Incl. SHE CESS"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Total TDS Incl. SHE CESS';
            Editable = false;
        }
        field(55; "eCESS Base Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'eCESS Base Amount';
        }
        field(56; "eCESS % Applied"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'eCESS % Applied';

            trigger OnValidate()
            begin
                UpdateAmountOnECessandSHECess();
                "TDS eCess Adjusted" := true;
                "Balance eCESS on TDS Amt" := ("Balance TDS Amount" + "Balance Surcharge Amount") * "eCESS % Applied" / 100;
                if ("SHE Cess % Applied" = 0) and (not "TDS SHE Cess Adjusted") then
                    "Bal. SHE Cess on TDS Amt" := ("Balance TDS Amount" + "Balance Surcharge Amount") * "SHE Cess %" / 100
                else
                    "Bal. SHE Cess on TDS Amt" := ("Balance TDS Amount" + "Balance Surcharge Amount") * "SHE Cess % Applied" / 100;

                RoundTDSAmounts(Rec);
                UpdateTDSAmount(Rec);
            end;
        }
        field(58; "Per Contract"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Per Contract';
        }
        field(59; "Bal. SHE Cess on TDS Amt"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Bal. SHE Cess on TDS Amt';
        }
        field(60; "T.A.N. No."; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'T.A.N. No.';
            TableRelation = "TAN Nos.";
        }
        field(61; "SHE Cess Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            Caption = 'SHE Cess Amount';

            trigger OnValidate()
            begin
                Validate(Amount,
                  "CESS Amount" + "Surcharge Amount" +
                  "eCess Amount" + "SHE Cess Amount");
            end;
        }
        field(62; "SHE Cess %"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'SHE Cess %';
            Editable = false;
        }
        field(63; "SHE Cess on TDS Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'SHE Cess on TDS Amount';
            Editable = false;
        }
        field(64; "SHE Cess Base Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'SHE Cess Base Amount';
            Editable = false;
        }
        field(65; "SHE Cess % Applied"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'SHE Cess % Applied';

            trigger OnValidate()
            begin
                UpdateAmountOnECessandSHECess();
                if ("eCESS % Applied" = 0) and (not "TDS eCess Adjusted") then
                    "Balance eCESS on TDS Amt" := ("Balance TDS Amount" + "Balance Surcharge Amount") * "eCESS %" / 100
                else
                    "Balance eCESS on TDS Amt" := ("Balance TDS Amount" + "Balance Surcharge Amount") * "eCESS % Applied" / 100;
                "TDS SHE Cess Adjusted" := true;
                "Bal. SHE Cess on TDS Amt" := ("Balance TDS Amount" + "Balance Surcharge Amount") * "SHE Cess % Applied" / 100;

                RoundTDSAmounts(Rec);
                UpdateTDSAmount(Rec);
            end;
        }
        field(66; "TDS Adjusted"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'TDS Adjusted';
        }
        field(67; "Surcharge Adjusted"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Surcharge Adjusted';
        }
        field(68; "TDS eCess Adjusted"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'TDS eCess Adjusted';
        }
        field(69; "TDS SHE Cess Adjusted"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'TDS SHE Cess Adjusted';
        }
        field(70; "TDS Base Amount Applied"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'TDS Base Amount Applied';

            trigger OnValidate()
            begin
                Validate("TDS % Applied", ((("TDS Base Amount Applied" / "TDS Base Amount") * 100) * "TDS %") / 100);
                if ("TDS % Applied" = 0) and (not "TDS Adjusted") then begin
                    "TDS % Applied" := "TDS %";
                    "Balance TDS Amount" := "TDS %" * "TDS Base Amount" / 100;
                end else
                    "Balance TDS Amount" := TDSEntityManagement.RoundTDSAmount("TDS Base Amount" * "TDS % Applied" / 100);

                "Surcharge Base Amount" := "Balance TDS Amount";
                UpdateTDSJournalOnTDSApplied(Rec);

                if ("TDS Base Amount Applied" = 0) and "TDS Base Amount Adjusted" then begin
                    Validate("TDS % Applied", 0);
                    Validate("Surcharge % Applied", 0);
                    Validate("eCESS % Applied", 0);
                    Validate("SHE Cess % Applied", 0);
                end;

                RoundTDSAmounts(Rec);
                if "TDS Section Code" <> '' then
                    UpdateTDSAmount(Rec);
            end;
        }
        field(71; "TDS Base Amount Adjusted"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'TDS Base Amount Adjusted';
            Editable = false;
        }
        field(72; "TDS Section Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'TDS Section Code';
            TableRelation = "TDS Section";
        }
        field(73; "TDSEntry"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'TDS Entry';
        }
        field(87; "Balance eCESS on TDS Amt"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Balance eCESS on TDS Amt';
        }
        field(88; "TDS Adjustment"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'TDS Adjustment';
        }
        field(89; "TDS Line Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'TDS Line Amount';
        }
    }

    keys
    {
        key(Key1; "Journal Template Name", "Journal Batch Name", "Line No.")
        {
            Clustered = true;
            MaintainSIFTIndex = false;
            SumIndexFields = "Balance (LCY)";
        }
        key(Key2; "Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.")
        {
            MaintainSQLIndex = false;
        }
        key(Key3; "Journal Template Name", "Journal Batch Name", "Location Code", "Document No.")
        {
        }
    }


    trigger OnInsert()
    var
        TDSJournalTemplate: Record "TDS Journal Template";
        TDSJournalBatch: Record "TDS Journal Batch";
    begin
        LockTable();
        TDSJournalTemplate.Get("Journal Template Name");
        TDSJournalBatch.Get("Journal Template Name", "Journal Batch Name");

        ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
        ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
    end;

    var
        DimensionManagement: Codeunit DimensionManagement;
        TDSEntityManagement: Codeunit "TDS Entity Management";
        AccountTypeErr: Label '%1 or %2 must be G/L Account or Bank Account.', Comment = '%1 = G/L Account No.,%2 = Bank Account No.';
        PostingDateErr: Label 'Posting Date %1 for TDS Adjustment cannot be earlier than the Invoice Date %2.', Comment = '%1 = Posting Date, %2 = xRec.Posting Date';

    procedure EmptyLine(): Boolean
    begin
        exit(
          ("Account No." = '') and (Amount = 0) and
          ("Bal. Account No." = ''));
    end;

    procedure SetUpNewLine(LastTDSJournalLine: Record "TDS Journal Line"; BottomLine: Boolean)
    var
        TDSJournalLine: Record "TDS Journal Line";
        TDSJournalTemplate: Record "TDS Journal Template";
        TDSJournalBatch: Record "TDS Journal Batch";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        TDSJournalTemplate.Get("Journal Template Name");
        TDSJournalBatch.Get("Journal Template Name", "Journal Batch Name");


        TDSJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        TDSJournalLine.SetRange("Journal Batch Name", "Journal Batch Name");
        if not TDSJournalLine.IsEmpty() then begin
            Validate("Posting Date", LastTDSJournalLine."Posting Date");
            Validate("Document Date", LastTDSJournalLine."Posting Date");
            Validate("Document No.", LastTDSJournalLine."Document No.");
            if BottomLine and
               not LastTDSJournalLine.EmptyLine()
            then
                "Document No." := IncStr("Document No.");
        end else begin
            "Posting Date" := WorkDate();
            "Document Date" := WorkDate();
            if TDSJournalBatch."No. Series" <> '' then begin
                Clear(NoSeriesManagement);
                "Document No." := NoSeriesManagement.GetNextNo(TDSJournalBatch."No. Series", "Posting Date", false);
            end;
        end;
        Validate("Account Type", LastTDSJournalLine."Account Type");
        Validate("Document Type", LastTDSJournalLine."Document Type");
        Validate("Source Code", TDSJournalTemplate."Source Code");
        Validate("Reason Code", TDSJournalBatch."Reason Code");
        Validate("Posting No. Series", TDSJournalBatch."Posting No. Series");
        Validate("Bal. Account Type", TDSJournalBatch."Bal. Account Type");
        Validate("Location Code", TDSJournalBatch."Location Code");
        if ("Account Type" in ["Account Type"::Customer, "Account Type"::Vendor]) and
           ("Bal. Account Type" in ["Bal. Account Type"::Customer, "Bal. Account Type"::Vendor])
        then
            Validate("Account Type", "Account Type"::"G/L Account");
        Validate("Bal. Account No.", TDSJournalBatch."Bal. Account No.");
        Validate(Description, '');
    end;

    procedure CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        "Dimension Set ID" :=
            DimensionManagement.GetDefaultDimID(DefaultDimSource, "Source Code", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimensionManagement.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    begin
        DimensionManagement.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode);
    end;

    procedure ShowDimensions()
    var
        DimLbl: Label '%1 %2 %3', Comment = '%1=Journal Template Name, %2=Journal Batch Name, %3=Line No.';
    begin
        "Dimension Set ID" :=
          DimensionManagement.EditDimensionSet(
            "Dimension Set ID", StrSubstNo(DimLbl, "Journal Template Name", "Journal Batch Name", "Line No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    local procedure CheckGLAcc()
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.CheckGLAcc();
        if GLAccount."Direct Posting" or ("Journal Template Name" = '') then
            exit;
        if "Posting Date" <> 0D then
            if "Posting Date" = ClosingDate("Posting Date") then
                exit;
        GLAccount.TestField("Direct Posting", true);
    end;

    local procedure UpdateAmountOnECessandSHECess()
    begin
        if ("TDS % Applied" = 0) and (not "TDS Adjusted") then
            "Balance TDS Amount" := "TDS Base Amount" * "TDS %" / 100
        else
            "Balance TDS Amount" := "TDS Base Amount" * "TDS % Applied" / 100;

        if ("Surcharge % Applied" = 0) and (not "Surcharge Adjusted") then
            "Balance Surcharge Amount" := "Balance TDS Amount" * "Surcharge %" / 100
        else
            "Balance Surcharge Amount" := "Balance TDS Amount" * "Surcharge % Applied" / 100;
    end;

    local procedure UpdateAmountOnSurchargeApplied()
    begin
        if ("TDS % Applied" = 0) and (not "TDS Adjusted") then
            "Balance TDS Amount" := "TDS Base Amount" * "TDS %" / 100
        else
            "Balance TDS Amount" := "TDS Base Amount" * "TDS % Applied" / 100;
        "Surcharge Adjusted" := true;
        "Balance Surcharge Amount" := "Surcharge % Applied" * "Balance TDS Amount" / 100;

        if ("eCESS % Applied" = 0) and (not "TDS eCess Adjusted") then
            "Balance eCESS on TDS Amt" := ("Balance Surcharge Amount" + "Balance TDS Amount") * "eCESS %" / 100
        else
            "Balance eCESS on TDS Amt" := TDSEntityManagement.RoundTDSAmount(("Balance Surcharge Amount" + "Balance TDS Amount") * "eCESS % Applied" / 100);

        if ("SHE Cess % Applied" = 0) and (not "TDS SHE Cess Adjusted") then
            "Bal. SHE Cess on TDS Amt" := ("Balance Surcharge Amount" + "Balance TDS Amount") * "SHE Cess %" / 100
        else
            "Bal. SHE Cess on TDS Amt" := TDSEntityManagement.RoundTDSAmount(("Balance Surcharge Amount" + "Balance TDS Amount") * "SHE Cess % Applied" / 100);
    end;

    local procedure UpdateTDSAmount(var TDSJournalLine: Record "TDS Journal Line")
    var
        TDSAmount: Decimal;
    begin
        TDSAmount := TDSJournalLine."Balance TDS Amount" +
            TDSJournalLine."Balance Surcharge Amount" +
            TDSJournalLine."Balance eCESS on TDS Amt" +
            TDSJournalLine."Bal. SHE Cess on TDS Amt";

        if TDSJournalLine."Debit Amount" < TDSEntityManagement.RoundTDSAmount(TDSAmount) then begin
            TDSJournalLine.Amount := TDSEntityManagement.RoundTDSAmount(TDSAmount) - TDSJournalLine."Debit Amount";
            TDSJournalLine."Bal. TDS Including SHE CESS" := Abs(TDSEntityManagement.RoundTDSAmount(TDSAmount));
        end else begin
            TDSJournalLine.Amount := -(TDSJournalLine."Debit Amount" - TDSEntityManagement.RoundTDSAmount(TDSAmount));
            TDSJournalLine."Bal. TDS Including SHE CESS" := Abs(TDSEntityManagement.RoundTDSAmount(TDSAmount));
        end;
    end;

    local procedure RoundTDSAmounts(var TDSJournalLine: Record "TDS Journal Line")
    begin
        TDSJournalLine."Balance TDS Amount" := TDSEntityManagement.RoundTDSAmount(TDSJournalLine."Balance TDS Amount");
        TDSJournalLine."Balance Surcharge Amount" := TDSEntityManagement.RoundTDSAmount(TDSJournalLine."Balance Surcharge Amount");
        TDSJournalLine."Balance eCESS on TDS Amt" := TDSEntityManagement.RoundTDSAmount(TDSJournalLine."Balance eCESS on TDS Amt");
        TDSJournalLine."Bal. SHE Cess on TDS Amt" := TDSEntityManagement.RoundTDSAmount(TDSJournalLine."Bal. SHE Cess on TDS Amt");
    end;

    local procedure UpdateTDSJournalOnTDSApplied(var TDSJournalLine: Record "TDS Journal Line")
    var
        BalTDSIncludingSurchargeAmount: Decimal;
    begin
        BalTDSIncludingSurchargeAmount := TDSJournalLine."Balance TDS Amount" + TDSJournalLine."Balance Surcharge Amount";

        if (TDSJournalLine."Surcharge % Applied" = 0) and (not TDSJournalLine."Surcharge Adjusted") then begin
            TDSJournalLine."Surcharge % Applied" := TDSJournalLine."Surcharge %";
            TDSJournalLine."Balance Surcharge Amount" := TDSJournalLine."Surcharge %" * TDSJournalLine."Balance TDS Amount" / 100;
        end else
            TDSJournalLine."Balance Surcharge Amount" := TDSEntityManagement.RoundTDSAmount(
                TDSJournalLine."Balance TDS Amount" * TDSJournalLine."Surcharge % Applied" / 100);

        if (TDSJournalLine."eCESS % Applied" = 0) and (not TDSJournalLine."TDS eCess Adjusted") then begin
            TDSJournalLine."eCESS % Applied" := TDSJournalLine."eCESS %";
            TDSJournalLine."Balance eCESS on TDS Amt" := TDSJournalLine."eCESS %" * (BalTDSIncludingSurchargeAmount) / 100;
        end else
            TDSJournalLine."Balance eCESS on TDS Amt" := TDSEntityManagement.RoundTDSAmount(
            BalTDSIncludingSurchargeAmount * TDSJournalLine."eCESS % Applied" / 100);

        if (TDSJournalLine."SHE Cess % Applied" = 0) and (not TDSJournalLine."TDS SHE Cess Adjusted") then begin
            TDSJournalLine."SHE Cess % Applied" := TDSJournalLine."SHE Cess %";
            TDSJournalLine."Bal. SHE Cess on TDS Amt" := TDSJournalLine."SHE Cess %" * (BalTDSIncludingSurchargeAmount) / 100;
        end else
            TDSJournalLine."Bal. SHE Cess on TDS Amt" := TDSEntityManagement.RoundTDSAmount(
            (BalTDSIncludingSurchargeAmount) * TDSJournalLine."SHE Cess % Applied" / 100);
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
        DimensionManagement.AddDimSource(DefaultDimSource, DimensionManagement.TypeToTableID1("Account Type".AsInteger()), Rec."Account No.", FromFieldNo = Rec.Fieldno("Account No."));
        DimensionManagement.AddDimSource(DefaultDimSource, DimensionManagement.TypeToTableID1("Bal. Account Type".AsInteger()), Rec."Bal. Account No.", FromFieldNo = Rec.Fieldno("Bal. Account No."));
        DimensionManagement.AddDimSource(DefaultDimSource, Database::Job, '', false);
        DimensionManagement.AddDimSource(DefaultDimSource, Database::"Salesperson/Purchaser", Rec."Salespers./Purch. Code", FromFieldNo = Rec.FieldNo("Salespers./Purch. Code"));
        DimensionManagement.AddDimSource(DefaultDimSource, Database::Campaign, '', false);
    end;
}
