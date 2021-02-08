table 31091 "Commodity Setup CZL"
{
    Caption = 'Commodity Setup';
    DataCaptionFields = "Commodity Code";
    DrillDownPageID = "Commodity Setup CZL";
    LookupPageID = "Commodity Setup CZL";

    fields
    {
        field(1; "Commodity Code"; Code[10])
        {
            Caption = 'Commodity Code';
            NotBlank = true;
            TableRelation = "Commodity CZL";
            DataClassification = CustomerContent;
        }
        field(2; "Valid From"; Date)
        {
            Caption = 'Valid From';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(3; "Valid To"; Date)
        {
            Caption = 'Valid To';
            DataClassification = CustomerContent;
        }
        field(4; "Commodity Limit Amount LCY"; Decimal)
        {
            Caption = 'Commodity Limit Amount LCY';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "Commodity Code", "Valid From")
        {
            Clustered = true;
        }
    }
}