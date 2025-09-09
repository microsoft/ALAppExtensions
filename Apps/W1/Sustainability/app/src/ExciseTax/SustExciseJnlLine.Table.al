// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ExciseTax;

using Microsoft.Finance.Dimension;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Finance.GeneralLedger.Account;
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
using Microsoft.Sustainability.CBAM;
using Microsoft.Sustainability.Certificate;
using Microsoft.Sustainability.EPR;
using Microsoft.Sustainability.Setup;
using System.Security.AccessControl;

table 6240 "Sust. Excise Jnl. Line"
{
    Caption = 'Excise Journal Line';
    DataClassification = CustomerContent;
    LookupPageId = "Sustainability Excise Journal";
    DataPerCompany = true;
    Extensible = true;

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Sust. Excise Journal Template";
            NotBlank = true;
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Sust. Excise Journal Batch".Name where("Journal Template Name" = field("Journal Template Name"));
            NotBlank = true;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            NotBlank = true;
        }
        field(5; "Entry Type"; Enum "Sust. Excise Jnl. Entry Type")
        {
            Caption = 'Entry Type';

            trigger OnValidate()
            begin
                Validate("Partner Type", "Partner Type"::" ");
                if (Rec."Document Type" <> Rec."Document Type"::" ") then
                    ValidateSustainabilityExciseJournalLineByField(Rec, Rec.FieldNo("Entry Type"));
            end;
        }
        field(6; "Document Type"; Enum "Sust. Excise Document Type")
        {
            Caption = 'Document Type';

            trigger OnValidate()
            begin
                if Rec."Document Type" <> Rec."Document Type"::" " then
                    ValidateSustainabilityExciseJournalLineByField(Rec, Rec.FieldNo("Document Type"));
            end;
        }
        field(7; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            NotBlank = true;
        }
