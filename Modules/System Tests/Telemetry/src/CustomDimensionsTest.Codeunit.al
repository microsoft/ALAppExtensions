// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139482 "Custom Dimensions Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;

    var
        Assert: Codeunit "Library Assert";
        CommonCustomDimensionNameTxt: Label 'Test custom dimension name', Locked = true;
        CommonCustomDimensionValueTxt: Label 'Test custom dimension value', Locked = true;

    [Test]
    procedure TestAddCommonCustomDimension()
    var
        CustomDimensionsTest: Codeunit "Custom Dimensions Test";
        TelemetryCustomDimensions: Codeunit "Telemetry Custom Dimensions";
        CommonCustomDimensions: Dictionary of [Text, Text];
        CurrentModuleInfo: ModuleInfo;
    begin
        // [GIVEN] The current module adds a common custom dimension in a subscriber to OnAddCommonCustomDimensions
        BindSubscription(CustomDimensionsTest);

        // [WHEN] OnAddCommonCustomDimensions event is raised
        RaiseOnAddCommonCustomDimensionsEvent(TelemetryCustomDimensions);

        // [THEN] The added common custom dimension is present for the current app publisher
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        CommonCustomDimensions := TelemetryCustomDimensions.GetAdditionalCommonCustomDimensions(CurrentModuleInfo.Publisher);
        Assert.AreEqual(CommonCustomDimensionValueTxt, CommonCustomDimensions.Get(CommonCustomDimensionNameTxt), 'Common custom dimension should have been added.');
    end;

    [Test]
    procedure TestNotAddCommonCustomDimension()
    var
        TelemetryCustomDimensions: Codeunit "Telemetry Custom Dimensions";
        CommonCustomDimensions: Dictionary of [Text, Text];
        CurrentModuleInfo: ModuleInfo;
        DimensionValue: Text;
    begin
        // [GIVEN] The current module does not add a common custom dimension in a subscriber to OnAddCommonCustomDimensions

        // [WHEN] OnAddCommonCustomDimensions event is raised
        RaiseOnAddCommonCustomDimensionsEvent(TelemetryCustomDimensions);

        // [THEN] The added common custom dimension is not present for the current app publisher
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        CommonCustomDimensions := TelemetryCustomDimensions.GetAdditionalCommonCustomDimensions(CurrentModuleInfo.Publisher);

        asserterror DimensionValue := CommonCustomDimensions.Get('Test');
        Assert.ExpectedError('The given key was not present in the dictionary');
    end;

    [Test]
    procedure TestAddCommonCustomDimensionDifferentPublisher()
    var
        TelemetryCustomDimsImpl: Codeunit "Telemetry Custom Dims Impl.";
        CommonCustomDimensions: Dictionary of [Text, Text];
        CurrentModuleInfo: ModuleInfo;
        DimensionValue: Text;
        PublisherName: Text;
    begin
        // [GIVEN] A common custom dimension is added for a test app publisher
        PublisherName := 'Test publisher';
        TelemetryCustomDimsImpl.AddAllowedCommonCustomDimensionPublisher(PublisherName);
        TelemetryCustomDimsImpl.AddCommonCustomDimension(CommonCustomDimensionNameTxt, CommonCustomDimensionValueTxt, PublisherName);

        // [THEN] The added common custom dimension is present for the test app publisher
        CommonCustomDimensions := TelemetryCustomDimsImpl.GetAdditionalCommonCustomDimensions(PublisherName);
        Assert.AreEqual(CommonCustomDimensionValueTxt, CommonCustomDimensions.Get(CommonCustomDimensionNameTxt), 'Common custom dimension should have been added.');

        // [THEN] The added common custom dimension is not present for the current app publisher
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        CommonCustomDimensions := TelemetryCustomDimsImpl.GetAdditionalCommonCustomDimensions(CurrentModuleInfo.Publisher);
        asserterror DimensionValue := CommonCustomDimensions.Get(CommonCustomDimensionNameTxt);
        Assert.ExpectedError('The given key was not present in the dictionary');
    end;

    local procedure RaiseOnAddCommonCustomDimensionsEvent(var TelemetryCustomDimensions: Codeunit "Telemetry Custom Dimensions")
    var
    begin
        TelemetryCustomDimensions.AddAllowedCommonCustomDimensionPublisher('Microsoft');
        TelemetryCustomDimensions.OnAddCommonCustomDimensions();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Telemetry Custom Dimensions", 'OnAddCommonCustomDimensions', '', true, true)]
    local procedure OnAddCommonCustomDimensions(var Sender: Codeunit "Telemetry Custom Dimensions")
    begin
        Sender.AddCommonCustomDimension(CommonCustomDimensionNameTxt, CommonCustomDimensionValueTxt);
    end;
}

