tableextension 11755 "Sales Line CZL" extends "Sales Line"
{
    fields
    {
        field(31065; "Tariff No. CZL"; Code[20])
        {
            Caption = 'Tariff No.';
            TableRelation = "Tariff Number";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                TariffNumber: Record "Tariff Number";
            begin
                if (Type = Type::"G/L Account") and ("Tariff No. CZL" <> xRec."Tariff No. CZL") then begin
                    if not TariffNumber.Get("Tariff No. CZL") then
                        TariffNumber.Init();

                    if ("Job Contract Entry No." <> 0) and
                       (TariffNumber."VAT Stat. UoM Code CZL" <> '') and
                       (TariffNumber."VAT Stat. UoM Code CZL" <> "Unit of Measure Code")
                    then
                        TestField("Unit of Measure Code", TariffNumber."VAT Stat. UoM Code CZL");

                    if "Job Contract Entry No." = 0 then
                        Validate("Unit of Measure Code", TariffNumber."VAT Stat. UoM Code CZL");
                end;

                if "Tariff No. CZL" <> xRec."Tariff No. CZL" then
                    "Statistic Indication CZL" := '';
            end;
        }
        field(31066; "Statistic Indication CZL"; Code[10])
        {
            Caption = 'Statistic Indication';
            TableRelation = "Statistic Indication CZL".Code WHERE("Tariff No." = FIELD("Tariff No. CZL"));
            DataClassification = CustomerContent;
        }
    }
}