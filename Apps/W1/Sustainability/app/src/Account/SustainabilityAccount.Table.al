namespace Microsoft.Sustainability.Account;

using Microsoft.Finance.Dimension;
using Microsoft.Inventory.Location;
using Microsoft.Foundation.Comment;
using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Journal;

table 6210 "Sustainability Account"
{
    Caption = 'Sustainability Account';
    DataCaptionFields = "No.", Name;
    DataClassification = CustomerContent;
    DrillDownPageID = "Chart of Sustain. Accounts";
    LookupPageID = "Sustainability Account List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2; "No. 2"; Code[20])
        {
            Caption = 'No. 2';
        }
        field(3; Name; Text[100])
        {
            Caption = 'Name';
            trigger OnValidate()
            begin
                if ("Search Name" = UpperCase(xRec.Name)) or ("Search Name" = '') then
                    "Search Name" := Name;
            end;
        }
        field(4; "Name 2"; Text[100])
        {
            Caption = 'Name 2';
        }
        field(5; "Search Name"; Code[100])
        {
            Caption = 'Search Name';
        }
        field(6; Category; Code[20])
        {
            Caption = 'Category';
            TableRelation = "Sustain. Account Category";

            trigger OnValidate()
            var
                SustainabilityJnlLine: Record "Sustainability Jnl. Line";
                SustainabilityAccountMgt: Codeunit "Sustainability Account Mgt.";
            begin
                SustainabilityAccountMgt.CheckIfChangeAllowedForAccount("No.", FieldCaption(Category));

                if SustainabilityAccountMgt.ShouldUpdateJournalLineForAccount("No.") then begin
                    SustainabilityJnlLine.SetRange("Account No.", "No.");

                    if SustainabilityJnlLine.FindSet() then
                        repeat
                            SustainabilityJnlLine.Validate("Account Category", Category);
                            SustainabilityJnlLine.Modify(true);
                        until SustainabilityJnlLine.Next() = 0;
                end;

                if Category <> xRec.Category then
                    Validate(Subcategory, '');
            end;
        }
        field(7; Subcategory; Code[20])
        {
            Caption = 'Subcategory';
            TableRelation = "Sustain. Account Subcategory".Code where("Category Code" = field(Category));

            trigger OnValidate()
            var
                SustainabilityJnlLine: Record "Sustainability Jnl. Line";
                SustainabilityAccountMgt: Codeunit "Sustainability Account Mgt.";
            begin
                SustainabilityAccountMgt.CheckIfChangeAllowedForAccount("No.", FieldCaption(Subcategory));

                if SustainabilityAccountMgt.ShouldUpdateJournalLineForAccount("No.") then begin
                    SustainabilityJnlLine.SetRange("Account No.", "No.");

                    if SustainabilityJnlLine.FindSet() then
                        repeat
                            SustainabilityJnlLine.Validate("Account Subcategory", Subcategory);
                            SustainabilityJnlLine.Modify(true);
                        until SustainabilityJnlLine.Next() = 0;
                end;
            end;
        }
        field(8; "Emission Scope"; Enum "Emission Scope")
        {
            Caption = 'Emission Scope';
            FieldClass = FlowField;
            CalcFormula = lookup("Sustain. Account Category"."Emission Scope" where(Code = field(Category)));
        }
        field(9; "Account Type"; Enum "Sustainability Account Type")
        {
            Caption = 'Account Type';
            trigger OnValidate()
            var
                SustainabilityAccountMgt: Codeunit "Sustainability Account Mgt.";
            begin
                if not IsPosting() and xRec.IsPosting() then
                    if SustainabilityAccountMgt.IsThereLedgerEntryForAccount("No.") then
                        Error(LedgerEntryExistsErr, "No.");

                Totaling := '';
                if IsPosting() then begin
                    if "Account Type" <> xRec."Account Type" then
                        "Direct Posting" := true;
                end else
                    "Direct Posting" := false;
            end;
        }
        field(10; Totaling; Text[250])
        {
            Caption = 'Totaling';
            trigger OnValidate()
            begin
                if IsPosting() and (Totaling <> '') then
                    FieldError("Account Type");
                CalcFields("Net Change (CO2)", "Balance at Date (CO2)", "Balance (CO2)", "Net Change (CH4)", "Balance at Date (CH4)", "Balance (CH4)", "Net Change (N2O)", "Balance at Date (N2O)", "Balance (N2O)");
            end;

            trigger OnLookup()
            var
                SustainAccountList: Page "Sustainability Account List";
            begin
                SustainAccountList.LookupMode(true);
                if (SustainAccountList.RunModal() = Action::LookupOK) then
                    Validate(Totaling, CopyStr(SustainAccountList.GetSelectionFilter(), 1, MaxStrLen(Totaling)));
            end;
        }
        field(11; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
        field(12; "Direct Posting"; Boolean)
        {
            Caption = 'Direct Posting';
            InitValue = true;
        }
        field(13; Indentation; Integer)
        {
            Caption = 'Indentation';
            Editable = false;
        }
        field(14; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1), Blocked = const(false));
            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(15; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2), Blocked = const(false));
            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
            end;
        }
        field(16; Comment; Boolean)
        {
            CalcFormula = exist("Comment Line" where("Table Name" = const("Sustainability Account"), "No." = field("No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
#pragma warning disable AA0232 // the SIFT key is added, there is a bug in the analyzer
        field(100; "Net Change (CO2)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission CO2" where("Account No." = field("No."),
                                                        "Account No." = field(filter(Totaling)),
                                                        "Responsibility Center" = field("Responsibility Center Filter"),
                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                        "Posting Date" = field("Date Filter"),
                                                        "Dimension Set ID" = field("Dimension Set ID Filter")));
            Caption = 'Net Change (CO2)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(101; "Balance at Date (CO2)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission CO2" where("Account No." = field("No."),
                                                        "Account No." = field(filter(Totaling)),
                                                        "Responsibility Center" = field("Responsibility Center Filter"),
                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                        "Posting Date" = field(upperlimit("Date Filter")),
                                                        "Dimension Set ID" = field("Dimension Set ID Filter")));
            Caption = 'Balance at Date (CO2)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(102; "Balance (CO2)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission CO2" where("Account No." = field("No."),
                                                        "Account No." = field(filter(Totaling)),
                                                        "Responsibility Center" = field("Responsibility Center Filter"),
                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                        "Dimension Set ID" = field("Dimension Set ID Filter")));
            Caption = 'Balance (CO2)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(103; "Net Change (CH4)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission CH4" where("Account No." = field("No."),
                                                        "Account No." = field(filter(Totaling)),
                                                        "Responsibility Center" = field("Responsibility Center Filter"),
                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                        "Posting Date" = field("Date Filter"),
                                                        "Dimension Set ID" = field("Dimension Set ID Filter")));
            Caption = 'Net Change (CH4)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(104; "Balance at Date (CH4)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission CH4" where("Account No." = field("No."),
                                                        "Account No." = field(filter(Totaling)),
                                                        "Responsibility Center" = field("Responsibility Center Filter"),
                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                        "Posting Date" = field(upperlimit("Date Filter")),
                                                        "Dimension Set ID" = field("Dimension Set ID Filter")));
            Caption = 'Balance at Date (CH4)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(105; "Balance (CH4)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission CH4" where("Account No." = field("No."),
                                                        "Account No." = field(filter(Totaling)),
                                                        "Responsibility Center" = field("Responsibility Center Filter"),
                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                        "Dimension Set ID" = field("Dimension Set ID Filter")));
            Caption = 'Balance (CH4)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(106; "Net Change (N2O)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission N2O" where("Account No." = field("No."),
                                                        "Account No." = field(filter(Totaling)),
                                                        "Responsibility Center" = field("Responsibility Center Filter"),
                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                        "Posting Date" = field("Date Filter"),
                                                        "Dimension Set ID" = field("Dimension Set ID Filter")));
            Caption = 'Net Change (N2O)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(107; "Balance at Date (N2O)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission N2O" where("Account No." = field("No."),
                                                        "Account No." = field(filter(Totaling)),
                                                        "Responsibility Center" = field("Responsibility Center Filter"),
                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                        "Posting Date" = field(upperlimit("Date Filter")),
                                                        "Dimension Set ID" = field("Dimension Set ID Filter")));
            Caption = 'Balance at Date (N2O)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(108; "Balance (N2O)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission N2O" where("Account No." = field("No."),
                                                        "Account No." = field(filter(Totaling)),
                                                        "Responsibility Center" = field("Responsibility Center Filter"),
                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                        "Dimension Set ID" = field("Dimension Set ID Filter")));
            Caption = 'Balance (N2O)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(109; "Net Change (Water)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Sustainability Ledger Entry"."Water Intensity" where("Account No." = field("No."),
                                                        "Account No." = field(filter(Totaling)),
                                                        "Responsibility Center" = field("Responsibility Center Filter"),
                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                        "Posting Date" = field("Date Filter"),
                                                        "Dimension Set ID" = field("Dimension Set ID Filter")));
            Caption = 'Net Change (Water)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110; "Balance at Date (Water)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Sustainability Ledger Entry"."Water Intensity" where("Account No." = field("No."),
                                                        "Account No." = field(filter(Totaling)),
                                                        "Responsibility Center" = field("Responsibility Center Filter"),
                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                        "Posting Date" = field(upperlimit("Date Filter")),
                                                        "Dimension Set ID" = field("Dimension Set ID Filter")));
            Caption = 'Balance at Date (Water)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(111; "Balance (Water)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Sustainability Ledger Entry"."Water Intensity" where("Account No." = field("No."),
                                                        "Account No." = field(filter(Totaling)),
                                                        "Responsibility Center" = field("Responsibility Center Filter"),
                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                        "Dimension Set ID" = field("Dimension Set ID Filter")));
            Caption = 'Balance (Water)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(112; "Net Change (Disch. Water)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Sustainability Ledger Entry"."Discharged Into Water" where("Account No." = field("No."),
                                                        "Account No." = field(filter(Totaling)),
                                                        "Responsibility Center" = field("Responsibility Center Filter"),
                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                        "Posting Date" = field("Date Filter"),
                                                        "Dimension Set ID" = field("Dimension Set ID Filter")));
            Caption = 'Net Change (Disch. Water)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(113; "Balance at Date (Disch. Water)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Sustainability Ledger Entry"."Discharged Into Water" where("Account No." = field("No."),
                                                        "Account No." = field(filter(Totaling)),
                                                        "Responsibility Center" = field("Responsibility Center Filter"),
                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                        "Posting Date" = field(upperlimit("Date Filter")),
                                                        "Dimension Set ID" = field("Dimension Set ID Filter")));
            Caption = 'Balance at Date (Disch. Water)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(114; "Balance (Disch. Water)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Sustainability Ledger Entry"."Discharged Into Water" where("Account No." = field("No."),
                                                        "Account No." = field(filter(Totaling)),
                                                        "Responsibility Center" = field("Responsibility Center Filter"),
                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                        "Dimension Set ID" = field("Dimension Set ID Filter")));
            Caption = 'Balance (Disch. Water)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(115; "Net Change (Waste)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Sustainability Ledger Entry"."Waste Intensity" where("Account No." = field("No."),
                                                        "Account No." = field(filter(Totaling)),
                                                        "Responsibility Center" = field("Responsibility Center Filter"),
                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                        "Posting Date" = field("Date Filter"),
                                                        "Dimension Set ID" = field("Dimension Set ID Filter")));
            Caption = 'Net Change (Waste)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(116; "Balance at Date (Waste)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Sustainability Ledger Entry"."Waste Intensity" where("Account No." = field("No."),
                                                        "Account No." = field(filter(Totaling)),
                                                        "Responsibility Center" = field("Responsibility Center Filter"),
                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                        "Posting Date" = field(upperlimit("Date Filter")),
                                                        "Dimension Set ID" = field("Dimension Set ID Filter")));
            Caption = 'Balance at Date (Waste)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(117; "Balance (Waste)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Sustainability Ledger Entry"."Waste Intensity" where("Account No." = field("No."),
                                                        "Account No." = field(filter(Totaling)),
                                                        "Responsibility Center" = field("Responsibility Center Filter"),
                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                        "Dimension Set ID" = field("Dimension Set ID Filter")));
            Caption = 'Balance (Waste)';
            Editable = false;
            FieldClass = FlowField;
        }
