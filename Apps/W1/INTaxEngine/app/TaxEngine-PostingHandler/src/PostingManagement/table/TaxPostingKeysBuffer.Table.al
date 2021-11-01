table 20337 "Tax Posting Keys Buffer"
{
    Caption = 'Tax Posting Keys Buffer';
    DataClassification = EndUserIdentifiableInformation;
    Access = Internal;
    Extensible = false;
    fields
    {

        field(1; "Key"; Text[2000])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Key';
        }
        field(2; "Record ID"; RecordId)
        {
            DataClassification = CustomerContent;
            Caption = 'Record ID';
        }
    }
    keys
    {
        key(PK; "Key", "Record ID")
        {
            Clustered = true;
        }
    }

}