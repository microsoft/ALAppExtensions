table 9260 "Customer Experience Survey"
{
    Access = Public;
    Caption = 'Customer Experience Survey';
    Extensible = false;
    TableType = Temporary;
    DataClassification = SystemMetadata;
    InherentEntitlements = X;
    InherentPermissions = X;

    fields
    {
        field(1; Name; Text[512])
        {
            DataClassification = SystemMetadata;
        }
        field(2; Description; Text[2048])
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Survey Cooling Time"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(4; "NPS Cooling Time"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(5; "CES Cooling Time"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(6; Enabled; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(7; "Trigger Event Name"; Text[512])
        {
            DataClassification = SystemMetadata;
        }
        field(8; "Trigger Type"; Option)
        {
            DataClassification = SystemMetadata;
            OptionMembers = Simple,EventBased,DayBased;
            OptionCaption = 'Simple,Event Based,Day Based';
        }
        field(9; "Trigger Period"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(10; "Prompt Probability"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(11; "Prompt Total Sample"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(12; "Prompt Sample"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(13; "Prompt Period"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(14; "Forms Pro Id"; Text[1024])
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Name)
        {
            Clustered = true;
        }
    }
}