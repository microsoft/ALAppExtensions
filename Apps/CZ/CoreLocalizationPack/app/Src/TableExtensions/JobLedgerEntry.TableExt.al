tableextension 11795 "Job Ledger Entry CZL" extends "Job Ledger Entry"
{
    fields
    {
        field(11764; "Correction CZL"; Boolean)
        {
            Caption = 'Correction';
            DataClassification = CustomerContent;
        }
        field(31050; "Tariff No. CZL"; Code[20])
        {
            Caption = 'Tariff No.';
            TableRelation = "Tariff Number";
            DataClassification = CustomerContent;
        }
        field(31054; "Net Weight CZL"; Decimal)
        {
            Caption = 'Net Weight';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(31057; "Country/Reg. of Orig. Code CZL"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }
        field(31058; "Statistic Indication CZL"; Code[10])
        {
            Caption = 'Statistic Indication';
            TableRelation = "Statistic Indication CZL".Code where("Tariff No." = field("Tariff No. CZL"));
            DataClassification = CustomerContent;
        }
        field(31059; "Intrastat Transaction CZL"; Boolean)
        {
            Caption = 'Intrastat Transaction';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}
