tableextension 11796 "Shipment Method CZL" extends "Shipment Method"
{
    fields
    {
        field(31065; "Incl. Item Charges (Amt.) CZL"; Boolean)
        {
            Caption = 'Include Item Charges (Amount)';
            DataClassification = CustomerContent;
        }
        field(31066; "Intrastat Deliv. Grp. Code CZL"; Code[10])
        {
            Caption = 'Intrastat Delivery Group Code';
            TableRelation = "Intrastat Delivery Group CZL".Code;
            DataClassification = CustomerContent;
        }
        field(31067; "Incl. Item Charges (S.Val) CZL"; Boolean)
        {
            Caption = 'Incl. Item Charges (Stat.Val.)';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Incl. Item Charges (S.Val) CZL" then begin
                    TestField("Adjustment % CZL", 0);
                    CheckIncludeIntrastatCZL();
                end;
            end;
        }
        field(31068; "Adjustment % CZL"; Decimal)
        {
            Caption = 'Adjustment %';
            MaxValue = 100;
            MinValue = -100;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Adjustment % CZL" <> 0 then begin
                    TestField("Incl. Item Charges (S.Val) CZL", false);
                    TestField("Incl. Item Charges (Amt.) CZL", false);
                end;
            end;
        }
    }

    procedure CheckIncludeIntrastatCZL()
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        StatutoryReportingSetupCZL.Get();
        StatutoryReportingSetupCZL.TestField("No Item Charges in Intrastat", false);
    end;
}