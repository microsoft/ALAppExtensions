// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8709 "Telemetry Loggers Impl."
{
    Access = Internal;

    var
        CurrentTelemetryLogger: Interface "Telemetry Logger";
        CurrentPublisher: Text;
        IsLoggerFound: Boolean;
        MultipleTelemetryLoggersFoundErr: Label 'More than one telemetry logger has been registered for publisher %1.', Locked = true;
        NoPublisherErr: Label 'An app from publisher %1 is sending telemetry, but there is no registered telemetry logger for this publisher.', Locked = true;
        TelemetryLibraryCategoryTxt: Label 'TelemetryLibrary', Locked = true;

    procedure Register(TelemetryLogger: Interface "Telemetry Logger"; Publisher: Text)
    begin
        if Publisher = CurrentPublisher then
            if not IsLoggerFound then begin
                CurrentTelemetryLogger := TelemetryLogger;
                IsLoggerFound := true;
            end else
                Session.LogMessage('0000G7J', StrSubstNo(MultipleTelemetryLoggersFoundErr, Publisher), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', TelemetryLibraryCategoryTxt)
    end;

    internal procedure GetTelemetryLogger(var TelemetryLogger: Interface "Telemetry Logger"): Boolean
    begin
        if IsLoggerFound then
            TelemetryLogger := CurrentTelemetryLogger
        else
            Session.LogMessage('0000G7K', StrSubstNo(NoPublisherErr, CurrentPublisher), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', TelemetryLibraryCategoryTxt);

        exit(IsLoggerFound);
    end;

    internal procedure SetCurrentPublisher(Publisher: Text)
    begin
        CurrentPublisher := Publisher;
    end;
}