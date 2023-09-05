codeunit 51750 "Bus Queue E2E"
{
    Access = Public;
    Subtype = Test;

    var
        JobQueueEntry: Record "Job Queue Entry";
        LibraryAssert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        BusQueue: Codeunit "Bus Queue";
        NonExistingUrlTxt: Label 'https://www.e89b2cb3d714451c94f03b617b5fd6824109b0cfef864576a3b5e7febadfe39b.com', Locked = true;
        MicrosoftUrlTxt: Label 'https://www.microsoft.com', Locked = true;

    [Test]
    procedure TestExistingURLIsProcessed()
    var
        BusQueueRec: Record "Bus Queue";
        BusQueueEntryNo: Integer;
    begin
        // [SCENARIO] Enqueues a bus queue with an existing URL and status must be Processed

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Bus Queue Exec');
        
        // [GIVEN] One bus queue
        BusQueue.Init(MicrosoftUrlTxt, Enum::"Http Request Type"::GET);
        BusQueue.SetRaiseOnAfterInsertBusQueueResponse(false);
        BusQueueEntryNo := Initialize();

        // [WHEN] Status is different than Pending
        Codeunit.Run(Codeunit::"Job Queue Start Codeunit", JobQueueEntry);
        
        // [THEN] The bus queue status must be Processed
        BusQueueRec.Get(BusQueueEntryNo);
        LibraryAssert.AreEqual(BusQueueRec.Status, BusQueueRec.Status::Processed, 'Status must be Processed');        
    end;

    [Test]
    procedure TestNonExistingURLIsError()
    var
        BusQueueRec: Record "Bus Queue";
        BusQueueEntryNo: Integer;
    begin
        // [SCENARIO] Enqueues a bus queue with a non existing URL and status must be Error

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Bus Queue Exec');

        // [GIVEN] One bus queue
        BusQueue.Init(NonExistingUrlTxt, Enum::"Http Request Type"::GET);
        BusQueue.SetRaiseOnAfterInsertBusQueueResponse(false);
        BusQueueEntryNo := Initialize();

        // [WHEN] Status is different than Pending
        Codeunit.Run(Codeunit::"Job Queue Start Codeunit", JobQueueEntry);

        // [THEN] The bus queue status must be Error
        BusQueueRec.Get(BusQueueEntryNo);
        LibraryAssert.AreEqual(BusQueueRec.Status, BusQueueRec.Status::Error, 'Status must be Error');
    end;

    [Test]
    procedure TestBusQueueIsReadInTheSameEncoding()
    var
        BusQueueRec: Record "Bus Queue";
        DotNetEncoding: Codeunit DotNet_Encoding;
        DotNetStreamReader: Codeunit DotNet_StreamReader;
        BusQueueEntryNo: Integer;
        InStream: InStream;
        BusQueueBody, JapaneseCharactersTok: Text;
    begin
        // [SCENARIO] Enqueues a bus queue with a specific codepage. Body of the bus queue must be read in the same codepage.

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Bus Queue Exec');

        // [GIVEN] Some non English characters 
        JapaneseCharactersTok := 'こんにちは世界'; //Hello world in Japanese

        // [WHEN] Bus queue is enqueued
        BusQueue.Init(MicrosoftUrlTxt, Enum::"Http Request Type"::GET);
        BusQueue.SetBody(JapaneseCharactersTok, 932); //Japanese (Shift-JIS)
        BusQueue.SetRaiseOnAfterInsertBusQueueResponse(false);
        BusQueueEntryNo := Initialize();

        // [THEN] The body must be read in the same codepage
        BusQueueRec.SetAutoCalcFields(Body);
        BusQueueRec.Get(BusQueueEntryNo);
        BusQueueRec.Body.CreateInStream(InStream);
        DotNetEncoding.Encoding(BusQueueRec.Codepage);
        DotNetStreamReader.StreamReader(InStream, DotNetEncoding);
        BusQueueBody := DotNetStreamReader.ReadToEnd();

        LibraryAssert.AreEqual(BusQueueBody, JapaneseCharactersTok, 'Read body is not equal to ' + JapaneseCharactersTok);
    end;

    [Test]
    procedure TestMaximumThreeTriesAreRun()
    var
        BusQueueRec: Record "Bus Queue";
        BusQueueEntryNo: Integer;
    begin
        // [SCENARIO] Enqueues a bus queue and only three tries must be run

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Bus Queue Exec');
        
        // [GIVEN] One bus queue
        BusQueue.Init(NonExistingUrlTxt, Enum::"Http Request Type"::GET);
        BusQueue.SetRaiseOnAfterInsertBusQueueResponse(false);
        BusQueueEntryNo := Initialize();

        // [WHEN] Status is different than Pending
        Codeunit.Run(Codeunit::"Job Queue Start Codeunit", JobQueueEntry);
        
        // [THEN] The bus queue number of tries must be three
        BusQueueRec.Get(BusQueueEntryNo);
        LibraryAssert.AreEqual(BusQueueRec."No. Of Tries", 3, 'No. of tries does not equal 3');
    end;

    [Test]
    procedure TestTwoSecondsElapse()
    var
        BusQueueRec: Record "Bus Queue";
        BusQueueEntryNo: Integer;
        BeforeRunDateTime, AfterRunDateTime: DateTime;
    begin
        // [SCENARIO] Enqueues a bus queue and very approximately only two seconds must elapse after three tries

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Bus Queue Exec');
        
        // [GIVEN] One bus queue
        BusQueue.Init(NonExistingUrlTxt, Enum::"Http Request Type"::GET);
        BusQueue.SetRaiseOnAfterInsertBusQueueResponse(false);
        BusQueueEntryNo := Initialize();

        // [WHEN] Status is different than Pending
        BeforeRunDateTime := CurrentDateTime();
        Codeunit.Run(Codeunit::"Job Queue Start Codeunit", JobQueueEntry);
        AfterRunDateTime := CurrentDateTime();
        
        // [THEN] The bus queue status must be Processed
        BusQueueRec.Get(BusQueueEntryNo);
        LibraryAssert.AreNearlyEqual(2, (AfterRunDateTime - BeforeRunDateTime) / 1000, 1, 'More than 3 seconds elapsed');
    end;

    [Test]
    procedure TestItIsPossibleToRetrieveResponse()
    var
        BusQueueRec: Record "Bus Queue";
        BusQueueTestSubscriber: Codeunit "Bus Queue Test Subscriber";
        BusQueueEntryNo: Integer;
    begin
        // [SCENARIO] Enqueues a bus queue and response must be retrieved through event subscription

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Bus Queue Exec');

        // [GIVEN] One bus queue
        if BindSubscription(BusQueueTestSubscriber) then;
        BusQueueTestSubscriber.ClearReasonPhrase();
        BusQueue.Init(NonExistingUrlTxt, Enum::"Http Request Type"::GET);
        BusQueue.SetRaiseOnAfterInsertBusQueueResponse(true);
        BusQueueEntryNo := Initialize();

        // [WHEN] Status is different than Pending
        Codeunit.Run(Codeunit::"Job Queue Start Codeunit", JobQueueEntry);
        
        // [THEN] The reason phrase must not be empty
        BusQueueRec.Get(BusQueueEntryNo);
        LibraryAssert.AreNotEqual('', BusQueueTestSubscriber.GetReasonPhrase(), 'Response''s reason phrase is empty');
    end;

    local procedure Initialize(): Integer
    var
        BusQueueEntryNo: Integer;
    begin
        BusQueue.SetSecondsBetweenRetries(1);
        BusQueue.SetMaximumNumberOfTries(3);
        BusQueue.SetUseTaskScheduler(false);
        BusQueueEntryNo := BusQueue.Enqueue();

        CreateJobQueueEntry();
        Commit();

        exit(BusQueueEntryNo);
    end;

    local procedure CreateJobQueueEntry()
    begin
        Clear(JobQueueEntry);
        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"Bus Queues Handler";
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        JobQueueEntry."Job Queue Category Code" := 'BQH';
        JobQueueEntry.Insert(true);
    end;
}