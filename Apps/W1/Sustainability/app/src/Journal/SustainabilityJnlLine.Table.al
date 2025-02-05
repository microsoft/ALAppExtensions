namespace Microsoft.Sustainability.Journal;

using Microsoft.Foundation.UOM;
using Microsoft.Foundation.Address;
using Microsoft.Inventory.Location;
using Microsoft.Finance.Dimension;
using Microsoft.Sustainability.Account;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Sustainability.Calculation;
using Microsoft.Sustainability.Setup;

table 6214 "Sustainability Jnl. Line"
{
    Caption = 'Sustainability Journal Line';
    Access = Public;
    DataClassification = CustomerContent;
    LookupPageId = "Sustainability Journal";
    DataPerCompany = true;
    Extensible = true;

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Sustainability Jnl. Template";
            NotBlank = true;
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Sustainability Jnl. Batch".Name where("Journal Template Name" = field("Journal Template Name"));
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
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            NotBlank = true;
        }
        field(6; "Document Type"; Enum "Sustainability Jnl. Doc. Type")
        {
            Caption = 'Document Type';
        }
        field(7; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = "Sustainability Account" where("Account Type" = const(Posting), Blocked = const(false));

            trigger OnValidate()
            var
                SustainabilityAccount: Record "Sustainability Account";
                SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
            begin
                if "Account No." = '' then begin
                    Validate("Account Category", '');
                    "Account Name" := '';
                end else begin
                    SustainabilityAccount.Get("Account No.");
                    SustainabilityAccount.CheckAccountReadyForPosting();
                    SustainabilityAccount.TestField("Direct Posting", true);

                    Validate("Account Category", SustainabilityAccount.Category);
                    Validate("Account Subcategory", SustainabilityAccount.Subcategory);

                    SustainabilityJournalMgt.CheckScopeMatchWithBatch(Rec);

                    if (Description = '') or (Description = "Account Name") then
                        Validate(Description, SustainabilityAccount.Name);
                    "Account Name" := SustainabilityAccount.Name;
                end;

                if Rec."Account No." <> xRec."Account No." then
                    ClearEmissionInformation(Rec);

                CreateDimFromDefaultDim(FieldNo("Account No."));
            end;
        }
        field(8; "Account Name"; Text[100])
        {
            Caption = 'Account Name';
            DataClassification = CustomerContent;
        }
        field(9; "Account Category"; Code[20])
        {
            Caption = 'Account Category';
            Editable = false;
            TableRelation = "Sustain. Account Category";

            trigger OnValidate()
            begin
                if "Account Category" <> xRec."Account Category" then
                    Validate("Account Subcategory", '');
            end;
        }
        field(10; "Account Subcategory"; Code[20])
        {
            Caption = 'Account Subcategory';
            TableRelation = "Sustain. Account Subcategory".Code where("Category Code" = field("Account Category"));
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(12; "Manual Input"; Boolean)
        {
            Caption = 'Manual Input';

            trigger OnValidate()
            var
                SustainabilityCalcMgt: Codeunit "Sustainability Calc. Mgt.";
            begin
                Validate(Distance, 0);
                Validate("Fuel/Electricity", 0);
                Validate("Custom Amount", 0);
                Validate("Installation Multiplier", 1);
                Validate("Time Factor", 0);

                SustainabilityCalcMgt.CalculationEmissions(Rec);
            end;
        }
        field(13; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = "Unit of Measure";
            NotBlank = true;
        }
        field(14; "Fuel/Electricity"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Fuel/El. Decimal Places"));
            Caption = 'Fuel/Electricity';

            trigger OnValidate()
            var
                SustainabilityCalcMgt: Codeunit "Sustainability Calc. Mgt.";
            begin
                SustainabilityCalcMgt.CalculationEmissions(Rec);
            end;
        }
        field(15; Distance; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Distance Decimal Places"));
            Caption = 'Distance';

            trigger OnValidate()
            var
                SustainabilityCalcMgt: Codeunit "Sustainability Calc. Mgt.";
            begin
                SustainabilityCalcMgt.CalculationEmissions(Rec);
            end;
        }
        field(16; "Custom Amount"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Custom Amt. Decimal Places"));
            Caption = 'Custom Amount';

            trigger OnValidate()
            var
                SustainabilityCalcMgt: Codeunit "Sustainability Calc. Mgt.";
            begin
                SustainabilityCalcMgt.CalculationEmissions(Rec);
            end;
        }
        field(17; "Installation Multiplier"; Decimal)
        {
            Caption = 'Installation Multiplier';
            InitValue = 1;

            trigger OnValidate()
            var
                SustainabilityCalcMgt: Codeunit "Sustainability Calc. Mgt.";
            begin
                SustainabilityCalcMgt.CalculationEmissions(Rec);
            end;
        }
        field(18; "Time Factor"; Decimal)
        {
            Caption = 'Time Factor';
            MaxValue = 1;

            trigger OnValidate()
            var
                SustainabilityCalcMgt: Codeunit "Sustainability Calc. Mgt.";
            begin
                SustainabilityCalcMgt.CalculationEmissions(Rec);
            end;
        }
        field(19; "Emission CO2"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CO2';

            trigger OnValidate()
            begin
                ValidateSustainabilityJournalLineByField(Rec, Rec.FieldNo("Emission CO2"), Rec."Emission CO2");
            end;
        }
        field(20; "Emission CH4"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CH4';

            trigger OnValidate()
            begin
                ValidateSustainabilityJournalLineByField(Rec, Rec.FieldNo("Emission CH4"), Rec."Emission CH4");
            end;
        }
        field(21; "Emission N2O"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission N2O';

            trigger OnValidate()
            begin
                ValidateSustainabilityJournalLineByField(Rec, Rec.FieldNo("Emission N2O"), Rec."Emission N2O");
            end;
        }
        field(22; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(23; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            TableRelation = "Responsibility Center";

            trigger OnValidate()
            var
                ResponsibilityCenter: Record "Responsibility Center";
                SustAccountCategory: Record "Sustain. Account Category";
            begin
                SustAccountCategory.Get(Rec."Account Category");
                if (Rec."Responsibility Center" <> '') and (SustAccountCategory."Water Intensity") then begin
                    ResponsibilityCenter.Get(Rec."Responsibility Center");

                    Rec.Validate("Unit of Measure", ResponsibilityCenter."Water Capacity Unit");
                    if not Rec."Manual Input" then
                        Rec.Validate("Custom Amount", ResponsibilityCenter."Water Capacity Quantity(Month)");
                end;
            end;
        }
        field(24; "Recurring Method"; Enum "Sustain. Jnl. Recur. Method")
        {
            Caption = 'Recurring Method';
            BlankZero = true;
        }
        field(25; "Recurring Frequency"; DateFormula)
        {
            Caption = 'Recurring Frequency';
        }
        field(26; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
        }
        field(34; "Water Intensity"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Water Intensity';

            trigger OnValidate()
            begin
                ValidateSustainabilityJournalLineByField(Rec, Rec.FieldNo("Water Intensity"), Rec."Water Intensity");
            end;
        }
        field(35; "Discharged Into Water"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Discharged Into Water';

            trigger OnValidate()
            begin
                ValidateSustainabilityJournalLineByField(Rec, Rec.FieldNo("Discharged Into Water"), Rec."Discharged Into Water");
            end;
        }
        field(36; "Waste Intensity"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Waste Intensity';

            trigger OnValidate()
            begin
                ValidateSustainabilityJournalLineByField(Rec, Rec.FieldNo("Waste Intensity"), Rec."Waste Intensity");
            end;
        }
        field(37; "Water/Waste Intensity Type"; Enum "Water/Waste Intensity Type")
        {
            Caption = 'Water/Waste Intensity Type';

            trigger OnValidate()
            begin
                ValidateSustainabilityJournalLineByField(Rec, FieldNo("Water/Waste Intensity Type"), 0);
            end;
        }
        field(38; "Water Type"; Enum "Water Type")
        {
            Caption = 'Water Type';
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
        field(28; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1), Blocked = const(false));

            trigger OnValidate()
            begin
                DimMgt.ValidateShortcutDimValues(1, "Shortcut Dimension 1 Code", "Dimension Set ID");
            end;
        }
        field(29; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2), Blocked = const(false));

            trigger OnValidate()
            begin
                DimMgt.ValidateShortcutDimValues(2, "Shortcut Dimension 2 Code", "Dimension Set ID");
            end;
        }
        field(30; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
        }
        field(31; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(32; "CO2e Emission"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'CO2e Emission';
            DecimalPlaces = 2 : 5;
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
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJnlTemplate: Record "Sustainability Jnl. Template";
    begin
        SustainabilityJnlTemplate.Get("Journal Template Name");
        SustainabilityJnlBatch.Get("Journal Template Name", "Journal Batch Name");
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        DimMgt: Codeunit DimensionManagement;
        JnlRecRefLbl: Label '%1 %2 %3', Locked = true;
        ValuesMustBeZeroErr: Label '%1, %2, %3 must be Zero.', Comment = '%1,%2,%3 = Field Caption';
        CanBeUsedOnlyForWaterErr: Label '%1 can be used only for water.', Comment = '%1 = Field Value';
        CanBeUsedOnlyForWasteErr: Label '%1 can be only used for waste.', Comment = '%1 = Field Value';
        CannotBeUsedForWaterErr: Label '%1 can''t be used for water.', Comment = '%1 = Field Value';

    procedure SetupNewLine(PreviousLine: Record "Sustainability Jnl. Line")
    var
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        IsPreviousLineValid: Boolean;
    begin
        SustainabilityJnlBatch.Get("Journal Template Name", "Journal Batch Name");

        SustainabilityJnlLine.SetRange("Journal Template Name", "Journal Template Name");
        SustainabilityJnlLine.SetRange("Journal Batch Name", "Journal Batch Name");
        IsPreviousLineValid := not SustainabilityJnlLine.IsEmpty();

        if IsPreviousLineValid then begin
            Validate("Posting Date", PreviousLine."Posting Date");
            Validate("Document Type", PreviousLine."Document Type");
        end else
            Validate("Posting Date", WorkDate());

        Validate("Reason Code", SustainabilityJnlBatch."Reason Code");
        Validate("Source Code", SustainabilityJnlBatch."Source Code");
        Validate("Document No.", SustainabilityJournalMgt.GetDocumentNo(IsPreviousLineValid, SustainabilityJnlBatch, PreviousLine."Document No.", "Posting Date"));

        OnAfterSetupNewLine(Rec, SustainabilityJnlBatch, PreviousLine);
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
        DimMgt.AddDimSource(DefaultDimSource, Database::"Sustainability Account", "Account No.", FieldNo = Rec.FieldNo("Account No."));
        OnAfterInitDefaultDimensionSources(Rec, DefaultDimSource, FieldNo);
    end;

    procedure CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        "Dimension Set ID" := DimMgt.GetRecDefaultDimID(Rec, CurrFieldNo, DefaultDimSource, "Source Code", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);
    end;

    procedure GetPostingSign(SustainabilityJnlLine: Record "Sustainability Jnl. Line"): Integer
    var
        Sign: Integer;
    begin
        Sign := 1;

        if SustainabilityJnlLine."Document Type" in [SustainabilityJnlLine."Document Type"::"Credit Memo", SustainabilityJnlLine."Document Type"::"GHG Credit"] then
            Sign := -1;

        exit(Sign);
    end;

    procedure UpdateSustainabilityJnlLineWithPostingSign(var SustainabilityJnlLine: Record "Sustainability Jnl. Line"; SignFactor: Integer)
    begin
        SustainabilityJnlLine.Validate("Emission CO2", SignFactor * SustainabilityJnlLine."Emission CO2");
        SustainabilityJnlLine.Validate("Emission CH4", SignFactor * SustainabilityJnlLine."Emission CH4");
        SustainabilityJnlLine.Validate("Emission N2O", SignFactor * SustainabilityJnlLine."Emission N2O");
        SustainabilityJnlLine.Validate("Water Intensity", SignFactor * SustainabilityJnlLine."Water Intensity");
        SustainabilityJnlLine.Validate("Waste Intensity", SignFactor * SustainabilityJnlLine."Waste Intensity");
        SustainabilityJnlLine.Validate("Discharged Into Water", SignFactor * SustainabilityJnlLine."Discharged Into Water");
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

    local procedure ClearEmissionInformation(var SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    begin
        SustainabilityJnlLine.Validate("Emission CO2", 0);
        SustainabilityJnlLine.Validate("Emission CH4", 0);
        SustainabilityJnlLine.Validate("Emission N2O", 0);
        SustainabilityJnlLine.Validate("Waste Intensity", 0);
        SustainabilityJnlLine.Validate("Water Intensity", 0);
        SustainabilityJnlLine.Validate("Discharged Into Water", 0);
        SustainabilityJnlLine.Validate("Water/Waste Intensity Type", "Water/Waste Intensity Type"::" ");
        SustainabilityJnlLine.Validate("Water Type", "Water Type"::" ");
    end;

    local procedure ValidateSustainabilityJournalLineByField(SustainabilityJnlLine: Record "Sustainability Jnl. Line"; CurrentFieldNo: Integer; FieldValue: Decimal)
    begin
        case CurrentFieldNo of
            SustainabilityJnlLine.FieldNo("Emission CO2"),
            SustainabilityJnlLine.FieldNo("Emission N2O"),
            SustainabilityJnlLine.FieldNo("Emission CH4"),
            SustainabilityJnlLine.FieldNo("Waste Intensity"),
            SustainabilityJnlLine.FieldNo("Discharged Into Water"),
            SustainabilityJnlLine.FieldNo("Water Intensity"):
                begin
                    if not SustainabilityJnlLine."Manual Input" then
                        exit;

                    if FieldValue <> 0 then
                        CheckSustainabilityJournalLineByField(SustainabilityJnlLine, CurrentFieldNo);
                end;
            SustainabilityJnlLine.FieldNo("Water/Waste Intensity Type"):
                if SustainabilityJnlLine."Water/Waste Intensity Type" <> SustainabilityJnlLine."Water/Waste Intensity Type"::" " then
                    CheckSustainabilityJournalLineByField(SustainabilityJnlLine, CurrentFieldNo);
        end;
    end;

    local procedure CheckSustainabilityJournalLineByField(SustainabilityJnlLine: Record "Sustainability Jnl. Line"; CurrentFieldNo: Integer)
    var
        SustAccountCategory: Record "Sustain. Account Category";
    begin
        case CurrentFieldNo of
            SustainabilityJnlLine.FieldNo("Emission CO2"),
            SustainabilityJnlLine.FieldNo("Emission N2O"),
            SustainabilityJnlLine.FieldNo("Emission CH4"):
                CheckEmissionsMustBeZeroIfWaterOrWasteIsEnabled(SustainabilityJnlLine);
            SustainabilityJnlLine.FieldNo("Waste Intensity"),
            SustainabilityJnlLine.FieldNo("Discharged Into Water"),
            SustainabilityJnlLine.FieldNo("Water Intensity"):
                begin
                    SustAccountCategory.Get(SustainabilityJnlLine."Account Category");

                    CheckWaterAndWasteMustBeZeroIfEmissionIsEnabled(SustainabilityJnlLine, SustAccountCategory);
                    CheckWaterOrDischargedIntoWaterAndWasteMustBeZeroIfWaterIsEnabled(SustainabilityJnlLine, SustAccountCategory);
                    CheckWaterAndDischargedIntoWaterMustBeZeroIfWasteIsEnabled(SustainabilityJnlLine, SustAccountCategory);
                end;
            SustainabilityJnlLine.FieldNo("Water/Waste Intensity Type"):
                CheckWaterOrWasteIntenistyType(SustainabilityJnlLine);
        end;
    end;

    local procedure CheckEmissionsMustBeZeroIfWaterOrWasteIsEnabled(SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    var
        SustAccountCategory: Record "Sustain. Account Category";
    begin
        SustAccountCategory.Get(SustainabilityJnlLine."Account Category");
        if SustAccountCategory."Water Intensity" or SustAccountCategory."Waste Intensity" or SustAccountCategory."Discharged Into Water" then
            Error(ValuesMustBeZeroErr, SustainabilityJnlLine.FieldCaption("Emission CO2"), SustainabilityJnlLine.FieldCaption("Emission CH4"), SustainabilityJnlLine.FieldCaption("Emission N2O"));
    end;

    local procedure CheckWaterAndWasteMustBeZeroIfEmissionIsEnabled(SustainabilityJnlLine: Record "Sustainability Jnl. Line"; SustAccountCategory: Record "Sustain. Account Category")
    begin
        if SustAccountCategory.CO2 or SustAccountCategory.CH4 or SustAccountCategory.N2O then
            Error(ValuesMustBeZeroErr, SustainabilityJnlLine.FieldCaption("Water Intensity"), SustainabilityJnlLine.FieldCaption("Discharged Into Water"), SustainabilityJnlLine.FieldCaption("Waste Intensity"));
    end;

    local procedure CheckWaterOrDischargedIntoWaterAndWasteMustBeZeroIfWaterIsEnabled(SustainabilityJnlLine: Record "Sustainability Jnl. Line"; SustAccountCategory: Record "Sustain. Account Category")
    begin
        if SustAccountCategory."Water Intensity" or SustAccountCategory."Discharged Into Water" then begin
            SustainabilityJnlLine.TestField("Waste Intensity", 0);

            if not SustAccountCategory."Discharged Into Water" then
                SustainabilityJnlLine.TestField("Discharged Into Water", 0);

            if not SustAccountCategory."Water Intensity" then
                SustainabilityJnlLine.TestField("Water Intensity", 0);
        end;
    end;

    local procedure CheckWaterAndDischargedIntoWaterMustBeZeroIfWasteIsEnabled(SustainabilityJnlLine: Record "Sustainability Jnl. Line"; SustAccountCategory: Record "Sustain. Account Category")
    begin
        if SustAccountCategory."Waste Intensity" then begin
            SustainabilityJnlLine.TestField("Water Intensity", 0);
            SustainabilityJnlLine.TestField("Discharged Into Water", 0);
        end;
    end;

    local procedure CheckWaterOrWasteIntenistyType(SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    var
        SustAccountCategory: Record "Sustain. Account Category";
    begin
        SustAccountCategory.Get(SustainabilityJnlLine."Account Category");
        if SustAccountCategory."Water Intensity" and SustAccountCategory."Discharged Into Water" then
            if not (SustainabilityJnlLine."Water/Waste Intensity Type" in [SustainabilityJnlLine."Water/Waste Intensity Type"::Withdrawn,
                                                                           SustainabilityJnlLine."Water/Waste Intensity Type"::Discharged,
                                                                           SustainabilityJnlLine."Water/Waste Intensity Type"::Consumed,
                                                                           SustainabilityJnlLine."Water/Waste Intensity Type"::Recycled])
            then
                Error(CanBeUsedOnlyForWasteErr, SustainabilityJnlLine."Water/Waste Intensity Type");

        if (SustAccountCategory."Discharged Into Water") and (not SustAccountCategory."Water Intensity") then
            SustainabilityJnlLine.TestField("Water/Waste Intensity Type", "Water/Waste Intensity Type"::Discharged);

        if SustAccountCategory."Water Intensity" and not SustAccountCategory."Discharged Into Water" then
            if not (SustainabilityJnlLine."Water/Waste Intensity Type" in [SustainabilityJnlLine."Water/Waste Intensity Type"::Withdrawn,
                                                                           SustainabilityJnlLine."Water/Waste Intensity Type"::Consumed,
                                                                           SustainabilityJnlLine."Water/Waste Intensity Type"::Recycled])
            then
                Error(CannotBeUsedForWaterErr, SustainabilityJnlLine."Water/Waste Intensity Type");

        if SustAccountCategory."Waste Intensity" then
            if not (SustainabilityJnlLine."Water/Waste Intensity Type" in [SustainabilityJnlLine."Water/Waste Intensity Type"::Generated,
                                                                           SustainabilityJnlLine."Water/Waste Intensity Type"::Disposed,
                                                                           SustainabilityJnlLine."Water/Waste Intensity Type"::Recovered])
            then
                Error(CanBeUsedOnlyForWaterErr, SustainabilityJnlLine."Water/Waste Intensity Type");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitDefaultDimensionSources(var SustainabilityJnlLine: Record "Sustainability Jnl. Line"; var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; FieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetupNewLine(var SustainabilityJnlLine: Record "Sustainability Jnl. Line"; SustainabilityJnlBatch: Record "Sustainability Jnl. Batch"; PreviousSustainabilityJnlLine: Record "Sustainability Jnl. Line")
    begin
    end;

}