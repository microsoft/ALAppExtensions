// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ExciseTax;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Certificate;
using Microsoft.Sustainability.Setup;
using System.Security.AccessControl;

table 6241 "Sust. Excise Taxes Trans. Log"
{
    Caption = 'Excise Taxes Transaction Log';
    DataClassification = CustomerContent;
    LookupPageId = "Sust. Excise Taxes Trans. Logs";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Sust. Excise Journal Template";
        }
        field(3; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Sust. Excise Journal Batch".Name where("Journal Template Name" = field("Journal Template Name"));
        }
        field(5; "Log Type"; Enum "Sust. Excise Jnl. Tax Type")
        {
            Caption = 'Log Type';
        }
        field(10; "Entry Type"; Enum "Sust. Excise Jnl. Entry Type")
        {
            Caption = 'Entry Type';
        }
        field(11; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            NotBlank = true;
        }
        field(12; "Document Type"; Enum "Sust. Excise Document Type")
        {
            Caption = 'Document Type';
        }
        field(15; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            NotBlank = true;
        }
#if not CLEANSCHEMA29
        field(16; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = "Sustainability Account" where("Account Type" = const(Posting), Blocked = const(false));
            ObsoleteReason = 'This field is no longer required and will be removed in a future release.';
#if not CLEAN28
            ObsoleteState = Pending;
            ObsoleteTag = '28.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#endif
        }
        field(17; "Account Name"; Text[100])
        {
            Caption = 'Account Name';
            DataClassification = CustomerContent;
            ObsoleteReason = 'This field is no longer required and will be removed in a future release.';
#if not CLEAN28
            ObsoleteState = Pending;
            ObsoleteTag = '28.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#endif
        }
        field(18; "Account Category"; Code[20])
        {
            Caption = 'Account Category';
            Editable = false;
            TableRelation = "Sustain. Account Category";
            ObsoleteReason = 'This field is no longer required and will be removed in a future release.';
#if not CLEAN28
            ObsoleteState = Pending;
            ObsoleteTag = '28.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#endif
        }
        field(19; "Account Subcategory"; Code[20])
        {
            Caption = 'Account Subcategory';
            TableRelation = "Sustain. Account Subcategory".Code where("Category Code" = field("Account Category"));
            ObsoleteReason = 'This field is no longer required and will be removed in a future release.';
#if not CLEAN28
            ObsoleteState = Pending;
            ObsoleteTag = '28.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#endif
        }
