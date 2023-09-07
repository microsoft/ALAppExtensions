/// <summary>
/// Codeunit that exposes Bus Queue functionality.
/// </summary>
codeunit 51754 "Bus Queue"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        BusQueueImpl: Codeunit "Bus Queue Impl.";

    /// <summary>
    /// Initializes a bus queue
    /// </summary>
    /// <param name="URL">The URL where the request will be sent</param>
    /// <param name="HttpRequestType">The HTTP verb of the request</param>
    procedure Init(URL: Text[2048]; HttpRequestType: Enum "Http Request Type")
    begin
        BusQueueImpl.Init(URL, HttpRequestType);
    end;

    /// <summary>
    /// Adds header to the request
    /// </summary>
    /// <param name="Name">Name of the header</param>
    /// <param name="Value">Value of the header</param>
    procedure AddHeader(Name: Text[250]; Value: Text)
    begin
        BusQueueImpl.AddHeader(Name, Value);
    end;

    /// <summary>
    /// Sets body for the request
    /// </summary>
    /// <param name="Body">Body of the request</param>
    procedure SetBody(Body: Text)
    begin
        BusQueueImpl.SetBody(Body, 0);
    end;

    /// <summary>
    /// Sets body for the request in a specific codepage
    /// </summary>
    /// <param name="Body">Body of the request</param>
    /// <param name="Codepage">Codepage body of the request</param>
    procedure SetBody(Body: Text; Codepage: Integer)
    begin
        BusQueueImpl.SetBody(Body, Codepage);
    end;

    /// <summary>
    /// Sets body for the request
    /// </summary>
    /// <param name="InStreamBody">InStream with the data</param>
    procedure SetBody(InStreamBody: InStream)
    begin
        BusQueueImpl.SetBody(InStreamBody);
    end;

    /// <summary>
    /// Sets maximum number of tries
    /// </summary>
    /// <param name="MaximumNumberOfTries">Maximum number of tries if a bus queue is in retry status</param>
    procedure SetMaximumNumberOfTries(MaximumNumberOfTries: Integer)
    begin
        BusQueueImpl.SetMaximumNumberOfTries(MaximumNumberOfTries);
    end;

    /// <summary>
    /// Sets seconds between retries
    /// </summary>
    /// <param name="SecondsBetweenTries">Seconds between retries if a bus queue is in Retry status</param>
    procedure SetSecondsBetweenRetries(SecondsBetweenTries: Integer)
    begin
        BusQueueImpl.SetSecondsBetweenRetries(SecondsBetweenTries);
    end;

    /// <summary>
    /// Sets the category in case you want a Bus Queues Handler per category
    /// </summary>
    /// <param name="CategoryCode">The category code of the bus queue</param>
    procedure SetCategory(CategoryCode: Code[10])
    begin
        BusQueueImpl.SetCategory(CategoryCode);
    end;

    /// <summary>
    /// Sets the certificate
    /// </summary>
    /// <param name="Certificate">The Base64 encoded certificate</param>
    /// <param name="Password">The certificate password</param>
    /*procedure AddCertificate(Certificate: Text; Password: Text)
    begin
        BusQueueImpl.AddCertificate(Certificate, Password);
    end;*/

    /// <summary>
    /// Sets the RecordId of the record you want to "link" to the bus queue
    /// </summary>
    /// <param name="RecordId">The RecordId of the record you want to "link" to the bus queue</param>
    procedure SetRecordId("RecordId": RecordId)
    begin
        BusQueueImpl.SetRecordId("RecordId");
    end;

    /// <summary>
    /// Sets the SetSystemId of the record you want to "link" to the bus queue
    /// </summary>
    /// <param name="TableNo">The table number of the record</param>
    /// <param name="SystemId">The SystemId of the record</param>
    procedure SetSystemId(TableNo: Integer; SystemId: Guid)
    begin
        BusQueueImpl.SetSystemId(TableNo, SystemId);
    end;

    /// <summary>
    /// Creates a Bus Queue record and runs the Bus Queues Handler
    /// </summary>
    /// <returns>Entry No. of the Bus Queue</returns>
    procedure Enqueue(): Integer
    begin
        exit(BusQueueImpl.Enqueue());
    end;

    internal procedure SetUseTaskScheduler(UseTaskScheduler: Boolean)
    begin
        BusQueueImpl.SetUseTaskScheduler(UseTaskScheduler);
    end;

    internal procedure SetRaiseOnAfterInsertBusQueueResponse(RaiseOnAfterInsertBusQueueResponse: Boolean)
    begin
        BusQueueImpl.SetRaiseOnAfterInsertBusQueueResponse(RaiseOnAfterInsertBusQueueResponse);
    end;
}