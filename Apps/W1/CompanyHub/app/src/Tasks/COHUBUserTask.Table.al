table 1154 "COHUB User Task"
{
    ReplicateData = false;
    DataPerCompany = false;
    Access = Internal;

    fields
    {
        field(1; ID; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; "Enviroment No."; Code[20])
        {
            TableRelation = "COHUB Enviroment";
            ValidateTableRelation = true;
            DataClassification = CustomerContent;
        }
        field(3; "Company Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Assigned To"; Guid)
        {
            TableRelation = User."User Security ID";
            ValidateTableRelation = true;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5; "Created By"; Code[50])
        {
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; "Created Date"; Date)
        {
            Caption = 'Created Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(7; "Due Date"; Date)
        {
            Caption = 'Due Date';
            DataClassification = CustomerContent;
        }
        field(8; "Percent Complete"; Integer)
        {
            Caption = '% Complete';
            MaxValue = 100;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(9; "Start Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = CustomerContent;
        }
        field(10; Priority; Option)
        {
            OptionMembers = ,Low,Normal,High;
            DataClassification = CustomerContent;
        }
        field(11; Title; Text[250])
        {
            Caption = 'Subject';
            DataClassification = CustomerContent;
        }
        field(12; "Last Refreshed"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(13; "Company Display Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(14; Link; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(15; "User Task Group Assigned To"; Code[20])
        {
            Caption = 'User Task Group';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1; "Enviroment No.", "Company Name", ID)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    procedure GetUserTaskCounts(EnviromentNumber: Code[20]; CompanyName: Text[50]; var TaskCount: Text[5]; var OverDueTaskCount: Text[5])
    begin
        SetRange("Enviroment No.", EnviromentNumber);
        SetRange("Company Name", CompanyName);
        SetRange("Assigned To", UserSecurityId());
        SetFilter("Percent Complete", '<%1', 100);
        TaskCount := CopyStr(Format(Count()), 1, MaxStrLen(TaskCount));

        SETRANGE("Due Date", 0D);
        SetFilter("Due Date", '<=%1', DT2DATE(CurrentDateTime()));
        OverDueTaskCount := CopyStr(Format(Count()), 1, MaxStrLen(OverDueTaskCount));
    end;
}

