// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Telemetry;

/// <summary>
/// A wrapper on top of Session.LogMessage that allows for having additional common custom dimensions emitted with every message.
/// </summary>
/// <remarks>
/// Every publisher needs to have an implementation of the "Telemetry Logger" interface and a subscriber 
/// to "Telemetry Loggers".OnRegisterTelemetryLogger event in one of their apps in order for this codeunit
/// to work as expected (see "System Telemetry Logger" codeunit or example below).
/// </remarks>
/// <example>
/// codeunit 50000 "PTE Telemetry Logger" implements "Telemetry Logger"
/// {
///    Access = Internal;
///
///    procedure LogMessage(EventId: Text; Message: Text; Verbosity: Verbosity; DataClassification: DataClassification; TelemetryScope: TelemetryScope; CustomDimensions: Dictionary of [Text, Text])
///    begin
///        Session.LogMessage(EventId, Message, Verbosity, DataClassification, TelemetryScope, CustomDimensions);
///    end;
///
///    // For the functionality to behave as expected, there should be exactly one implementation of the "Telemetry Logger" interface registered per app publisher
///    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Telemetry Loggers", 'OnRegisterTelemetryLogger', '', true, true)]
///    local procedure OnRegisterTelemetryLogger(var Sender: Codeunit "Telemetry Loggers")
///    var
///        TelemetryLogger: Codeunit "PTE Telemetry Logger";
///    begin
///        Sender.Register(TelemetryLogger);
///    end;
/// }
/// </example>
codeunit 8711 "Telemetry"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        TelemetryImpl: Codeunit "Telemetry Impl.";

    /// <summary>
    /// Logs a telemetry message.
    /// </summary>
    /// <param name="EventId">A unique identifier of the telemetry message.</param>
    /// <param name="Message">The main content of the telemetry message (typically contains text that can be easily read by a person).</param>
    /// <param name="Verbosity">The verbosity of the telemetry message.</param>
    /// <param name="DataClassification">The data classification of the telemetry message.</param>
    /// <param name="TelemetryScope">The telemetry scope of the message.</param>
    /// <param name="CustomDimensions">Any additional information provided together with the telemetry message.</param>
    procedure LogMessage(EventId: Text; Message: Text; Verbosity: Verbosity; DataClassification: DataClassification; TelemetryScope: TelemetryScope; CustomDimensions: Dictionary of [Text, Text])
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        TelemetryImpl.LogMessage(EventId, Message, Verbosity, DataClassification, TelemetryScope, CustomDimensions, CallerModuleInfo);
    end;

    /// <summary>
    /// Logs a telemetry message.
    /// </summary>
    /// <param name="EventId">A unique identifier of the telemetry message.</param>
    /// <param name="Message">The main content of the telemetry message (typically contains text that can be easily read by a person).</param>
    /// <param name="Verbosity">The verbosity of the telemetry message.</param>
    /// <param name="DataClassification">The data classification of the telemetry message.</param>
    /// <param name="TelemetryScope">The telemetry scope of the message.</param>
    procedure LogMessage(EventId: Text; Message: Text; Verbosity: Verbosity; DataClassification: DataClassification; TelemetryScope: TelemetryScope)
    var
        DummyCustomDimensions: Dictionary of [Text, Text];
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        TelemetryImpl.LogMessage(EventId, Message, Verbosity, DataClassification, TelemetryScope, DummyCustomDimensions, CallerModuleInfo);
    end;

    /// <summary>
    /// Logs a telemetry message.
    /// </summary>
    /// <param name="EventId">A unique identifier of the telemetry message.</param>
    /// <param name="Message">The main content of the telemetry message (typically contains text that can be easily read by a person).</param>
    /// <param name="Verbosity">The verbosity of the telemetry message.</param>
    /// <param name="DataClassification">The data classification of the telemetry message.</param>
    procedure LogMessage(EventId: Text; Message: Text; Verbosity: Verbosity; DataClassification: DataClassification)
    var
        DummyCustomDimensions: Dictionary of [Text, Text];
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        TelemetryImpl.LogMessage(EventId, Message, Verbosity, DataClassification, TelemetryScope::ExtensionPublisher, DummyCustomDimensions, CallerModuleInfo);
    end;
}

