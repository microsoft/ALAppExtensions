codeunit 30202 "Shpfy Initial Import"
{
    Access = Internal;

    procedure Generate(ShopCode: Code[20])
    var
        EntityReportDict: Dictionary of [Code[20], Integer];
        EntityDependencyFilterDict: Dictionary of [Code[20], Text];
        EntityPageDict: Dictionary of [Code[20], Integer];
        EntityName: Code[20];
    begin
        GetEntityReportDict(EntityReportDict);
        GetEntityDependencyFilterDict(EntityDependencyFilterDict);
        GetEntityPageDict(EntityPageDict);

        foreach EntityName in EntityReportDict.Keys do
            InsertLine(ShopCode, EntityName, EntityDependencyFilterDict.Get(EntityName), EntityPageDict.Get(EntityName), false);
    end;

    procedure GenerateSelected(ShopCode: Code[20]; SyncProducts: Boolean; SyncCustomers: Boolean; SyncItemImages: Boolean; DemoImport: Boolean)
    var
        EntityDependencyFilterDict: Dictionary of [Code[20], Text];
        EntityPageDict: Dictionary of [Code[20], Integer];
    begin
        GetEntityDependencyFilterDict(EntityDependencyFilterDict);
        GetEntityPageDict(EntityPageDict);

        if SyncProducts then
            InsertLine(ShopCode, 'ITEM', EntityDependencyFilterDict.Get('ITEM'), EntityPageDict.Get('ITEM'), DemoImport);
        if SyncCustomers then
            InsertLine(ShopCode, 'CUSTOMER', EntityDependencyFilterDict.Get('CUSTOMER'), EntityPageDict.Get('CUSTOMER'), false);
        if SyncItemImages then
            InsertLine(ShopCode, 'ITEM IMAGE', EntityDependencyFilterDict.Get('ITEM IMAGE'), EntityPageDict.Get('ITEM IMAGE'), false);
    end;

    local procedure InsertLine(ShopCode: Code[20]; EntityName: Code[20]; DependencyFilter: Text; PageNumber: Integer; DemoImport: Boolean)
    var
        ShpfyInitialImportLine: Record "Shpfy Initial Import Line";
    begin
        ShpfyInitialImportLine.Init();
        ShpfyInitialImportLine.Name := EntityName;
        if not ShpfyInitialImportLine.Find('=') then begin
            ShpfyInitialImportLine.Validate("Dependency Filter", DependencyFilter);
            ShpfyInitialImportLine.Validate("Shop Code", ShopCode);
            ShpfyInitialImportLine.Validate("Page ID", PageNumber);
            ShpfyInitialImportLine.Validate("Demo Import", DemoImport);
            ShpfyInitialImportLine.Insert(true);
        end else
            if ShpfyInitialImportLine."Job Queue Entry Status" = ShpfyInitialImportLine."Job Queue Entry Status"::" " then begin
                ShpfyInitialImportLine.Validate("Dependency Filter", DependencyFilter);
                ShpfyInitialImportLine.Validate("Shop Code", ShopCode);
                ShpfyInitialImportLine.Validate("Page ID", PageNumber);
                ShpfyInitialImportLine.Validate("Demo Import", DemoImport);
                ShpfyInitialImportLine.Modify(true);
            end;
    end;

    local procedure GetEntityReportDict(var EntityReportDict: Dictionary of [Code[20], Integer])
    begin
        EntityReportDict.Add('ITEM', Report::"Shpfy Sync Products");
        EntityReportDict.Add('CUSTOMER', Report::"Shpfy Sync Customers");
        EntityReportDict.Add('ITEM IMAGE', Report::"Shpfy Sync Images");
    end;

    local procedure GetEntityPageDict(var EntityPageDict: Dictionary of [Code[20], Integer])
    begin
        EntityPageDict.Add('ITEM', Page::"Item List");
        EntityPageDict.Add('CUSTOMER', Page::"Customer List");
        EntityPageDict.Add('ITEM IMAGE', Page::"Item List");
    end;

    local procedure GetEntityDependencyFilterDict(var EntityDependencyFilterDict: Dictionary of [Code[20], Text])
    begin
        EntityDependencyFilterDict.Add('ITEM', '');
        EntityDependencyFilterDict.Add('CUSTOMER', '');
        EntityDependencyFilterDict.Add('ITEM IMAGE', 'ITEM');
    end;

    procedure IsActiveSession(SessionId: Integer): Boolean
    begin
        exit(IsSessionActive(SessionId));
    end;

    procedure ShowJobQueueLogEntry(JobQueueEntryId: Guid)
    var
        JobQueueLogEntry: Record "Job Queue Log Entry";
    begin
        JobQueueLogEntry.SetRange(ID, JobQueueEntryId);
        Page.RunModal(Page::"Job Queue Log Entries", JobQueueLogEntry);
    end;

    procedure GetStatusStyleExpression(StatusText: Text): Text
    begin
        case StatusText of
            'Error':
                exit('Unfavorable');
            'Finished', 'Success':
                exit('Favorable');
            'In Process':
                exit('Ambiguous');
            else
                exit('Subordinate');
        end;
    end;

    procedure Start()
    var
        ShpfyInitialImportLine: Record "Shpfy Initial Import Line";
        TempShpfyInitialImportLine: Record "Shpfy Initial Import Line" temporary;
        JobQueueEntryID: Guid;
    begin
        if FindLinesThatCanBeStarted(TempShpfyInitialImportLine) then
            repeat
                    JobQueueEntryID := EnqueueSyncJob(TempShpfyInitialImportLine.Name, TempShpfyInitialImportLine."Shop Code", TempShpfyInitialImportLine."Demo Import");
                ShpfyInitialImportLine.Get(TempShpfyInitialImportLine.Name);
                ShpfyInitialImportLine.Validate("Job Queue Entry ID", JobQueueEntryID);
                ShpfyInitialImportLine.Modify(true);
                Commit();
            until TempShpfyInitialImportLine.Next() = 0;
    end;

    local procedure EnqueueSyncJob(Name: Code[20]; ShopCode: Code[20]; DemoImport: Boolean): Guid
    var
        ShpfyBackgroundSyncs: Codeunit "Shpfy Background Syncs";
    begin
        case Name of
            'ITEM':
                if DemoImport then
                    exit(ShpfyBackgroundSyncs.ProductsBackgroundSync(ShopCode, GetDemoCompanyInitialImportNumber()))
                else
                    exit(ShpfyBackgroundSyncs.ProductsBackgroundSync(ShopCode, -1));
            'CUSTOMER':
                exit(ShpfyBackgroundSyncs.CustomerBackgroundSync(ShopCode));
            'ITEM IMAGE':
                exit(ShpfyBackgroundSyncs.ProductImagesBackgroundSync(ShopCode));
        end;
    end;

    local procedure FindLinesThatCanBeStarted(var TempShpfyInitialImportLine: Record "Shpfy Initial Import Line" temporary): Boolean
    var
        ShpfyInitialImportLine: Record "Shpfy Initial Import Line";
    begin
        TempShpfyInitialImportLine.Reset();
        TempShpfyInitialImportLine.DeleteAll();

        ShpfyInitialImportLine.SetRange("Job Queue Entry Status", ShpfyInitialImportLine."Job Queue Entry Status"::" ");
        if ShpfyInitialImportLine.FindSet() then
            repeat
                if AreAllParentalJobsFinished(ShpfyInitialImportLine."Dependency Filter") then begin
                    TempShpfyInitialImportLine := ShpfyInitialImportLine;
                    TempShpfyInitialImportLine.Insert();
                end;
            until ShpfyInitialImportLine.Next() = 0;
        exit(TempShpfyInitialImportLine.FindSet());
    end;

    local procedure AreAllParentalJobsFinished(DependencyFilter: Text[250]): Boolean
    var
        ShpfyInitialImportLine: Record "Shpfy Initial Import Line";
    begin
        if DependencyFilter <> '' then begin
            ShpfyInitialImportLine.SetFilter(Name, DependencyFilter);
            ShpfyInitialImportLine.SetFilter(
              "Job Queue Entry Status", '<>%1', ShpfyInitialImportLine."Job Queue Entry Status"::Finished);
            exit(ShpfyInitialImportLine.IsEmpty());
        end;
        exit(true);
    end;

    procedure OnBeforeModifyJobQueueEntry(JobQueueEntry: Record "Job Queue Entry")
    var
        ShpfyInitialImportLine: Record "Shpfy Initial Import Line";
        EntityName: Code[20];
    begin
        EntityName := GetEntityNameFromJobQueueEntry(JobQueueEntry);
        if EntityName = '' then
            exit;

        if ShpfyInitialImportLine.Get(EntityName) then
            if ShpfyInitialImportLine."Job Queue Entry ID" = JobQueueEntry.ID then begin
                ShpfyInitialImportLine.SetJobQueueEntryStatus(JobQueueEntry.Status);
                ShpfyInitialImportLine.Modify();

                if IsJobQueueEntryProcessed(JobQueueEntry) then
                    Start();
            end;
    end;

    local procedure GetEntityNameFromJobQueueEntry(JobQueueEntry: Record "Job Queue Entry"): Code[20]
    var
        EntityReportDict: Dictionary of [Code[20], Integer];
        DictIndex: Integer;
    begin
        if JobQueueEntry."Object Type to Run" <> JobQueueEntry."Object Type to Run"::Report then
            exit;

        GetEntityReportDict(EntityReportDict);
        DictIndex := EntityReportDict.Values().IndexOf(JobQueueEntry."Object ID to Run");
        if DictIndex <> 0 then
            exit(EntityReportDict.Keys().Get(DictIndex));
    end;

    local procedure IsJobQueueEntryProcessed(JobQueueEntry: Record "Job Queue Entry"): Boolean
    var
        xJobQueueEntry: Record "Job Queue Entry";
    begin
        xJobQueueEntry := JobQueueEntry;
        xJobQueueEntry.Find();
        exit((xJobQueueEntry.Status = xJobQueueEntry.Status::"In Process") and (xJobQueueEntry.Status <> JobQueueEntry.Status));
    end;

    procedure InitialImportCompleted(): Boolean
    var
        ShpfyInitialImportLine: Record "Shpfy Initial Import Line";
    begin
        ShpfyInitialImportLine.SetFilter("Job Status", '%1|%2', ShpfyInitialImportLine."Job Status"::" ", ShpfyInitialImportLine."Job Status"::"In Process");
        exit(ShpfyInitialImportLine.IsEmpty());
    end;

    local procedure GetDemoCompanyInitialImportNumber(): Integer
    begin
        exit(25)
    end;
}