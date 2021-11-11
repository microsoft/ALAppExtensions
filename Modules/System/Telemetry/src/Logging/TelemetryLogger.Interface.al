// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The interface that allows 3d party extensions to emit telemetry to their own telemetry stores when the Telemetry codeunit is used.
/// </summary>
/// <example>
/// codeunit 50100 "My Telemetry Logger" implements "Telemetry Logger"
/// {
///     Access = Internal;
///
///     procedure LogMessage(EventId: Text; Message: Text; Verbosity: Verbosity; DataClassification: DataClassification; TelemetryScope: TelemetryScope; CustomDimensions: Dictionary of [Text, Text])
///     begin
///         Session.LogMessage(EventId, Message, Verbosity, DataClassification, TelemetryScope, CustomDimensions);
///     end;
/// }
/// </example>
interface "Telemetry Logger"
{
    /// <summary>
    /// Logs a telemetry message.
    /// </summary>
    /// <param name="EventId">A unique identifier of the telemetry message.</param>
    /// <param name="Message">The main content of the telemetry message (typically contains text that can be easily read by a person).</param>
    /// <param name="Verbosity">The verbosity of the telemetry message.</param>
    /// <param name="DataClassification">The data classification of the telemetry message.</param>
    /// <param name="TelemetryScope">The telemetry scope of the message.</param>
    /// <param name="CustomDimensions">Any additional information provided together with the telemetry message.</param>
    procedure LogMessage(EventId: Text; Message: Text; Verbosity: Verbosity; DataClassification: DataClassification; TelemetryScope: TelemetryScope; CustomDimensions: Dictionary of [Text, Text]);
}