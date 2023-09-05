codeunit 51757 "Bus Queue Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Name/Value Buffer" = RI;

    var
        BusQueue: Record "Bus Queue";
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;

    internal procedure Init(URL: Text[2048]; HttpRequestType: Enum "Http Request Type")
    begin
        Clear(BusQueue);
        BusQueue.Init();
        BusQueue.Validate(URL, URL);
        BusQueue."HTTP Request Type" := HTTPRequestType;

        TempNameValueBuffer.DeleteAll();
    end;

    internal procedure AddHeader(Name: Text[250]; Value: Text)
    begin
        if (Name <> '') and (Value <> '') then
            TempNameValueBuffer.AddNewEntry(Name, Value);
    end;

    internal procedure SetBody(NewBody: Text; DotNetEncoding: Codeunit DotNet_Encoding)
    var
        DotNetStreamWriter: Codeunit DotNet_StreamWriter;
        OutStream: OutStream;
    begin
        if NewBody = '' then
            exit;

        BusQueue."Is Text" := true;
        BusQueue.Codepage := DotNetEncoding.Codepage();
        BusQueue.Body.CreateOutStream(OutStream);
        DotNetStreamWriter.StreamWriter(OutStream, DotNetEncoding);
        DotNetStreamWriter.Write(NewBody);
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
        BusQueue.SaveHeaders(TempNameValueBuffer);
        BusQueue.Insert(true);

        exit(BusQueue."Entry No.");
    end;
}