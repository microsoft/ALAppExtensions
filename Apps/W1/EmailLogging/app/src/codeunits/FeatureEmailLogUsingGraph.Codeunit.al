codeunit 1680 "Feature Email Log. Using Graph" implements "Feature Data Update"
{
    procedure IsDataUpdateRequired(): Boolean;
    begin
        CountRecords();
        exit(not TempDocumentEntry.IsEmpty());
    end;

    procedure ReviewData();
    var
        DataUpgradeOverview: Page "Data Upgrade Overview";
    begin
        Commit();
        Clear(DataUpgradeOverview);
        DataUpgradeOverview.Set(TempDocumentEntry);
        DataUpgradeOverview.RunModal();
    end;

    procedure AfterUpdate(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    begin
    end;

    procedure UpdateData(FeatureDataUpdateStatus: Record "Feature Data Update Status");
    var
        TempMarketingSetup: Record "Marketing Setup" temporary;
        StartDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime;
        DisableEmailLoggingUsingEWS();
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, TempMarketingSetup.TableCaption(), StartDateTime);
    end;

    procedure GetTaskDescription() TaskDescription: Text;
    begin
        TaskDescription := DescriptionTxt;
    end;

    var
        TempDocumentEntry: Record "Document Entry" temporary;
        FeatureDataUpdateMgt: Codeunit "Feature Data Update Mgt.";
        LastEntryNo: Integer;
        DescriptionTxt: Label 'Email logging done through public folders in Exchange Online will be disabled and the corresponding job queue entry will be deleted. Administrators can then set up email logging to use a shared mailbox in Exchange.';

    local procedure CountRecords()
    var
        MarketingSetup: Record "Marketing Setup";
        JobQueueEntry: Record "Job Queue Entry";
        JobCount: Integer;
    begin
        TempDocumentEntry.Reset();
        TempDocumentEntry.DeleteAll();

        if MarketingSetup.Get() then
            if MarketingSetup."Email Logging Enabled" then
                InsertDocumentEntry(Database::"Marketing Setup", MarketingSetup.TableCaption(), 1);

        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Email Logging Context Adapter");
        JobCount := JobQueueEntry.Count();
        if JobCount > 0 then
            InsertDocumentEntry(Database::"Marketing Setup", MarketingSetup.TableCaption(), JobCount);
    end;

    local procedure DisableEmailLoggingUsingEWS()
    var
        MarketingSetup: Record "Marketing Setup";
        JobQueueEntry: Record "Job Queue Entry";
        EmailLoggingManagement: Codeunit "Email Logging Management";
    begin
        if MarketingSetup.Get() then
            if MarketingSetup."Email Logging Enabled" then
                MarketingSetup.Validate("Email Logging Enabled", false);

        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Email Logging Context Adapter");
        JobQueueEntry.DeleteTasks();

        EmailLoggingManagement.RegisterAssistedSetup();
    end;

    local procedure InsertDocumentEntry(TableID: Integer; TableName: Text; RecordCount: Integer)
    begin
        if RecordCount = 0 then
            exit;

        LastEntryNo += 1;
        TempDocumentEntry.Init();
        TempDocumentEntry."Entry No." := LastEntryNo;
        TempDocumentEntry."Table ID" := TableID;
        TempDocumentEntry."Table Name" := CopyStr(TableName, 1, MaxStrLen(TempDocumentEntry."Table Name"));
        TempDocumentEntry."No. of Records" := RecordCount;
        TempDocumentEntry.Insert();
    end;
}