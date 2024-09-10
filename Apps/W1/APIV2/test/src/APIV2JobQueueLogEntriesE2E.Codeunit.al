codeunit 139861 "APIV2JobQueueLogEntriesE2E"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [JobQueue] [JobQueueLogEntry]
    end;

    var
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        Assert: Codeunit "Assert";
        ServiceNameTxt: Label 'jobQueueLogEntries';

    [Test]
    procedure TestGetJobQueueLogEntry()
    var
        JobQueueLogEntry: Record "Job Queue Log Entry";
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Use a GET method to retrieve Job Queue Log Entries
        // [GIVEN] A new Job Queue Log Entry created 
        JobQueueLogEntry.DeleteAll();
        JobQueueLogEntry := CreateJobQueueLogEntry(CreateGuid(), 'Test Job Queue Log Entry', JobQueueLogEntry.Status::Success);
        Commit();

        // [WHEN] We GET all the JobQueueLogEntries from the web service
        ClearLastError();
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Job Queue Log Entries", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        if GetLastErrorText() <> '' then
            Assert.ExpectedError('Request failed with error: ' + GetLastErrorText());

        // [THEN] the job queue log entries should exist in the response
        GetAndVerifyJobQueueLogEntryFromJSON(ResponseText, JobQueueLogEntry.ID, 'Test Job Queue Log Entry', 'Success');
    end;

    local procedure GetAndVerifyJobQueueLogEntryFromJSON(ResponseText: Text; JobQueueEntryID: Guid; Description: Text; Status: Text)
    var
        JobQueueLogEntryJSON: Text;
    begin
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectFromJSONResponse(ResponseText, JobQueueLogEntryJSON, 1),
          'Could not find the job queue log entry in JSON');
        LibraryGraphMgt.VerifyIDInJson(JobQueueLogEntryJSON);
        LibraryGraphMgt.VerifyPropertyInJSON(JobQueueLogEntryJSON, 'description', Description);
        LibraryGraphMgt.VerifyPropertyInJSON(JobQueueLogEntryJSON, 'jobQueueEntryId', DELCHR(LowerCase(JobQueueEntryID), '=', '{}'));
        LibraryGraphMgt.VerifyPropertyInJSON(JobQueueLogEntryJSON, 'status', Status);
    end;

    local procedure CreateJobQueueLogEntry(JobQueueEntryID: Guid; Description: Text; Status: Option): Record "Job Queue Log Entry"
    var
        JobQueueLogEntry: Record "Job Queue Log Entry";
    begin
        JobQueueLogEntry.Init();
        JobQueueLogEntry.Validate(ID, JobQueueEntryID);
        JobQueueLogEntry.Validate(Description, Description);
        JobQueueLogEntry.Validate(Status, Status);
        JobQueueLogEntry.Insert();
        exit(JobQueueLogEntry);
    end;
}
