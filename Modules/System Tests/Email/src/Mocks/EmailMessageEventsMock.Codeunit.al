// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Email;

using System.Email;
using System.Utilities;
codeunit 134852 "Email Message Events Mock"
{
    EventSubscriberInstance = Manual;

    var
        ModifySubject: Boolean;
        ModifyBody: Boolean;
        ModifyRecipients: Boolean;
        ModifyAttachments: Boolean;
        SubjectNewEmailLbl: Label 'This is a new email subject';
        BodyNewEmailLbl: Label 'This is a new email body';
        AttachmentNewEmailLbl: Label 'This is a new email attachment';

    procedure SetModifySubject(NewModifySubject: Boolean)
    begin
        ModifySubject := NewModifySubject;
    end;

    procedure SetModifyBody(NewModifyBody: Boolean)
    begin
        ModifyBody := NewModifyBody;
    end;

    procedure SetModifyRecipients(NewModifyRecipients: Boolean)
    begin
        ModifyRecipients := NewModifyRecipients;
    end;

    procedure SetModifyAttachments(NewModifyAttachments: Boolean)
    begin
        ModifyAttachments := NewModifyAttachments;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Email, 'OnBeforeOpenEmailEditor', '', false, false)]
    local procedure OnBeforeOpenEmailEditor(var EmailMessage: Codeunit "Email Message"; IsNewEmail: Boolean)
    begin
        Modify(EmailMessage);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Email, 'OnBeforeSendEmail', '', false, false)]
    local procedure OnBeforeSendEmail(var EmailMessage: Codeunit "Email Message")
    begin
        Modify(EmailMessage);
    end;

    local procedure Modify(var EmailMessage: Codeunit "Email Message")
    var
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
    begin
        if ModifySubject then
            EmailMessage.SetSubject(SubjectNewEmailLbl);

        if ModifyBody then
            EmailMessage.SetBody(BodyNewEmailLbl);

        if ModifyRecipients then
            EmailMessage.AddRecipient(Enum::"Email Recipient Type"::"To", 'test@newemail.com');

        if ModifyAttachments then begin
            TempBlob.CreateOutStream(OutStr);
            OutStr.WriteText(AttachmentNewEmailLbl);
            TempBlob.CreateInStream(InStr);
            EmailMessage.AddAttachment('EventAttachment.txt', 'text/plain', InStr);
        end;
    end;
}