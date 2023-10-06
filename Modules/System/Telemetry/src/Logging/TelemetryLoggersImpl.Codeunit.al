// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Telemetry;

codeunit 8709 "Telemetry Loggers Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        CurrentTelemetryLogger: Interface "Telemetry Logger";
        CurrentPublisher: Text;
        IsLoggerFound: Boolean;
        MultipleTelemetryLoggersFoundErr: Label 'More than one telemetry logger has been registered for publisher %1.', Locked = true;
        NoPublisherErr: Label 'An app from publisher %1 is sending telemetry, but there is no registered telemetry logger for this publisher.', Locked = true;
        RichTelemetryUsedTxt: Label 'A 3rd party app from publisher %1 is using rich telemetry.', Locked = true;
        TelemetryLibraryCategoryTxt: Label 'TelemetryLibrary', Locked = true;
        FirstPartyPublisherTxt: Label 'Microsoft', Locked = true;

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
        if IsLoggerFound then begin
            TelemetryLogger := CurrentTelemetryLogger;
            if CurrentPublisher <> FirstPartyPublisherTxt then
                Session.LogMessage('0000HIW', StrSubstNo(RichTelemetryUsedTxt, CurrentPublisher), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryLibraryCategoryTxt);
        end else
            Session.LogMessage('0000G7K', StrSubstNo(NoPublisherErr, CurrentPublisher), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', TelemetryLibraryCategoryTxt);

        exit(IsLoggerFound);
    end;

    internal procedure SetCurrentPublisher(Publisher: Text)
    begin
        CurrentPublisher := Publisher;
    end;
}