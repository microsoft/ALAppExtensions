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

                GetDefaultDimensionsFromAccount();
            end;
        }
        field(8; "Account Name"; Text[100])
        {
            Caption = 'Account Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Sustainability Account".Name where("No." = field("Account No.")));
        }
        field(9; "Account Category"; Code[20])
        {
            Caption = 'Category';
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
            Caption = 'Subcategory';
            Editable = false;
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
        field(27; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
        field(28; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1), Blocked = const(false));

            trigger OnValidate()
            var
                DimMgt: Codeunit DimensionManagement;
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
            var
                DimMgt: Codeunit DimensionManagement;
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

    internal procedure SetupNewLine(PreviousLine: Record "Sustainability Jnl. Line")
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

        if IsPreviousLineValid then
            Validate("Posting Date", PreviousLine."Posting Date")
        else
            Validate("Posting Date", WorkDate());

        Validate("Reason Code", SustainabilityJnlBatch."Reason Code");
        Validate("Source Code", SustainabilityJnlBatch."Source Code");
        Validate("Document No.", SustainabilityJournalMgt.GetDocumentNo(IsPreviousLineValid, SustainabilityJnlBatch, PreviousLine."Document No.", "Posting Date"));
    end;

    local procedure GetDefaultDimensionsFromAccount()
    var
        DimMgt: Codeunit DimensionManagement;
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';

        DimMgt.AddDimSource(DefaultDimSource, Database::"Sustainability Account", "Account No.", true);
        Validate("Dimension Set ID", DimMgt.GetRecDefaultDimID(Rec, CurrFieldNo, DefaultDimSource, "Source Code", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0));
    end;
}
