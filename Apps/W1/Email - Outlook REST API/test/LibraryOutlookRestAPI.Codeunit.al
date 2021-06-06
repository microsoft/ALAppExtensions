// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139755 "Library - Outlook Rest API"
{
    var
        Assert: Codeunit "Library Assert";
        SubjectTxt: Label 'Test Subject', Locked = true;
        BodyTxt: Label 'Test Body', Locked = true;
        AttachmentTxt: Label 'Test Attachment', Locked = true;
        AttachemntContentTypeTxt: Label 'application/text', Locked = true;
        Attachment1Tok: Label 'Attachment1', Locked = true;
        Attachment2Tok: Label 'Attachment2', Locked = true;
        ToList: List of [Text];
        CCList: List of [Text];
        BCCList: List of [Text];
        IsInitialized: Boolean;

    procedure CreateEmailMessage(HtmlFormatted: Boolean; var Message: Codeunit "Email Message")
    var
        Base64Convert: Codeunit "Base64 Convert";
        TempBLob: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
    begin
        TempBLob.CreateOutStream(OutStream);
        OutStream.WriteText(AttachmentTxt);
        TempBLob.CreateInStream(InStream);

        Message.Create(ToList, SubjectTxt, BodyTxt, HtmlFormatted, CCList, BCCList);
        Message.AddAttachment(Attachment1Tok, AttachemntContentTypeTxt, Base64Convert.ToBase64(AttachmentTxt));
        Message.AddAttachment(Attachment2Tok, AttachemntContentTypeTxt, InStream);
    end;

    procedure VerifyEmailJson(Message: JsonObject; HtmlFormatted: Boolean)
    var
        Base64Convert: Codeunit "Base64 Convert";
        JToken: JsonToken;
        BodyJson: JsonObject;
        JArray: JsonArray;
        Index: Integer;
    begin
        VerifyJsonProperty(Message, 'saveToSentItems', 'true', 'Email message should be save on the send folder');

        Message.Get('message', JToken);
        Message := JToken.AsObject();

        VerifyJsonProperty(Message, 'subject', SubjectTxt, 'A different Subject was expected');

        Message.Get('body', JToken);
        BodyJson := JToken.AsObject();

        if HtmlFormatted then
            VerifyJsonProperty(BodyJson, 'contentType', 'HTML', 'Body content type was expected to be HTML')
        else
            VerifyJsonProperty(BodyJson, 'contentType', 'text', 'Body content type was expected to be text');

        Message.Get('toRecipients', JToken);
        JArray := JToken.AsArray();
        Assert.AreEqual(3, JArray.Count, 'Three addresses were expected');

        for Index := 1 to JArray.Count do begin
            JArray.Get(Index - 1, JToken);
            JToken.AsObject().Get('emailAddress', JToken);
            VerifyJsonProperty(JToken.AsObject(), 'address', ToList.Get(Index), 'A different email address was expected');
        end;

        Message.Get('ccRecipients', JToken);
        JArray := JToken.AsArray();
        Assert.AreEqual(3, JArray.Count, 'Three addresses were expected');

        for Index := 1 to JArray.Count do begin
            JArray.Get(Index - 1, JToken);
            JToken.AsObject().Get('emailAddress', JToken);
            VerifyJsonProperty(JToken.AsObject(), 'address', CCList.Get(Index), 'A different email address was expected');
        end;

        Message.Get('bccRecipients', JToken);
        JArray := JToken.AsArray();
        Assert.AreEqual(3, JArray.Count, 'Three addresses were expected');

        for Index := 1 to JArray.Count do begin
            JArray.Get(Index - 1, JToken);
            JToken.AsObject().Get('emailAddress', JToken);
            VerifyJsonProperty(JToken.AsObject(), 'address', BCCList.Get(Index), 'A different email address was expected');
        end;

        Message.Get('attachments', JToken);
        JArray := JToken.AsArray();
        Assert.AreEqual(2, JArray.Count, 'Two attachments were expected');

        JArray.Get(0, JToken);
        VerifyJsonProperty(JToken.AsObject(), '@odata.type', '#microsoft.graph.fileAttachment', 'A different value was expected');
        VerifyJsonProperty(JToken.AsObject(), 'name', Attachment1Tok, 'A different attachment name was expected');
        VerifyJsonProperty(JToken.AsObject(), 'contentType', AttachemntContentTypeTxt, 'A different attachment content type was expected');
        VerifyJsonProperty(JToken.AsObject(), 'isInline', 'false', 'Attachment was not expected to be inline');
        JToken.AsObject().Get('contentBytes', JToken);
        Assert.AreEqual(AttachmentTxt, Base64Convert.FromBase64(JToken.AsValue().AsText()), 'A different attachment content was expected');

        JArray.Get(1, JToken);
        VerifyJsonProperty(JToken.AsObject(), '@odata.type', '#microsoft.graph.fileAttachment', 'A different value was expected');
        VerifyJsonProperty(JToken.AsObject(), 'name', Attachment2Tok, 'A different attachment name was expected');
        VerifyJsonProperty(JToken.AsObject(), 'contentType', AttachemntContentTypeTxt, 'A different attachment content type was expected');
        VerifyJsonProperty(JToken.AsObject(), 'isInline', 'false', 'Attachment was not expected to be inline');
        JToken.AsObject().Get('contentBytes', JToken);
        Assert.AreEqual(AttachmentTxt, Base64Convert.FromBase64(JToken.AsValue().AsText()), 'A different attachment content was expected');
    end;

    procedure VerifyJsonProperty(Object: JsonObject; Property: Text; Expected: Text; Message: Text)
    var
        JToken: JsonToken;
    begin
        Object.Get(Property, JToken);
        Assert.AreEqual(Expected, JToken.AsValue().AsText(), Message);
    end;

    procedure Initialize()
    begin
        if IsInitialized then
            exit;
        ToList.Add('mail1@outlook.com');
        ToList.Add('mail2@outlook.com');
        ToList.Add('mail3@outlook.com');

        CCList.Add('mail3@outlook.com');
        CCList.Add('mail4@outlook.com');
        CCList.Add('mail5@outlook.com');

        BCCList.Add('mail6@outlook.com');
        BCCList.Add('mail7@outlook.com');
        BCCList.Add('mail8@outlook.com');

        IsInitialized := true;
    end;
}