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
        }
        field(20; "Emission CH4"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CH4';
        }
        field(21; "Emission N2O"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission N2O';
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

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitDefaultDimensionSources(var SustainabilityJnlLine: Record "Sustainability Jnl. Line"; var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; FieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetupNewLine(var SustainabilityJnlLine: Record "Sustainability Jnl. Line"; SustainabilityJnlBatch: Record "Sustainability Jnl. Batch"; PreviousSustainabilityJnlLine: Record "Sustainability Jnl. Line")
    begin
    end;

}