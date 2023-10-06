// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Reconcilation;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;

table 18281 "GST Reconcilation Line"
{
    Caption = 'GST Reconcilation Lines';

    fields
    {
        field(1; "GSTIN No."; Code[20])
        {
            Caption = 'GSTIN No.';
            DataClassification = CustomerContent;
            TableRelation = "GST Registration Nos.";
        }
        field(2; "State Code"; Code[10])
        {
            Caption = 'State Code';
            DataClassification = CustomerContent;
            TableRelation = State;
        }
        field(3; Month; Integer)
        {
            Caption = 'Month';
            DataClassification = CustomerContent;
        }
        field(4; Year; Integer)
        {
            Caption = 'Year';
            DataClassification = CustomerContent;
        }
        field(5; "Document Type"; Option)
        {
            OptionCaption = 'Invoice,Revised Invoice, Debit Note, Revised Debit Note, Credit Note, Revised Credit Note, ISD Credit", TDS Credit, TCS Credit';
            OptionMembers = Invoice,"Revised Invoice","Debit Note","Revised Debit Note","Credit Note","Revised Credit Note","ISD Credit","TDS Credit","TCS Credit";
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(6; "GSTIN of Supplier"; Code[20])
        {
            Caption = 'GSTIN of Supplier';
            DataClassification = CustomerContent;
        }
        field(7; "Document No."; Code[35])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(9; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(11; "Goods/Services"; enum "GST Group Type")
        {
            Caption = 'Goods/Services';
            DataClassification = CustomerContent;
        }
        field(12; "HSN/SAC"; Code[10])
        {
            Caption = 'HSN/SAC';
            DataClassification = CustomerContent;
        }
        field(13; "Taxable Value"; Decimal)
        {
            Caption = 'Taxable Value';
            DataClassification = CustomerContent;
        }
        field(14; "Component 1 Rate"; Decimal)
        {
            Caption = 'Component 1 Rate';
            DataClassification = CustomerContent;
        }
        field(15; "Component 1 Amount"; Decimal)
        {
            Caption = 'Component 1 Amount';
            DataClassification = CustomerContent;
        }
        field(16; "Component 2 Rate"; Decimal)
        {
            Caption = 'Component 2 Rate';
            DataClassification = CustomerContent;
        }
        field(17; "Component 2 Amount"; Decimal)
        {
            Caption = 'Component 2 Amount';
            DataClassification = CustomerContent;
        }
        field(18; "Component 3 Rate"; Decimal)
        {
            Caption = 'Component 3 Rate';
            DataClassification = CustomerContent;
        }
        field(19; "Component 3 Amount"; Decimal)
        {
            Caption = 'Component 3 Amount';
            DataClassification = CustomerContent;
        }
        field(20; POS; Text[50])
        {
            Caption = 'POS';
            DataClassification = CustomerContent;
        }
        field(21; "Revised GSTIN of Supplier"; Code[20])
        {
            Caption = 'Revised GSTIN of Supplier';
            DataClassification = CustomerContent;
        }
        field(22; "Revised Document No."; Code[35])
        {
            Caption = 'Revised Document No.';
            DataClassification = CustomerContent;
        }
        field(23; "Revised Document Date"; Date)
        {
            Caption = 'Revised Document Date';
            DataClassification = CustomerContent;
        }
        field(24; "Revised Document Value"; Decimal)
        {
            Caption = 'Revised Document Value';
            DataClassification = CustomerContent;
        }
        field(25; "Revised Goods/Services"; Option)
        {
            Caption = 'Revised Goods/Services';
            OptionCaption = 'Goods, Services';
            OptionMembers = Goods,Services;
            DataClassification = CustomerContent;
        }
        field(26; "Revised HSN/SAC"; Code[10])
        {
            Caption = 'Revised HSN/SAC';
            DataClassification = CustomerContent;
        }
        field(27; "Revised Taxable Value"; Decimal)
        {
            Caption = 'Revised Taxable Value';
            DataClassification = CustomerContent;
        }
        field(28; "Type of Note"; Option)
        {
            Caption = 'Type of Note';
            OptionCaption = 'Debit, Credit';
            OptionMembers = Debit,Credit;
            DataClassification = CustomerContent;
        }
        field(29; "Debit/Credit Note No."; Code[35])
        {
            Caption = 'Debit/Credit Note No.';
            DataClassification = CustomerContent;
        }
        field(30; "Debit/Credit Note Date"; Date)
        {
            Caption = 'Debit/Credit Note Date';
            DataClassification = CustomerContent;
        }
        field(31; "Differential Value"; Decimal)
        {
            Caption = 'Differential Value';
            DataClassification = CustomerContent;
        }
        field(32; "Date of Payment to Deductee"; Date)
        {
            Caption = 'Date of Payment to Deductee';
            DataClassification = CustomerContent;
        }
        field(33; "Value on TDS has been Deducted"; Decimal)
        {
            Caption = 'Value on TDS has been Deducted';
            DataClassification = CustomerContent;
        }
        field(34; "Merch. ID alloc. By e-com port"; Code[35])
        {
            Caption = 'Merch. ID alloc. By e-com port';
            DataClassification = CustomerContent;
        }
        field(35; "Gross Value of Supplies"; Decimal)
        {
            Caption = 'Gross Value of Supplies';
            DataClassification = CustomerContent;
        }
        field(36; "Tax Value on TCS has Deducted"; Decimal)
        {
            Caption = 'Tax Value on TCS has Deducted';
            DataClassification = CustomerContent;
        }
        field(37; Reconciled; Boolean)
        {
            Caption = 'Reconciled';
            DataClassification = CustomerContent;
        }
        field(38; "Reconciliation Date"; Date)
        {
            Caption = 'Reconciliation Date';
            DataClassification = CustomerContent;
        }
        field(39; "User Id"; Code[50])
        {
            Caption = 'User Id';
            DataClassification = CustomerContent;
        }
        field(40; "External Document No."; Code[40])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(41; "Error Type"; Text[250])
        {
            Caption = 'Error Type';
            DataClassification = CustomerContent;
        }
        field(42; "GST Credit"; Option)
        {
            Caption = 'GST Credit';
            OptionMembers = Availment,"Non-Availment";
            OptionCaption = 'Availment,Non-Availment';
            DataClassification = CustomerContent;
        }
        field(43; "Credit Availed"; Boolean)
        {
            Caption = 'Credit Availed';
            DataClassification = CustomerContent;
        }
        field(46; "Component 4 Rate"; Decimal)
        {
            Caption = 'Component 4 Rate';
            DataClassification = CustomerContent;
        }
        field(47; "Component 4 Amount"; Decimal)
        {
            Caption = 'Component 4 Amount';
            DataClassification = CustomerContent;
        }
        field(48; "Component 5 Rate"; Decimal)
        {
            Caption = 'Component 5 Rate';
            DataClassification = CustomerContent;
        }
        field(49; "Component 5 Amount"; Decimal)
        {
            Caption = 'Component 5 Amount';
            DataClassification = CustomerContent;
        }
        field(50; "Component 6 Rate"; Decimal)
        {
            Caption = 'Component 6 Rate';
            DataClassification = CustomerContent;
        }
        field(51; "Component 6 Amount"; Decimal)
        {
            Caption = 'Component 6 Amount';
            DataClassification = CustomerContent;
        }
        field(52; "Component 7 Rate"; Decimal)
        {
            Caption = 'Component 7 Rate';
            DataClassification = CustomerContent;
        }
        field(53; "Component 7 Amount"; Decimal)
        {
            Caption = 'Component 7 Amount';
            DataClassification = CustomerContent;
        }
        field(54; "Component 8 Rate"; Decimal)
        {
            Caption = 'Component 8 Rate';
            DataClassification = CustomerContent;
        }
        field(55; "Component 8 Amount"; Decimal)
        {
            Caption = 'Component 8 Amount';
            DataClassification = CustomerContent;
        }
        field(56; "Input Service Distribution"; Boolean)
        {
            Caption = 'Input Service Distribution';
            DataClassification = CustomerContent;
        }
        field(57; "Component 1 Avl. Amount"; Decimal)
        {
            Caption = 'Component 1 Avl. Amount';
            DataClassification = CustomerContent;
        }
        field(58; "Component 2 Avl. Amount"; Decimal)
        {
            Caption = 'Component 2 Avl. Amount';
            DataClassification = CustomerContent;
        }
        field(59; "Component 3 Avl. Amount"; Decimal)
        {
            Caption = 'Component 3 Avl. Amount';
            DataClassification = CustomerContent;
        }
        field(60; "Component 4 Avl. Amount"; Decimal)
        {
            Caption = 'Component 4 Avl. Amount';
            DataClassification = CustomerContent;
        }
        field(61; "Component 5 Avl. Amount"; Decimal)
        {
            Caption = 'Component 5 Avl. Amount';
            DataClassification = CustomerContent;
        }
        field(62; "Component 6 Avl. Amount"; Decimal)
        {
            Caption = 'Component 6 Avl. Amount';
            DataClassification = CustomerContent;
        }
        field(63; "Component 7 Avl. Amount"; Decimal)
        {
            Caption = 'Component 7 Avl. Amount';
            DataClassification = CustomerContent;
        }
        field(64; "Component 8 Avl. Amount"; Decimal)
        {
            Caption = 'Component 8 Avl. Amount';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "GSTIN No.", "State Code", Month, Year, "Document No.")
        {
            Clustered = true;
        }
        key(Key2; "GSTIN No.", Reconciled, "Credit Availed", Month, Year)
        {
        }
        key(Key3; "Document Type", "Document No.", "GSTIN No.", Month, Year, "HSN/SAC")
        {
        }
    }
}
