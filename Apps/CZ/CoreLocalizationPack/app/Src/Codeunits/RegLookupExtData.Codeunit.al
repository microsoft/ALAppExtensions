codeunit 11754 "Reg. Lookup Ext. Data CZL"
{
    TableNo = "Registration Log CZL";

    trigger OnRun()
    begin
        RegistrationLogCZL := Rec;
        LookupRegistrationFromService();
        Rec := RegistrationLogCZL;
    end;

    var
        RegistrationLogCZL: Record "Registration Log CZL";
        RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";

    procedure LookupRegistrationFromService()
    var
        RegNoServiceResponse: Text;
    begin
        RegNoServiceResponse := SendRequest();
        InsertLogEntry(RegNoServiceResponse);
        Commit();
    end;

    local procedure SendRequest() ResponseText: Text
    var
        RegNoServiceConfigCZL: Record "Reg. No. Service Config CZL";
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        RequestURL: Text;
        RegNoTok: Label '%1?ico=%2', Locked = true, Comment = '%1 = Registration No. service URL, %2 = Reistraton No.';
        ServiceCallErr: Label 'Web service call failed.';
        ServiceStatusErr: Label 'Web service returned error message.\\Status Code: %1\Description: %2', Comment = '%1 = HTTP error status, %2 = HTTP error description';
    begin
        RequestURL := StrSubstNo(RegNoTok, RegNoServiceConfigCZL.GetRegNoURL(), RegistrationLogCZL."Registration No.");
        if not HttpClient.Get(RequestURL, HttpResponseMessage) then
            Error(ServiceCallErr);
        if not HttpResponseMessage.IsSuccessStatusCode() then
            Error(ServiceStatusErr, HttpResponseMessage.HttpStatusCode(), HttpResponseMessage.ReasonPhrase());
        HttpResponseMessage.Content().ReadAs(ResponseText);
    end;

    local procedure InsertLogEntry(ResponseText: Text)
    var
        XmlDoc: XmlDocument;
        NamespaceTok: Label 'http://wwwinfo.mfcr.cz/ares/xml_doc/schemas/ares/ares_datatypes/v_1.0.3', Locked = true;
    begin
        XmlDocument.ReadFrom(ResponseText, XmlDoc);
        RegistrationLogMgtCZL.LogVerification(RegistrationLogCZL, XmlDoc, NamespaceTok);
    end;

    procedure GetRegistrationNoValidationWebServiceURL(): Text[250]
    var
        RegNoValidationWebServiceURLTok: Label 'http://wwwinfo.mfcr.cz/cgi-bin/ares/darv_bas.cgi', Locked = true;
    begin
        exit(RegNoValidationWebServiceURLTok);
    end;

    procedure SetRegistrationLog(RegistrationLogCZL: Record "Registration Log CZL")
    begin
        RegistrationLogCZL := RegistrationLogCZL;
    end;
}
