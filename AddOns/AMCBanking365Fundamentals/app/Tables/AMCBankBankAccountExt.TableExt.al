tableextension 20103 "AMC Bank Bank Account ext." extends "Bank Account"
{
    fields
    {
        field(20100; "AMC Bank Name"; Text[50])
        {
            Caption = 'Bank Name';
            TableRelation = "AMC Bank Banks" WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
    }

}

