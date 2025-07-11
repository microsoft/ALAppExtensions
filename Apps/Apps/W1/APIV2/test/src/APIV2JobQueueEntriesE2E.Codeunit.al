codeunit 139862 "APIV2JobQueueEntriesE2E"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [JobQueue] [JobQueueEntry]
        // This API only supports GET request and it is not editable.
        // User can only view the Job Queue Entries or use the action to restart the Job Queue Entry.
    end;

    var
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        Assert: Codeunit "Assert";
        ServiceNameTxt: Label 'jobQueueEntries';
        JobQueueEntryDescriptionLbl: Label 'JobQueueEntry Description for test Job Queue Entry API';
        JobQueueLogEntryDescriptionLbl: Label 'JobQueueLogEntry Description for test Job Queue Entry API';

    [Test]
    procedure TestGetJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Create 1 JobQueueEntry and use a GET method to retrieve it·
        // [GIVEN] Clean Job Queue Entries and create a new JobQueueEntry
        JobQueueEntry.DeleteAll();
        JobQueueEntry := CreateJobQueueEntry(JobQueueEntryDescriptionLbl, JobQueueEntry.Status::Error);
        Commit();

        // [WHEN] We GET the JobQueueEntry from the web service
        ClearLastError();
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Job Queue Entries", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The JobQueueEntry should exist in the response
        if GetLastErrorText() <> '' then
            Assert.ExpectedError('Request failed with error: ' + GetLastErrorText());

        GetAndVerifyJobQueueEntryFromJSON(ResponseText, JobQueueEntry.ID, JobQueueEntryDescriptionLbl, Format(JobQueueEntry.Status::Error));
    end;

    [Test]
    procedure TestGetCorrespondingJobQueueLogEntryFromSubPage()
    var
        JobQueueEntry: Record "Job Queue Entry";
        TargetURL: Text;
        ResponseText: Text;
        JobQueueEntryJSON: Text;
    begin
        // [SCENARIO] Create 1 JobQueueEntry and use a GET method to retrieve it.
        // [GIVEN] Clean Job Queue Entries and create a new JobQueueEntry and one corresponding JobQueueLogEntry
        JobQueueEntry.DeleteAll();

        JobQueueEntry := CreateJobQueueEntry(JobQueueEntryDescriptionLbl, JobQueueEntry.Status::Error);
        CreateJobQueueLogEntry(JobQueueEntry.ID, JobQueueLogEntryDescriptionLbl, JobQueueEntry.Status::Error);
        Commit();

        // [WHEN] We GET the JobQueueLogEntry from the web service
        ClearLastError();
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(JobQueueEntry.SystemId, Page::"APIV2 - Job Queue Entries", ServiceNameTxt, 'jobQueueLogEntries');
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the response should job queue log entry
        Assert.IsTrue(LibraryGraphMgt.GetObjectFromJSONResponseByName(ResponseText, 'value', JobQueueEntryJSON, 1), 'Could not find the job queue log entry in JSON');
        LibraryGraphMgt.VerifyIDInJson(JobQueueEntryJSON);
        LibraryGraphMgt.VerifyPropertyInJSON(JobQueueEntryJSON, 'description', JobQueueLogEntryDescriptionLbl);
        LibraryGraphMgt.VerifyPropertyInJSON(JobQueueEntryJSON, 'jobQueueEntryId', DELCHR(LowerCase(JobQueueEntry.ID), '=', '{}'));
    end;

    [Test]
    procedure TestGetCorrespondingJobQueueLogEntryFromExpand()
    var
        JobQueueEntry: Record "Job Queue Entry";
        TargetURL: Text;
        ResponseText: Text;
        JobQueueLogEntryJSON: Text;
    begin
        // [SCENARIO] Create 1 JobQueueEntry with 2 corresponding JobQueueLogEntries and use a GET method to retrieve it.
        // [GIVEN] Clean Job Queue Entries and create a new JobQueueEntry and 3 corresponding JobQueueLogEntries
        JobQueueEntry.DeleteAll();
        JobQueueEntry := CreateJobQueueEntry(JobQueueEntryDescriptionLbl, JobQueueEntry.Status::Error);
        CreateJobQueueLogEntry(JobQueueEntry.ID, JobQueueLogEntryDescriptionLbl, JobQueueEntry.Status::Error);
        CreateJobQueueLogEntry(JobQueueEntry.ID, JobQueueLogEntryDescriptionLbl, JobQueueEntry.Status::Error);
        CreateJobQueueLogEntry(JobQueueEntry.ID, JobQueueLogEntryDescriptionLbl, JobQueueEntry.Status::Error);
        Commit();

        // [WHEN] We GET the JobQueueLogEntry from the web service
        ClearLastError();
        TargetURL := GetHeadersURLWithExpandedLines(JobQueueEntry.SystemId, Page::"APIV2 - Job Queue Entries", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the response should contain job queue log entry
        LibraryGraphMgt.GetPropertyValueFromJSON(ResponseText, 'jobQueueLogEntries', JobQueueLogEntryJSON);
        VerifyJobQueueLogEntries(JobQueueLogEntryJSON, JobQueueEntry.ID, 3);
    end;

    [Test]
    procedure TestRescheduleJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Create 1 JobQueueEntry with status error. Use an action to reschedule the JobQueueEntry
        // [GIVEN] Clean Job Queue Entries and create a new JobQueueEntry with status error
        JobQueueEntry.DeleteAll();
        JobQueueEntry := CreateJobQueueEntry(JobQueueEntryDescriptionLbl, JobQueueEntry.Status::Error);
        Commit();

        // [WHEN] We trigger the JobQueueEntry reschedule action from the web service
        ClearLastError();
        TargetURL := LibraryGraphMgt.CreateTargetURL(JobQueueEntry.SystemId, Page::"APIV2 - Job Queue Entries", ServiceNameTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL + '/Microsoft.NAV.restart', '', ResponseText, 204);

        // [WHEN] We GET the JobQueueEntry from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Job Queue Entries", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The JobQueueEntry should exist in the response with status ready
        if GetLastErrorText() <> '' then
            Assert.ExpectedError('Request failed with error: ' + GetLastErrorText());

        GetAndVerifyJobQueueEntryFromJSON(ResponseText, JobQueueEntry.ID, JobQueueEntryDescriptionLbl, Format(JobQueueEntry.Status::Ready));
    end;

    local procedure CreateJobQueueEntry(Description: Text; Status: Option): Record "Job Queue Entry"
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.Init();
        JobQueueEntry.Validate(ID, CreateGuid());
        JobQueueEntry.Validate(Description, Description);
        JobQueueEntry.Validate(Status, Status);
        JobQueueEntry.Insert();
        exit(JobQueueEntry);
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

    local procedure GetHeadersURLWithExpandedLines(DocumentId: Text; PageNumber: Integer; ServiceName: Text): Text
    var
        TargetURL: Text;
        URLFilter: Text;
    begin
        TargetURL := LibraryGraphMgt.CreateTargetURL(DocumentId, PageNumber, ServiceName);
        URLFilter := '$expand=jobQueueLogEntries';

        if StrPos(TargetURL, '?') <> 0 then
            TargetURL := TargetURL + '&' + UrlFilter
        else
            TargetURL := TargetURL + '?' + UrlFilter;

        exit(TargetURL);
    end;

    local procedure GetAndVerifyJobQueueEntryFromJSON(ResponseText: Text; JobQueueEntryID: Guid; Description: Text; Status: Text)
    var
        JobQueueEntryJSON: Text;
    begin
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectFromJSONResponseByName(ResponseText, 'value', JobQueueEntryJSON, 1),
          'Could not find the job queue log entry in JSON');
        LibraryGraphMgt.VerifyIDInJson(JobQueueEntryJSON);
        LibraryGraphMgt.VerifyPropertyInJSON(JobQueueEntryJSON, 'description', Description);
        LibraryGraphMgt.VerifyPropertyInJSON(JobQueueEntryJSON, 'jobQueueEntryId', DELCHR(LowerCase(JobQueueEntryID), '=', '{}'));
        LibraryGraphMgt.VerifyPropertyInJSON(JobQueueEntryJSON, 'status', Status);
    end;

    local procedure VerifyJobQueueLogEntries(JobQueueLogEntryJSON: Text; IdTxt: Text; Count: Integer)
    var
        Index: Integer;
        JobQueueLogEntryTxt: Text;
        DocumentIdValue: Text;
        DescriptionTxt: Text;
    begin
        Index := 0;
        repeat
            JobQueueLogEntryTxt := LibraryGraphMgt.GetObjectFromCollectionByIndex(JobQueueLogEntryJSON, Index);
            LibraryGraphMgt.GetPropertyValueFromJSON(JobQueueLogEntryTxt, 'jobQueueEntryId', DocumentIdValue);
            LibraryGraphMgt.GetPropertyValueFromJSON(JobQueueLogEntryTxt, 'description', DescriptionTxt);
            LibraryGraphMgt.VerifyIDFieldInJson(JobQueueLogEntryTxt, 'jobQueueEntryId');
            DocumentIdValue := '{' + DocumentIdValue + '}';
            Assert.AreEqual(DocumentIdValue, IdTxt.ToLower(), 'The parent ID value is wrong.');
            Assert.AreEqual(JobQueueLogEntryDescriptionLbl, DescriptionTxt, 'The description value is wrong.');
            Index := Index + 1;
        until (Index = LibraryGraphMgt.GetCollectionCountFromJSON(JobQueueLogEntryJSON));
        Assert.AreEqual(Count, Index, 'The number of Job Queue Log Entries is wrong.');
    end;
}