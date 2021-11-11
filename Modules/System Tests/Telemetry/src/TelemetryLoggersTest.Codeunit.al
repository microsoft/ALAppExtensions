// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139484 "Telemetry Loggers Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
        CurrentEventIdTxt: Label '0000ABC';
        CurrentMessageTxt: Label 'Test telemetry message';
        TestPublisherTxt: Label 'TestPublisher', Locked = true;

    [Test]
    procedure TestCustomTelemetryLogger()
    var
        TelemetryImpl: Codeunit "Telemetry Impl.";
        TestTelemetryLogger: Codeunit "Test Telemetry Logger";
        EmptyCustomDimensions: Dictionary of [Text, Text];
    begin
        // [GIVEN] The test implementation of the telemetry logger interface is registered as the current implementation (see OnRegisterTelemetryLogger subscriber).
        BindSubscription(TestTelemetryLogger);

        // [WHEN] A telemetry message is logged via the Telemetry Codeunit.
        TelemetryImpl.LogMessageInternal(CurrentEventIdTxt, CurrentMessageTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, EmptyCustomDimensions, EmptyCustomDimensions, TestPublisherTxt);

        // [THEN] The correct information is passed to the inteface (verified in the LogMessage method).
    end;

    [Test]
    procedure TestTelemetryLoggerImplementationIsCalled()
    var
        TelemetryImpl: Codeunit "Telemetry Impl.";
        ErrorTelemetryLogger: Codeunit "Error Telemetry Logger";
        EmptyCustomDimensions: Dictionary of [Text, Text];
    begin
        // [GIVEN] The test implementation of the telemetry logger interface is registered as the current implementation (see OnRegisterTelemetryLogger subscriber).
        BindSubscription(ErrorTelemetryLogger);

        // [WHEN] A telemetry message is logged via the Telemetry Codeunit with an event ID that is not expected by the verification.
        asserterror TelemetryImpl.LogMessageInternal(CurrentEventIdTxt, CurrentMessageTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, EmptyCustomDimensions, EmptyCustomDimensions, TestPublisherTxt);

        // [THEN] The assertion fails, confirming that LogMessage is called when the subscribers are active.
        Assert.ExpectedError('Error when logging telemetry.');
    end;

    [Test]
    procedure TestNoLogger()
    var
        TelemetryImpl: Codeunit "Telemetry Impl.";
        EmptyCustomDimensions: Dictionary of [Text, Text];
    begin
        // [GIVEN] The test implementation of the telemetry logger interface is not registered as the current implementation.
        TelemetryImpl.LogMessageInternal('AnotherEventID', 'AnotherMessage', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, EmptyCustomDimensions, EmptyCustomDimensions, TestPublisherTxt);

        // [THEN] The implementation was not registered. No failures.
    end;
}

