// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139485 "Test Telemetry Logger" implements "Telemetry Logger"
{
    EventSubscriberInstance = Manual;

    var
        Assert: Codeunit "Library Assert";
        CurrentEventIdTxt: Label '0000ABC';
        CurrentMessageTxt: Label 'Test telemetry message';
        CommonCustomDimensionNameTxt: Label 'Test custom dimension name', Locked = true;
        CommonCustomDimensionValueTxt: Label 'Test custom dimension value', Locked = true;
        TestPublisherTxt: Label 'TestPublisher', Locked = true;

    procedure LogMessage(EventId: Text; Message: Text; Verbosity: Verbosity; DataClassification: DataClassification; TelemetryScope: TelemetryScope; CustomDimensions: Dictionary of [Text, Text])
    begin
        Assert.AreEqual(CurrentEventIdTxt, EventId, 'Unexpected telemetry message content.');
        Assert.AreEqual(CurrentMessageTxt, Message, 'Unexpected telemetry message content.');
        Assert.IsTrue(CustomDimensions.ContainsKey(CommonCustomDimensionNameTxt), 'The common custom dimension should have been a part of the telemetry message.');
        Assert.AreEqual(CommonCustomDimensionValueTxt, CustomDimensions.Get(CommonCustomDimensionNameTxt), 'The common custom dimension value is incorrect.');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Telemetry Loggers", 'OnRegisterTelemetryLogger', '', true, true)]
    local procedure OnRegisterTelemetryLogger(var Sender: Codeunit "Telemetry Loggers")
    var
        TestTelemetryLogger: Codeunit "Test Telemetry Logger";
    begin
        Sender.Register(TestTelemetryLogger, TestPublisherTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Telemetry Custom Dimensions", 'OnAddCommonCustomDimensions', '', true, true)]
    local procedure OnAddCommonCustomDimensions(var Sender: Codeunit "Telemetry Custom Dimensions")
    var
    begin
        Sender.AddCommonCustomDimension(CommonCustomDimensionNameTxt, CommonCustomDimensionValueTxt, TestPublisherTxt);
    end;
}

