tableextension 11753 "Tariff Number CZL" extends "Tariff Number"
{
    fields
    {
        field(11765; "Statement Code CZL"; Code[10])
        {
            Caption = 'Statement Code';
            TableRelation = "Commodity CZL".Code;
            DataClassification = CustomerContent;
        }
        field(11766; "VAT Stat. UoM Code CZL"; Code[10])
        {
            Caption = 'VAT Stat. Unit of Measure Code';
            TableRelation = "Unit of Measure";
            DataClassification = CustomerContent;
        }
        field(11767; "Allow Empty UoM Code CZL"; Boolean)
        {
            Caption = 'Allow Empty Unit of Measure Code';
            DataClassification = CustomerContent;
        }
        field(11768; "Statement Limit Code CZL"; Code[10])
        {
            Caption = 'Statement Limit Code';
            TableRelation = "Commodity CZL".Code;
            DataClassification = CustomerContent;
        }
        field(11795; "Description EN CZL"; Text[100])
        {
            Caption = 'Description EN';
            DataClassification = CustomerContent;
        }
        field(31065; "Suppl. Unit of Meas. Code CZL"; Code[10])
        {
            Caption = 'Supplementary Unit of Measure Code';
            TableRelation = "Unit of Measure";
            DataClassification = CustomerContent;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
#if not CLEAN22

            trigger OnValidate()
            var
                UnitofMeasure: Record "Unit of Measure";
            begin
                if "Suppl. Unit of Meas. Code CZL" = '' then
                    "Supplementary Units" := false
                else
                    "Supplementary Units" := UnitofMeasure.Get("Suppl. Unit of Meas. Code CZL");
            end;
#endif
        }
    }
#if not CLEAN22
    keys
    {
        key(Key11700; "Suppl. Unit of Meas. Code CZL")
        {
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
    }
#endif
}