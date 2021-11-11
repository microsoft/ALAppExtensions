// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139486 "Error Telemetry Logger" implements "Telemetry Logger"
{
    EventSubscriberInstance = Manual;

    procedure LogMessage(EventId: Text; Message: Text; Verbosity: Verbosity; DataClassification: DataClassification; TelemetryScope: TelemetryScope; CustomDimensions: Dictionary of [Text, Text])
    begin
        Error('Error when logging telemetry.')
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Telemetry Loggers", 'OnRegisterTelemetryLogger', '', true, true)]
    local procedure OnRegisterTelemetryLogger(var Sender: Codeunit "Telemetry Loggers")
    var
        ErrorTelemetryLogger: Codeunit "Error Telemetry Logger";
    begin
        Sender.Register(ErrorTelemetryLogger, 'TestPublisher');
    end;
}

