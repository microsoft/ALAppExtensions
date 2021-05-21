tableextension 11763 "Service Line CZL" extends "Service Line"
{
    fields
    {
        field(11769; "Negative CZL"; Boolean)
        {
            Caption = 'Negative';
            DataClassification = CustomerContent;
        }
        field(31064; "Physical Transfer CZL"; Boolean)
        {
            Caption = 'Physical Transfer';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Physical Transfer CZL" then begin
                    TestField(Type, Type::Item);
                    if "Document Type" = "Document Type"::"Credit Memo" then
                        FieldError("Document Type");
                end;
            end;
        }
        field(31065; "Tariff No. CZL"; Code[20])
        {
            Caption = 'Tariff No.';
            TableRelation = "Tariff Number";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                TariffNo: Record "Tariff Number";
            begin
                if (Type = Type::"G/L Account") and ("Tariff No. CZL" <> xRec."Tariff No. CZL") then begin
                    if not TariffNo.Get("Tariff No. CZL") then
                        TariffNo.Init();
                    Validate("Unit of Measure Code", TariffNo."VAT Stat. UoM Code CZL");
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
        field(31067; "Country/Reg. of Orig. Code CZL"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }
    }
}