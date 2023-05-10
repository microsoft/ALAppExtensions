// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132101 "Cust. Exp. Survey Req. Mock"
{
    EventSubscriberInstance = Manual;
    SingleInstance = true;

    var
        EligibilityUriLbl: Label 'Eligibilities', Locked = true;
        SurveyUriLbl: Label 'Surveys', Locked = true;
        EventsUriLbl: Label 'Events', Locked = true;
        GlobalRequestUri: Text;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cust. Exp. Survey Req. Impl.", 'OnGetRequest', '', false, false)]
    local procedure HandleOnGetRequest(RequestUri: Text; var ResponseJsonObject: JsonObject; IsGraph: Boolean; var IsHandled: Boolean)
    begin
        if IsGraph then
            ResponseJsonObject := MockGraphResponse()
        else
            ResponseJsonObject := MockCESGetRequestResponse(RequestUri);

        GlobalRequestUri := RequestUri;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cust. Exp. Survey Req. Impl.", 'OnPostRequest', '', false, false)]
    local procedure HandleOnPostRequest(RequestUri: Text; var ResponseJsonObject: JsonObject; var IsHandled: Boolean)
    begin
        ResponseJsonObject := MockCESPostRequestResponse(RequestUri);
        GlobalRequestUri := RequestUri;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Exp. Survey Impl.", 'OnGetTenantId', '', false, false)]
    local procedure HandlOnGetTenantId(var Result: Text; var IsHandled: Boolean)
    begin
        Result := '816800a7-f29f-464c-9d58-c7b250995cba';
        IsHandled := true;
    end;

    local procedure MockGraphResponse(): JsonObject
    var
        Response: Text;
        ResponseJsonObject: JsonObject;
    begin
        Response := '{' +
                        '"@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users/$entity",' +
                        '"businessPhones": [' +
                        '    "+1 412 555 0109"' +
                        '],' +
                        '"displayName": "Megan Bowen",' +
                        '"givenName": "Megan",' +
                        '"jobTitle": "Auditor",' +
                        '"mail": "MeganB@M365x214355.onmicrosoft.com",' +
                        '"mobilePhone": null,' +
                        '"officeLocation": "12/1110",' +
                        '"preferredLanguage": "en-US",' +
                        '"surname": "Bowen",' +
                        '"userPrincipalName": "MeganB@M365x214355.onmicrosoft.com",' +
                        '"id": "48d31887-5fad-4d73-a9f5-3c356e68a038"' +
                    '}';
        ResponseJsonObject.ReadFrom(Response);
        exit(ResponseJsonObject)
    end;

    local procedure MockCESGetRequestResponse(RequestUri: Text): JsonObject
    var
        Response: Text;
        ResponseJsonObject: JsonObject;
    begin
        if RequestUri.Contains(EligibilityUriLbl) then
            Response := '{' +
                            '"SurveyName": "modernactionbar",' +
                            '"Eligibility": true,' +
                            '"FormsProId": null,' +
                            '"FormsProEligibilityId": null,' +
                            '"RenderDetails": null' +
                        '}';
        if RequestUri.Contains(SurveyUriLbl) then
            Response := '{' +
                            '"SurveyName": "modernactionbar",' +
                            '"SurveyDescription": "Modern Action Bar",' +
                            '"TeamName": "d365bc",' +
                            '"SurveyCoolingTime": 90,' +
                            '"NPSCoolingTime": 90,' +
                            '"CESCoolingTime": 90,' +
                            '"SurveyPriority": 0,' +
                            '"SurveyType": "ShortSurvey",' +
                            '"IsEnabled": true,' +
                            '"ABConfigs": null,' +
                            '"TriggerCondition": {' +
                                '"Events": [],' +
                                '"TriggerEventName": "modernactionbar_event",' +
                                '"TriggerType": "Simple",' +
                                '"Period": 0' +
                            '},' +
                            '"PromptLimits": {' +
                                '"Probability": 0,' +
                                '"TotalSample": 0,' +
                                '"TotalSamplePerPeriod": {' +
                                '"Sample": 0,' +
                                '"Period": 0' +
                                '}' +
                            '},' +
                            '"FormsProId": "v4j5cvGGr0GRqyOTdPVEc3U0pJV0FGSUJGWi4u"' +
                        '}';

        ResponseJsonObject.ReadFrom(Response);
        exit(ResponseJsonObject)
    end;

    local procedure MockCESPostRequestResponse(RequestUri: Text): JsonObject
    var
        Response: Text;
        ResponseJsonObject: JsonObject;
    begin
        if RequestUri.Contains(EventsUriLbl) then
            Response := '{' +
                            '"EventId": "55d580cd-c651-44da-8a81-3cc4d624c83b"' +
                        '}';
        if RequestUri.Contains(EligibilityUriLbl) then
            Response := '{' +
                            '"SurveyName": "modernactionbar",' +
                            '"Eligibility": true,' +
                            '"FormsProId": "v4j5cvGGr0GRqyOTdPVEc3U0pJV0FGSUJGWi4u",' +
                            '"FormsProEligibilityId": "fbbb693b-9798-488e-bf96-21abb6d20d1d",' +
                            '"RenderDetails": null' +
                        '}';

        ResponseJsonObject.ReadFrom(Response);
        exit(ResponseJsonObject)
    end;

    procedure GetGlobalRequestUri(): Text
    begin
        exit(GlobalRequestUri);
    end;
}