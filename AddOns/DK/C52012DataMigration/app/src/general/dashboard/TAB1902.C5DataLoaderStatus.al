table 1902 "C5 Data Loader Status"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; PK; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; Proccessed; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(3; Total; Integer)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; PK)
        {
            Clustered = true;
        }
    }

    procedure GetSingleInstance()
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert();
        end;
    end;

    procedure Initialize(TotalRecords: Integer)
    begin
        GetSingleInstance();
        Total := TotalRecords;
        Modify();
    end;

    procedure GetProgressPercentage(): Integer
    begin
        GetSingleInstance();
        if Total <> 0 then
            exit(Round(Proccessed / Total * 100, 2));
    end;

    procedure IncrementProccessedRecords(Records: Integer)
    begin
        GetSingleInstance();
        Proccessed += Records;
        Modify();
        // Update Dashboard
        Commit();
    end;
}