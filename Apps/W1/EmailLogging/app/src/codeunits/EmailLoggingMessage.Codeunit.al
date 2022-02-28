codeunit 1687 "Email Logging Message"
{
    Access = Internal;

    var
        Id: Text;
        InternetMessageId: Text;
        Sender: Text;
        ToRecipients: List of [Text];
        CcRecipients: List of [Text];
        Subject: Text;
        WebLink: Text;
        SentDateTime: DateTime;
        ReceivedDateTime: DateTime;
        IsDraft: Boolean;
        Initialized: Boolean;

    internal procedure GetId(): Text
    begin
        exit(Id);
    end;

    internal procedure GetInternetMessageId(): Text
    begin
        exit(InternetMessageId);
    end;

    internal procedure GetSender(): Text
    begin
        exit(Sender);
    end;

    internal procedure GetToAndCcRecipients(): List of [Text]
    var
        ToAndCcRecipients: List of [Text];
    begin
        ToAndCcRecipients.AddRange(ToRecipients);
        ToAndCcRecipients.AddRange(CcRecipients);
        exit(ToAndCcRecipients);
    end;

    internal procedure GetToRecipients(): List of [Text]
    begin
        exit(ToRecipients);
    end;

    internal procedure GetCcRecipients(): List of [Text]
    begin
        exit(CcRecipients);
    end;

    internal procedure GetSubject(): Text
    begin
        exit(Subject);
    end;

    internal procedure GetWebLink(): Text
    begin
        exit(WebLink);
    end;

    internal procedure GetSentDateTime(): DateTime
    begin
        exit(SentDateTime);
    end;

    internal procedure GetReceivedDateTime(): DateTime
    begin
        exit(ReceivedDateTime);
    end;

    internal procedure GetIsDraft(): Boolean
    begin
        exit(IsDraft);
    end;

    internal procedure IsInitialized(): Boolean
    begin
        exit(Initialized);
    end;

    internal procedure Initialize(JsonObject: JsonObject)
    var
        DictinctRecipients: Dictionary of [Text, Boolean];
    begin
        Id := GetTextProperty(JsonObject, 'id');
        IsDraft := GetBooleanProperty(JsonObject, 'isDraft');
        if not IsDraft then begin
            InternetMessageId := GetTextProperty(JsonObject, 'internetMessageId');
            Subject := GetTextProperty(JsonObject, 'subject');
            WebLink := GetTextProperty(JsonObject, 'webLink');
            SentDateTime := GetDateTimeProperty(JsonObject, 'sentDateTime');
            ReceivedDateTime := GetDateTimeProperty(JsonObject, 'receivedDateTime');
            Sender := GetEmailProperty(JsonObject, 'sender');
            ToRecipients := GetEmailListProperty(JsonObject, 'toRecipients', DictinctRecipients);
            CcRecipients := GetEmailListProperty(JsonObject, 'ccRecipients', DictinctRecipients);
        end;
        Initialized := true;
    end;

    local procedure GetProperty(var JsonObject: JsonObject; PropertyName: Text; var PropertyJsonValue: JsonValue): Boolean
    var
        PropertyJsonToken: JsonToken;
    begin
        if not JsonObject.Get(PropertyName, PropertyJsonToken) then
            exit(false);
        PropertyJsonValue := PropertyJsonToken.AsValue();
        exit(true);
    end;

    local procedure GetTextProperty(var JsonObject: JsonObject; PropertyName: Text): Text
    var
        JsonValue: JsonValue;
    begin
        if GetProperty(JsonObject, PropertyName, JsonValue) then
            exit(JsonValue.AsText());
        exit('');
    end;

    local procedure GetDateTimeProperty(var JsonObject: JsonObject; PropertyName: Text): DateTime
    var
        JsonValue: JsonValue;
    begin
        if GetProperty(JsonObject, PropertyName, JsonValue) then
            exit(JsonValue.AsDateTime());
        exit(0DT);
    end;

    local procedure GetBooleanProperty(var JsonObject: JsonObject; PropertyName: Text): Boolean
    var
        JsonValue: JsonValue;
    begin
        if GetProperty(JsonObject, PropertyName, JsonValue) then
            exit(JsonValue.AsBoolean());
        exit(false);
    end;

    local procedure GetEmailProperty(var JsonObject: JsonObject; PropertyName: Text): Text
    var
        PropertyJsonToken: JsonToken;
        EmailAddressJsonToken: JsonToken;
        EmailAddressJsonObject: JsonObject;
        EmailAddress: Text;
    begin
        JsonObject.Get(PropertyName, PropertyJsonToken);
        PropertyJsonToken.AsObject().Get('emailAddress', EmailAddressJsonToken);
        EmailAddressJsonObject := EmailAddressJsonToken.AsObject();
        EmailAddress := GetEmailAddressProperty(EmailAddressJsonObject, 'address');
        exit(EmailAddress);
    end;

    local procedure GetEmailListProperty(var JsonObject: JsonObject; PropertyName: Text; var DistinctEmails: Dictionary of [Text, Boolean]): List of [Text]
    var
        EmailList: List of [Text];
        PropertyArrayJsonToken: JsonToken;
        PropertyJsonArray: JsonArray;
        PropertyJsonToken: JsonToken;
        EmailAddressJsonToken: JsonToken;
        EmailAddressJsonObject: JsonObject;
        EmailCount: Integer;
        EmailNumber: Integer;
        EmailAddress: Text;
    begin
        JsonObject.Get(PropertyName, PropertyArrayJsonToken);
        PropertyJsonArray := PropertyArrayJsonToken.AsArray();
        EmailCount := PropertyJsonArray.Count();
        for EmailNumber := 0 to EmailCount - 1 do begin
            PropertyJsonArray.Get(EmailNumber, PropertyJsonToken);
            PropertyJsonToken.AsObject().Get('emailAddress', EmailAddressJsonToken);
            EmailAddressJsonObject := EmailAddressJsonToken.AsObject();
            EmailAddress := GetEmailAddressProperty(EmailAddressJsonObject, 'address');
            if not DistinctEmails.ContainsKey(EmailAddress.ToLower()) then begin
                DistinctEmails.Add(EmailAddress.ToLower(), true);
                EmailList.Add(EmailAddress);
            end;
        end;
        exit(EmailList);
    end;

    local procedure GetEmailAddressProperty(var JsonObject: JsonObject; PropertyName: Text): Text
    var
        MailManagement: Codeunit "Mail Management";
        EmailAddress: Text;
    begin
        EmailAddress := GetTextProperty(JsonObject, PropertyName);
        MailManagement.ValidateEmailAddressField(EmailAddress);
        exit(EmailAddress);
    end;
}