tableextension 31018 "Item Charge CZL" extends "Item Charge"
{
    fields
    {
        field(31052; "Incl. in Intrastat Amount CZL"; Boolean)
        {
            Caption = 'Incl. in Intrastat Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Incl. in Intrastat Amount CZL" then begin
                    StatutoryReportingSetupCZL.CheckItemChargesInIntrastatCZL();
                    TestField("Incl. in Intrastat S.Value CZL", false);
                end;
            end;
        }
        field(31053; "Incl. in Intrastat S.Value CZL"; Boolean)
        {
            Caption = 'Incl. in Intrastat Stat. Value';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Incl. in Intrastat S.Value CZL" then begin
                    StatutoryReportingSetupCZL.CheckItemChargesInIntrastatCZL();
                    TestField("Incl. in Intrastat Amount CZL", false);
                end;
            end;
        }
    }

    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
}