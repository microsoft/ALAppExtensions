tableextension 11738 "VAT Posting Setup CZL" extends "VAT Posting Setup"
{
    fields
    {
        field(11770; "Reverse Charge Check CZL"; Enum "Reverse Charge Check CZL")
        {
            Caption = 'Reverse Charge Check';
            DataClassification = CustomerContent;
        }
        field(11774; "Purch. VAT Curr. Exch. Acc CZL"; Code[20])
        {
            Caption = 'Purchase VAT Currency Exchange Rate Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Purch. VAT Curr. Exch. Acc CZL");
            end;
        }
        field(11775; "Sales VAT Curr. Exch. Acc CZL"; Code[20])
        {
            Caption = 'Sales VAT Currency Exchange Rate Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Sales VAT Curr. Exch. Acc CZL");
            end;
        }
        field(31050; "VIES Purchase CZL"; Boolean)
        {
            Caption = 'VIES Purchase';
            DataClassification = CustomerContent;
        }
        field(31051; "VIES Sales CZL"; Boolean)
        {
            Caption = 'VIES Sales';
            DataClassification = CustomerContent;
        }
        field(31110; "VAT Rate CZL"; Enum "VAT Rate CZL")
        {
            Caption = 'VAT Rate';
            DataClassification = CustomerContent;
        }
        field(31111; "Supplies Mode Code CZL"; Enum "VAT Ctrl. Report Mode CZL")
        {
            Caption = 'Supplies Mode Code';
            DataClassification = CustomerContent;
        }
        field(31112; "Ratio Coefficient CZL"; Boolean)
        {
            Caption = 'Ratio Coefficient';
            DataClassification = CustomerContent;
        }
        field(31113; "Corrections Bad Receivable CZL"; Enum "VAT Ctrl. Report Corect. CZL")
        {
            Caption = 'Corrections for Bad Receivable';
            DataClassification = CustomerContent;
        }
    }

    procedure GetVATAccountNoCZL(Type: Enum "General Posting Type"; Advance: Boolean): Code[20]
    begin
        case Type of
            Type::Purchase:
                if Advance then begin
                    TestField("Purch. Advance VAT Account");
                    exit("Purch. Advance VAT Account");
                end else begin
                    TestField("Purchase VAT Account");
                    exit("Purchase VAT Account");
                end;
            Type::Sale:
                if Advance then begin
                    TestField("Sales Advance VAT Account");
                    exit("Sales Advance VAT Account");
                end else begin
                    TestField("Sales VAT Account");
                    exit("Sales VAT Account");
                end;
        end;
    end;
}
