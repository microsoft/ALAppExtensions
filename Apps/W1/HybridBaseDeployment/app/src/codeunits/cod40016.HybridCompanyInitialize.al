codeunit 40016 "Hybrid Company Initialize"
{
    TableNo = "Hybrid Company";

    trigger OnRun()
    begin
        Codeunit.Run(Codeunit::"Company-Initialize");
        Rec.Validate("Company Initialization Status", Rec."Company Initialization Status"::Initialized);
        Clear(Rec."Company Initialization Task");
        Rec.Modify();
    end;

    procedure MarkCompanyAsInitialized(var HybridCompany: Record "Hybrid Company")
    begin
        CheckTaskActive(HybridCompany);
        HybridCompany.Validate("Company Initialization Status", HybridCompany."Company Initialization Status"::Initialized);
        HybridCompany.Modify();
    end;

    procedure MarkCompanyAsNotInitialized(var HybridCompany: Record "Hybrid Company")
    begin
        CheckTaskActive(HybridCompany);
        HybridCompany.Validate("Company Initialization Status", HybridCompany."Company Initialization Status"::"Not Initialized");
        HybridCompany.Modify();
    end;

    procedure InitalizeCompany(var HybridCompany: Record "Hybrid Company")
    begin
        CheckTaskActive(HybridCompany);
        if TaskScheduler.CanCreateTask() then begin
            HybridCompany."Company Initialization Task" := TaskScheduler.CreateTask(Codeunit::"Hybrid Company Initialize", Codeunit::"Handle Create Company Failure", true, HybridCompany.Name, 0DT, HybridCompany.RecordId);
            HybridCompany.Modify();
        end else
            Codeunit.Run(Codeunit::"Hybrid Company Initialize", HybridCompany);
    end;

    procedure OpenManageCompaniesPage(NonInitializedCompaniesNotification: Notification)
    begin
        Page.Run(Page::"Hybrid Companies List");
    end;

    procedure GetUnintializedCompaniesNotificationID(): Guid
    begin
        exit('14d41abc-cc55-4954-a641-94cbc5251ab8');
    end;

    procedure GetNonInitialziedCompaniesWithMigrationCompleted(var NonInitializedCompanies: List of [Text[50]])
    var
        HybridCompany: Record "Hybrid Company";
    begin
        Clear(NonInitializedCompanies);
#pragma warning disable AA0210        
        HybridCompany.SetFilter("Company Initialization Status", '<>%1', HybridCompany."Company Initialization Status"::Initialized);
        HybridCompany.SetRange(Replicate, true);
#pragma warning restore
        if HybridCompany.IsEmpty() then
            exit;

        HybridCompany.FindSet();
        repeat
            if CheckCompanyMigrated(HybridCompany) then
                NonInitializedCompanies.Add(HybridCompany.Name);
        until HybridCompany.Next() = 0;
    end;

    local procedure CheckCompanyMigrated(HybridCompany: Record "Hybrid Company"): Boolean
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
    begin
        HybridReplicationDetail.SetRange("Company Name", HybridCompany.Name);
        HybridReplicationDetail.SetFilter(Status, '=%1|%2', HybridReplicationDetail.Status::Successful, HybridReplicationDetail.Status::Warning);

        if not HybridReplicationDetail.FindFirst() then
            exit(false);

        if not HybridReplicationSummary.Get(HybridReplicationDetail."Run ID") then
            exit(false);

        if not (HybridReplicationSummary.ReplicationType in [HybridReplicationSummary.ReplicationType::Full, HybridReplicationSummary.ReplicationType::Normal]) then
            exit(false);

        exit(HybridReplicationSummary.Status = HybridReplicationSummary.Status::Completed);
    end;

    local procedure CheckTaskActive(HybridCompany: Record "Hybrid Company")
    begin
        if IsNullGuid(HybridCompany."Company Initialization Task") then
            exit;

        if not TaskScheduler.TaskExists(HybridCompany."Company Initialization Task") then
            exit;

        Error(InitalizationTaskAlreadyExistsErr);
    end;

    var
        InitalizationTaskAlreadyExistsErr: Label 'The company is being initialized. You must wait for this task to finish before you can make any modifications.';
}