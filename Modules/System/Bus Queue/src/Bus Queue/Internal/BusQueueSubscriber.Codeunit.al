codeunit 51762 "Bus Queue Subscriber"
{
    Access = Internal;
    SingleInstance = true;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Job Queue Entry" = RIMD,
                  tabledata "Job Queue Log Entry" = RIMD,
                  tabledata "Error Message" = RIMD,
                  tabledata "Error Message Register" = RIMD;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", OnAfterLogin, '', false, false)]
    local procedure CreateBusQueuesHandlerJobQueueEntryAfterCompanyOpen()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if (not (Session.CurrentClientType() in [ClientType::Web, ClientType::Desktop, ClientType::Tablet, ClientType::Phone])) or (not TaskScheduler.CanCreateTask()) then
            exit;

        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Bus Queues Handler");
        if JobQueueEntry.FindFirst() then begin
            if JobQueueEntry.Status = JobQueueEntry.Status::Error then
                JobQueueEntry.Restart();

            exit;
        end;

        JobQueueEntry.InitRecurringJob(1);
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"Bus Queues Handler";
        JobQueueEntry."Earliest Start Date/Time" := CurrentDateTime();
        JobQueueEntry."Job Queue Category Code" := 'BQH';

        Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);
    end;
}