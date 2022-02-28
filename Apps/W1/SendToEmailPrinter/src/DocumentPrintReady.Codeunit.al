// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
///  Handels the OnDocumentPrintReady event for Email Printers
/// </summary>
codeunit 2651 "Document Print Ready"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reporting Triggers", 'OnDocumentPrintReady', '', true, true)]
    procedure OnDocumentPrintReady(ObjectType: Option "Report","Page"; ObjectId: Integer; ObjectPayload: JsonObject; DocumentStream: InStream; var Success: Boolean);
    var
        EmailPrinterSettings: Record "Email Printer Settings";
        MailManagement: Codeunit "Mail Management";
        PrinterNameToken: JsonToken;
        PrinterName: Text[250];
        ToList: List of [Text];
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

        FeatureTelemetry.LogUptake('0000GG1', EmailPrinterFeatureTelemetryNameTxt, Enum::"Feature Uptake Status"::Used);

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
        Success := SendEmailByEmailFeature(ToList, EmailPrinterSettings."Email Subject", EmailPrinterSettings."Email Body", DocumentStream, AttachmentName);

        if Success then
            FeatureTelemetry.LogUsage('0000GG2', EmailPrinterFeatureTelemetryNameTxt, 'Send To Email Print Job Sent');
    end;

    local procedure GetAttachmentName(ObjectPayload: JsonObject; var AttachmentName: Text[250])
    var
        FileName: Text;
        DocumentTypeParts: List of [Text];
        FileExtension: Text;
        ObjectName: JsonToken;
        DocumentType: JsonToken;
    begin
        if ObjectPayload.Get('objectname', ObjectName) then
            FileName := ObjectName.AsValue().AsText();
        if ObjectPayload.Get('documenttype', DocumentType) then begin
            DocumentTypeParts := DocumentType.AsValue().AsText().Split('/');
            FileExtension := DocumentTypeParts.Get(DocumentTypeParts.Count());
        end;
        AttachmentName := CopyStr(FileName + '.' + FileExtension, 1, MaxStrLen(AttachmentName));
    end;

    local procedure SendEmailByEmailFeature(ToList: List of [Text]; EmailSubject: Text[250]; EmailBody: Text[2048]; DocumentStream: InStream; AttachmentName: Text[250]): Boolean
    var
        EmailAccount: Record "Email Account";
        Email: Codeunit Email;
        Message: Codeunit "Email Message";
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

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SendErr: Label 'The email couldn''t be sent. %1', Comment = '%1 = a more detailed error message';
        PrinterEmailNotSetupErr: Label 'The email address of %1 printer is not configured. Please add the printer''s email address.', Comment = '%1 = Printer name.';
        NoEmailAccountDefinedErr: Label 'Email is not set up for the action you are trying to take. Ask your administrator to either add the %1 scenario to your email account, or to specify a default account for email scenarios.', Comment = '%1 = Email scenario. E.g. "Email Printer"';
        EmailPrinterTelemetryCategoryTok: Label 'AL Email Printer', Locked = true;
        EmailPrinterFeatureTelemetryNameTxt: Label 'Send to Email Print', Locked = true;
        NoEmailAccountTxt: Label 'There is no account for the "Email Printer" scenario.', Locked = true;
        PrinterEmailNotSetupTelemetryTxt: Label 'The email address of the printer is missing', Locked = true;
        NotSentTelemetryTxt: Label 'The email has not been sent to the printer.', Locked = true;
}