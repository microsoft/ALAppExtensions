table 1876 "Business Setup Icon"
{
    Access = Internal;
    Caption = 'Business Setup Icon';
    DataPerCompany = false;

    fields
    {
        field(1; "Business Setup Name"; Text[50])
        {
            Caption = 'Business Setup Name';
        }
        field(2; Icon; Media)
        {
            Caption = 'Icon';
        }
        field(3; "Media Resources Ref"; Code[50])
        {
            Caption = 'Media Resources Ref';
        }
    }

    keys
    {
        key(Key1; "Business Setup Name")
        {
            Clustered = true;
        }
    }

}

