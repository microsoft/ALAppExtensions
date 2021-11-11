// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8704 "Feature Telemetry Impl."
{
    Access = Internal;

    var
        UptakeLbl: Label 'Feature %1 is %2', Locked = true, Comment = '%1 - feature name; %2 - uptake status, for example, Discovered';

    procedure LogUsage(EventId: Text; FeatureName: Text; EventName: Text; CallerCustomDimensions: Dictionary of [Text, Text]; CallerModuleInfo: ModuleInfo)
    var
        UsageCustomDimensions: Dictionary of [Text, Text];
    begin
        UsageCustomDimensions.Add('Category', 'FeatureTelemetry');
        UsageCustomDimensions.Add('SubCategory', 'Usage');
        UsageCustomDimensions.Add('FeatureName', FeatureName);
        UsageCustomDimensions.Add('EventName', EventName);

        LogMessage(EventId, EventName, Verbosity::Normal, CallerCustomDimensions, UsageCustomDimensions, CallerModuleInfo);
    end;

    procedure LogError(EventId: Text; FeatureName: Text; EventName: Text; ErrorText: Text; ErrorCallStack: Text; CallerCustomDimensions: Dictionary of [Text, Text]; CallerModuleInfo: ModuleInfo)
    var
        ErrorCustomDimensions: Dictionary of [Text, Text];
    begin
        ErrorCustomDimensions.Add('Category', 'FeatureTelemetry');
        ErrorCustomDimensions.Add('SubCategory', 'Error');
        ErrorCustomDimensions.Add('FeatureName', FeatureName);
        ErrorCustomDimensions.Add('EventName', EventName);
        ErrorCustomDimensions.Add('ErrorText', ErrorText);
        ErrorCustomDimensions.Add('ErrorCallStack', ErrorCallStack);

        LogMessage(EventId, ErrorText, Verbosity::Error, CallerCustomDimensions, ErrorCustomDimensions, CallerModuleInfo);
    end;

    procedure LogUptake(EventId: Text; FeatureName: Text; FeatureUptakeStatus: Enum "Feature Uptake Status"; IsPerUser: Boolean; PerformWriteTransactionsInASeparateSession: Boolean; CallerCustomDimensions: Dictionary of [Text, Text]; CallerModuleInfo: ModuleInfo)
    var
        EnvironmentInformation: Codeunit "Environment Information";
        FeatureUptakeStatusImpl: Codeunit "Feature Uptake Status Impl.";
        Language: Codeunit Language;
        UptakeCustomDimensions: Dictionary of [Text, Text];
        FeatureUptakeStatusText: Text;
        EventName: Text;
        CurrentLanguage: Integer;
        IsExpectedUpdate: Boolean;
    begin
        if not EnvironmentInformation.IsSaaS() then
            exit;

        CurrentLanguage := GlobalLanguage();
        GlobalLanguage(Language.GetDefaultApplicationLanguageId());

        IsExpectedUpdate := FeatureUptakeStatusImpl.UpdateFeatureUptakeStatus(FeatureName, FeatureUptakeStatus, IsPerUser, PerformWriteTransactionsInASeparateSession, CallerModuleInfo.Publisher);
        FeatureUptakeStatusText := Format(FeatureUptakeStatus);
        EventName := StrSubstNo(UptakeLbl, FeatureName, FeatureUptakeStatusText);

        UptakeCustomDimensions.Add('Category', 'FeatureTelemetry');
        UptakeCustomDimensions.Add('SubCategory', 'Uptake');
        UptakeCustomDimensions.Add('FeatureName', FeatureName);
        UptakeCustomDimensions.Add('EventName', EventName);
        UptakeCustomDimensions.Add('FeatureUptakeStatus', FeatureUptakeStatusText);
        UptakeCustomDimensions.Add('IsPerUser', Format(IsPerUser));
        UptakeCustomDimensions.Add('IsExpectedUpdate', Format(IsExpectedUpdate));

        GlobalLanguage(CurrentLanguage);

        LogMessage(EventId, EventName, Verbosity::Normal, CallerCustomDimensions, UptakeCustomDimensions, CallerModuleInfo);
    end;

    local procedure LogMessage(EventId: Text; Message: Text; Verbosity: Verbosity; CallerCustomDimensions: Dictionary of [Text, Text]; EventCustomDimensions: Dictionary of [Text, Text]; CallerModuleInfo: ModuleInfo)
    var
        TelemetryImpl: Codeunit "Telemetry Impl.";
    begin
        TelemetryImpl.AddCustomDimensionsSafely(EventCustomDimensions, CallerCustomDimensions);
        TelemetryImpl.LogMessage(EventId, Message, Verbosity, DataClassification::SystemMetadata, TelemetryScope::All, EventCustomDimensions, CallerModuleInfo);
    end;
}