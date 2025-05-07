namespace Microsoft.Sustainability.FinancialReporting;

using Microsoft.Finance.Analysis;
using Microsoft.Finance.Consolidation;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.FinancialReports;
using Microsoft.Finance.GeneralLedger.Budget;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.SalesTax;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Comment;
using Microsoft.Sustainability.Account;

table 6225 "Sust. Account (Analysis View)"
{
    Caption = 'Sustainability Account (Analysis View)';
    DataCaptionFields = "No.", Name;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
            TableRelation = if ("Account Source" = const("Sust. Account")) "Sustainability Account";
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(3; "Search Name"; Code[100])
        {
            Caption = 'Search Name';
        }
        field(4; "Account Type"; Enum "Sustainability Account Type")
        {
            Caption = 'Account Type';
        }
        field(5; "Account Source"; Enum "Analysis Account Source")
        {
            Caption = 'Account Source';
        }
        field(6; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(7; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(11; "No. 2"; Code[20])
        {
            Caption = 'No. 2';
        }
        field(12; Comment; Boolean)
        {
            CalcFormula = exist("Comment Line" where("Table Name" = const("Sustainability Account"),
                                                     "No." = field("No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
        field(14; "Direct Posting"; Boolean)
        {
            Caption = 'Direct Posting';
            InitValue = true;
        }
        field(17; "New Page"; Boolean)
        {
            Caption = 'New Page';
        }
        field(18; "No. of Blank Lines"; Integer)
        {
            Caption = 'No. of Blank Lines';
            MinValue = 0;
        }
        field(19; Indentation; Integer)
        {
            Caption = 'Indentation';
            MinValue = 0;
        }
        field(26; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(28; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(29; "Global Dimension 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(30; "Global Dimension 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(34; Totaling; Text[250])
        {
            Caption = 'Totaling';
            TableRelation = if ("Account Source" = const("Sust. Account")) "Sustainability Account";
            ValidateTableRelation = false;
        }
        field(35; "Budget Filter"; Code[10])
        {
            Caption = 'Budget Filter';
            FieldClass = FlowFilter;
            TableRelation = "G/L Budget Name";
        }
        field(40; "Consol. Debit Acc."; Code[20])
        {
            AccessByPermission = TableData "Business Unit" = R;
            Caption = 'Consol. Debit Acc.';
        }
        field(41; "Consol. Credit Acc."; Code[20])
        {
            AccessByPermission = TableData "Business Unit" = R;
            Caption = 'Consol. Credit Acc.';
        }
        field(42; "Business Unit Filter"; Code[20])
        {
            Caption = 'Business Unit Filter';
            FieldClass = FlowFilter;
            TableRelation = "Business Unit";
        }
        field(43; "Gen. Posting Type"; Option)
        {
            Caption = 'Gen. Posting Type';
            OptionCaption = ' ,Purchase,Sale';
            OptionMembers = " ",Purchase,Sale;
        }
        field(44; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(45; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(49; "Automatic Ext. Texts"; Boolean)
        {
            Caption = 'Automatic Ext. Texts';
        }
        field(54; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            TableRelation = "Tax Area";
        }
        field(55; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
        }
        field(56; "Tax Group Code"; Code[20])
        {
            Caption = 'Tax Group Code';
            TableRelation = "Tax Group";
        }
        field(57; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(58; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(63; "Exchange Rate Adjustment"; Option)
        {
            Caption = 'Exchange Rate Adjustment';
            OptionCaption = 'No Adjustment,Adjust Amount,Adjust Additional-Currency Amount';
            OptionMembers = "No Adjustment","Adjust Amount","Adjust Additional-Currency Amount";
        }
        field(66; "Analysis View Filter"; Code[10])
        {
            Caption = 'Analysis View Filter';
            FieldClass = FlowFilter;
            TableRelation = "Analysis View";
        }
        field(67; "Dimension 1 Filter"; Code[20])
        {
            CaptionClass = GetCaptionClass(1);
            Caption = 'Dimension 1 Filter';
            FieldClass = FlowFilter;
        }
        field(68; "Dimension 2 Filter"; Code[20])
        {
            CaptionClass = GetCaptionClass(2);
            Caption = 'Dimension 2 Filter';
            FieldClass = FlowFilter;
        }
        field(69; "Dimension 3 Filter"; Code[20])
        {
            CaptionClass = GetCaptionClass(3);
            Caption = 'Dimension 3 Filter';
            FieldClass = FlowFilter;
        }
        field(70; "Dimension 4 Filter"; Code[20])
        {
            CaptionClass = GetCaptionClass(4);
            Caption = 'Dimension 4 Filter';
            FieldClass = FlowFilter;
        }
        field(100; "Net Change (CO2)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Analysis View Entry"."Emission CO2" where("Analysis View Code" = field("Analysis View Filter"),
                                                                         "Business Unit Code" = field("Business Unit Filter"),
                                                                         "Account No." = field("No."),
                                                                         "Account Source" = field("Account Source"),
                                                                         "Account No." = field(filter(Totaling)),
                                                                         "Dimension 1 Value Code" = field("Dimension 1 Filter"),
                                                                         "Dimension 2 Value Code" = field("Dimension 2 Filter"),
                                                                         "Dimension 3 Value Code" = field("Dimension 3 Filter"),
                                                                         "Dimension 4 Value Code" = field("Dimension 4 Filter"),
                                                                         "Posting Date" = field("Date Filter")));
            Caption = 'Net Change (CO2)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(101; "Balance at Date (CO2)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Analysis View Entry"."Emission CO2" where("Analysis View Code" = field("Analysis View Filter"),
                                                                         "Business Unit Code" = field("Business Unit Filter"),
                                                                         "Account No." = field("No."),
                                                                         "Account Source" = field("Account Source"),
                                                                         "Account No." = field(filter(Totaling)),
                                                                         "Dimension 1 Value Code" = field("Dimension 1 Filter"),
                                                                         "Dimension 2 Value Code" = field("Dimension 2 Filter"),
                                                                         "Dimension 3 Value Code" = field("Dimension 3 Filter"),
                                                                         "Dimension 4 Value Code" = field("Dimension 4 Filter"),
                                                                         "Posting Date" = field(upperlimit("Date Filter"))));
            Caption = 'Balance at Date (CO2)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(102; "Balance (CO2)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Analysis View Entry"."Emission CO2" where("Analysis View Code" = field("Analysis View Filter"),
                                                                                 "Business Unit Code" = field("Business Unit Filter"),
                                                                                 "Account No." = field("No."),
                                                                                 "Account Source" = field("Account Source"),
                                                                                 "Account No." = field(filter(Totaling)),
                                                                                 "Dimension 1 Value Code" = field("Dimension 1 Filter"),
                                                                                 "Dimension 2 Value Code" = field("Dimension 2 Filter"),
                                                                                 "Dimension 3 Value Code" = field("Dimension 3 Filter"),
                                                                                 "Dimension 4 Value Code" = field("Dimension 4 Filter"),
                                                                                 "Posting Date" = field("Date Filter")));
            Caption = 'Balance (CO2)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(103; "Net Change (CH4)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Analysis View Entry"."Emission CH4" where("Analysis View Code" = field("Analysis View Filter"),
                                                                         "Business Unit Code" = field("Business Unit Filter"),
                                                                         "Account No." = field("No."),
                                                                         "Account Source" = field("Account Source"),
                                                                         "Account No." = field(filter(Totaling)),
                                                                         "Dimension 1 Value Code" = field("Dimension 1 Filter"),
                                                                         "Dimension 2 Value Code" = field("Dimension 2 Filter"),
                                                                         "Dimension 3 Value Code" = field("Dimension 3 Filter"),
                                                                         "Dimension 4 Value Code" = field("Dimension 4 Filter"),
                                                                         "Posting Date" = field("Date Filter")));
            Caption = 'Net Change (CH4)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(104; "Balance at Date (CH4)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Analysis View Entry"."Emission CH4" where("Analysis View Code" = field("Analysis View Filter"),
                                                                         "Business Unit Code" = field("Business Unit Filter"),
                                                                         "Account No." = field("No."),
                                                                         "Account Source" = field("Account Source"),
                                                                         "Account No." = field(filter(Totaling)),
                                                                         "Dimension 1 Value Code" = field("Dimension 1 Filter"),
                                                                         "Dimension 2 Value Code" = field("Dimension 2 Filter"),
                                                                         "Dimension 3 Value Code" = field("Dimension 3 Filter"),
                                                                         "Dimension 4 Value Code" = field("Dimension 4 Filter"),
                                                                         "Posting Date" = field(upperlimit("Date Filter"))));
            Caption = 'Balance at Date (CH4)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(105; "Balance (CH4)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Analysis View Entry"."Emission CH4" where("Analysis View Code" = field("Analysis View Filter"),
                                                                                 "Business Unit Code" = field("Business Unit Filter"),
                                                                                 "Account No." = field("No."),
                                                                                 "Account Source" = field("Account Source"),
                                                                                 "Account No." = field(filter(Totaling)),
                                                                                 "Dimension 1 Value Code" = field("Dimension 1 Filter"),
                                                                                 "Dimension 2 Value Code" = field("Dimension 2 Filter"),
                                                                                 "Dimension 3 Value Code" = field("Dimension 3 Filter"),
                                                                                 "Dimension 4 Value Code" = field("Dimension 4 Filter"),
                                                                                 "Posting Date" = field("Date Filter")));
            Caption = 'Balance (CH4)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(106; "Net Change (N2O)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Analysis View Entry"."Emission N2O" where("Analysis View Code" = field("Analysis View Filter"),
                                                                         "Business Unit Code" = field("Business Unit Filter"),
                                                                         "Account No." = field("No."),
                                                                         "Account Source" = field("Account Source"),
                                                                         "Account No." = field(filter(Totaling)),
                                                                         "Dimension 1 Value Code" = field("Dimension 1 Filter"),
                                                                         "Dimension 2 Value Code" = field("Dimension 2 Filter"),
                                                                         "Dimension 3 Value Code" = field("Dimension 3 Filter"),
                                                                         "Dimension 4 Value Code" = field("Dimension 4 Filter"),
                                                                         "Posting Date" = field("Date Filter")));
            Caption = 'Net Change (N2O)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(107; "Balance at Date (N2O)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Analysis View Entry"."Emission N2O" where("Analysis View Code" = field("Analysis View Filter"),
                                                                         "Business Unit Code" = field("Business Unit Filter"),
                                                                         "Account No." = field("No."),
                                                                         "Account Source" = field("Account Source"),
                                                                         "Account No." = field(filter(Totaling)),
                                                                         "Dimension 1 Value Code" = field("Dimension 1 Filter"),
                                                                         "Dimension 2 Value Code" = field("Dimension 2 Filter"),
                                                                         "Dimension 3 Value Code" = field("Dimension 3 Filter"),
                                                                         "Dimension 4 Value Code" = field("Dimension 4 Filter"),
                                                                         "Posting Date" = field(upperlimit("Date Filter"))));
            Caption = 'Balance at Date (N2O)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(108; "Balance (N2O)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Analysis View Entry"."Emission N2O" where("Analysis View Code" = field("Analysis View Filter"),
                                                                                 "Business Unit Code" = field("Business Unit Filter"),
                                                                                 "Account No." = field("No."),
                                                                                 "Account Source" = field("Account Source"),
                                                                                 "Account No." = field(filter(Totaling)),
                                                                                 "Dimension 1 Value Code" = field("Dimension 1 Filter"),
                                                                                 "Dimension 2 Value Code" = field("Dimension 2 Filter"),
                                                                                 "Dimension 3 Value Code" = field("Dimension 3 Filter"),
                                                                                 "Dimension 4 Value Code" = field("Dimension 4 Filter"),
                                                                                 "Posting Date" = field("Date Filter")));
            Caption = 'Balance (N2O)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(109; "Net Change (CO2e Emission)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Analysis View Entry"."CO2e Emission" where("Analysis View Code" = field("Analysis View Filter"),
                                                                         "Business Unit Code" = field("Business Unit Filter"),
                                                                         "Account No." = field("No."),
                                                                         "Account Source" = field("Account Source"),
                                                                         "Account No." = field(filter(Totaling)),
                                                                         "Dimension 1 Value Code" = field("Dimension 1 Filter"),
                                                                         "Dimension 2 Value Code" = field("Dimension 2 Filter"),
                                                                         "Dimension 3 Value Code" = field("Dimension 3 Filter"),
                                                                         "Dimension 4 Value Code" = field("Dimension 4 Filter"),
                                                                         "Posting Date" = field("Date Filter")));
            Caption = 'Net Change (CO2e Emission)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110; "Bal. at Date (CO2e Emission)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Analysis View Entry"."CO2e Emission" where("Analysis View Code" = field("Analysis View Filter"),
                                                                         "Business Unit Code" = field("Business Unit Filter"),
                                                                         "Account No." = field("No."),
                                                                         "Account Source" = field("Account Source"),
                                                                         "Account No." = field(filter(Totaling)),
                                                                         "Dimension 1 Value Code" = field("Dimension 1 Filter"),
                                                                         "Dimension 2 Value Code" = field("Dimension 2 Filter"),
                                                                         "Dimension 3 Value Code" = field("Dimension 3 Filter"),
                                                                         "Dimension 4 Value Code" = field("Dimension 4 Filter"),
                                                                         "Posting Date" = field(upperlimit("Date Filter"))));
            Caption = 'Balance at Date (CO2e Emission)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(111; "Balance (CO2e Emission)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Analysis View Entry"."CO2e Emission" where("Analysis View Code" = field("Analysis View Filter"),
                                                                                 "Business Unit Code" = field("Business Unit Filter"),
                                                                                 "Account No." = field("No."),
                                                                                 "Account Source" = field("Account Source"),
                                                                                 "Account No." = field(filter(Totaling)),
                                                                                 "Dimension 1 Value Code" = field("Dimension 1 Filter"),
                                                                                 "Dimension 2 Value Code" = field("Dimension 2 Filter"),
                                                                                 "Dimension 3 Value Code" = field("Dimension 3 Filter"),
                                                                                 "Dimension 4 Value Code" = field("Dimension 4 Filter"),
                                                                                 "Posting Date" = field("Date Filter")));
            Caption = 'Balance (CO2e Emission)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(112; "Net Change (Carbon Fee)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Analysis View Entry"."Carbon Fee" where("Analysis View Code" = field("Analysis View Filter"),
                                                                         "Business Unit Code" = field("Business Unit Filter"),
                                                                         "Account No." = field("No."),
                                                                         "Account Source" = field("Account Source"),
                                                                         "Account No." = field(filter(Totaling)),
                                                                         "Dimension 1 Value Code" = field("Dimension 1 Filter"),
                                                                         "Dimension 2 Value Code" = field("Dimension 2 Filter"),
                                                                         "Dimension 3 Value Code" = field("Dimension 3 Filter"),
                                                                         "Dimension 4 Value Code" = field("Dimension 4 Filter"),
                                                                         "Posting Date" = field("Date Filter")));
            Caption = 'Net Change (Carbon Fee)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(113; "Balance at Date (Carbon Fee)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Analysis View Entry"."Carbon Fee" where("Analysis View Code" = field("Analysis View Filter"),
                                                                         "Business Unit Code" = field("Business Unit Filter"),
                                                                         "Account No." = field("No."),
                                                                         "Account Source" = field("Account Source"),
                                                                         "Account No." = field(filter(Totaling)),
                                                                         "Dimension 1 Value Code" = field("Dimension 1 Filter"),
                                                                         "Dimension 2 Value Code" = field("Dimension 2 Filter"),
                                                                         "Dimension 3 Value Code" = field("Dimension 3 Filter"),
                                                                         "Dimension 4 Value Code" = field("Dimension 4 Filter"),
                                                                         "Posting Date" = field(upperlimit("Date Filter"))));
            Caption = 'Balance at Date (Carbon Fee)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(114; "Balance (Carbon Fee)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Analysis View Entry"."Carbon Fee" where("Analysis View Code" = field("Analysis View Filter"),
                                                                                 "Business Unit Code" = field("Business Unit Filter"),
                                                                                 "Account No." = field("No."),
                                                                                 "Account Source" = field("Account Source"),
                                                                                 "Account No." = field(filter(Totaling)),
                                                                                 "Dimension 1 Value Code" = field("Dimension 1 Filter"),
                                                                                 "Dimension 2 Value Code" = field("Dimension 2 Filter"),
                                                                                 "Dimension 3 Value Code" = field("Dimension 3 Filter"),
                                                                                 "Dimension 4 Value Code" = field("Dimension 4 Filter"),
                                                                                 "Posting Date" = field("Date Filter")));
            Caption = 'Balance (Carbon Fee)';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "No.", "Account Source")
        {
            Clustered = true;
        }
        key(Key2; "Search Name")
        {
        }
        key(Key3; "Gen. Bus. Posting Group")
        {
        }
        key(Key4; "Gen. Prod. Posting Group")
        {
        }
    }

    fieldgroups
    {
    }

    var
        AnalysisView: Record "Analysis View";
        Dimension1FilterTxt: Label '1,6,,Dimension 1 Filter';
        Dimension2FilterTxt: Label '1,6,,Dimension 2 Filter';
        Dimension3FilterTxt: Label '1,6,,Dimension 3 Filter';
        Dimension4FilterTxt: Label '1,6,,Dimension 4 Filter';

    procedure GetCaptionClass(AnalysisViewDimType: Integer) Result: Text[250]
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetCaptionClass(Rec, AnalysisViewDimType, Result, IsHandled);
        if IsHandled then
            exit;

        if AnalysisView.Code <> GetFilter("Analysis View Filter") then
            AnalysisView.Get(GetFilter("Analysis View Filter"));
        case AnalysisViewDimType of
            1:
                begin
                    if AnalysisView."Dimension 1 Code" <> '' then
                        exit('1,6,' + AnalysisView."Dimension 1 Code");

                    exit(Dimension1FilterTxt);
                end;
            2:
                begin
                    if AnalysisView."Dimension 2 Code" <> '' then
                        exit('1,6,' + AnalysisView."Dimension 2 Code");

                    exit(Dimension2FilterTxt);
                end;
            3:
                begin
                    if AnalysisView."Dimension 3 Code" <> '' then
                        exit('1,6,' + AnalysisView."Dimension 3 Code");

                    exit(Dimension3FilterTxt);
                end;
            4:
                begin
                    if AnalysisView."Dimension 4 Code" <> '' then
                        exit('1,6,' + AnalysisView."Dimension 4 Code");

                    exit(Dimension4FilterTxt);
                end;
        end;
    end;

    procedure CopyDimFilters(var AccSchedLine: Record "Acc. Schedule Line")
    begin
        AccSchedLine.CopyFilter("Dimension 1 Filter", "Dimension 1 Filter");
        AccSchedLine.CopyFilter("Dimension 2 Filter", "Dimension 2 Filter");
        AccSchedLine.CopyFilter("Dimension 3 Filter", "Dimension 3 Filter");
        AccSchedLine.CopyFilter("Dimension 4 Filter", "Dimension 4 Filter");
    end;

    procedure SetDimFilters(DimFilter1: Text; DimFilter2: Text; DimFilter3: Text; DimFilter4: Text)
    begin
        SetFilter("Dimension 1 Filter", DimFilter1);
        SetFilter("Dimension 2 Filter", DimFilter2);
        SetFilter("Dimension 3 Filter", DimFilter3);
        SetFilter("Dimension 4 Filter", DimFilter4);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetCaptionClass(var SustAccountAnalysisView: Record "Sust. Account (Analysis View)"; AnalysisViewDimType: Integer; var Result: Text[250]; var IsHandled: Boolean)
    begin
    end;
}