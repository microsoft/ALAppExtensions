// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Device.UniversalPrint;

using System.Environment;
using System.Telemetry;
using System.Utilities;

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
        FileNameWithExtension: Text;
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

        if ObjectPayload.Get('objectname', PropertyBag) then
            FileName := PropertyBag.AsValue().AsText();

        if ObjectPayload.Get('documenttype', PropertyBag) then
            DocumentType := PropertyBag.AsValue().AsText();

        FileNameWithExtension := this.GetFileNameWithExtension(FileName, DocumentType);

        Success := this.SendPrintJob(UniversalPrinterSettings, DocumentStream, FileNameWithExtension, DocumentType);
    end;

    procedure SendPrintJob(UniversalPrinterSettings: Record "Universal Printer Settings"; DocumentInStream: InStream; FileNameWithExtension: Text; DocumentType: Text): Boolean
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
    begin
        if UniversalPrinterSettings.IsEmpty() then
            exit(false);

        if DocumentType = '' then
            exit(false);

        if FileNameWithExtension = '' then
            exit(false);

        this.FeatureTelemetry.LogUptake('0000GFX', this.UniversalPrintGraphHelper.GetUniversalPrintFeatureTelemetryName(), Enum::"Feature Uptake Status"::Used);

        // check if the printer is shared to user
        if not UniversalPrinterSetup.PrintShareExists(UniversalPrinterSettings."Print Share ID") then begin
            if GuiAllowed() then
                Message(this.NoAccessToPrinterErr, UniversalPrinterSettings.Name);
            Session.LogMessage('0000EFB', this.PrintShareNotFoundTelemetryTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', this.UniversalPrintGraphHelper.GetUniversalPrintTelemetryCategory());
            exit(false);
        end;

        TempBlob.CreateOutStream(DocumentOutStream);
        CopyStream(DocumentOutStream, DocumentInStream);
        Size := TempBlob.Length();

        // https://go.microsoft.com/fwlink/?linkid=2206361
        // check the maximum bytes in any given request is less than 10 MB.
        if Size > this.MaximumRequestSizeInBytes() then begin
            if GuiAllowed() then
                Message(this.PrintJobTooLargeErr);
            Session.LogMessage('0000EJX', strSubstNo(this.PrintJobTooLargeTelemetryTxt, Size), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', this.UniversalPrintGraphHelper.GetUniversalPrintTelemetryCategory());
            exit(false);
        end;

        // TODO: Split larger upload requests.
        // create a print job and store the resulting Job ID and Document ID.
        if not this.UniversalPrintGraphHelper.CreatePrintJobRequest(UniversalPrinterSettings, JobID, DocumentID, ErrorMessage) then begin
            if GuiAllowed() then
                Message(this.UnableToCreateJobErr, ErrorMessage);
            Session.LogMessage('0000EFC', this.PrintJobNotCreatedTelemetryTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', this.UniversalPrintGraphHelper.GetUniversalPrintTelemetryCategory());
            exit(false);
        end;

        // create an upload session
        if not this.UniversalPrintGraphHelper.CreateUploadSessionRequest(UniversalPrinterSettings."Print Share ID", FileNameWithExtension, DocumentType, Size, JobID, DocumentID, UploadUrl, ErrorMessage) then begin
            if GuiAllowed() then
                Message(this.UnableToUploadDocErr, JobID, ErrorMessage);
            Session.LogMessage('0000EFZ', strSubstNo(this.PrintJobUploadSessionNotCreatedTxt, JobID, Size), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', this.UniversalPrintGraphHelper.GetUniversalPrintTelemetryCategory());
            exit(false);
        end;

        // upload document data to the document.
        if not this.UniversalPrintGraphHelper.UploadDataRequest(UniversalPrinterSettings."Print Share ID", UploadUrl, TempBlob, 0, Size - 1, Size, JobID, DocumentID, ErrorMessage) then begin
            if GuiAllowed() then
                Message(this.UnableToUploadDocErr, JobID, ErrorMessage);
            Session.LogMessage('0000EFD', strSubstNo(this.PrintJobNotUploadedTelemetryTxt, JobID, Size), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', this.UniversalPrintGraphHelper.GetUniversalPrintTelemetryCategory());
            exit(false);
        end;

        // Start the print job.
        if not this.UniversalPrintGraphHelper.StartPrintJobRequest(UniversalPrinterSettings."Print Share ID", JobID, JobStateDescription, ErrorMessage) then begin
            if GuiAllowed() then
                Message(this.UnableToStartJobErr, JobID, ErrorMessage);
            Session.LogMessage('0000EFE', strSubstNo(this.PrintJobNotStartedTxt, JobID, Size), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', this.UniversalPrintGraphHelper.GetUniversalPrintTelemetryCategory());
            exit(false);
        end;

        this.FeatureTelemetry.LogUsage('0000GFY', this.UniversalPrintGraphHelper.GetUniversalPrintFeatureTelemetryName(), 'Universal Print Job Sent');
        Session.LogMessage('0000FSY', this.JobSentTelemtryTxt, Verbosity::Verbose, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', this.UniversalPrintGraphHelper.GetUniversalPrintTelemetryCategory());
        exit(true);
    end;

    local procedure MaximumRequestSizeInBytes(): Integer
    begin
        exit(10485760); // 10 MB
    end;

    local procedure GetFileNameWithExtension(FileName: Text; DocumentType: Text): Text
    var
        DocumentTypeParts: List of [Text];
        FileExtension: Text;
    begin
        if FileName = '' then
            exit;

        if DocumentType = '' then
            exit;

        DocumentTypeParts := DocumentType.Split('/');
        FileExtension := DocumentTypeParts.Get(DocumentTypeParts.Count());

        if FileExtension = '' then
            exit;

        exit(FileName + '.' + FileExtension);
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
        PrintJobNotUploadedTelemetryTxt: Label 'Uploading Universal Print data for job %1 of size %2 failed.', Locked = true, Comment = '%1 = Print job ID, %2 = Size of the print job';
        PrintJobUploadSessionNotCreatedTxt: Label 'Creating Universal Print upload session for job %1 of size %2 failed.', Locked = true, Comment = '%1 = Print job ID, %2 = Size of the print job';
        PrintJobNotStartedTxt: Label 'Starting Universal Print job %1 of size %2 failed.', Locked = true, Comment = '%1 = Print job ID, %2 = Size of the print job';
        PrintJobTooLargeTelemetryTxt: Label 'The Universal Print job of size %1 is too large.', Locked = true, Comment = '%1 = Size of print job';
}