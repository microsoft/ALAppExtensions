tableextension 11760 "Purch. Inv. Line CZL" extends "Purch. Inv. Line"
{
    fields
    {
        field(31065; "Tariff No. CZL"; Code[20])
        {
            Caption = 'Tariff No.';
            TableRelation = "Tariff Number";
            DataClassification = CustomerContent;
        }
        field(31066; "Statistic Indication CZL"; Code[10])
        {
            Caption = 'Statistic Indication';
            TableRelation = "Statistic Indication CZL".Code where("Tariff No." = field("Tariff No. CZL"));
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