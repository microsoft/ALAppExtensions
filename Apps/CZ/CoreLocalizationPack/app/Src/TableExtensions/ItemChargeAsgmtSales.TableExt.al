tableextension 31020 "Item Charge Asgmt. (Sales) CZL" extends "Item Charge Assignment (Sales)"
{
    fields
    {
        field(31052; "Incl. in Intrastat Amount CZL"; Boolean)
        {
            Caption = 'Incl. in Intrastat Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                StatutoryReportingSetupCZL.CheckItemChargesInIntrastatCZL();
            end;
        }
        field(31053; "Incl. in Intrastat S.Value CZL"; Boolean)
        {
            Caption = 'Incl. in Intrastat Stat. Value';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                StatutoryReportingSetupCZL.CheckItemChargesInIntrastatCZL();
            end;
        }
    }

    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
}