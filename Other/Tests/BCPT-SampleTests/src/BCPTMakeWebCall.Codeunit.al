codeunit 149108 "BCPT Make Web Call"
{
    SingleInstance = true;

    trigger OnRun();
    var
        NewUrl: text;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Client: HttpClient;
    begin
        NewUrl := 'https://www.microsoft.com';

        RequestMessage.SetRequestUri(NewUrl);
        RequestMessage.Method('GET');

        Client.Send(RequestMessage, ResponseMessage);
    end;
}