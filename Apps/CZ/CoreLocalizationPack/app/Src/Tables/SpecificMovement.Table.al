table 31077 "Specific Movement CZL"
{
    Caption = 'Specific Movement';
#if not CLEAN22
    LookupPageID = "Specific Movements CZL";
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
#else
    ObsoleteState = Removed;
    ObsoleteTag = '25.0';
#endif
    ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Description EN"; Text[100])
        {
            Caption = 'Description EN';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }
}