#endif
        field(20; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(21; "Partner Type"; Enum "Sust. Excise Jnl. Partner Type")
        {
            Caption = 'Partner Type';
        }
        field(22; "Partner No."; Code[20])
        {
            Caption = 'Partner No.';
            TableRelation = if ("Partner Type" = const(Vendor)) Vendor
            else
            if ("Partner Type" = const(Customer)) Customer;
        }
        field(25; "Source Type"; Enum "Sust. Excise Jnl. Source Type")
        {
            Caption = 'Source Type';
        }
        field(26; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            TableRelation = if ("Source Type" = const(Item)) Item
            else
            if ("Source Type" = const("G/L Account")) "G/L Account" where("Direct Posting" = const(true), "Account Type" = const(Posting), Blocked = const(false))
            else
            if ("Source Type" = const("Fixed Asset")) "Fixed Asset"
            else
            if ("Source Type" = const("Charge (Item)")) "Item Charge"
            else
            if ("Source Type" = const(Resource)) Resource
            else
            if ("Source Type" = const(Certificate)) "Sustainability Certificate";
        }
        field(27; "Source Description"; Text[100])
        {
            Caption = 'Source Description';
        }
        field(28; "Source Unit of Measure Code"; Code[10])
        {
            TableRelation = "Unit of Measure";
            Caption = 'Source Unit of Measure';
        }
        field(29; "Source Qty."; Decimal)
        {
            Caption = 'Source Qty.';
        }
        field(40; "Material Breakdown No."; Code[20])
        {
            Caption = 'Material Breakdown No.';
        }
        field(41; "Material Breakdown Description"; Text[100])
        {
            Caption = 'Material Breakdown Description';
        }
        field(42; "Material Breakdown Weight"; Decimal)
        {
            Caption = 'Material Breakdown Weight';
        }
        field(43; "Material Breakdown UOM"; Code[10])
        {
            TableRelation = "Unit of Measure";
            Caption = 'Material Breakdown UOM';
        }
        field(50; "Total Embedded CO2e Emission"; Decimal)
        {
            Caption = 'Total Embedded CO2e Emission';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
        }
        field(51; "CO2e Unit of Measure"; Code[10])
        {
            TableRelation = "Unit of Measure";
            Caption = 'CO2e Unit of Measure';
        }
        field(60; "CBAM Certificates Required"; Boolean)
        {
            Caption = 'CBAM Certificates Required';
        }
        field(61; "Total Emission Cost"; Decimal)
        {
            Caption = 'Total Emission Cost';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
        }
        field(65; "Carbon Pricing Paid"; Boolean)
        {
            Caption = 'Carbon Pricing Paid';
        }
        field(70; "Already Paid Emission"; Decimal)
        {
            Caption = 'Already Paid Emission';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
        }
        field(80; "Adjusted CBAM Cost"; Decimal)
        {
            Caption = 'Adjusted CBAM Cost';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
        }
        field(90; "Certificate Amount"; Decimal)
        {
            Caption = 'Certificate Amount';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
        }
        field(100; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Editable = false;
            InitValue = 1;
        }
        field(110; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(120; "Source Document No."; Code[20])
        {
            Caption = 'Source Document No.';
        }
        field(121; "Source Document Line No."; Integer)
        {
            Caption = 'Source Document Line No.';
            Editable = false;
        }
        field(130; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            TableRelation = "Responsibility Center";
        }
        field(140; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(150; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(200; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
        }
        field(201; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions();
            end;
        }
        field(500; "Item Ledger Entry No."; Integer)
        {
            Caption = 'Item Ledger Entry No.';
            TableRelation = "Item Ledger Entry";
        }
        field(5156; "Shortcut Dimension 3 Code"; Code[20])
        {
            CaptionClass = '1,2,3';
            Caption = 'Shortcut Dimension 3 Code';
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"), "Global Dimension No." = const(3)));
        }
        field(5157; "Shortcut Dimension 4 Code"; Code[20])
        {
            CaptionClass = '1,2,4';
            Caption = 'Shortcut Dimension 4 Code';
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"), "Global Dimension No." = const(4)));
        }
        field(5158; "Shortcut Dimension 5 Code"; Code[20])
        {
            CaptionClass = '1,2,5';
            Caption = 'Shortcut Dimension 5 Code';
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"), "Global Dimension No." = const(5)));
        }
        field(5159; "Shortcut Dimension 6 Code"; Code[20])
        {
            CaptionClass = '1,2,6';
            Caption = 'Shortcut Dimension 6 Code';
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"), "Global Dimension No." = const(6)));
        }
        field(5160; "Shortcut Dimension 7 Code"; Code[20])
        {
            CaptionClass = '1,2,7';
            Caption = 'Shortcut Dimension 7 Code';
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"), "Global Dimension No." = const(7)));
        }
        field(5161; "Shortcut Dimension 8 Code"; Code[20])
        {
            CaptionClass = '1,2,8';
            Caption = 'Shortcut Dimension 8 Code';
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"), "Global Dimension No." = const(8)));
        }
        field(5170; "Calculated Date"; Date)
        {
            Caption = 'Calculated Date';
        }
        field(5171; "Calculated By"; Code[50])
        {
            Caption = 'Calculated By';
            TableRelation = User."User Name";
            DataClassification = EndUserIdentifiableInformation;
            ValidateTableRelation = false;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
        EntryRecIDLbl: Label '%1 %2', Locked = true;

    procedure CopyFromSustainabilityExciseJnlLine(SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line")
    begin
        Rec."Journal Template Name" := SustainabilityExciseJnlLine."Journal Template Name";
        Rec."Journal Batch Name" := SustainabilityExciseJnlLine."Journal Batch Name";
        Rec."Entry Type" := SustainabilityExciseJnlLine."Entry Type";
        Rec."Posting Date" := SustainabilityExciseJnlLine."Posting Date";
        Rec."Document Type" := SustainabilityExciseJnlLine."Document Type";
        Rec."Document No." := SustainabilityExciseJnlLine."Document No.";
        Rec.Description := SustainabilityExciseJnlLine.Description;
        Rec."Partner Type" := SustainabilityExciseJnlLine."Partner Type";
        Rec."Partner No." := SustainabilityExciseJnlLine."Partner No.";
        Rec."Source Type" := SustainabilityExciseJnlLine."Source Type";
        Rec."Source No." := SustainabilityExciseJnlLine."Source No.";
        Rec."Source Description" := SustainabilityExciseJnlLine."Source Description";
        Rec."Source Unit of Measure Code" := SustainabilityExciseJnlLine."Source Unit of Measure Code";
        Rec."Source Qty." := SustainabilityExciseJnlLine."Source Qty.";
        Rec."Material Breakdown No." := SustainabilityExciseJnlLine."Material Breakdown No.";
        Rec."Material Breakdown Description" := SustainabilityExciseJnlLine."Material Breakdown Description";
        Rec."Material Breakdown UOM" := SustainabilityExciseJnlLine."Material Breakdown UOM";
        Rec."Material Breakdown Weight" := SustainabilityExciseJnlLine."Material Breakdown Weight";
        Rec."Total Embedded CO2e Emission" := SustainabilityExciseJnlLine."Total Embedded CO2e Emission";
        Rec."CO2e Unit of Measure" := SustainabilityExciseJnlLine."CO2e Unit of Measure";
        Rec."CBAM Certificates Required" := SustainabilityExciseJnlLine."CBAM Certificates Required";
        Rec."Total Emission Cost" := SustainabilityExciseJnlLine."Total Emission Cost";
        Rec."Carbon Pricing Paid" := SustainabilityExciseJnlLine."Carbon Pricing Paid";
        Rec."Already Paid Emission" := SustainabilityExciseJnlLine."Already Paid Emission";
        Rec."Adjusted CBAM Cost" := SustainabilityExciseJnlLine."Adjusted CBAM Cost";
        Rec."Certificate Amount" := SustainabilityExciseJnlLine."Certificate Amount";
        Rec."Qty. per Unit of Measure" := SustainabilityExciseJnlLine."Qty. per Unit of Measure";
        Rec."Country/Region Code" := SustainabilityExciseJnlLine."Country/Region Code";
        Rec."Source Document No." := SustainabilityExciseJnlLine."Source Document No.";
        Rec."Source Document Line No." := SustainabilityExciseJnlLine."Source Document Line No.";
        Rec."Responsibility Center" := SustainabilityExciseJnlLine."Responsibility Center";
        Rec."Global Dimension 1 Code" := SustainabilityExciseJnlLine."Shortcut Dimension 1 Code";
        Rec."Global Dimension 2 Code" := SustainabilityExciseJnlLine."Shortcut Dimension 2 Code";
        Rec."Reason Code" := SustainabilityExciseJnlLine."Reason Code";
        Rec."Source Code" := SustainabilityExciseJnlLine."Source Code";
        Rec."Item Ledger Entry No." := SustainabilityExciseJnlLine."Item Ledger Entry No.";
        Rec."Dimension Set ID" := SustainabilityExciseJnlLine."Dimension Set ID";
        Rec."Calculated Date" := SustainabilityExciseJnlLine."Calculated Date";
        Rec."Calculated By" := SustainabilityExciseJnlLine."Calculated By";
    end;

    local procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo(EntryRecIDLbl, TableCaption(), "Entry No."));
    end;
}