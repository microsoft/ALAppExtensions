page 30068 "APIV2 - Aut. Scheduled Jobs"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'Scheduled Job';
    EntitySetCaption = 'Scheduled Jobs';
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    EntityName = 'scheduledJob';
    EntitySetName = 'scheduledJobs';
    PageType = API;
    SourceTable = "Job Queue Entry Buffer";
    Extensible = false;
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; SystemId)
                {
                    Caption = 'Id';
                }
                field(category; "Job Queue Category Code")
                {
                    Caption = 'Category';
                }
                field(startDateTime; "Start Date/Time")
                {
                    Caption = 'Start Date/Time';
                }
                field(status; Status)
                {
                    Caption = 'Status';
                }
                field(description; Description)
                {
                    Caption = 'Description';
                }
                field(errorMessage; ErrorMessage)
                {
                    Caption = 'Error Message';
                }
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        JobQueueCategoryCodeFilter: Text;
        SystemIdFilter: Text;
    begin
        JobQueueCategoryCodeFilter := GetFilter("Job Queue Category Code");
        SystemIdFilter := GetFilter(SystemId);
        if (JobQueueCategoryCodeFilter = '') and (SystemIdFilter = '') then
            Error(FiltersNotSpecifiedErr);

        exit(Rec.Find(Which));
    end;

    trigger OnAfterGetRecord()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        Clear(Status);
        Clear(ErrorMessage);
        if JobQueueEntry.GetBySystemId(Rec."Job Queue Entry ID") then begin
            Status := Format(JobQueueEntry.Status);
            if JobQueueEntry.Status = JobQueueEntry.Status::Error then
                ErrorMessage := JobQueueEntry."Error Message";
        end else
            Status := Format(JobQueueEntry.Status::Finished);
    end;

    var
        FiltersNotSpecifiedErr: Label 'You must specify a job Id or a job category to get a scheduled job.';
        Status: Text;
        ErrorMessage: Text;
}