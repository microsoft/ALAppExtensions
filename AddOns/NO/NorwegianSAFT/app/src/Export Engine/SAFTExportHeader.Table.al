table 10682 "SAF-T Export Header"
{
    DataClassification = CustomerContent;
    Caption = 'SAF-T Export Header';

    fields
    {
        field(1; ID; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'ID';
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "Mapping Range Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Mapping Range Code';
            TableRelation = "SAF-T Mapping Range";

            trigger OnValidate()
            var
                SAFTMappingRange: Record "SAF-T Mapping Range";
            begin
                if "Mapping Range Code" = '' then begin
                    "Starting Date" := 0D;
                    "Ending Date" := 0D;
                end else begin
                    SAFTMappingRange.Get("Mapping Range Code");
                    "Starting Date" := SAFTMappingRange."Starting Date";
                    "Ending Date" := SAFTMappingRange."Ending Date";
                end;
            end;
        }
        field(3; "Starting Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Starting Date';
            Editable = false;
        }
        field(4; "Ending Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Ending Date';
            Editable = false;
        }
        field(5; "Parallel Processing"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Parallel Processing';
        }
        field(6; "Max No. Of Jobs"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Max No. Of Jobs';
            MinValue = 1;
            InitValue = 3;
        }
        field(7; "Split By Month"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Split By Month';
            InitValue = true;
        }
        field(8; "Earliest Start Date/Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Earliest Start Date/Time';

            trigger OnLookup()
            var
                DateTimeDialog: Page "Date-Time Dialog";
            begin
                DateTimeDialog.SetDateTime(RoundDateTime("Earliest Start Date/Time", 1000));
                if DateTimeDialog.RunModal() = Action::OK then
                    "Earliest Start Date/Time" := DateTimeDialog.GetDateTime();
            end;
        }
        field(9; "Folder Path"; Text[1024])
        {
            DataClassification = CustomerContent;
            Caption = 'Folder Path';
        }
        field(10; Status; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
            OptionMembers = "Not Started","In Progress",Failed,Completed;
            OptionCaption = 'Not Started,In Progress,Failed,Completed';
            Editable = false;
        }
        field(11; "Header Comment"; Text[18])
        {
            DataClassification = CustomerContent;
            Caption = 'Header Comment';
        }
        field(12; "Execution Start Date/Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Execution Start Date/Time';
            Editable = false;
        }
        field(13; "Execution End Date/Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Execution End Date/Time';
            Editable = false;
        }
        field(20; "SAF-T File"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'SAF-T File';
        }
        field(30; "Latest Data Check Date/Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Latest Data Check Date/Time';
            Editable = false;
        }
        field(31; "Data check status"; Enum "SAF-T Data Check status")
        {
            DataClassification = CustomerContent;
            Caption = 'Data check status';
            Editable = false;
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        "Parallel Processing" := TaskScheduler.CanCreateTask();
    end;

    trigger OnDelete()
    var
        SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
    begin
        SAFTExportMgt.DeleteExport(Rec);
    end;

    procedure AllowedToExportIntoFolder(): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if EnvironmentInformation.IsSaaS() then
            exit(false);
        exit("Folder Path" <> '');
    end;
}