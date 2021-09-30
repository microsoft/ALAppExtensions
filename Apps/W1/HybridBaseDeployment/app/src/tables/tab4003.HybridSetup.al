table 4003 "Intelligent Cloud Setup"
{
    DataPerCompany = false;
    ReplicateData = false;
    // Do not extend this table
    // Extensible = false;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Description = 'The primary key.';
            DataClassification = SystemMetadata;
        }
        field(2; "Product ID"; Text[250])
        {
            Description = 'The ID of the source product to replicate.';
            DataClassification = SystemMetadata;
        }
        field(3; "Sql Server Type"; Option)
        {
            Description = 'The SQL server type of the source product to replicate.';
            OptionMembers = SQLServer,AzureSQL;
            DataClassification = SystemMetadata;
        }
        field(4; "Time to Run"; Time)
        {
            Description = 'The start time of the replication schedule.';
            DataClassification = SystemMetadata;
        }
        field(5; "Replication Enabled"; Boolean)
        {
            Description = 'Specifies whether the replication schedule is enabled.';
            DataClassification = SystemMetadata;
        }
        field(6; "Recurrence"; Option)
        {
            Description = 'The frequency of the replication schedule.';
            OptionMembers = Daily,Weekly;
            DataClassification = SystemMetadata;
        }
        field(7; "Sunday"; Boolean)
        {
            Description = 'Indicates whether replication is scheduled to run on Sundays.';
            DataClassification = SystemMetadata;
        }
        field(8; "Monday"; Boolean)
        {
            Description = 'Indicates whether replication is scheduled to run on Mondays.';
            DataClassification = SystemMetadata;
        }
        field(9; "Tuesday"; Boolean)
        {
            Description = 'Indicates whether replication is scheduled to run on Tuesdays.';
            DataClassification = SystemMetadata;
        }
        field(10; "Wednesday"; Boolean)
        {
            Description = 'Indicates whether replication is scheduled to run on Wednesdays.';
            DataClassification = SystemMetadata;
        }
        field(11; "Thursday"; Boolean)
        {
            Description = 'Indicates whether replication is scheduled to run on Thursdays.';
            DataClassification = SystemMetadata;
        }
        field(12; "Friday"; Boolean)
        {
            Description = 'Indicates whether replication is scheduled to run on Fridays.';
            DataClassification = SystemMetadata;
        }
        field(13; "Saturday"; Boolean)
        {
            Description = 'Indicates whether replication is scheduled to run on Saturdays.';
            DataClassification = SystemMetadata;
        }
        field(14; "Company Creation Task ID"; Guid)
        {
            Description = 'The ID of the job task that was intiated to create companies from the setup wizard.';
            DataClassification = SystemMetadata;
        }
        field(15; "Company Creation Task Status"; Option)
        {
            Description = 'Indicates the status of the Company Creation Task.';
            OptionMembers = InProgress,Failed,Completed;
            OptionCaption = 'In Progress,Failed,Completed';
            DataClassification = SystemMetadata;
        }

        field(16; "Company Creation Task Error"; Text[250])
        {
            Description = 'The error from the Company Creation Task.';
            DataClassification = SystemMetadata;
        }

        field(18; "Replication User"; Code[50])
        {
            Description = 'The user who set up replication.';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }

        field(19; "Deployed Version"; Code[10])
        {
            Description = 'The deployed version of Intelligent Cloud pipeline.';
            DataClassification = SystemMetadata;
        }

        field(20; "Latest Version"; Code[10])
        {
            Description = 'The latest version of Intelligent Cloud pipeline available.';
            DataClassification = SystemMetadata;
        }

        field(21; "Upgrade Tag Backup ID"; Integer)
        {
            Description = 'Upgrade Tag Backup ID';
            DataClassification = SystemMetadata;
        }

        field(22; "Schedule Upgrade"; Boolean)
        {
            Description = 'Schedule Upgrade';
            DataClassification = SystemMetadata;
        }

        field(23; "Company Creation Session ID"; Integer)
        {
            Description = 'The ID of the session that was intiated to create companies from the setup wizard.';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure ConstructDaysToRun(Utc: boolean): Text
    var
        daysToRun: Text;
        dailyBitmap: Text;
    begin
        case Recurrence of
            Recurrence::Daily:
                daysToRun := '';
            Recurrence::Weekly:
                begin
                    dailyBitmap := GetDailyBitmap(Utc);
                    if CopyStr(dailyBitmap, 7, 1) = '1' then
                        daysToRun := daysToRun + 'Sunday,';
                    if CopyStr(dailyBitmap, 1, 1) = '1' then
                        daysToRun := daysToRun + 'Monday,';
                    if CopyStr(dailyBitmap, 2, 1) = '1' then
                        daysToRun := daysToRun + 'Tuesday,';
                    if CopyStr(dailyBitmap, 3, 1) = '1' then
                        daysToRun := daysToRun + 'Wednesday,';
                    if CopyStr(dailyBitmap, 4, 1) = '1' then
                        daysToRun := daysToRun + 'Thursday,';
                    if CopyStr(dailyBitmap, 5, 1) = '1' then
                        daysToRun := daysToRun + 'Friday,';
                    if CopyStr(dailyBitmap, 6, 1) = '1' then
                        daysToRun := daysToRun + 'Saturday';

                    daysToRun := DelChr(daysToRun, '>', ',');
                end;
        end;
        exit(daysToRun);
    end;

    procedure ConvertRecurrenceTypeToText(): Text
    var
        RecurrenceType: Text;
    begin
        case Recurrence of
            Recurrence::Daily:
                RecurrenceType := 'Daily';
            Recurrence::Weekly:
                RecurrenceType := 'Weekly';
        end;

        exit(RecurrenceType);
    end;

    procedure ConvertSqlServerTypeToText(): Text
    var
        SqlType: Text;
    begin
        case "Sql Server Type" of
            "Sql Server Type"::SQLServer:
                SqlType := 'SQLServer';
            "Sql Server Type"::AzureSQL:
                SqlType := 'AzureSQL';
        end;

        exit(SqlType);
    end;

    procedure GetDailyBitmap(Utc: Boolean) Bitmap: Text[7]
    var
        OutlookSynchTypeConv: Codeunit "Outlook Synch. Type Conv";
        TimeToRunUtc: DateTime;
    begin
        case Recurrence of
            Recurrence::Daily:
                Bitmap := '1111111';
            Recurrence::Weekly:
                Bitmap := CopyStr(FORMAT(Monday, 1, '<Number>') + FORMAT(Tuesday, 1, '<Number>') + FORMAT(Wednesday, 1, '<Number>') + FORMAT(Thursday, 1, '<Number>') + FORMAT(Friday, 1, '<Number>') + FORMAT(Saturday, 1, '<Number>') + FORMAT(Sunday, 1, '<Number>'), 1, 7);
        end;

        // If the UTC time is tomorrow, then rotate the bitmap right with carry
        if Utc then begin
            TimeToRunUtc := OutlookSynchTypeConv.LocalDT2UTC(CreateDateTime(Today(), "Time to Run"));
            if (DT2Date(TimeToRunUtc) > Today()) then
                Bitmap := CopyStr(Bitmap, 7, 1) + CopyStr(Bitmap, 1, 6);
        end;
    end;

    /*
     *  Gets the next scheduled time to run the replication after the specified date time.
     */
    procedure GetNextScheduledRunDateTime(AfterDateTime: DateTime) NextScheduledDateTime: DateTime
    var
        DailyBitmap: Text;
        RestOfWeekBitmap: Text;
        TodayWeekDay: Integer;
        DaysUntilRun: Integer;
        TodayHasRun: Boolean;
        TodayHasRunInt: Integer;
    begin
        if "Time to Run" = 0T then
            exit;

        DailyBitmap := GetDailyBitmap(false);
        DailyBitmap += DailyBitmap;
        if StrPos(DailyBitmap, '1') = 0 then
            exit;

        TodayWeekDay := Date2DWY(DT2Date(AfterDateTime), 1);
        TodayHasRun := (DT2Time(AfterDateTime) > "Time to Run");
        Evaluate(TodayHasRunInt, Format(TodayHasRun, 1, '<Number>'));

        RestOfWeekBitmap := CopyStr(DailyBitmap, TodayWeekDay + TodayHasRunInt);
        DaysUntilRun := StrPos(RestOfWeekBitmap, '1');
        if not TodayHasRun then
            DaysUntilRun -= 1;

        NextScheduledDateTime := CreateDateTime(DT2Date(AfterDateTime) + DaysUntilRun, "Time to Run");
    end;

    procedure SetReplicationSchedule()
    var
        HybridDeployment: Codeunit "Hybrid Deployment";
        DaysToRun: Text;
        TimeToRun: Time;
    begin
        TimeToRun := "Time to Run";
        if TimeToRun = 0T then
            // Use 12:00:00 AM as a default time.
            TimeToRun := 000000T;

        DaysToRun := ConstructDaysToRun(true);
        HybridDeployment.Initialize("Product ID");
        HybridDeployment.SetReplicationSchedule(ConvertRecurrenceTypeToText(), DaysToRun, TimeToRun, "Replication Enabled");
    end;

    procedure UpdateAvailable(): Boolean
    begin
        if Get() then
            exit("Deployed Version" <> "Latest Version");

        exit(false);
    end;

    procedure SetDeployedVersion(Version: Text)
    begin
        if Get() then begin
            "Deployed Version" := CopyStr(Version, 1, 10);
            Modify();
        end;
    end;

    procedure SetLatestVersion(Version: Text)
    begin
        if Get() then begin
            "Latest Version" := CopyStr(Version, 1, 10);
            Modify();
        end;
    end;

    procedure UpdateDeployedToLatest()
    begin
        if Get() then begin
            "Deployed Version" := "Latest Version";
            Modify();
        end;
    end;
}