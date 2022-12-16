// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 20351 "Connectivity Apps Impl."
{
    Access = Internal;

    var
        ApplicationVersionTxt: Label 'Application version from constants: %1', Comment = '%1 = Application version', Locked = true;
        CountryCodeEmptyTxt: Label 'CountryCode is empty', Locked = true;
        CountryCodeTxt: Label 'Country code: %1', Comment = '%1 = Country code', Locked = true;
        DisableBankingAppsNotificationNameTxt: Label 'Banking Apps - Disable Notification';
        DisableBankingAppsNotificationDescriptionTxt: Label 'This notification is used when the bank account card is opened. It can be used to discover banking apps.';

    procedure LoadCategory(var ConnectivityApp: Record "Connectivity App"; ConnectivityAppCategory: Enum "Connectivity Apps Category")
    var
        TempConnectivityApps: Record "Connectivity App" temporary;
        TempApprovedForConnectivityAppCountry: Record "Connectivity App Country" temporary;
        TempWorksOnConnectivityAppCountry: Record "Connectivity App Country" temporary;
        ConnectivityAppDefinitions: Codeunit "Connectivity App Definitions";
        CurrentCountryCode: Enum "Conn. Apps Supported Country";
    begin
        ConnectivityAppDefinitions.GetConnectivityAppDefinitions(TempConnectivityApps, TempApprovedForConnectivityAppCountry, TempWorksOnConnectivityAppCountry);

        if not TryGetCurrentCountry(CurrentCountryCode) then
            exit;

        TempWorksOnConnectivityAppCountry.SetRange(Country, CurrentCountryCode);
        TempWorksOnConnectivityAppCountry.SetRange(Category, ConnectivityAppCategory);
        if TempWorksOnConnectivityAppCountry.IsEmpty() then
            exit;
        TempWorksOnConnectivityAppCountry.FindSet();
        repeat
            TempApprovedForConnectivityAppCountry.SetRange("App Id", TempWorksOnConnectivityAppCountry."App Id");
            if TempApprovedForConnectivityAppCountry.FindSet() then
                repeat
                    if TempConnectivityApps."App Id" <> TempWorksOnConnectivityAppCountry."App Id" then
                        TempConnectivityApps.Get(TempWorksOnConnectivityAppCountry."App Id");
                    Clear(ConnectivityApp);
                    ConnectivityApp.Copy(TempConnectivityApps);
                    ConnectivityApp."App Id" := TempConnectivityApps."App Id";
                    Evaluate(ConnectivityApp.Country, "Conn. Apps Supported Country".Names().Get(TempApprovedForConnectivityAppCountry.Country.Ordinals.IndexOf(TempApprovedForConnectivityAppCountry.Country.AsInteger())));
                    ConnectivityApp.Category := TempApprovedForConnectivityAppCountry.Category;
                    ConnectivityApp.Insert();
                until TempApprovedForConnectivityAppCountry.Next() = 0;
        until TempWorksOnConnectivityAppCountry.Next() = 0;
    end;

    procedure Load(var ConnectivityApp: Record "Connectivity App")
    var
        AppCategory: Enum "Connectivity Apps Category";
        EnumVal: Integer;
    begin
        foreach EnumVal in "Connectivity Apps Category".Ordinals() do begin
            AppCategory := "Connectivity Apps Category".FromInteger(EnumVal);
            LoadCategory(ConnectivityApp, AppCategory);
        end;
    end;

    procedure LoadImages(var ConnectivityApp: Record "Connectivity App")
    var
        ConnectivityAppsLogoMgt: Codeunit "Connectivity Apps Logo Mgt.";
    begin
        ConnectivityAppsLogoMgt.LoadImages(ConnectivityApp);
    end;

    procedure OpenBankingAppsPage(ConnectivityAppsNotification: Notification)
    begin
        Page.Run(Page::"Banking Apps");
    end;

    procedure DisableBankingAppsNotification(ConnectivityAppsNotification: Notification)
    var
        MyNotifications: Record "My Notifications";
        NotificationId: Text;
    begin
        NotificationId := ConnectivityAppsNotification.GetData('NotificationId');
        if not MyNotifications.Disable(NotificationId) then
            MyNotifications.InsertDefault(NotificationId, DisableBankingAppsNotificationNameTxt, DisableBankingAppsNotificationDescriptionTxt, false);
    end;

    local procedure GetCurrentCountryCode(): Text
    var
        CompanyInformation: Record "Company Information";
        ApplicationSystemConstants: Codeunit "Application System Constants";
        ApplicationVersion: Text[248];
        CountryCode: Text;
        Handled: Boolean;
    begin
        OnGetCurrentCountryCode(CountryCode, Handled);
        if Handled then
            exit(CountryCode);

        ApplicationVersion := ApplicationSystemConstants.OriginalApplicationVersion();
        Session.LogMessage('0000I5I', StrSubstNo(ApplicationVersionTxt, ApplicationVersion), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', 'Connectivity Apps');

        CountryCode := ApplicationVersion.Substring(1, 2);
        if CountryCode <> '' then begin
            Session.LogMessage('0000IA6', StrSubstNo(CountryCodeTxt, CountryCode), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', 'Connectivity Apps');
            exit(CountryCode);
        end;

        Session.LogMessage('0000I5J', CountryCodeEmptyTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', 'Connectivity Apps');

        CompanyInformation.Get();
        exit(Format(CompanyInformation."Country/Region Code"));
    end;

    [TryFunction]
    local procedure TryGetCurrentCountry(var ConnAppsSupportedCountry: Enum "Conn. Apps Supported Country")
    var
        Index: Integer;
        OrdinalValue: Integer;
    begin
        Index := ConnAppsSupportedCountry.Names.IndexOf(GetCurrentCountryCode());
        OrdinalValue := ConnAppsSupportedCountry.Ordinals.Get(Index);
        ConnAppsSupportedCountry := Enum::"Conn. Apps Supported Country".FromInteger(OrdinalValue);
    end;

    procedure IsConnectivityAppsAvailableForGeo(): Boolean
    var
        CompanyInformation: Record "Company Information";
        ConnectivityAppDefinitions: Codeunit "Connectivity App Definitions";
        ApprovedCtry: Enum "Conn. Apps Supported Country";
        WorksOnCtry: Enum "Conn. Apps Supported Country";
        ApprovedConnectivityAppsForCurrentCountryExists: Boolean;
        WorksOnConnectivityAppForCurrentCountryExists: Boolean;
    begin
        if TryGetCurrentCountry(WorksOnCtry) then
            WorksOnConnectivityAppForCurrentCountryExists := ConnectivityAppDefinitions.WorksOnConnectivityAppForCurrentCountryExists(WorksOnCtry);

        if not WorksOnConnectivityAppForCurrentCountryExists then
            exit(false);

        CompanyInformation.Get();
        if Evaluate(ApprovedCtry, CompanyInformation."Country/Region Code") then
            ApprovedConnectivityAppsForCurrentCountryExists := ConnectivityAppDefinitions.ApprovedConnectivityAppsForCurrentCountryExists(ApprovedCtry, WorksOnCtry);

        exit(ApprovedConnectivityAppsForCurrentCountryExists and WorksOnConnectivityAppForCurrentCountryExists);
    end;

    procedure IsConnectivityAppsAvailableForGeo(ConnectivityAppCategory: Enum "Connectivity Apps Category"): Boolean
    var
        CompanyInformation: Record "Company Information";
        ConnectivityAppDefinitions: Codeunit "Connectivity App Definitions";
        ApprovedCtry: Enum "Conn. Apps Supported Country";
        WorksOnCtry: Enum "Conn. Apps Supported Country";
        ApprovedConnectivityAppsForCurrentCountryExists: Boolean;
        WorksOnConnectivityAppForCurrentCountryExists: Boolean;
    begin
        if TryGetCurrentCountry(WorksOnCtry) then
            WorksOnConnectivityAppForCurrentCountryExists := ConnectivityAppDefinitions.WorksOnConnectivityAppForCurrentCountryExists(WorksOnCtry, ConnectivityAppCategory);

        if not WorksOnConnectivityAppForCurrentCountryExists then
            exit(false);

        CompanyInformation.Get();
        if Evaluate(ApprovedCtry, CompanyInformation."Country/Region Code") then
            ApprovedConnectivityAppsForCurrentCountryExists := ConnectivityAppDefinitions.ApprovedConnectivityAppsForCurrentCountryExists(ApprovedCtry, WorksOnCtry, ConnectivityAppCategory);

        exit(ApprovedConnectivityAppsForCurrentCountryExists and WorksOnConnectivityAppForCurrentCountryExists);
    end;

    procedure LogFeatureTelemetry(AppId: Guid; AppName: Text; AppPublisher: Text)
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        CustomDimensions: Dictionary of [Text, Text];
    begin
        CustomDimensions.Add('App Id', Format(AppId));
        CustomDimensions.Add('App Name', AppName);
        CustomDimensions.Add('App Publisher', AppPublisher);
        FeatureTelemetry.LogUsage('0000I4H', 'Connectivity Apps', 'App installation', CustomDimensions);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Connectivity Apps Mgt.", 'OnIsBankingAppAvailable', '', false, false)]
    local procedure HandleOnIsBankingAppAvailable(var Result: Boolean)
    var
        ConnectivityAppCategory: Enum "Connectivity Apps Category";
    begin
        Result := IsConnectivityAppsAvailableForGeo(ConnectivityAppCategory::Banking);
    end;

    [InternalEvent(false, false)]
    local procedure OnGetCurrentCountryCode(var CountryCode: Text; var Handled: Boolean)
    begin
    end;
}