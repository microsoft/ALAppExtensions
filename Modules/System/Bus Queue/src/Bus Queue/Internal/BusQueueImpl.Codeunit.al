codeunit 51757 "Bus Queue Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Scheduled Task" = I;

    var
        BusQueue: Record "Bus Queue";
        Headers: List of [Dictionary of [Text, Text]];
        CannotScheduledTaskErr: Label 'No permission to schedule tasks';

    internal procedure Init(URL: Text[2048]; HttpRequestType: Enum "Http Request Type")
    begin
        Clear(Headers);
        Clear(BusQueue);
        BusQueue.Init();
        BusQueue.Validate(URL, URL);
        BusQueue."HTTP Request Type" := HTTPRequestType;
    end;

    internal procedure AddHeader(Name: Text[250]; Value: Text)
    var
        Dictionary: Dictionary of [Text, Text];
    begin
        if (Name <> '') and (Value <> '') then begin
            Dictionary.Add(Name, Value);
            Headers.Add(Dictionary);
        end;
    end;

    internal procedure SetBody(NewBody: Text; Codepage: Integer)
    var
        StreamWriter: DotNet StreamWriter;
        Encoding: DotNet Encoding;
        OutStream: OutStream;
    begin
        if NewBody = '' then
            exit;

        BusQueue."Is Text" := true;
        BusQueue.Codepage := Codepage;

        if Codepage = 0 then begin
            BusQueue.Body.CreateOutStream(OutStream, TextEncoding::UTF8);
            OutStream.WriteText(NewBody);
        end else begin
            BusQueue.Body.CreateOutStream(OutStream);
            StreamWriter := StreamWriter.StreamWriter(OutStream, Encoding.GetEncoding(Codepage));
            StreamWriter.Write(NewBody);
        end;
    end;

    internal procedure SetBody(InStreamBody: InStream)
    var
        OutStreamBody: OutStream;
    begin
        InStreamBody.ResetPosition();
        if InStreamBody.Length() = 0 then
            exit;

        BusQueue."Is Text" := false;
        BusQueue.Body.CreateOutStream(OutStreamBody, TextEncoding::UTF8);
        CopyStream(OutStreamBody, InStreamBody);
    end;

    internal procedure SetMaximumNumberOfTries(MaximumNumberOfTries: Integer)
    begin
        BusQueue.Validate("Max. No. Of Tries", MaximumNumberOfTries);
    end;

    internal procedure SetSecondsBetweenRetries(SecondsBetweenTries: Integer)
    begin
        BusQueue.Validate("Seconds Between Retries", SecondsBetweenTries);
    end;

    internal procedure SetCategory(CategoryCode: Code[10])
    begin
        BusQueue."Category Code" := CategoryCode;
    end;

    internal procedure AddCertificate(Certificate: Text; Password: Text)
    begin
        if Certificate = '' then
            exit;

        BusQueue."Use Certificate" := true;
        if IsolatedStorage.Set('Certificate', Certificate) then;
        if Password <> '' then
            if IsolatedStorage.SetEncrypted('Password', Password) then;
    end;

    internal procedure SetRecordId("RecordId": RecordId)
    begin
        BusQueue."RecordId" := "RecordId";
    end;

    internal procedure SetSystemId(TableNo: Integer; SystemId: Guid)
    begin
        BusQueue."Table No." := TableNo;
        BusQueue."System Id" := SystemId;
    end;

    internal procedure SetUseTaskScheduler(UseTaskScheduler: Boolean)
    begin
        BusQueue."Use Task Scheduler" := UseTaskScheduler;
    end;

    internal procedure SetRaiseOnAfterInsertBusQueueResponse(RaiseOnAfterInsertBusQueueResponse: Boolean)
    begin
        BusQueue."Raise Response Event" := RaiseOnAfterInsertBusQueueResponse;
    end;

    internal procedure Enqueue(): Integer
    begin
        BusQueue.TestField(URL);
        BusQueue.SaveHeaders(Headers);
        BusQueue.Insert(true);

        if BusQueue."Use Task Scheduler" then begin
            if not TaskScheduler.CanCreateTask() then
                Error(CannotScheduledTaskErr);
            
            ScheduleBusQueuesHandlerTask();
        end else
            Codeunit.Run(Codeunit::"Bus Queues Handler");

        exit(BusQueue."Entry No.");
    end;

    local procedure ScheduleBusQueuesHandlerTask()
    var
        ScheduledTask: Record "Scheduled Task";
        SystemTaskId: Guid;
        i: Integer;
    begin
        ScheduledTask.SetRange(Company, CompanyName());
        ScheduledTask.SetRange("Run Codeunit", Codeunit::"Bus Queues Handler");
        if not ScheduledTask.IsEmpty() then
            exit;

        SystemTaskId := TaskScheduler.CreateTask(Codeunit::"Bus Queues Handler", 0, true, CompanyName(), CurrentDateTime() + 60000);
        ScheduledTask.SetRange(ID, SystemTaskId);
        if ScheduledTask.IsEmpty() then
            repeat
                Sleep(100);
                i += 1;
            until (not ScheduledTask.IsEmpty()) or (i = 10);
    end;
}