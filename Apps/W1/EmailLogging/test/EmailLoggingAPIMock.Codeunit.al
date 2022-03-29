codeunit 139766 "Email Logging API Mock" implements "Email Logging API Client"
{
    Access = Internal;
    SingleInstance = true;

    var
        InboxDictionary: Dictionary of [Text, Text];
        ArchiveDictionary: Dictionary of [Text, Text];
        DeletedItemsDictionary: Dictionary of [Text, Text];

    internal procedure ClearMailbox()
    begin
        Clear(InboxDictionary);
        Clear(ArchiveDictionary);
        clear(DeletedItemsDictionary);
    end;

    internal procedure AddMessageToInbox(Id: Text; InternetMessageId: Text; WebLink: Text; IsDraft: Boolean; SentDateTime: Text; ReceivedDateTime: Text; Subject: Text; Sender: Text; ToRecipient: Text; CcRecipient: Text)
    var
        ToRecipientList: List of [Text];
        CcRecipientList: List of [Text];
    begin
        if ToRecipient <> '' then
            ToRecipientList.Add(ToRecipient);
        if CcRecipient <> '' then
            CcRecipientList.Add(CcRecipient);
        AddMessageToInbox(Id, InternetMessageId, WebLink, IsDraft, SentDateTime, ReceivedDateTime, Subject, Sender, ToRecipientList, CcRecipientList);
    end;

    internal procedure AddMessageToInbox(Id: Text; InternetMessageId: Text; WebLink: Text; IsDraft: Boolean; SentDateTime: Text; ReceivedDateTime: Text; Subject: Text; Sender: Text; var ToRecipientList: List of [Text]; var CcRecipientList: List of [Text])
    var
        JsonText: Text;
    begin
        JsonText := GetMessageJsonText(Id, InternetMessageId, WebLink, IsDraft, SentDateTime, ReceivedDateTime, Subject, Sender, ToRecipientList, CcRecipientList);
        InboxDictionary.Add(Id, JsonText);
    end;

    internal procedure GetArchivedMessage(MessageId: Text; var EmailLoggingMessage: Codeunit "Email Logging Message"): Boolean
    var
        JsonObject: JsonObject;
        JsonText: Text;
    begin
        if not IsMessageArchived(MessageId) then
            exit(false);
        JsonText := ArchiveDictionary.Get('+' + MessageId);
        JsonObject.ReadFrom(JsonText);
        EmailLoggingMessage.Initialize(JsonObject);
        exit(true);
    end;

    internal procedure IsMessageArchived(MessageId: Text): Boolean
    begin
        exit(ArchiveDictionary.ContainsKey('+' + MessageId) and
            (not InboxDictionary.ContainsKey(MessageId)) and
            (not DeletedItemsDictionary.ContainsKey('-' + MessageId)));
    end;

    internal procedure IsMessageDeleted(MessageId: Text): Boolean
    begin
        exit(DeletedItemsDictionary.ContainsKey('-' + MessageId) and
            (not InboxDictionary.ContainsKey(MessageId)) and
            (not ArchiveDictionary.ContainsKey('-' + MessageId)));
    end;

    internal procedure GetMessages(AccessToken: Text; UserEmail: Text; MaxCount: Integer; var MessagesJsonObject: JsonObject)
    var
        JsonText: Text;
        Message: Text;
        Number: Integer;
    begin
        Number := 0;
        JsonText := '{"value":[';
        foreach Message in InboxDictionary.Values() do begin
            if Number > 0 then
                JsonText += ',';
            JsonText += Message;
            Number += 1;
        end;
        JsonText += ']}';
        MessagesJsonObject.ReadFrom(JsonText);
    end;

    internal procedure GetMessage(AccessToken: Text; UserEmail: Text; MessageId: Text; var MessagesJsonObject: JsonObject)
    var
        JsonText: Text;
    begin
        if not InboxDictionary.ContainsKey(MessageId) then
            Error('');
        JsonText := InboxDictionary.Get(MessageId);
        MessagesJsonObject.ReadFrom(JsonText);
    end;

    internal procedure DeleteMessage(AccessToken: Text; UserEmail: Text; MessageId: Text)
    var
        SourceMessage: Text;
        TargetMessage: Text;
        TargetMessageId: Text;
    begin
        if not InboxDictionary.ContainsKey(MessageId) then
            exit;
        SourceMessage := InboxDictionary.Get(MessageId);
        InboxDictionary.Remove(MessageId);
        TargetMessageId := '-' + MessageId;
        TargetMessage := SourceMessage.Replace('"id":"' + MessageId + '"', '"id":"' + TargetMessageId + '"');
        DeletedItemsDictionary.Add(TargetMessageId, TargetMessage);
    end;

    internal procedure ArchiveMessage(AccessToken: Text; UserEmail: Text; MessageId: Text; var TargetMessageJsonObject: JsonObject)
    var
        SourceMessage: Text;
        TargetMessage: Text;
        TargetMessageId: Text;
    begin
        if not InboxDictionary.ContainsKey(MessageId) then
            Error('');
        SourceMessage := InboxDictionary.Get(MessageId);
        InboxDictionary.Remove(MessageId);
        TargetMessageId := '+' + MessageId;
        TargetMessage := SourceMessage.Replace('"id":"' + MessageId + '"', '"id":"' + TargetMessageId + '"');
        ArchiveDictionary.Add(TargetMessageId, TargetMessage);
        TargetMessageJsonObject.ReadFrom(TargetMessage);
    end;

    local procedure GetMessageJsonText(Id: Text; InternetMessageId: Text; WebLink: Text; IsDraft: Boolean; SentDateTime: Text; ReceivedDateTime: Text; Subject: Text; Sender: Text; var ToRecipientList: List of [Text]; var CcRecipientList: List of [Text]): Text
    var
        JsonText: Text;
    begin

        JsonText += '{';
        JsonText += '"id":"' + Id + '",';
        JsonText += '"internetMessageId":"' + InternetMessageId + '",';
        JsonText += '"webLink":"' + WebLink + '",';
        if IsDraft then
            JsonText += '"isDraft":true,'
        else
            JsonText += '"isDraft":false,';
        JsonText += '"subject":"' + Subject + '",';
        JsonText += '"sentDateTime":"' + SentDateTime + '",';
        JsonText += '"receivedDateTime":"' + ReceivedDateTime + '",';
        JsonText += '"sender":' + GetEmailAddressJsonText(Sender) + ',';
        JsonText += '"toRecipients":' + GetEmailAddressJsonText(ToRecipientList) + ',';
        JsonText += '"ccRecipients":' + GetEmailAddressJsonText(CcRecipientList);
        JsonText += '}';
        exit(JsonText);
    end;

    local procedure GetEmailAddressJsonText(var AddressList: List of [Text]): Text
    var
        JsonText: Text;
        Address: Text;
        Number: Integer;
    begin
        Number := 0;
        JsonText := '[';
        foreach Address in AddressList do begin
            if Number > 0 then
                JsonText += ',';
            JsonText += GetEmailAddressJsonText(Address);
            Number += 1;
        end;
        JsonText += ']';
        exit(JsonText);
    end;

    local procedure GetEmailAddressJsonText(Address: Text): Text
    var
        JsonText: Text;
        Name: Text;
        AtPos: Integer;
    begin
        AtPos := Address.IndexOf('@');
        if AtPos > 1 then
            Name := Address.Substring(1, AtPos - 1)
        else
            Name := Address;
        JsonText := '{"emailAddress":{"name":"' + Name + '","address":"' + Address + '"}}';
        exit(JsonText);
    end;
}