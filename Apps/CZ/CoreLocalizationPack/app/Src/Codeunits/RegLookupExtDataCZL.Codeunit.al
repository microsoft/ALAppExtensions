// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Registration;

using System.RestClient;

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

    local procedure SendRequest() HttpResponseMessage: Codeunit "Http Response Message"
    var
        RegNoServiceConfigCZL: Record "Reg. No. Service Config CZL";
        RestClient: Codeunit "Rest Client";
        RequestURL: Text;
        RegNoTok: Label '%1/%2', Locked = true, Comment = '%1 = Registration No. service URL, %2 = Registraton No.';
    begin
        RequestURL := StrSubstNo(RegNoTok, RegNoServiceConfigCZL.GetRegNoURL(), RegistrationLogCZL."Registration No.");
        RestClient.Initialize();
        HttpResponseMessage := RestClient.Get(RequestURL);
    end;

    local procedure InsertLogEntry(HttpResponseMessage: Codeunit "Http Response Message")
    var
        ResponseJsonObject: JsonObject;
    begin
        ResponseJsonObject := HttpResponseMessage.GetContent().AsJson().AsObject();
        if HttpResponseMessage.GetIsSuccessStatusCode() then
            RegistrationLogMgtCZL.LogVerification(RegistrationLogCZL, ResponseJsonObject)
        else
            RegistrationLogMgtCZL.LogError(RegistrationLogCZL, ResponseJsonObject);
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
