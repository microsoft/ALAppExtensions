codeunit 148014 "Mock Http Client Nemhandel" implements "Http Client Nemhandel Status"
{
    var
        MockHttpResponseMsgNemhandel: Codeunit "Mock HttpResponseMsg Nemhandel";
        RequestResultGlobal: Boolean;

    procedure SendGetRequest(RequestURI: Text; var RequestMessage: HttpRequestMessage; var ResponseMessage: Interface "Http Response Msg Nemhandel") Result: Boolean
    begin
        ResponseMessage := MockHttpResponseMsgNemhandel;
        Result := RequestResultGlobal;
    end;

    procedure GetRequestURI(CVRNumber: Text) RequestURI: Text
    begin
        RequestURI := 'https://testurl';
    end;

    procedure SetRequestResult(NewResult: Boolean)
    begin
        RequestResultGlobal := NewResult;
    end;

    procedure SetBlockedByEnvironment(NewBlockedByEnv: Boolean)
    begin
        MockHttpResponseMsgNemhandel.SetBlockedByEnvironment(NewBlockedByEnv);
    end;

    procedure SetError(NewStatusCode: Integer; NewReasonPhraseValue: Text)
    begin
        MockHttpResponseMsgNemhandel.SetError(NewStatusCode, NewReasonPhraseValue);
    end;

    procedure SetSuccess(NewStatusCode: Integer; NewResponseBodyText: Text)
    begin
        MockHttpResponseMsgNemhandel.SetSuccess(NewStatusCode, NewResponseBodyText);
    end;
}