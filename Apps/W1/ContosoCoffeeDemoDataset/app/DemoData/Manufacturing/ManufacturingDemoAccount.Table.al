table 4761 "Manufacturing Demo Account"
{
    TableType = Temporary;
    ObsoleteReason = 'This table will be replaced by "Contoso GL Account".';
    ObsoleteState = Removed;
    ObsoleteTag = '26.0';

    fields
    {
        field(1; "Account Key"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Account Value"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Account Description"; text[50])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Account Key")
        {
            Clustered = true;
        }
    }
}