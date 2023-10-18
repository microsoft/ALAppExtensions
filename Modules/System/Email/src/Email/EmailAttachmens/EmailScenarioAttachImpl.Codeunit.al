// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

codeunit 8902 "Email Scenario Attach Impl."
{
    Access = Internal;
    InherentPermissions = X;
    InherentEntitlements = X;
    Permissions = tabledata "Email Attachments" = rimd,
                  tabledata "Email Scenario Attachments" = rimd;

    var
        ConfirmUploadEmailQst: Label 'Do you want to add the selected attachments?';
        ConfirmUploadNotDefaultToListQst: Label 'This page is for adding additional, non-default attachments to the scenario. Do you want to add an attachment?';
        AddeFileToScenariosMsg: Label 'Add attachment to selected email scenario';
        AddFileToCurrentScenarioMsg: Label 'Add attachment to current email scenario';

    procedure GetEmailAttachmentsByEmailScenarios(var Result: Record "Email Attachments"; EmailScenario: Integer)
    var
        EmailScenarioAttachments: Record "Email Scenario Attachments";
        Email: Codeunit "Email";
    begin
        Email.OnBeforeGetEmailAttachmentsByEmailScenarios(EmailScenarioAttachments);
        if EmailScenario <> 0 then
            EmailScenarioAttachments.SetRange(Scenario, Enum::"Email Scenario".FromInteger(EmailScenario));

        SetEmailScenarioAttachment(Result, EmailScenarioAttachments);
    end;

    procedure DeleteScenarioAttachments(var EmailAttachments: Record "Email Attachments"; var EmailScenarioAttachments: Record "Email Scenario Attachments"): Boolean
    var
        CountNumber: Integer;
        Count: Integer;
    begin
        CountNumber := EmailAttachments.Count();
        if not EmailScenarioAttachments.FindSet() then
            exit(false);

        for Count := 1 to CountNumber do
            if EmailAttachments.FindFirst() then
                if EmailScenarioAttachments.Get(EmailAttachments.Id) then begin
                    EmailScenarioAttachments.Delete();
                    EmailAttachments.Get(EmailAttachments.Id);
                    EmailAttachments.Delete();
                end;
        exit(true);
    end;

    procedure SetEmailScenarioAttachmentStatus(var EmailScenarioAttachments: Record "Email Scenario Attachments"; EmailAttachmentId: BigInteger; EmailDefaultAttachmentStatus: Boolean)
    begin
        if EmailScenarioAttachments.Get(EmailAttachmentId) then begin
            EmailScenarioAttachments.AttachmentDefaultStatus := EmailDefaultAttachmentStatus;
            EmailScenarioAttachments.Modify();
        end;
    end;

    procedure UploadAttachmentsConfirm(var EmailAttachments: Record "Email Scenario Attachments"; Confirm: Boolean): Boolean
    begin
        if Confirm then
            if not Confirm(ConfirmUploadEmailQst, true) then
                exit(false);

        exit(true);
    end;

    procedure UploadNotDefutAttachmentsToListConfirm(Confirm: Boolean): Boolean
    begin
        if Confirm then
            if not Confirm(ConfirmUploadNotDefaultToListQst, true) then
                exit(false);

        exit(true);
    end;

    procedure SetEmailScenarioAttachment(var Result: Record "Email Attachments"; var EmailScenarioAttachments: Record "Email Scenario Attachments")
    begin
        Result.Reset();
        Result.DeleteAll();

        if EmailScenarioAttachments.FindSet() then
            repeat
                Result.TransferFields(EmailScenarioAttachments);
                Result.Insert();
            until EmailScenarioAttachments.Next() = 0;
    end;

    procedure AddAttachmentToMessage(var Message: Codeunit "Email Message"; CurrentEmailScenario: Enum "Email Scenario")
    var
        EmailAttachments: Record "Email Attachments";
        AttachmentsCount: Integer;
    begin
        if CurrentEmailScenario.AsInteger() <> 0 then begin
            GetEmailAttachmentsByEmailScenarios(EmailAttachments, CurrentEmailScenario.AsInteger());
            EmailAttachments.SetRange(AttachmentDefaultStatus, true);
            AttachmentsCount := EmailAttachments.Count();
            if AttachmentsCount > 0 then
                Message.AddAttachmentFromScenario(EmailAttachments);
        end;

    end;

    procedure AddAttachmentToScenarios(EmailScenarioAttachments: Record "Email Scenario Attachments"; var EmailAttachments: Record "Email Attachments"; var SelectedScenarios: Record "Email Account Scenario")
    var
        EmailScenario: Integer;
        FileName: Text;
        Instream: Instream;
    begin
        if not SelectedScenarios.FindSet() then
            exit;

        ClearLastError();
        if not UploadIntoStream(AddeFileToScenariosMsg, '', '', FileName, Instream) then
            Error(GetLastErrorText());

        repeat
            EmailScenario := SelectedScenarios.Scenario;
            AddAttachmentToSelectedScenario(EmailScenarioAttachments, EmailAttachments, EmailScenario, Instream, FileName);
        until SelectedScenarios.Next() = 0;
    end;

    procedure AddAttachmentToSelectedScenario(EmailScenarioAttachments: Record "Email Scenario Attachments"; var EmailAttachments: Record "Email Attachments"; EmailScenario: Integer; Instream: InStream; FileName: Text)
    begin
        EmailScenarioAttachments."Attachment Name" := CopyStr(FileName, 1, 250);
        EmailScenarioAttachments."Email Attachment".ImportStream(Instream, FileName);
        EmailScenarioAttachments.Scenario := Enum::"Email Scenario".FromInteger(EmailScenario);
        EmailScenarioAttachments.AttachmentDefaultStatus := false;
        EmailScenarioAttachments.Insert();
        InsertEmailAttachments(EmailScenarioAttachments, EmailAttachments, EmailScenario);
    end;

    procedure AddAttachment(var EmailScenarioAttachments: Record "Email Scenario Attachments"; var EmailAttachments: Record "Email Attachments"; EmailScenario: Integer)
    var
        FileName: Text;
        Instream: Instream;
    begin
        ClearLastError();
        if not UploadIntoStream(AddFileToCurrentScenarioMsg, '', '', FileName, Instream) then
            Error(GetLastErrorText());

        EmailScenarioAttachments."Attachment Name" := CopyStr(FileName, 1, 250);
        EmailScenarioAttachments."Email Attachment".ImportStream(Instream, FileName);
        EmailScenarioAttachments.Scenario := Enum::"Email Scenario".FromInteger(EmailScenario);
        EmailScenarioAttachments.AttachmentDefaultStatus := false;
        EmailScenarioAttachments.Insert();
        InsertEmailAttachments(EmailScenarioAttachments, EmailAttachments, EmailScenario);
    end;

    local procedure InsertEmailAttachments(EmailScenarioAttachments: Record "Email Scenario Attachments"; var EmailAttachment: Record "Email Attachments"; EmailScenario: Integer)
    begin
        EmailAttachment.Id := EmailScenarioAttachments.Id;
        EmailAttachment."Attachment Name" := EmailScenarioAttachments."Attachment Name";
        EmailAttachment."Email Attachment" := EmailScenarioAttachments."Email Attachment";
        EmailAttachment.AttachmentDefaultStatus := EmailScenarioAttachments.AttachmentDefaultStatus;
        EmailAttachment.Scenario := Enum::"Email Scenario".FromInteger(EmailScenario);
        EmailAttachment.Insert();
    end;

}