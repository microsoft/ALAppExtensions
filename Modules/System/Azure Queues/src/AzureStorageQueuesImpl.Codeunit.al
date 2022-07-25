/// <summary>
/// Provides internal implementations of the helper functions for working with Azure Storage Queues
/// Reference: https://docs.microsoft.com/en-us/rest/api/storageservices/queue-service-rest-api
/// </summary>
codeunit 50101 "Azure Storage Queues Impl."
{
    Access = Internal;

    procedure CreateQueue(StorageAccountName: Text; Queue: Text): Boolean
    var
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        HttpContent: HttpContent;
    begin
        HttpClient.Put(GetQueueEndpoint(StorageAccountName, Queue), HttpContent, HttpResponseMessage);
        exit(HttpResponseMessage.IsSuccessStatusCode);
    end;

    procedure ListQueues(StorageAccountName: Text): List of [Text]
    var
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;
    begin
        HttpClient.Get(GetAzureQueueServiceEndpoint(StorageAccountName) + '&comp=list', HttpResponseMessage);
        if HttpResponseMessage.IsSuccessStatusCode then begin
            if HttpResponseMessage.Content.ReadAs(ResponseText) then
                exit(GetQueuesListFromResponseBody(ResponseText));
        end;
    end;

    procedure DeleteQueue(StorageAccountName: Text; Queue: Text): Boolean
    var
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        HttpContent: HttpContent;
    begin
        HttpClient.Delete(GetQueueEndpoint(StorageAccountName, Queue), HttpResponseMessage);
        exit(HttpResponseMessage.IsSuccessStatusCode);
    end;

    procedure CheckIfQueueExists(StorageAccountName: Text; Queue: Text): Boolean
    var
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        HttpContent: HttpContent;
    begin
        HttpClient.Put(GetQueueEndpoint(StorageAccountName, Queue), HttpContent, HttpResponseMessage);
        exit(HttpResponseMessage.IsSuccessStatusCode);
    end;

    procedure PostMessageToQueue(StorageAccountName: Text; Queue: Text; MessageBody: Text): Boolean
    var
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        ResponseText: Text;
    begin
        if CheckIfQueueExists(StorageAccountName, Queue) then begin
            HttpContent.WriteFrom('<QueueMessage><MessageText>' + MessageBody + '</MessageText></QueueMessage>');
            HttpClient.Post(GetAzureQueueMessagesEndpoint(StorageAccountName, Queue), HttpContent, HttpResponse);
            exit(HttpResponse.IsSuccessStatusCode);
        end;
    end;

    procedure UpdateMessageToQueue(StorageAccountName: Text; Queue: Text; MessageId: Text; PopReceipt: Text; NewMessageBody: Text): Boolean
    var
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        ResponseText: Text;
    begin
        if CheckIfQueueExists(StorageAccountName, Queue) then begin
            HttpContent.WriteFrom('<QueueMessage><MessageText>' + NewMessageBody + '</MessageText></QueueMessage>');
            HttpClient.Put(GetAzureQueueUpdateMessageEndpoint(StorageAccountName, Queue, MessageId, PopReceipt), HttpContent, HttpResponse);
            exit(HttpResponse.IsSuccessStatusCode);
        end;
    end;

    procedure GetNextMessageFromQueue(StorageAccountName: Text; Queue: Text[20]): Text
    var
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        ResponseText: Text;
    begin
        if CheckIfQueueExists(StorageAccountName, Queue) then begin
            HttpClient.Get(GetAzureQueueMessagesEndpoint(StorageAccountName, Queue), HttpResponse);
            HttpResponse.Content().ReadAs(ResponseText);

            if HttpResponse.IsSuccessStatusCode then begin
                Exit(ResponseText);
            end else
                Error(ResponseText);
        end;
    end;

    procedure PeekNextMessageFromQueue(StorageAccountName: Text; Queue: Text[20]): Text
    var
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        ResponseText: Text;
    begin
        if CheckIfQueueExists(StorageAccountName, Queue) then begin
            HttpClient.Get(GetAzureQueuePeekMessagesEndpoint(StorageAccountName, Queue), HttpResponse);
            HttpResponse.Content().ReadAs(ResponseText);
            if HttpResponse.IsSuccessStatusCode then begin
                Exit(ResponseText);
            end else
                Error(ResponseText);
        end;
    end;

    procedure GetMessageIdFromResponseBody(var ResponseBody: Text): Text
    var
        MessageDocument: XmlDocument;
        MessageId: XmlNode;
    begin
        if XmlDocument.ReadFrom(ResponseBody, MessageDocument) then begin
            if MessageDocument.SelectSingleNode('QueueMessagesList/QueueMessage/MessageId', MessageId) then begin
                exit(MessageId.AsXmlElement().InnerText())
            end;
        end;
    end;

    procedure GetMessagePopReceiptFromResponseBody(var ResponseBody: Text): Text
    var
        MessageDocument: XmlDocument;
        PopReceipt: XmlNode;
    begin
        if XmlDocument.ReadFrom(ResponseBody, MessageDocument) then begin
            if MessageDocument.SelectSingleNode('QueueMessagesList/QueueMessage/PopReceipt', PopReceipt) then begin
                exit(PopReceipt.AsXmlElement().InnerText())
            end;
        end;
    end;

    procedure GetMessageTextFromResponseBody(var ResponseBody: Text): Text
    var
        MessageDocument: XmlDocument;
        MessageText: XmlNode;
    begin
        if XmlDocument.ReadFrom(ResponseBody, MessageDocument) then begin
            if MessageDocument.SelectSingleNode('QueueMessagesList/QueueMessage/MessageText', MessageText) then begin
                exit(MessageText.AsXmlElement().InnerText())
            end;
        end;
    end;

    procedure GetMessageInsertionTimeFromResponseBody(var ResponseBody: Text): Text
    var
        MessageDocument: XmlDocument;
        MessageText: XmlNode;
    begin
        if XmlDocument.ReadFrom(ResponseBody, MessageDocument) then begin
            if MessageDocument.SelectSingleNode('QueueMessagesList/QueueMessage/InsertionTime', MessageText) then begin
                exit(MessageText.AsXmlElement().InnerText())
            end;
        end;
    end;

    procedure GetMessageExpirationTimeFromResponseBody(var ResponseBody: Text): Text
    var
        MessageDocument: XmlDocument;
        MessageText: XmlNode;
    begin
        if XmlDocument.ReadFrom(ResponseBody, MessageDocument) then begin
            if MessageDocument.SelectSingleNode('QueueMessagesList/QueueMessage/ExpirationTime', MessageText) then begin
                exit(MessageText.AsXmlElement().InnerText())
            end;
        end;
    end;

    local procedure GetQueuesListFromResponseBody(var ResponseBody: Text): List of [Text]
    var
        MessageDocument: XmlDocument;
        NamesNodeList: XmlNodeList;
        Node: XmlNode;
        NamesList: List of [Text];
    begin
        if XmlDocument.ReadFrom(ResponseBody, MessageDocument) then begin
            if MessageDocument.SelectNodes('EnumerationResults/Queues/Queue/Name', NamesNodeList) then begin
                if NamesNodeList.Count() > 0 then begin
                    foreach Node in NamesNodeList do begin
                        NamesList.Add(node.AsXmlElement().InnerText());
                    end;
                    exit(NamesList);
                end;
            end;
        end;
    end;


    procedure DeleteMessageFromQueue(StorageAccountName: Text; Queue: Text[20]; MessageID: Text[100]; PopReceipt: Text[30]): Boolean
    var
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        ResponseText: Text;
    begin
        HttpClient.Delete(GetAzureQueueUpdateMessageEndpoint(StorageAccountName, Queue, MessageID, PopReceipt), HttpResponse);
        exit(HttpResponse.IsSuccessStatusCode);
    end;

    procedure ClearMessagesFromQueue(StorageAccountName: Text; Queue: Text[20]): Boolean
    var
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        ResponseText: Text;
    begin
        HttpClient.Delete(GetAzureQueueMessagesEndpoint(StorageAccountName, Queue), HttpResponse);
        exit(HttpResponse.IsSuccessStatusCode);
    end;

    local procedure GetQueueEndpoint(StorageAccountName: Text; Queue: Text): Text
    var
        AzureQueueSetup: Record "Azure Queue Setup";
        EndPoint: Text;
    begin
        AzureQueueSetup.Get(StorageAccountName);
        Endpoint := GetAzureQueueBaseEndpoint(StorageAccountName);
        exit(EndPoint + '/' + Queue + '/' + AzureQueueSetup."SAS Key");
    end;

    local procedure GetAzureQueueServiceEndpoint(StorageAccountName: Text): Text
    var
        AzureQueueSetup: Record "Azure Queue Setup";
        EndPoint: Text;
    begin
        AzureQueueSetup.Get(StorageAccountName);
        Endpoint := GetAzureQueueBaseEndpoint(StorageAccountName);
        exit(EndPoint + AzureQueueSetup."SAS Key");
    end;

    local procedure GetAzureQueueUpdateMessageEndpoint(StorageAccountName: Text; Queue: Text; MessageID: Text; Popreceipt: Text): Text
    var
        AzureQueueSetup: Record "Azure Queue Setup";
        EndPoint: Text;
    begin
        AzureQueueSetup.Get(StorageAccountName);
        Endpoint := GetAzureQueueBaseEndpoint(StorageAccountName);
        exit(EndPoint + '/' + Queue + '/' + 'messages' + '/' + MessageID + AzureQueueSetup."SAS Key" + '&' + 'popreceipt=' + Popreceipt);

    end;

    local procedure GetAzureQueueMessagesEndpoint(StorageAccountName: Text; Queue: Text): Text
    var
        AzureQueueSetup: Record "Azure Queue Setup";
        EndPoint: Text;
    begin
        AzureQueueSetup.Get(StorageAccountName);
        Endpoint := GetAzureQueueBaseEndpoint(StorageAccountName);
        exit(EndPoint + '/' + Queue + '/' + 'messages' + AzureQueueSetup."SAS Key");
    end;

    local procedure GetAzureQueuePeekMessagesEndpoint(StorageAccountName: Text; Queue: Text): Text
    var
        AzureQueueSetup: Record "Azure Queue Setup";
        EndPoint: Text;
    begin
        AzureQueueSetup.Get(StorageAccountName);
        Endpoint := GetAzureQueueBaseEndpoint(StorageAccountName);
        exit(EndPoint + '/' + Queue + '/' + 'messages?peekonly=true' + AzureQueueSetup."SAS Key");
    end;

    local procedure GetAzureQueueBaseEndpoint(StorageAccountName: Text): Text
    var
        AzureQueueSetup: Record "Azure Queue Setup";
        StorageAccountEndpoint: Label 'https://{1}.queue.core.windows.net', Locked = true;
        EndPoint: Text;
    begin
        AzureQueueSetup.Get(StorageAccountName);
        Endpoint := StrSubstNo(StorageAccountEndpoint, StorageAccountName);
        exit(EndPoint);
    end;



}