codeunit 30005 "APIV2 - Job Queue Management"
{
    procedure CreateAndScheduleBackgroundJob(ObjectIdToRun: Integer; JobQueueEntryCategory: Code[10]; Description: Text[250]): Guid
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueEntryBuffer: Record "Job Queue Entry Buffer";
    begin
        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := ObjectIdToRun;
        JobQueueEntry."Maximum No. of Attempts to Run" := 1;
        JobQueueEntry."Job Queue Category Code" := JobQueueEntryCategory;
        JobQueueEntry.Description := Description;
        Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);

        JobQueueEntryBuffer.Init();
        JobQueueEntryBuffer.TransferFields(JobQueueEntry);
        JobQueueEntryBuffer."Job Queue Entry ID" := JobQueueEntry.SystemId;
        JobQueueEntryBuffer."Start Date/Time" := CurrentDateTime();
        JobQueueEntryBuffer.Insert();

        exit(JobQueueEntryBuffer.SystemId);
    end;

    procedure IsJobScheduled(ObjectIdToRun: Integer; JobQueueEntryCategory: Code[10]; Description: Text[250]): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", ObjectIdToRun);
        JobQueueEntry.SetRange("Job Queue Category Code", JobQueueEntryCategory);
        JobQueueEntry.SetRange(Description, Description);
        if JobQueueEntry.FindFirst() then
            exit(JobQueueEntry.Status in [JobQueueEntry.Status::Ready, JobQueueEntry.Status::"In Process"]);
        exit(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnCleanupAfterJobQueueDeletion(var Rec: Record "Job Queue Entry"; RunTrigger: Boolean)
    var
        JobQueueEntryBuffer: Record "Job Queue Entry Buffer";
    begin
        if Rec.IsTemporary() then
            exit;

        if JobQueueEntryBuffer.Get(Rec.SystemId) then
            if Rec.Status = Rec.Status::Error then
                JobQueueEntryBuffer.Delete();
    end;
}