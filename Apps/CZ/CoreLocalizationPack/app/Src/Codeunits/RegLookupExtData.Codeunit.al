// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Registration;

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
    begin
        InsertLogEntry(SendRequest());
        Commit();
    end;

    local procedure SendRequest() HttpResponseMessage: HttpResponseMessage
    var
        RegNoServiceConfigCZL: Record "Reg. No. Service Config CZL";
        HttpClient: HttpClient;
        RequestURL: Text;
        RegNoTok: Label '%1/%2', Locked = true, Comment = '%1 = Registration No. service URL, %2 = Registraton No.';
#if not CLEAN23
        OldRegNoTok: Label '%1?ico=%2', Locked = true, Comment = '%1 = Registration No. service URL, %2 = Reistraton No.';
#endif
        ServiceCallErr: Label 'Web service call failed.';
    begin
#if not CLEAN23
        if RegNoServiceConfigCZL.GetRegNoURL() = GetRegistrationNoValidationWebServiceURL() then
            RequestURL := StrSubstNo(RegNoTok, RegNoServiceConfigCZL.GetRegNoURL(), RegistrationLogCZL."Registration No.")
        else
            RequestURL := StrSubstNo(OldRegNoTok, RegNoServiceConfigCZL.GetRegNoURL(), RegistrationLogCZL."Registration No.");
#else
        RequestURL := StrSubstNo(RegNoTok, RegNoServiceConfigCZL.GetRegNoURL(), RegistrationLogCZL."Registration No.");
#endif
        if not HttpClient.Get(RequestURL, HttpResponseMessage) then
            Error(ServiceCallErr);
    end;

    local procedure InsertLogEntry(HttpResponseMessage: HttpResponseMessage)
    var
        ResponseObject: JsonObject;
#if not CLEAN23
        ResponseXmlDoc: XmlDocument;
#endif
        HttpResponseText: Text;
#if not CLEAN23
        NamespaceTok: Label 'http://wwwinfo.mfcr.cz/ares/xml_doc/schemas/ares/ares_datatypes/v_1.0.3', Locked = true;
#endif
    begin
        HttpResponseMessage.Content().ReadAs(HttpResponseText);
#if not CLEAN23
        if ResponseObject.ReadFrom(HttpResponseText) then begin
#endif            
            if HttpResponseMessage.IsSuccessStatusCode() then
                RegistrationLogMgtCZL.LogVerification(RegistrationLogCZL, ResponseObject)
            else
                RegistrationLogMgtCZL.LogError(RegistrationLogCZL, ResponseObject);
#if not CLEAN23
            exit;
        end;

        XmlDocument.ReadFrom(HttpResponseText, ResponseXmlDoc);
#pragma warning disable AL0432
        RegistrationLogMgtCZL.LogVerification(RegistrationLogCZL, ResponseXmlDoc, NamespaceTok);
#pragma warning restore AL0432
#endif
    end;

    procedure GetRegistrationNoValidationWebServiceURL(): Text[250]
    var
        RegNoValidationWebServiceURLTok: Label 'https://ares.gov.cz/ekonomicke-subjekty-v-be/rest/ekonomicke-subjekty', Locked = true;
    begin
        exit(RegNoValidationWebServiceURLTok);
    end;

    procedure SetRegistrationLog(RegistrationLogCZL: Record "Registration Log CZL")
    begin
        RegistrationLogCZL := RegistrationLogCZL;
    end;
}
