namespace Microsoft.EServices;

codeunit 13658 "Http Client Nemhandel Status" implements "Http Client Nemhandel Status"
{
    var
        NemhandelCompanyLookupUrlLbl: Label 'https://api.nemhandel.dk/v3-nhr-api/search/lookup/%1', Locked = true;

    procedure SendGetRequest(RequestURI: Text; var RequestMessage: HttpRequestMessage; var ResponseMessage: Interface "Http Response Msg Nemhandel") Result: Boolean
    var
        HttpResponseMsgNemhandel: Codeunit "Http Response Msg Nemhandel";
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
    begin
        RequestMessage.Method('GET');
        RequestMessage.SetRequestUri(RequestURI);
        Result := HttpClient.Send(RequestMessage, HttpResponseMessage);
        HttpResponseMsgNemhandel.Initialize(HttpResponseMessage);
        ResponseMessage := HttpResponseMsgNemhandel;
    end;

    procedure GetRequestURI(CVRNumber: Text) RequestURI: Text
    begin
        RequestURI := StrSubstNo(NemhandelCompanyLookupUrlLbl, CVRNumber);
    end;
}