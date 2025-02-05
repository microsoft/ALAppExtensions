codeunit 5279 "Generate Contoso Demo Data"
{
    TableNo = "Contoso Demo Data Module";
    Access = Internal;
    trigger OnRun()
    var
        JobQueueEntry: Record "Job Queue Entry";
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
        JobQueueLogEntry: Record "Job Queue Log Entry";
    begin
        // give time to update AssistedCompanySetupStatus with "Session ID" and "Task ID"
        Sleep(500);

        if not CODEUNIT.Run(CODEUNIT::"Company Creation Contoso", Rec) then begin
            AssistedCompanySetupStatus.Get(CompanyName);
            JobQueueEntry.Init();
            JobQueueEntry.ID := AssistedCompanySetupStatus."Task ID";
            JobQueueEntry."User ID" := CopyStr(UserId(), 1, MaxStrLen(JobQueueEntry."User ID"));
            JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
            JobQueueEntry."Object ID to Run" := CODEUNIT::"Company Creation Contoso";
            JobQueueEntry.Status := JobQueueEntry.Status::Error;
            JobQueueEntry."Error Message" := CopyStr(GetLastErrorText, 1, MaxStrLen(JobQueueEntry."Error Message"));
            JobQueueEntry.Description := DescriptionTxt;
            JobQueueEntry.InsertLogEntry(JobQueueLogEntry);
            JobQueueEntry.FinalizeLogEntry(JobQueueLogEntry);
            Commit();
            Error(GetLastErrorText);
        end;
    end;

    var
        DescriptionTxt: Label 'Could not complete the company setup.';
}