// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality for adding common custom dimensions to telemetry.
/// </summary>
/// <remarks>This codeunit is only intended to be used from subscribers of <see cref="OnAddCommonCustomDimensions"/> event.</remarks>
codeunit 8706 "Telemetry Custom Dimensions"
{
    Access = Public;

    var
        TelemetryCustomDimsImpl: Codeunit "Telemetry Custom Dims Impl.";

    /// <summary>
    /// Add a custom dimension for every telemetry message. Is used in conjunction with <see cref="OnAddCommonCustomDimensions"/>
    /// </summary>
    /// <param name="CustomDimensionName">The name of the custom dimension.</param>
    /// <param name="CustomDimensionValue">The value of the custom dimension.</param>
    /// <remarks>Only system metadata classified information should be added here as these custom dimensions will be used for all telemetry messages.</remarks>
    procedure AddCommonCustomDimension(CustomDimensionName: Text; CustomDimensionValue: Text)
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        TelemetryCustomDimsImpl.AddCommonCustomDimension(CustomDimensionName, CustomDimensionValue, CallerModuleInfo.Publisher);
    end;

    /// <summary>
    /// Allows to provide additional custom dimensions for every telemetry message. Is used in conjunction with <see cref="AddCommonCustomDimensions"/>.
    /// </summary>
    /// <remarks>Global language is set to default for the subscribers of this event.</remarks>
    /// <example>
    /// [EventSubscriber(ObjectType::Codeunit, Codeunit::"Telemetry Custom Dimensions", 'OnAddCommonCustomDimensions', '', true, true)]
    /// local procedure OnAddCommonCustomDimensions(var Sender: Codeunit "Telemetry Custom Dimensions")
    /// begin
    ///     Sender.AddCommonCustomDimension('CommonCustomDimension', 'Some info');
    /// end;
    /// </example>
    [IntegrationEvent(true, false)]
    internal procedure OnAddCommonCustomDimensions()
    begin
    end;

    internal procedure GetAdditionalCommonCustomDimensions(ForPublisher: Text): Dictionary of [Text, Text]
    begin
        exit(TelemetryCustomDimsImpl.GetAdditionalCommonCustomDimensions(ForPublisher));
    end;

    internal procedure AddAllowedCommonCustomDimensionPublisher(Publisher: Text)
    begin
        TelemetryCustomDimsImpl.AddAllowedCommonCustomDimensionPublisher(Publisher);
    end;

    internal procedure AddCommonCustomDimension(CustomDimensionName: Text; CustomDimensionValue: Text; Publisher: Text)
    begin
        TelemetryCustomDimsImpl.AddCommonCustomDimension(CustomDimensionName, CustomDimensionValue, Publisher);
    end;
}

