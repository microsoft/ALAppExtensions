// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
///  Handles the OnDocumentPrintReady event for Universal Printers
/// </summary>
codeunit 2751 "Universal Print Document Ready"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reporting Triggers", 'OnDocumentPrintReady', '', true, true)]
    local procedure OnDocumentPrintReady(ObjectType: Option "Report","Page"; ObjectId: Integer; ObjectPayload: JsonObject; DocumentStream: InStream; var Success: Boolean);
    var
        UniversalPrinterSettings: Record "Universal Printer Settings";
        PrinterNameToken: JsonToken;
        PropertyBag: JsonToken;
        PrinterName: Text[250];
        FileName: Text;
        DocumentType: Text;
        DocumentTypeParts: List of [Text];
        FileExtension: Text;
    begin
        // exit if handled already
        if Success then
            exit;

        // exit if not report
        if ObjectType <> ObjectType::Report then
            exit;

        // exit if not Universal Print printer
        if ObjectPayload.Get('printername', PrinterNameToken) then
            PrinterName := CopyStr(PrinterNameToken.AsValue().AsText(), 1, MaxStrLen(PrinterName));
        if not UniversalPrinterSettings.Get(PrinterName) then
            exit;

        FeatureTelemetry.LogUptake('0000GFX', UniversalPrintGraphHelper.GetUniversalPrintFeatureTelemetryName(), Enum::"Feature Uptake Status"::Used);

        if ObjectPayload.Get('objectname', PropertyBag) then
            FileName := PropertyBag.AsValue().AsText();
        if FileName = '' then
            exit;

        if ObjectPayload.Get('documenttype', PropertyBag) then
            DocumentType := PropertyBag.AsValue().AsText();
        if DocumentType = '' then
            exit;

        DocumentTypeParts := DocumentType.Split('/');
        FileExtension := DocumentTypeParts.Get(DocumentTypeParts.Count());
        Success := SendPrintJob(UniversalPrinterSettings, DocumentStream, FileName, FileExtension, DocumentType);
    end;

    internal procedure SendPrintJob(UniversalPrinterSettings: Record "Universal Printer Settings"; DocumentInStream: InStream; FileName: Text; FileExtension: Text; DocumentType: Text): Boolean
    var
        UniversalPrinterSetup: Codeunit "Universal Printer Setup";
        TempBlob: Codeunit "Temp Blob";
        DocumentOutStream: OutStream;
        Size: Integer;
        JobID: Text;
        DocumentID: Text;
        ErrorMessage: Text;
        UploadUrl: Text;
        JobStateDescription: Text;
        FileNameWithExtension: Text;
    begin

        // check if the printer is shared to user
        if not UniversalPrinterSetup.PrintShareExists(UniversalPrinterSettings."Print Share ID") then begin
            if GuiAllowed() then
                Message(NoAccessToPrinterErr, UniversalPrinterSettings.Name);
            Session.LogMessage('0000EFB', PrintShareNotFoundTelemetryTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UniversalPrintGraphHelper.GetUniversalPrintTelemetryCategory());
            exit(false);
        end;

        TempBlob.CreateOutStream(DocumentOutStream);
        CopyStream(DocumentOutStream, DocumentInStream);
        Size := TempBlob.Length();

        // https://docs.microsoft.com/en-us/graph/upload-data-to-upload-session
        // check the maximum bytes in any given request is less than 10 MB.
        if Size > MaximumRequestSizeInBytes() then begin
            if GuiAllowed() then
                Message(PrintJobTooLargeErr);
            Session.LogMessage('0000EJX', strSubstNo(PrintJobTooLargeTelemetryTxt, Size), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UniversalPrintGraphHelper.GetUniversalPrintTelemetryCategory());
            exit(false);
        end;

        // TODO: Split larger upload requests.
        // create a print job and store the resulting Job ID and Document ID.
        if not UniversalPrintGraphHelper.CreatePrintJobRequest(UniversalPrinterSettings, JobID, DocumentID, ErrorMessage) then begin
            if GuiAllowed() then
                Message(UnableToCreateJobErr, ErrorMessage);
            Session.LogMessage('0000EFC', PrintJobNotCreatedTelemetryTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UniversalPrintGraphHelper.GetUniversalPrintTelemetryCategory());
            exit(false);
        end;

        FileNameWithExtension := FileName + '.' + FileExtension;
        // create an upload session
        if not UniversalPrintGraphHelper.CreateUploadSessionRequest(UniversalPrinterSettings."Print Share ID", FileNameWithExtension, DocumentType, Size, JobID, DocumentID, UploadUrl, ErrorMessage) then begin
            if GuiAllowed() then
                Message(UnableToUploadDocErr, JobID, ErrorMessage);
            Session.LogMessage('0000EFZ', strSubstNo(PrintJobUploadSessionNotCreatedTxt, Size), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UniversalPrintGraphHelper.GetUniversalPrintTelemetryCategory());
            exit(false);
        end;

        // upload document data to the document.
        if not UniversalPrintGraphHelper.UploadDataRequest(UniversalPrinterSettings."Print Share ID", UploadUrl, TempBlob, 0, Size - 1, Size, JobID, DocumentID, ErrorMessage) then begin
            if GuiAllowed() then
                Message(UnableToUploadDocErr, JobID, ErrorMessage);
            Session.LogMessage('0000EFD', strSubstNo(PrintJobNotUploadedTelemetryTxt, Size), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UniversalPrintGraphHelper.GetUniversalPrintTelemetryCategory());
            exit(false);
        end;

        // Start the print job.
        if not UniversalPrintGraphHelper.StartPrintJobRequest(UniversalPrinterSettings."Print Share ID", JobID, JobStateDescription, ErrorMessage) then begin
            if GuiAllowed() then
                Message(UnableToStartJobErr, JobID, ErrorMessage);
            Session.LogMessage('0000EFE', PrintJobNotStartedTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UniversalPrintGraphHelper.GetUniversalPrintTelemetryCategory());
            exit(false);
        end;

        FeatureTelemetry.LogUsage('0000GFY', UniversalPrintGraphHelper.GetUniversalPrintFeatureTelemetryName(), 'Universal Print Job Sent');
        Session.LogMessage('0000FSY', JobSentTelemtryTxt, Verbosity::Verbose, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UniversalPrintGraphHelper.GetUniversalPrintTelemetryCategory());
        exit(true);
    end;

    local procedure MaximumRequestSizeInBytes(): Integer
    begin
        exit(10485760); // 10 MB
    end;

    var
        UniversalPrintGraphHelper: Codeunit "Universal Print Graph Helper";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        NoAccessToPrinterErr: Label 'You don''t have access to the printer %1.', Comment = '%1 = name of the printer';
        PrintJobTooLargeErr: Label 'Cannot send the print job because the size is too large. The size limit for print job is 10 MB.';
        UnableToCreateJobErr: Label 'The print job couldn''t be created.\\%1', Comment = '%1 = a more detailed error message';
        UnableToUploadDocErr: Label 'Could not upload the document to print job %1.\\%2', Comment = '%1 = a print job ID, %2 = a more detailed error message';
        UnableToStartJobErr: Label 'The print job %1 couldn''t be started.\\%2', Comment = '%1 = a print job ID, %2 = a more detailed error message';
        JobSentTelemtryTxt: Label 'The print job has been sent for processing in Universal Print.', Locked = true;
        PrintShareNotFoundTelemetryTxt: Label 'Universal Print share is not found.', Locked = true;
        PrintJobNotCreatedTelemetryTxt: Label 'Creating Universal Print job failed.', Locked = true;
        PrintJobNotUploadedTelemetryTxt: Label 'Uploading Universal Print job of size %1 failed.', Locked = true, Comment = '%1 = Size of print job';
        PrintJobUploadSessionNotCreatedTxt: Label 'Creating Universal Print job upload session of size %1 failed.', Locked = true, Comment = '%1 = Size of print job';
        PrintJobNotStartedTxt: Label 'Starting Universal Print job failed.', Locked = true;
        PrintJobTooLargeTelemetryTxt: Label 'The Universal Print job of size %1 is too large.', Locked = true, Comment = '%1 = Size of print job';
}