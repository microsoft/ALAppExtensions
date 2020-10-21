// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4508 "Email - Outlook API Client" implements "Email - Outlook API Client"
{
    var
        OutlookCateogryLbl: Label 'Outlook', Locked = true;
        GraphURLTxt: label 'https://graph.microsoft.com', Locked = true;
        SendEmailErr: Label 'Could not send the email message. Try again later.';
        EmailSentTxt: Label 'Email sent.', Locked = true;

    [NonDebuggable]
    procedure GetAccountInformation(AccessToken: Text; var Email: Text[250]; var Name: Text[250]): Boolean
    begin
        exit(TryGetAccountInformation(AccessToken, Email, Name));
    end;

    [NonDebuggable]
    [TryFunction]
    procedure TryGetAccountInformation(AccessToken: Text; var Email: Text[250]; var Name: Text[250])
    var
        AccountHttpClient: HttpClient;
        AccountRequestHeaders: HttpHeaders;
        AccountResponseMessage: HttpResponseMessage;
        ResponseContent: Text;
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        AccountRequestHeaders := AccountHttpClient.DefaultRequestHeaders();
        AccountRequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);

        if not AccountHttpClient.Get(GraphURLTxt + '/v1.0/me', AccountResponseMessage) then
            exit;

        AccountResponseMessage.Content().ReadAs(ResponseContent);
        JObject.ReadFrom(ResponseContent);

        JObject.Get('userPrincipalName', JToken);
        Email := CopyStr(JToken.AsValue().AsText(), 1, 250);

        JObject.Get('displayName', JToken);
        Name := CopyStr(JToken.AsValue().AsText(), 1, 250);
    end;

    [NonDebuggable]
    procedure SendEmail(AccessToken: Text; MessageJson: JsonObject)
    var
        MailHttpClient: HttpClient;
        MailRequestHeaders: HttpHeaders;
        MailContentHeaders: HttpHeaders;
        MailContent: HttpContent;
        MailResponseMessage: HttpResponseMessage;
        MailRequestMessage: HttpRequestMessage;
        JToken: JsonToken;
        ResponseJson: JsonObject;
        MessageJsonText: Text;
        ResponseJsonText: Text;
    begin
        MailRequestMessage.Method('POST');
        MailRequestMessage.SetRequestUri(GraphURLTxt + '/v1.0/me/sendMail');
        MailRequestMessage.GetHeaders(MailRequestHeaders);
        MailRequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);

        MessageJson.WriteTo(MessageJsonText);
        MailContent.WriteFrom(MessageJsonText);
        MailContent.GetHeaders(MailContentHeaders);
        MailContentHeaders.Clear();
        MailContentHeaders.Add('Content-Type', 'application/json');

        MailRequestMessage.Content := MailContent;

        if not MailHttpClient.Send(MailRequestMessage, MailResponseMessage) then begin
            Session.LogMessage('0000D1P', SendEmailErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCateogryLbl);
            error(SendEmailErr);
        end;

        if MailResponseMessage.HttpStatusCode <> 202 then begin
            MailResponseMessage.Content.ReadAs(ResponseJsonText);
            ResponseJson.ReadFrom(ResponseJsonText);
            ResponseJson.Get('error', JToken);
            JToken.AsObject().Get('message', JToken);

            Session.LogMessage('0000D1Q', JToken.AsValue().AsText(), Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', OutlookCateogryLbl);
            error(JToken.AsValue().AsText())
        end else
            Session.LogMessage('0000D1R', EmailSentTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCateogryLbl);
    end;
}