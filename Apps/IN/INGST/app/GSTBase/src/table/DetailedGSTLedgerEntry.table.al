// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

table 18001 "Detailed GST Ledger Entry"
{
    Caption = 'Detailed GST Ledger Entry';
    LookupPageId = "Detailed GST Ledger Entry";
    DrillDownPageId = "Detailed GST Ledger Entry";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "Entry Type"; Enum "Detail Ledger Entry Type")
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
        }
        field(3; "Transaction Type"; Enum "Detail Ledger Transaction Type")
        {
            Caption = 'Transaction Type';
            DataClassification = CustomerContent;
        }
        field(4; "Document Type"; Enum "GST Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(7; Type; enum Type)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(8; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = if (Type = const("G/L Account")) "G/L Account"
            else
            if (Type = const(Item)) Item
            else
            if (Type = const(Resource)) Resource
            else
            if (Type = const("Fixed Asset")) "Fixed Asset"
            else
            if (Type = const("Charge (Item)")) "Item Charge";
        }
        field(9; "Product Type"; enum "Product Type")
        {
            Caption = 'Product Type';
            DataClassification = CustomerContent;
        }
        field(10; "Source Type"; enum "Source Type")
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
        }
        field(11; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Source Type" = const(Customer)) Customer
            else
            if ("Source Type" = const(Vendor)) Vendor;
        }
        field(12; "HSN/SAC Code"; Code[10])
        {
            Caption = 'HSN/SAC Code';
            DataClassification = CustomerContent;
            TableRelation = "HSN/SAC".Code where("GST Group Code" = field("GST Group Code"));
        }
        field(13; "GST Component Code"; Code[30])
        {
            Caption = 'GST Component Code';
            DataClassification = CustomerContent;
        }
        field(14; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            TableRelation = "GST Group";
            DataClassification = CustomerContent;
        }
        field(15; "GST Jurisdiction Type"; enum "GST Jurisdiction Type")
        {
            Caption = 'GST Jurisdiction Type';
            DataClassification = CustomerContent;
        }
        field(16; "GST Base Amount"; Decimal)
        {
            Caption = 'GST Base Amount';
            DataClassification = CustomerContent;
        }
        field(17; "GST %"; Decimal)
        {
            Caption = 'GST %';
            DataClassification = CustomerContent;
        }
        field(18; "GST Amount"; Decimal)
        {
            Caption = 'GST Amount';
            DataClassification = CustomerContent;
        }
        field(19; "External Document No."; Code[40])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(20; "Amount Loaded on Item"; Decimal)
        {
            Caption = 'Amount Loaded on Item';
            DataClassification = CustomerContent;
        }
        field(21; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(22; "GST Without Payment of Duty"; Boolean)
        {
            Caption = 'GST Without Payment of Duty';
            DataClassification = CustomerContent;
        }
        field(23; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }
        field(24; "Reversed by Entry No."; Integer)
        {
            Caption = 'Reversed by Entry No.';
            DataClassification = CustomerContent;
        }
        field(25; Reversed; Boolean)
        {
            Caption = 'Reversed';
            DataClassification = CustomerContent;
        }
        field(26; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = CustomerContent;
        }
        field(27; "Item Charge Entry"; Boolean)
        {
            Caption = 'Item Charge Entry';
            DataClassification = CustomerContent;
        }
        field(28; "Reverse Charge"; Boolean)
        {
            Caption = 'Reverse Charge';
            DataClassification = CustomerContent;
        }
        field(29; "GST on Advance Payment"; Boolean)
        {
            Caption = 'GST on Advance Payment';
            DataClassification = CustomerContent;
        }
        field(30; "Payment Document No."; Code[20])
        {
            Caption = 'Payment Document No.';
            DataClassification = CustomerContent;
        }
        field(31; "GST Exempted Goods"; Boolean)
        {
            Caption = 'GST Exempted Goods';
            DataClassification = CustomerContent;
        }
        field(32; "Location  Reg. No."; Code[20])
        {
            Caption = 'Location  Reg. No.';
            DataClassification = CustomerContent;
        }
        field(33; "Buyer/Seller Reg. No."; Code[20])
        {
            Caption = 'Buyer/Seller Reg. No.';
            DataClassification = CustomerContent;
        }
        field(34; "GST Group Type"; enum "GST Group Type")
        {
            Caption = 'GST Group Type';
            DataClassification = CustomerContent;
        }
        field(35; "GST Credit"; enum "GST Credit")
        {
            Caption = 'GST Credit';
            DataClassification = CustomerContent;
        }
        field(36; "Reversal Entry"; Boolean)
        {
            Caption = 'Reversal Entry';
            DataClassification = CustomerContent;
        }
        field(37; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            DataClassification = CustomerContent;
        }
        field(38; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }
        field(39; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 1 : 6;
            DataClassification = CustomerContent;
        }
        field(40; "Application Doc. Type"; Enum "Application Doc Type")
        {
            Caption = 'Application Doc. Type';
            DataClassification = CustomerContent;
        }
        field(41; "Application Doc. No"; Code[20])
        {
            Caption = 'Application Doc. No';
            DataClassification = CustomerContent;
        }
        field(42; "Applied From Entry No."; Integer)
        {
            Caption = 'Applied From Entry No.';
            DataClassification = CustomerContent;
        }
        field(43; "Reversed Entry No."; Integer)
        {
            Caption = 'Reversed Entry No.';
            DataClassification = CustomerContent;
        }
        field(44; "Remaining Closed"; Boolean)
        {
            Caption = 'Remaining Closed';
            DataClassification = CustomerContent;
        }
        field(45; "GST Rounding Precision"; Decimal)
        {
            Caption = 'GST Rounding Precision';
            DataClassification = CustomerContent;
        }
        field(46; "GST Rounding Type"; Enum "GST Inv Rounding Type")
        {
            Caption = 'GST Rounding Type';
            DataClassification = CustomerContent;
        }
        field(47; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location where("Use As In-Transit" = const(false));
            DataClassification = CustomerContent;
        }
        field(48; "GST Customer Type"; Enum "GST Customer Type")
        {
            Caption = 'GST Customer Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(49; "GST Vendor Type"; Enum "GST Vendor Type")
        {
            Caption = 'GST Vendor Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(50; "Original Invoice No."; Code[20])
        {
            Caption = 'Original Invoice No.';
            DataClassification = CustomerContent;
        }
        field(51; "Reconciliation Month"; Integer)
        {
            Caption = 'Reconciliation Month';
            DataClassification = CustomerContent;
        }
        field(52; "Reconciliation Year"; Integer)
        {
            Caption = 'Reconciliation Year';
            DataClassification = CustomerContent;
        }
        field(53; Reconciled; Boolean)
        {
            Caption = 'Reconciled';
            DataClassification = CustomerContent;
        }
        field(54; "Credit Availed"; Boolean)
        {
            Caption = 'Credit Availed';
            DataClassification = CustomerContent;
        }
        field(55; Paid; Boolean)
        {
            Caption = 'Paid';
            DataClassification = CustomerContent;
        }
        field(56; "Credit Adjustment Type"; Enum "Credit Adjustment Type")
        {
            Caption = 'Credit Adjustment Type';
            DataClassification = CustomerContent;
        }
        field(57; UnApplied; Boolean)
        {
            Caption = 'UnApplied';
            DataClassification = CustomerContent;
        }
        field(58; "GST Place of Supply"; enum "GST Dependency Type")
        {
            Caption = 'GST Place of Supply';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(59; "Payment Type"; Enum "Payment Type")
        {
            Caption = 'Payment Type';
            DataClassification = CustomerContent;
        }
        field(60; Distributed; Boolean)
        {
            Caption = 'Distributed';
            DataClassification = CustomerContent;
        }
        field(61; "Distributed Reversed"; Boolean)
        {
            Caption = 'Distributed Reversed';
            DataClassification = CustomerContent;
        }
        field(62; "Input Service Distribution"; Boolean)
        {
            Caption = 'Input Service Distribution';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(63; Opening; Boolean)
        {
            Caption = 'Opening';
            DataClassification = CustomerContent;
        }
        field(64; "Remaining Base Amount"; Decimal)
        {
            Caption = 'Remaining Base Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(65; "Remaining GST Amount"; Decimal)
        {
            Caption = 'Remaining GST Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(66; "Dist. Document No."; Code[20])
        {
            Caption = 'Dist. Document No.';
            DataClassification = CustomerContent;
        }
        field(67; "Associated Enterprises"; Boolean)
        {
            Caption = 'Associated Enterprises';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(68; "Liable to Pay"; Boolean)
        {
            Caption = 'Liable to Pay';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(69; "Dist. Input GST Credit"; Boolean)
        {
            Caption = 'Dist. Input GST Credit';
            DataClassification = CustomerContent;
        }
        field(70; "Dist. Reverse Document No."; Code[20])
        {
            Caption = 'Dist. Reverse Document No.';
            DataClassification = CustomerContent;
        }
        field(71; "Eligibility for ITC"; Enum "Eligibility for ITC")
        {
            Caption = 'Eligibility for ITC';
            DataClassification = CustomerContent;
        }
        field(72; "GST Assessable Value"; Decimal)
        {
            Caption = 'GST Assessable Value';
            DataClassification = CustomerContent;
        }
        field(73; "GST Inv. Rounding Precision"; Decimal)
        {
            Caption = 'GST Inv. Rounding Precision';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(74; "GST Inv. Rounding Type"; enum "GST Inv Rounding Type")
        {
            Caption = 'GST Inv. Rounding Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75; "Cr. & Liab. Adjustment Type"; Enum "Cr Libty Adjustment Type")
        {
            Caption = 'Cr. & Liab. Adjustment Type';
            DataClassification = CustomerContent;
        }
        field(76; "AdjustmentBase Amount"; Decimal)
        {
            Caption = 'AdjustmentBase Amount';
            DataClassification = CustomerContent;
        }
        field(77; "Adjustment Amount"; Decimal)
        {
            Caption = 'Adjustment Amount';
            DataClassification = CustomerContent;
        }
        field(78; "Custom Duty Amount"; Decimal)
        {
            Caption = 'Custom Duty Amount';
            DataClassification = CustomerContent;
        }
        field(79; "Journal Entry"; Boolean)
        {
            Caption = 'Journal Entry';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(80; "Remaining Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Remaining Quantity';
        }
        field(81; "ARN No."; Code[20])
        {
            Caption = 'ARN No.';
            DataClassification = CustomerContent;
        }
        field(82; "Forex Fluctuation"; Boolean)
        {
            Caption = 'Forex Fluctuation';
            DataClassification = CustomerContent;
        }
        field(83; "Fluctuation Amt. Credit"; Boolean)
        {
            Caption = 'Fluctuation Amt. Credit';
            DataClassification = CustomerContent;
        }
        field(84; "CAJ %"; Decimal)
        {
            Caption = 'CAJ %';
            DataClassification = CustomerContent;
        }
        field(85; "CAJ Amount"; Decimal)
        {
            Caption = 'CAJ Amount';
            DataClassification = CustomerContent;
        }
        field(86; "CAJ % Permanent Reversal"; Decimal)
        {
            Caption = 'CAJ % Permanent Reversal';
            DataClassification = CustomerContent;
        }
        field(87; "CAJ Amount Permanent Reversal"; Decimal)
        {
            Caption = 'CAJ Amount Permanent Reversal';
            DataClassification = CustomerContent;
        }
        field(88; "Remaining CAJ Adj. Base Amt"; Decimal)
        {
            Caption = 'Remaining CAJ Adj. Base Amt';
            DataClassification = CustomerContent;
        }
        field(89; "Remaining CAJ Adj. Amt"; Decimal)
        {
            Caption = 'Remaining CAJ Adj. Amt';
            DataClassification = CustomerContent;
        }
        field(90; "CAJ Base Amount"; Decimal)
        {
            Caption = 'CAJ Base Amount';
            DataClassification = CustomerContent;
        }
        field(91; "G/L Entry No."; Integer)
        {
            Caption = 'G/L Entry No.';
            DataClassification = CustomerContent;
            Editable = False;
        }
        field(92; "Skip Tax Engine Trigger"; Boolean)
        {
            Caption = 'Skip Tax Engine Trigger';
            DataClassification = CustomerContent;
            Editable = False;
        }
        field(93; "Executed Use Case ID"; Guid)
        {
            Caption = 'Executed Use Case ID';
            DataClassification = CustomerContent;
            Editable = False;
        }
        field(94; "Post GST to Customer"; Boolean)
        {
            Caption = 'Post GST to Customer';
            DataClassification = CustomerContent;
            Editable = False;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Transaction No.")
        {
        }
        key(Key3; "Transaction Type", "Location  Reg. No.", "Document Type", Reconciled, "GST Vendor Type", Reversed, "Posting Date", Paid, "Credit Adjustment Type")
        {
        }
        key(Key4; "Location  Reg. No.", "Transaction Type", "Entry Type", "GST Vendor Type", "GST Credit", "Reconciliation Month", "Reconciliation Year")
        {
        }
        key(Key5; "Document No.", "Document Line No.", "GST Component Code")
        {
        }
        key(Key6; "Transaction Type", "Document Type", "Document No.", "Document Line No.")
        {
        }
        key(Key7; "Payment Document No.")
        {
        }
        key(Key9; "Transaction Type", "Document Type", "Document No.", "Transaction No.")
        {
        }
        key(Key11; "Document No.", "HSN/SAC Code")
        {
            SumIndexFields = "GST Base Amount", "GST Amount";
        }
        key(Key14; "Transaction Type", "Document Type", "Document No.", "Document Line No.", "GST Component Code")
        {
            SumIndexFields = "GST Amount";
        }
        key(Key15; "Transaction Type", "Source Type", "Source No.", "Document Type", "Document No.", "GST Group Type")
        {
        }
        key(Key17; "Document No.", "GST Component Code")
        {
        }
        key(Key18; "Entry Type", "Transaction Type", "Document Type", "Document No.", "Document Line No.")
        {
        }
        key(Key19; "Transaction Type", "Entry Type", "Document No.", "Document Line No.")
        {
        }
        key(Key20; "Dist. Document No.", Distributed)
        {
        }
        key(Key21; "Location  Reg. No.", Reconciled, "Reconciliation Month", "Reconciliation Year")
        {
        }
        key(Key22; "Location  Reg. No.", "Transaction Type", "Entry Type", "GST Vendor Type", "GST Credit", "Posting Date", "Source No.", "Document Type", "Document No.")
        {
        }
        key(Key23; "Location  Reg. No.", "Transaction Type", "Entry Type", "GST Vendor Type", "GST Credit", "Posting Date", "Source No.", "Document Type", "Document No.", "Document Line No.")
        {
        }
        key(Key24; "Transaction Type", "GST Jurisdiction Type", "Source No.", "Document Type", "Document No.", "Posting Date")
        {
        }
        key(Key25; "Location  Reg. No.", "GST Component Code", Paid, "Posting Date", "Liable to Pay", "Reverse Charge")
        {
        }
        key(Key26; "Location  Reg. No.", "GST Component Code", Paid, "Posting Date", "Credit Availed")
        {
        }
        key(Key27; "Location  Reg. No.", "Posting Date", "Entry Type", "Transaction Type", "Document Type")
        {
        }
        key(Key28; "Location  Reg. No.", "Document Type", "Document No.", "HSN/SAC Code", "GST %")
        {
            SumIndexFields = "GST Amount";
        }
        key(Key29; "Transaction Type", "Entry Type", "Document Type", "Document No.", "Posting Date")
        {
        }
    }
}
