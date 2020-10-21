// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
///  Handels the OnDocumentPrintReady event for Email Printers
/// </summary>
codeunit 2651 "Document Print Ready"
{
    EventSubscriberInstance = StaticAutomatic;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reporting Triggers", 'OnDocumentPrintReady', '', true, true)]
    procedure OnDocumentPrintReady(ObjectType: Option "Report","Page"; ObjectId: Integer; ObjectPayload: JsonObject; DocumentStream: InStream; var Success: Boolean);
    var
        EmailPrinterSettings: Record "Email Printer Settings";
        MailManagement: Codeunit "Mail Management";
        PrinterNameToken: JsonToken;
        PrinterName: Text[250];
        ToList: List of [Text];
        FileExtension: Text;
        AttachmentName: Text[250];
    begin
        // exit if handled already
        if Success then
            exit;

        // exit if not report
        if ObjectType <> ObjectType::Report then
            exit;

        // exit if not email printer
        if ObjectPayload.Get('printername', PrinterNameToken) then
            PrinterName := CopyStr(PrinterNameToken.AsValue().AsText(), 1, MaxStrLen(PrinterName));
        if not EmailPrinterSettings.Get(PrinterName) then
            exit;

        // exit if printer email adress is empty
        if EmailPrinterSettings."Email Address" = '' then begin
            if GuiAllowed() then
                Message(PrinterEmailNotSetupErr, PrinterName);
            Session.LogMessage('0000BGJ', PrinterEmailNotSetupTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailPrinterTelemetryCategoryTok);
            exit;
        end;

        // get recipient list and attachment name
        MailManagement.CheckValidEmailAddress(EmailPrinterSettings."Email Address");
        ToList.Add(EmailPrinterSettings."Email Address");
        GetAttachmentName(ObjectPayload, AttachmentName);

        // handle success parameter by sending email
        Success := SendEmail(ToList, EmailPrinterSettings."Email Subject", EmailPrinterSettings."Email Body", DocumentStream, AttachmentName, PrinterName);
    end;

    local procedure GetAttachmentName(ObjectPayload: JsonObject; var AttachmentName: Text[250])
    var
        FileName: Text;
        PrinterName: Text[250];
        DocumentTypeParts: List of [Text];
        ToList: List of [Text];
        FileExtension: Text;
        ObjectName: JsonToken;
        DocumentType: JsonToken;
    begin
        If ObjectPayload.Get('objectname', ObjectName) then
            FileName := ObjectName.AsValue().AsText();
        If ObjectPayload.Get('documenttype', DocumentType) then begin
            DocumentTypeParts := DocumentType.AsValue().AsText().Split('/');
            FileExtension := DocumentTypeParts.Get(DocumentTypeParts.Count());
        end;
        AttachmentName := CopyStr(FileName + '.' + FileExtension, 1, MaxStrLen(AttachmentName));
    end;

    local procedure SendEmail(ToList: List of [Text]; EmailSubject: Text[250]; EmailBody: Text[2048]; DocumentStream: InStream; AttachmentName: Text[250]; PrinterName: Text[250]): Boolean
    var
        EmailFeature: Codeunit "Email Feature";
    begin
        if EmailFeature.IsEnabled() then
            exit(SendEmailByEmailFeature(ToList, EmailSubject, EmailBody, DocumentStream, AttachmentName));

        exit(SendEmailBySMTP(ToList, EmailSubject, EmailBody, DocumentStream, AttachmentName, PrinterName));
    end;

    local procedure SendEmailByEmailFeature(ToList: List of [Text]; EmailSubject: Text[250]; EmailBody: Text[2048]; DocumentStream: InStream; AttachmentName: Text[250]): Boolean
    var
        EmailAccount: Record "Email Account";
        Email: Codeunit Email;
        Message: Codeunit "Email Message";
        EmailFeature: Codeunit "Email Feature";
        EmailScenario: Codeunit "Email Scenario";
    begin
        // exit if email account is not set for Email Printer scenario
        if not EmailScenario.GetEmailAccount(Enum::"Email Scenario"::"Email Printer", EmailAccount) then begin
            if GuiAllowed() then
                Message(NoEmailAccountDefinedErr, Enum::"Email Scenario"::"Email Printer");
            Session.LogMessage('0000D6E', NoEmailAccountTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailPrinterTelemetryCategoryTok);
            exit(false);
        end;

        // create message
        Message.Create(ToList, EmailSubject, EmailBody, true);
        Message.AddAttachment(AttachmentName, 'Document', DocumentStream);
        ClearLastError();

        // exit if sending message fails
        if not Email.Send(Message, EmailAccount."Account Id", EmailAccount.Connector) then begin
            if GuiAllowed() then
                Message(SendErr, GetLastErrorText());
            Session.LogMessage('0000BGK', NotSentTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailPrinterTelemetryCategoryTok);
            exit(false);
        end;

        exit(true);
    end;

    local procedure SendEmailBySMTP(ToList: List of [Text]; EmailSubject: Text[250]; EmailBody: Text[2048]; DocumentStream: InStream; AttachmentName: Text[250]; PrinterName: Text[250]): Boolean
    var
        SMTPMail: Codeunit "SMTP Mail";
        MailManagement: Codeunit "Mail Management";
        SendFrom: Text[250];
    begin
        // exit if SMTP is not setup
        if not SetupPrinters.IsSMTPSetup() then begin
            if GuiAllowed() then
                Message(SetupSMTPErr, PrinterName);
            Session.LogMessage('0000BGH', SMTPNotSetupTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailPrinterTelemetryCategoryTok);
            exit(false);
        end;

        // exit if from adress is empty
        if MailManagement.TryGetSenderEmailAddress(SendFrom) then
            if SendFrom = '' then begin
                if GuiAllowed() then
                    Message(FromAddressWasNotFoundErr);
                Session.LogMessage('0000BGI', FromAddressNotSetupTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailPrinterTelemetryCategoryTok);
                exit(false);
            end;

        // create message
        SMTPMail.CreateMessage('', SendFrom, ToList, EmailSubject, EmailBody);
        SMTPMail.AddAttachmentStream(DocumentStream, AttachmentName);
        ClearLastError();

        // exit if sending message fails
        if not SMTPMail.Send() then begin
            if GuiAllowed() then
                Message(SendErr, SMTPMail.GetLastSendMailErrorText());
            Session.LogMessage('0000BGK', NotSentTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailPrinterTelemetryCategoryTok);
            exit(false);
        end;

        exit(true);
    end;

    var
        SetupPrinters: Codeunit "Setup Printers";
        SendErr: Label 'The email couldn''t be sent. %1', Comment = '%1 = a more detailed error message';
        PrinterEmailNotSetupErr: Label 'The email address of %1 printer is not configured. Please add the printer''s email address.', Comment = '%1 = Printer name.';
        FromAddressWasNotFoundErr: Label 'An email from address was not found.';
        NoEmailAccountDefinedErr: Label 'Email is not set up for the action you are trying to take. Ask your administrator to either add the %1 scenario to your email account, or to specify a default account for email scenarios.', Comment = '%1 = Email scenario. E.g. "Email Printer"';
        SetupSMTPErr: Label 'To send print job to the %1 printer, you must set up SMTP.', Comment = '%1 = Printer name.';
        EmailPrinterTelemetryCategoryTok: Label 'AL Email Printer', Locked = true;
        SMTPNotSetupTelemetryTxt: Label 'SMTP is not set up.', Locked = true;
        NoEmailAccountTxt: Label 'There is no account for the "Email Printer" scenario.', Locked = true;
        PrinterEmailNotSetupTelemetryTxt: Label 'The email address of the printer is missing', Locked = true;
        FromAddressNotSetupTelemetryTxt: Label 'The email address of the sender is missing.', Locked = true;
        NotSentTelemetryTxt: Label 'The email has not been sent to the printer.', Locked = true;
}