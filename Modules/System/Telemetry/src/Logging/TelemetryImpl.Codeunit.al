// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8712 "Telemetry Impl."
{
    Access = Internal;

    var
        CustomDimensionsNameClashErr: Label 'Multiple custom dimensions with the same dimension name provided.', Locked = true;
        FirstPartyPublisherTxt: Label 'Microsoft', Locked = true;

    procedure LogMessage(EventId: Text; Message: Text; Verbosity: Verbosity; DataClassification: DataClassification; TelemetryScope: TelemetryScope; CallerCustomDimensions: Dictionary of [Text, Text]; CallerModuleInfo: ModuleInfo)
    var
        EnvironmentInformation: Codeunit "Environment Information";
        CommonCustomDimensions: Dictionary of [Text, Text];
    begin
        if not EnvironmentInformation.IsSaaS() then
            exit;

        AddCommonCustomDimensions(CommonCustomDimensions, CallerModuleInfo);
        LogMessageInternal(EventId, Message, Verbosity, DataClassification, TelemetryScope, CommonCustomDimensions, CallerCustomDimensions, CallerModuleInfo.Publisher);
    end;

    procedure LogMessageInternal(EventId: Text; Message: Text; Verbosity: Verbosity; DataClassification: DataClassification; TelemetryScope: TelemetryScope; CustomDimensions: Dictionary of [Text, Text]; CallerCustomDimensions: Dictionary of [Text, Text]; Publisher: Text)
    var
        TelemetryLoggers: Codeunit "Telemetry Loggers";
        TelemetryLogger: Interface "Telemetry Logger";
    begin
        AddCustomDimensionsFromSubscribers(CustomDimensions, Publisher);
        AddCustomDimensionsSafely(CustomDimensions, CallerCustomDimensions);

        TelemetryLoggers.SetCurrentPublisher(Publisher);
        TelemetryLoggers.OnRegisterTelemetryLogger();

        if TelemetryLoggers.GetTelemetryLogger(TelemetryLogger) then
            TelemetryLogger.LogMessage(EventId, Message, Verbosity, DataClassification, TelemetryScope, CustomDimensions);
    end;

    local procedure AddCommonCustomDimensions(CustomDimensions: Dictionary of [Text, Text]; CallerModuleInfo: ModuleInfo)
    var
        Company: Record Company;
        UserPersonalization: Record "User Personalization";
        Language: Codeunit Language;
        CurrentLanguage: Integer;
    begin
        CurrentLanguage := GlobalLanguage();
        GlobalLanguage(Language.GetDefaultApplicationLanguageId());

        CustomDimensions.Add('CallerAppName', CallerModuleInfo.Name);
        CustomDimensions.Add('CallerAppVersionMajor', Format(CallerModuleInfo.AppVersion.Major));
        CustomDimensions.Add('CallerAppVersionMinor', Format(CallerModuleInfo.AppVersion.Minor));
        CustomDimensions.Add('ClientType', Format(CurrentClientType()));
        CustomDimensions.Add('Company', CompanyName());
        if Company.Get(CompanyName()) then
            CustomDimensions.Add('IsEvaluationCompany', Format(Company."Evaluation Company"));
        if UserPersonalization.Get(UserSecurityId()) then
            if UserPersonalization.Scope = UserPersonalization.Scope::System then
                CustomDimensions.Add('UserRole', UserPersonalization."Profile ID");

        GlobalLanguage(CurrentLanguage);
    end;

    local procedure AddCustomDimensionsFromSubscribers(CustomDimensions: Dictionary of [Text, Text]; Publisher: Text)
    var
        Language: Codeunit Language;
        TelemetryCustomDimensions: Codeunit "Telemetry Custom Dimensions";
        CustomDimensionsFromSubscribers: Dictionary of [Text, Text];
        CurrentLanguage: Integer;
    begin
        CurrentLanguage := GlobalLanguage();
        GlobalLanguage(Language.GetDefaultApplicationLanguageId());

        TelemetryCustomDimensions.AddAllowedCommonCustomDimensionPublisher(Publisher);
        TelemetryCustomDimensions.AddAllowedCommonCustomDimensionPublisher(FirstPartyPublisherTxt);
        TelemetryCustomDimensions.OnAddCommonCustomDimensions();

        if FirstPartyPublisherTxt <> Publisher then begin
            CustomDimensionsFromSubscribers := TelemetryCustomDimensions.GetAdditionalCommonCustomDimensions(FirstPartyPublisherTxt);
            AddCustomDimensionsSafely(CustomDimensions, CustomDimensionsFromSubscribers);
        end;
        CustomDimensionsFromSubscribers := TelemetryCustomDimensions.GetAdditionalCommonCustomDimensions(Publisher);
        AddCustomDimensionsSafely(CustomDimensions, CustomDimensionsFromSubscribers);

        GlobalLanguage(CurrentLanguage);
    end;

    procedure AddCustomDimensionsSafely(CustomDimensions: Dictionary of [Text, Text]; CustomDimensionsToAdd: Dictionary of [Text, Text])
    var
        CustomDimensionName: Text;
    begin
        foreach CustomDimensionName in CustomDimensionsToAdd.Keys() do
            if not CustomDimensions.ContainsKey(CustomDimensionName) then
                CustomDimensions.Add(CustomDimensionName, CustomDimensionsToAdd.Get(CustomDimensionName))
            else
                Session.LogMessage('0000G7I', CustomDimensionsNameClashErr, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', 'TelemetryLibrary');
    end;
}