#if not CLEANSCHEMA29
        field(8; "Account No."; Code[20])
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
        field(9; "Account Name"; Text[100])
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
        field(10; "Account Category"; Code[20])
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
        field(11; "Account Subcategory"; Code[20])
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
        field(12; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(13; "Partner Type"; Enum "Sust. Excise Jnl. Partner Type")
        {
            Caption = 'Partner Type';
            trigger OnValidate()
            begin
                if Rec."Partner Type" <> Rec."Partner Type"::" " then begin
                    if Rec."Entry Type" = Rec."Entry Type"::Purchase then
                        Rec.TestField("Partner Type", "Partner Type"::Vendor);

                    if Rec."Entry Type" = Rec."Entry Type"::Sales then
                        Rec.TestField("Partner Type", "Partner Type"::Customer);
                end;

                if xRec."Partner Type" <> Rec."Partner Type" then begin
                    Rec.Validate("Partner No.", '');
                    Rec.Validate("Source Type", Rec."Source Type"::" ");
                    ClearEmissionInformation(Rec);
                end;
            end;
        }
        field(14; "Partner No."; Code[20])
        {
            Caption = 'Partner No.';
            TableRelation = if ("Partner Type" = const(Vendor)) Vendor
            else
            if ("Partner Type" = const(Customer)) Customer;

            trigger OnValidate()
            begin
                if Rec."Partner No." <> '' then
                    Rec.TestField("Partner Type");

                CreateDimFromDefaultDim(FieldNo("Partner No."));
            end;
        }
        field(17; "Source of Emission Data"; Enum "Sust. Source of Emission")
        {
            Caption = 'Source of Emission Data';
        }
        field(18; "Emission Verified"; Boolean)
        {
            Caption = 'Emission Verified';

            trigger OnValidate()
            begin
                if Rec."Emission Verified" then
                    ValidateSustainabilityExciseJournalLineByField(Rec, Rec.FieldNo("Emission Verified"));
            end;
        }
        field(19; "CBAM Compliance"; Boolean)
        {
            Caption = 'CBAM Compliance';

            trigger OnValidate()
            begin
                if Rec."CBAM Compliance" then
                    ValidateSustainabilityExciseJournalLineByField(Rec, Rec.FieldNo("CBAM Compliance"));
            end;
        }
        field(20; "Source Type"; Enum "Sust. Excise Jnl. Source Type")
        {
            Caption = 'Source Type';

            trigger OnValidate()
            begin
                Rec.Validate("Source No.", '');
                Rec.Validate("Source Description", '');
                Rec.Validate("Source Unit of Measure Code", '');
                Rec.Validate("Source Qty.", 0);
            end;
        }
        field(21; "Source No."; Code[20])
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
            if ("Source Type" = const(Certificate)) "Sustainability Certificate"."No." where(Type = const(Vendor));

            trigger OnValidate()
            var
                Item: Record Item;
                GLAccount: Record "G/L Account";
                FixedAsset: Record "Fixed Asset";
                ItemCharge: Record "Item Charge";
                Resource: Record Resource;
                SustainabilityCertificate: Record "Sustainability Certificate";
                SustainabilityExciseJnlBatch: Record "Sust. Excise Journal Batch";
            begin
                Rec.Validate("Source Description", '');
                if Rec."Source No." = '' then begin
                    CreateDimFromDefaultDim(FieldNo("Source No."));
                    exit;
                end;

                Rec.TestField("Partner No.");
                case "Source Type" of
                    Rec."Source Type"::Item:
                        begin
                            Item.Get(Rec."Source No.");

                            Rec.Validate("Source Description", Item.Description);
                            Rec.Validate("Source Unit of Measure Code", Item."Base Unit of Measure");

                            SustainabilityExciseJnlBatch.Get("Journal Template Name", "Journal Batch Name");
                            if SustainabilityExciseJnlBatch.Type = SustainabilityExciseJnlBatch.Type::EPR then
                                Rec.Validate("Material Breakdown No.", Item."Material Composition No.");
                        end;
                    Rec."Source Type"::"G/L Account":
                        begin
                            GLAccount.Get(Rec."Source No.");

                            Rec.Validate("Source Description", GLAccount.Name);
                        end;
                    Rec."Source Type"::"Fixed Asset":
                        begin
                            FixedAsset.Get(Rec."Source No.");

                            Rec.Validate("Source Description", FixedAsset.Description);
                        end;
                    Rec."Source Type"::"Charge (Item)":
                        begin
                            ItemCharge.Get(Rec."Source No.");

                            Rec.Validate("Source Description", ItemCharge.Description);
                        end;
                    Rec."Source Type"::Resource:
                        begin
                            Resource.Get(Rec."Source No.");

                            Rec.Validate("Source Description", Resource.Name);
                            Rec.Validate("Source Unit of Measure Code", Resource."Base Unit of Measure");
                        end;
                    Rec."Source Type"::Certificate:
                        begin
                            Rec.TestField("Partner Type", Rec."Partner Type"::Vendor);
                            SustainabilityCertificate.Get(SustainabilityCertificate.Type::Vendor, Rec."Source No.");

                            Rec.Validate("Source Description", SustainabilityCertificate.Name);
                        end;
                end;

                CreateDimFromDefaultDim(FieldNo("Source No."));
            end;
        }
        field(22; "Source Description"; Text[100])
        {
            Caption = 'Source Description';
        }
        field(23; "Source Unit of Measure Code"; Code[10])
        {
            TableRelation = "Unit of Measure";
            Caption = 'Source Unit of Measure';

            trigger OnValidate()
            var
                Item: Record Item;
                ResUnitofMeasure: Record "Resource Unit of Measure";
                UOMMgt: Codeunit "Unit of Measure Management";
            begin
                if Rec."Source Unit of Measure Code" <> '' then
                    Rec.TestField("Source No.");

                if Rec."Source Unit of Measure Code" <> '' then
                    case Rec."Source Type" of
                        Rec."Source Type"::Item:
                            begin
                                Item.Get(Rec."Source No.");
                                "Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item, "Source Unit of Measure Code");
                            end;
                        Rec."Source Type"::Resource:
                            begin
                                ResUnitofMeasure.Get("Source No.", "Source Unit of Measure Code");
                                "Qty. per Unit of Measure" := ResUnitofMeasure."Qty. per Unit of Measure";
                            end;
                    end;
            end;
        }
        field(24; "Source Qty."; Decimal)
        {
            Caption = 'Source Qty.';

            trigger OnValidate()
            begin
                if Rec."Source Qty." <> 0 then
                    Rec.TestField("Source No.");

                UpdateSustainabilityEmission(Rec);
            end;
        }
        field(25; "Material Breakdown No."; Code[20])
        {
            Caption = 'Material Breakdown No.';
            TableRelation = "Sust. Item Mat. Comp. Header"."No.";

            trigger OnValidate()
            var
                ItemMatCompHeader: Record "Sust. Item Mat. Comp. Header";
            begin
                Rec."Material Breakdown Description" := '';
                Rec."Material Breakdown UOM" := '';
                Rec."Material Breakdown Weight" := 0;

                if Rec."Material Breakdown No." <> '' then begin
                    ValidateSustainabilityExciseJournalLineByField(Rec, Rec.FieldNo("Material Breakdown No."));

                    ItemMatCompHeader.Get(Rec."Material Breakdown No.");

                    ItemMatCompHeader.TestField(Status, ItemMatCompHeader.Status::Certified);
                    Rec.Validate("Material Breakdown Description", ItemMatCompHeader.Description);
                    Rec.Validate("Material Breakdown UOM", ItemMatCompHeader."Unit of Measure Code");
                    Rec.Validate("Material Breakdown Weight", GetTotalWeightOfItemMaterialComposition(ItemMatCompHeader."No."));
                end
            end;
        }
        field(26; "Material Breakdown Description"; Text[100])
        {
            Caption = 'Material Breakdown Description';

            trigger OnValidate()
            begin
                if Rec."Material Breakdown Description" <> '' then
                    ValidateSustainabilityExciseJournalLineByField(Rec, Rec.FieldNo("Material Breakdown Description"));
            end;
        }
        field(27; "Material Breakdown UOM"; Code[10])
        {
            TableRelation = "Unit of Measure";
            Caption = 'Material Breakdown Unit of Measure';

            trigger OnValidate()
            begin
                if Rec."Material Breakdown UOM" <> '' then
                    ValidateSustainabilityExciseJournalLineByField(Rec, Rec.FieldNo("Material Breakdown UOM"));
            end;
        }
        field(28; "Material Breakdown Weight"; Decimal)
        {
            Caption = 'Material Breakdown Weight';

            trigger OnValidate()
            begin
                if Rec."Material Breakdown Weight" <> 0 then
                    ValidateSustainabilityExciseJournalLineByField(Rec, Rec.FieldNo("Material Breakdown Weight"));
            end;
        }
        field(29; "CO2e Emission per Unit"; Decimal)
        {
            Caption = 'CO2e Emission per Unit';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));

            trigger OnValidate()
            begin
                if Rec."CO2e Emission per Unit" <> 0 then
                    ValidateSustainabilityExciseJournalLineByField(Rec, Rec.FieldNo("CO2e Emission per Unit"));

                UpdateSustainabilityEmission(Rec);
            end;
        }
        field(30; "CO2e Unit of Measure"; Code[10])
        {
            TableRelation = "Unit of Measure";
            Caption = 'CO2e Unit of Measure';

            trigger OnValidate()
            begin
                if Rec."CO2e Unit of Measure" <> '' then
                    ValidateSustainabilityExciseJournalLineByField(Rec, Rec.FieldNo("CO2e Unit of Measure"));
            end;
        }
        field(31; "Total Embedded CO2e Emission"; Decimal)
        {
            Caption = 'Total Embedded CO2e Emission';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));

            trigger OnValidate()
            begin
                if Rec."Total Embedded CO2e Emission" <> 0 then
                    ValidateSustainabilityExciseJournalLineByField(Rec, Rec.FieldNo("Total Embedded CO2e Emission"));

                UpdateEmissionPerUnit(Rec);

                if CurrFieldNo = Rec.FieldNo("Total Embedded CO2e Emission") then
                    UpdateCarbonPricingInExciseJournalLine(Rec);
            end;
        }
        field(32; "CBAM Certificates Required"; Boolean)
        {
            Caption = 'CBAM Certificates Required';

            trigger OnValidate()
            begin
                if Rec."CBAM Certificates Required" then
                    ValidateSustainabilityExciseJournalLineByField(Rec, Rec.FieldNo("CBAM Certificates Required"));
            end;
        }
        field(35; "Emission Cost per Unit"; Decimal)
        {
            Caption = 'Emission Cost per Unit';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));

            trigger OnValidate()
            begin
                if Rec."Emission Cost per Unit" <> 0 then
                    ValidateSustainabilityExciseJournalLineByField(Rec, Rec.FieldNo("Emission Cost per Unit"));

                UpdateSustainabilityEmission(Rec);
            end;
        }
        field(36; "Total Emission Cost"; Decimal)
        {
            Caption = 'Total Emission Cost';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));

            trigger OnValidate()
            var
                SustainabilityExciseJnlBatch: Record "Sust. Excise Journal Batch";
            begin
                if Rec."Total Emission Cost" <> 0 then
                    ValidateSustainabilityExciseJournalLineByField(Rec, Rec.FieldNo("Total Emission Cost"));

                UpdateEmissionPerUnit(Rec);

                SustainabilityExciseJnlBatch.Get("Journal Template Name", "Journal Batch Name");
                if SustainabilityExciseJnlBatch.Type = SustainabilityExciseJnlBatch.Type::CBAM then
                    Rec.Validate("Adjusted CBAM Cost", Rec."Total Emission Cost" - Rec."Already Paid Emission");
            end;
        }
        field(40; "Carbon Pricing Paid"; Boolean)
        {
            Caption = 'Carbon Pricing Paid';

            trigger OnValidate()
            begin
                if Rec."Carbon Pricing Paid" then
                    ValidateSustainabilityExciseJournalLineByField(Rec, Rec.FieldNo("Carbon Pricing Paid"));
            end;
        }
        field(41; "Already Paid Emission"; Decimal)
        {
            Caption = 'Already Paid Emission';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));

            trigger OnValidate()
            begin
                if Rec."Already Paid Emission" <> 0 then
                    ValidateSustainabilityExciseJournalLineByField(Rec, Rec.FieldNo("Already Paid Emission"));

                Rec.Validate("Adjusted CBAM Cost", Rec."Total Emission Cost" - Rec."Already Paid Emission");
            end;
        }
        field(42; "Adjusted CBAM Cost"; Decimal)
        {
            Caption = 'Adjusted CBAM Cost';
            Editable = false;
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));

            trigger OnValidate()
            begin
                if Rec."Adjusted CBAM Cost" <> 0 then
                    ValidateSustainabilityExciseJournalLineByField(Rec, Rec.FieldNo("Adjusted CBAM Cost"));
            end;
        }
        field(43; "Certificate Amount"; Decimal)
        {
            Caption = 'Certificate Amount';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));

            trigger OnValidate()
            begin
                if Rec."Certificate Amount" <> 0 then
                    ValidateSustainabilityExciseJournalLineByField(Rec, Rec.FieldNo("Certificate Amount"));
            end;
        }
        field(45; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Editable = false;
            InitValue = 1;
        }
        field(50; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(55; "Source Document No."; Code[20])
        {
            Caption = 'Source Document No.';
        }
        field(56; "Source Document Line No."; Integer)
        {
            Caption = 'Source Document Line No.';
            Editable = false;
        }
        field(60; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            TableRelation = "Responsibility Center";
        }
        field(70; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1), Blocked = const(false));

            trigger OnValidate()
            begin
                DimMgt.ValidateShortcutDimValues(1, "Shortcut Dimension 1 Code", "Dimension Set ID");
            end;
        }
        field(71; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2), Blocked = const(false));

            trigger OnValidate()
            begin
                DimMgt.ValidateShortcutDimValues(2, "Shortcut Dimension 2 Code", "Dimension Set ID");
            end;
        }
        field(80; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
        }
        field(90; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions();
            end;

            trigger OnValidate()
            begin
                DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            end;
        }
        field(500; "Item Ledger Entry No."; Integer)
        {
            Caption = 'Item Ledger Entry No.';
            TableRelation = "Item Ledger Entry";
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
        key(PK; "Journal Template Name", "Journal Batch Name", "Line No.")
        {
            Clustered = true;
        }
        key(SortOnDocumentNo; "Document No.")
        {
        }
    }

    trigger OnInsert()
    var
        SustainabilityExciseJnlBatch: Record "Sust. Excise Journal Batch";
        SustainabilityExciseJnlTemplate: Record "Sust. Excise Journal Template";
    begin
        SustainabilityExciseJnlTemplate.Get("Journal Template Name");
        SustainabilityExciseJnlBatch.Get("Journal Template Name", "Journal Batch Name");
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        DimMgt: Codeunit DimensionManagement;
        JnlRecRefLbl: Label '%1 %2 %3', Locked = true;
        UnsupportedEntryErr: Label '%1 %2 is supported with %3 %4', Comment = '%1 = Field Caption, %2 = Field Value, %3 = Field Caption, %4 = Field Value';

    procedure SetupNewLine(PreviousLine: Record "Sust. Excise Jnl. Line")
    var
        SustainabilityExciseJnlBatch: Record "Sust. Excise Journal Batch";
        SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line";
        SustainabilityExciseJournalMgt: Codeunit "Sust. Excise Journal Mgt.";
        IsPreviousLineValid: Boolean;
    begin
        SustainabilityExciseJnlBatch.Get("Journal Template Name", "Journal Batch Name");

        SustainabilityExciseJnlLine.SetRange("Journal Template Name", "Journal Template Name");
        SustainabilityExciseJnlLine.SetRange("Journal Batch Name", "Journal Batch Name");
        IsPreviousLineValid := not SustainabilityExciseJnlLine.IsEmpty();

        if IsPreviousLineValid then begin
            Validate("Posting Date", PreviousLine."Posting Date");
            Validate("Entry Type", PreviousLine."Entry Type");
        end else
            Validate("Posting Date", WorkDate());

        Validate("Reason Code", SustainabilityExciseJnlBatch."Reason Code");
        Validate("Source Code", SustainabilityExciseJnlBatch."Source Code");
        Validate("Document No.", SustainabilityExciseJournalMgt.GetDocumentNo(IsPreviousLineValid, SustainabilityExciseJnlBatch, PreviousLine."Document No.", "Posting Date"));

        OnAfterSetupNewLine(Rec, SustainabilityExciseJnlBatch, PreviousLine);
    end;

    procedure CreateDimFromDefaultDim(FieldNo: Integer)
    var
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        InitDefaultDimensionSources(DefaultDimSource, FieldNo);
        CreateDim(DefaultDimSource);
    end;

    procedure CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        "Dimension Set ID" := DimMgt.GetRecDefaultDimID(Rec, CurrFieldNo, DefaultDimSource, "Source Code", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);
    end;

    procedure GetPostingSign(SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line"): Integer
    var
        Sign: Integer;
    begin
        Sign := 1;
        case SustainabilityExciseJnlLine."Entry Type" of
            SustainabilityExciseJnlLine."Entry Type"::" ", SustainabilityExciseJnlLine."Entry Type"::Purchase:
                if SustainabilityExciseJnlLine."Document Type" in [SustainabilityExciseJnlLine."Document Type"::"Credit Memo"] then
                    Sign := -1;
            SustainabilityExciseJnlLine."Entry Type"::Sales:
                if SustainabilityExciseJnlLine."Document Type" in [SustainabilityExciseJnlLine."Document Type"::Invoice] then
                    Sign := -1;
        end;

        exit(Sign);
    end;

    procedure UpdateSustainabilityJnlLineWithPostingSign(var SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line"; SignFactor: Integer)
    begin
        SustainabilityExciseJnlLine.Validate("Total Emission Cost", SignFactor * SustainabilityExciseJnlLine."Total Emission Cost");
        SustainabilityExciseJnlLine.Validate("Total Embedded CO2e Emission", SignFactor * SustainabilityExciseJnlLine."Total Embedded CO2e Emission");
    end;

    internal procedure ShowDimensions() IsChanged: Boolean
    var
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" := DimMgt.EditDimensionSet(
            Rec, "Dimension Set ID", StrSubstNo(JnlRecRefLbl, "Journal Template Name", "Journal Batch Name", "Line No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");

        IsChanged := OldDimSetID <> "Dimension Set ID";
    end;

    internal procedure GetSustExciseJournalLineLastLineNo(SustainabilityExciseJnlBatch: Record "Sust. Excise Journal Batch"): Integer
    var
        SustExciseJournalLine: Record "Sust. Excise Jnl. Line";
    begin
        SustExciseJournalLine.SetRange("Journal Template Name", SustainabilityExciseJnlBatch."Journal Template Name");
        SustExciseJournalLine.SetRange("Journal Batch Name", SustainabilityExciseJnlBatch.Name);
        if SustExciseJournalLine.FindLast() then
            exit(SustExciseJournalLine."Line No.");
    end;

    internal procedure UpdateCarbonPricingInExciseJournalLine(var SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line")
    var
        SustainabilityCarbonPricing: Record "Sustainability Carbon Pricing";
        ExistCarbonPrice: Boolean;
    begin
        if (SustainabilityExciseJnlLine."Source Type" <> SustainabilityExciseJnlLine."Source Type"::Item) then
            exit;

        SustainabilityExciseJnlLine."Emission Cost Per Unit" := 0;
        SustainabilityExciseJnlLine."Total Emission Cost" := 0;
        FindCarbonPricingFromExciseLine(SustainabilityCarbonPricing, SustainabilityExciseJnlLine, ExistCarbonPrice);
        if not ExistCarbonPrice then
            exit;

        SustainabilityExciseJnlLine.Validate("Total Emission Cost", SustainabilityCarbonPricing."Carbon Price" * SustainabilityExciseJnlLine."Total Embedded CO2e Emission");
    end;

    local procedure FindCarbonPricingFromExciseLine(var SustainabilityCarbonPricing: Record "Sustainability Carbon Pricing"; var SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line"; var ExistCarbonPrice: Boolean)
    begin
        FilterCarbonPricing(SustainabilityCarbonPricing, SustainabilityExciseJnlLine);
        if not SustainabilityCarbonPricing.FindLast() then
            exit;

        if (SustainabilityExciseJnlLine."Total Embedded CO2e Emission" > SustainabilityCarbonPricing."Threshold Quantity") then
            ExistCarbonPrice := true;
    end;

    local procedure FilterCarbonPricing(var SustainabilityCarbonPricing: Record "Sustainability Carbon Pricing"; SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line")
    var
        Item: Record Item;
    begin
        Item.Get(SustainabilityExciseJnlLine."Source No.");

        SustainabilityCarbonPricing.Reset();
        if Item."Country/Region of Origin Code" <> '' then
            SustainabilityCarbonPricing.SetRange("Country/Region of Origin", Item."Country/Region of Origin Code")
        else
            SustainabilityCarbonPricing.SetRange("Country/Region of Origin", SustainabilityExciseJnlLine."Country/Region Code");

        SustainabilityCarbonPricing.SetFilter("Ending Date", '%1|>=%2', 0D, SustainabilityExciseJnlLine."Posting Date");
        SustainabilityCarbonPricing.SetRange("Starting Date", 0D, SustainabilityExciseJnlLine."Posting Date");
    end;

    local procedure InitDefaultDimensionSources(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; FieldNo: Integer)
    begin
        if Rec."Partner Type" = Rec."Partner Type"::Customer then
            DimMgt.AddDimSource(DefaultDimSource, Database::Customer, Rec."Partner No.", FieldNo = Rec.Fieldno("Partner No."));

        if Rec."Partner Type" = Rec."Partner Type"::Vendor then
            DimMgt.AddDimSource(DefaultDimSource, Database::Vendor, Rec."Partner No.", FieldNo = Rec.Fieldno("Partner No."));

        DimMgt.AddDimSource(DefaultDimSource, ExciseLineTypeToTableID(Rec."Source Type"), Rec."Source No.", FieldNo = Rec.FieldNo("Source No."));
        OnAfterInitDefaultDimensionSources(Rec, DefaultDimSource, FieldNo);
    end;

    internal procedure ExciseLineTypeToTableID(LineType: Enum "Sust. Excise Jnl. Source Type"): Integer
    begin
        case LineType of
            "Sust. Excise Jnl. Source Type"::" ":
                exit(0);
            "Sust. Excise Jnl. Source Type"::"G/L Account":
                exit(Database::"G/L Account");
            "Sust. Excise Jnl. Source Type"::Item:
                exit(Database::Item);
            "Sust. Excise Jnl. Source Type"::Resource:
                exit(Database::Resource);
            "Sust. Excise Jnl. Source Type"::"Fixed Asset":
                exit(Database::"Fixed Asset");
            "Sust. Excise Jnl. Source Type"::"Charge (Item)":
                exit(Database::"Item Charge");
            "Sust. Excise Jnl. Source Type"::Certificate:
                exit(Database::"Sustainability Certificate");
        end;
    end;

    local procedure ClearEmissionInformation(var SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line")
    begin
        SustainabilityExciseJnlLine.Validate("CO2e Emission per Unit", 0);
        SustainabilityExciseJnlLine.Validate("Emission Cost per Unit", 0);
        SustainabilityExciseJnlLine.Validate("Already Paid Emission", 0);
    end;

    local procedure ValidateSustainabilityExciseJournalLineByField(SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line"; CurrentFieldNo: Integer)
    var
        SustainabilityExciseJnlBatch: Record "Sust. Excise Journal Batch";
    begin
        case CurrentFieldNo of
            SustainabilityExciseJnlLine.FieldNo("Entry Type"),
            SustainabilityExciseJnlLine.FieldNo("Document Type"):
                if (SustainabilityExciseJnlLine."Document Type" = SustainabilityExciseJnlLine."Document Type"::Journal) and
                   (SustainabilityExciseJnlLine."Entry Type" <> SustainabilityExciseJnlLine."Entry Type"::" ") or
                   (SustainabilityExciseJnlLine."Document Type" <> SustainabilityExciseJnlLine."Document Type"::Journal) and
                   (SustainabilityExciseJnlLine."Entry Type" = SustainabilityExciseJnlLine."Entry Type"::" ")
                then
                    Error(
                        UnsupportedEntryErr,
                        SustainabilityExciseJnlLine.FieldCaption("Entry Type"),
                        SustainabilityExciseJnlLine."Entry Type"::" ",
                        SustainabilityExciseJnlLine.FieldCaption("Document Type"),
                        SustainabilityExciseJnlLine."Document Type"::Journal);

            SustainabilityExciseJnlLine.FieldNo("Emission Cost per Unit"),
            SustainabilityExciseJnlLine.FieldNo("Total Emission Cost"),
            SustainabilityExciseJnlLine.FieldNo("CO2e Emission per Unit"):
                begin
                    SustainabilityExciseJnlLine.TestField("Source No.");
                    SustainabilityExciseJnlLine.TestField("Source Qty.");
                end;

            SustainabilityExciseJnlLine.FieldNo("Emission Verified"),
            SustainabilityExciseJnlLine.FieldNo("CBAM Compliance"),
            SustainabilityExciseJnlLine.FieldNo("CO2e Unit of Measure"),
            SustainabilityExciseJnlLine.FieldNo("CBAM Certificates Required"),
            SustainabilityExciseJnlLine.FieldNo("Carbon Pricing Paid"),
            SustainabilityExciseJnlLine.FieldNo("Certificate Amount"):
                begin
                    SustainabilityExciseJnlBatch.Get(SustainabilityExciseJnlLine."Journal Template Name", SustainabilityExciseJnlLine."Journal Batch Name");

                    SustainabilityExciseJnlBatch.TestField(Type, SustainabilityExciseJnlBatch.Type::CBAM);
                end;

            SustainabilityExciseJnlLine.FieldNo("Already Paid Emission"),
            SustainabilityExciseJnlLine.FieldNo("Adjusted CBAM Cost"),
            SustainabilityExciseJnlLine.FieldNo("Total Embedded CO2e Emission"):
                begin
                    SustainabilityExciseJnlBatch.Get(SustainabilityExciseJnlLine."Journal Template Name", SustainabilityExciseJnlLine."Journal Batch Name");

                    SustainabilityExciseJnlBatch.TestField(Type, SustainabilityExciseJnlBatch.Type::CBAM);
                    SustainabilityExciseJnlLine.TestField("Source No.");
                    SustainabilityExciseJnlLine.TestField("Source Qty.")
                end;

            SustainabilityExciseJnlLine.FieldNo("Material Breakdown No."),
            SustainabilityExciseJnlLine.FieldNo("Material Breakdown Description"),
            SustainabilityExciseJnlLine.FieldNo("Material Breakdown Weight"),
            SustainabilityExciseJnlLine.FieldNo("Material Breakdown UOM"):
                begin
                    SustainabilityExciseJnlLine.TestField("Material Breakdown No.");
                    SustainabilityExciseJnlBatch.Get(SustainabilityExciseJnlLine."Journal Template Name", SustainabilityExciseJnlLine."Journal Batch Name");

                    SustainabilityExciseJnlBatch.TestField(Type, SustainabilityExciseJnlBatch.Type::EPR);
                end;
        end;
    end;

    local procedure UpdateSustainabilityEmission(var SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line")
    begin
        SustainabilityExciseJnlLine."Total Emission Cost" := SustainabilityExciseJnlLine."Emission Cost per Unit" * SustainabilityExciseJnlLine."Qty. per Unit of Measure" * SustainabilityExciseJnlLine."Source Qty.";
        SustainabilityExciseJnlLine."Total Embedded CO2e Emission" := SustainabilityExciseJnlLine."CO2e Emission per Unit" * SustainabilityExciseJnlLine."Qty. per Unit of Measure" * SustainabilityExciseJnlLine."Source Qty.";
    end;

    local procedure UpdateEmissionPerUnit(var SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line")
    var
        Denominator: Decimal;
    begin
        SustainabilityExciseJnlLine."Emission Cost per Unit" := 0;
        SustainabilityExciseJnlLine."CO2e Emission per Unit" := 0;

        if (SustainabilityExciseJnlLine."Qty. per Unit of Measure" = 0) or (SustainabilityExciseJnlLine."Source Qty." = 0) then
            exit;

        Denominator := SustainabilityExciseJnlLine."Qty. per Unit of Measure" * SustainabilityExciseJnlLine."Source Qty.";
        if SustainabilityExciseJnlLine."Total Emission Cost" <> 0 then
            SustainabilityExciseJnlLine."Emission Cost per Unit" := SustainabilityExciseJnlLine."Total Emission Cost" / Denominator;

        if SustainabilityExciseJnlLine."Total Embedded CO2e Emission" <> 0 then
            SustainabilityExciseJnlLine."CO2e Emission per Unit" := SustainabilityExciseJnlLine."Total Embedded CO2e Emission" / Denominator;
    end;

    local procedure GetTotalWeightOfItemMaterialComposition(ItemMatCompNo: Code[20]): Decimal
    var
        ItemMatCompLine: Record "Sust. Item Mat. Comp. Line";
    begin
        ItemMatCompLine.SetRange("Item Material Composition No.", ItemMatCompNo);
        ItemMatCompLine.CalcSums(Weight);

        exit(ItemMatCompLine.Weight);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitDefaultDimensionSources(var SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line"; var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; FieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetupNewLine(var SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line"; SustainabilityExciseJnlBatch: Record "Sust. Excise Journal Batch"; PreviousSustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line")
    begin
    end;
}