#pragma warning restore AA0232
        field(200; "Responsibility Center Filter"; Code[20])
        {
            Caption = 'Responsibility Center Filter';
            FieldClass = FlowFilter;
            TableRelation = "Responsibility Center";
        }
        field(201; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(202; "Global Dimension 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(203; "Global Dimension 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(204; "Dimension Set ID Filter"; Integer)
        {
            Caption = 'Dimension Set ID Filter';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Name, "Emission Scope", Blocked, "Direct Posting") { }
        fieldgroup(Brick; "No.", Name, "Emission Scope", Blocked) { }
    }

    trigger OnDelete()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
    begin
        SustainabilityLedgerEntry.SetRange("Account No.", "No.");
        if not SustainabilityLedgerEntry.IsEmpty() then
            Error(LedgerEntryExistsErr, "No.");
    end;

    trigger OnInsert()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.UpdateDefaultDim(Database::"Sustainability Account", "No.", "Global Dimension 1 Code", "Global Dimension 2 Code");
    end;

    procedure CheckAccountReadyForPosting()
    begin
        TestField("Account Type", "Account Type"::Posting, ErrorInfo.Create());
        TestField(Blocked, false, ErrorInfo.Create());
        TestField(Category, ErrorInfo.Create());
        TestField(Subcategory, ErrorInfo.Create());
    end;

    local procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        if not IsTemporary() then
            DimMgt.SaveDefaultDim(Database::"Sustainability Account", "No.", FieldNumber, ShortcutDimCode);
    end;

    procedure IsPosting(): Boolean
    begin
        exit("Account Type" = "Account Type"::Posting);
    end;

    var
        LedgerEntryExistsErr: Label 'You cannot change this value because there are one or more ledger entries associated with this account: %1.', Comment = '%1 = Account No.';
}