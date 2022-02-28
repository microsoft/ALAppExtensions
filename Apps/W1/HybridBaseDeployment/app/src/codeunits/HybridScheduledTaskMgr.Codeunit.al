codeunit 40028 "Hybrid Scheduled Task Mgr"
{
    TableNo = "Job Queue Entry";
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue Error Handler", 'OnAfterLogError', '', false, false)]
    local procedure HandleErrors(var JobQueueEntry: Record "Job Queue Entry")
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        HandleCreateCompanyFailure: Codeunit "Handle Create Company Failure";
    begin
        if not HybridCloudManagement.IsIntelligentCloudEnabled() then
            exit;

        if not (JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) then
            exit;

        case JobQueueEntry."Object ID to Run" of
            Codeunit::"Create Companies IC":
                HandleCreateCompanyFailure.UpdateIntelligentCloudSetup(JobQueueEntry."Error Message");
        end;
    end;

    procedure RunSynchroniously(var JobQueueEntry: Record "Job Queue Entry"; CompanyToRun: Text)
    var
        SessionID: Integer;
    begin
        Session.StartSession(SessionID, Codeunit::"Hybrid Scheduled Task Mgr", CompanyToRun, JobQueueEntry)
    end;

    procedure CreateAndScheduleBackgroundJob(ObjectIdToRun: Integer; Description: Text[250]): Guid
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueEntryBuffer: Record "Job Queue Entry Buffer";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := ObjectIdToRun;
        JobQueueEntry."Maximum No. of Attempts to Run" := 1;
        JobQueueEntry."Job Queue Category Code" := HybridCloudManagement.GetJobQueueCategory();
        JobQueueEntry.Description := Description;
        Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);

        JobQueueEntryBuffer.Init();
        JobQueueEntryBuffer.TransferFields(JobQueueEntry);
        JobQueueEntryBuffer."Job Queue Entry ID" := JobQueueEntry.SystemId;
        JobQueueEntryBuffer."Start Date/Time" := CurrentDateTime();
        JobQueueEntryBuffer.Insert();

        exit(JobQueueEntryBuffer.SystemId);
    end;
}