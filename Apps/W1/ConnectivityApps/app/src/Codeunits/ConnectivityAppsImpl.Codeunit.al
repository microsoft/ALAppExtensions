// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

codeunit 20351 "Connectivity Apps Impl."
{
    Access = Internal;

    var
        DisableBankingAppsNotificationNameTxt: Label 'Banking Apps - Disable Notification';
        DisableBankingAppsNotificationDescriptionTxt: Label 'This notification is used when the bank account card is opened. It can be used to discover banking apps.';

    procedure LoadCategory(var ConnectivityApp: Record "Connectivity App"; ConnectivityAppCategory: Enum "Connectivity Apps Category")
    var
        TempConnectivityApps: Record "Connectivity App" temporary;
        TempApprovedForConnectivityAppCountryOrRegion: Record "Conn. App Country/Region" temporary;
        TempWorksOnConnectivityAppLocalization: Record "Conn. App Country/Region" temporary;
        ConnectivityAppDefinitions: Codeunit "Connectivity App Definitions";
        CurrentLocalizationCode: Enum "Connectivity Apps Localization";
    begin
        ConnectivityAppDefinitions.GetConnectivityAppDefinitions(TempConnectivityApps, TempApprovedForConnectivityAppCountryOrRegion, TempWorksOnConnectivityAppLocalization);

        GetLocalizationCode(CurrentLocalizationCode);

        TempWorksOnConnectivityAppLocalization.SetRange(Localization, CurrentLocalizationCode);
        TempWorksOnConnectivityAppLocalization.SetRange(Category, ConnectivityAppCategory);
        if TempWorksOnConnectivityAppLocalization.IsEmpty() then
            exit;

        if TempWorksOnConnectivityAppLocalization.FindSet() then
            repeat
                TempApprovedForConnectivityAppCountryOrRegion.SetRange("App Id", TempWorksOnConnectivityAppLocalization."App Id");
                if TempApprovedForConnectivityAppCountryOrRegion.FindSet() then
                    repeat
                        if TempConnectivityApps."App Id" <> TempApprovedForConnectivityAppCountryOrRegion."App Id" then
                            TempConnectivityApps.Get(TempApprovedForConnectivityAppCountryOrRegion."App Id");
                        Clear(ConnectivityApp);
                        ConnectivityApp.Copy(TempConnectivityApps);
                        ConnectivityApp."App Id" := TempConnectivityApps."App Id";
                        Evaluate(ConnectivityApp."Country/Region", "Conn. Apps Country/Region".Names().Get(TempApprovedForConnectivityAppCountryOrRegion."Country/Region".Ordinals.IndexOf(TempApprovedForConnectivityAppCountryOrRegion."Country/Region".AsInteger())));
                        ConnectivityApp.Category := TempApprovedForConnectivityAppCountryOrRegion.Category;
                        ConnectivityApp.Insert();
                    until TempApprovedForConnectivityAppCountryOrRegion.Next() = 0;
            until TempWorksOnConnectivityAppLocalization.Next() = 0;
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

    local procedure GetLocalizationCode(var WorksOnLocalization: Enum "Connectivity Apps Localization")
    var
        EnvironmentInformation: Codeunit "Environment Information";
        LocalizationCode: Text;
        Index, OrdinalValue : Integer;
        IsHandled: Boolean;
    begin
        OnGetCurrentLocalizationCode(LocalizationCode, IsHandled);
        if not IsHandled then
            LocalizationCode := EnvironmentInformation.GetApplicationFamily();

        Index := WorksOnLocalization.Names.IndexOf(LocalizationCode);
        OrdinalValue := WorksOnLocalization.Ordinals.Get(Index);
        WorksOnLocalization := Enum::"Connectivity Apps Localization".FromInteger(OrdinalValue);
    end;

    procedure IsConnectivityAppsAvailableForGeo(): Boolean
    var
        CompanyInformation: Record "Company Information";
        ConnectivityAppDefinitions: Codeunit "Connectivity App Definitions";
        CurrentCountryOrRegion: Enum "Conn. Apps Country/Region";
        CurrentLocalization: Enum "Connectivity Apps Localization";
        ApprovedConnectivityAppsForCurrentCountryExists: Boolean;
        WorksOnConnectivityAppForCurrentLocalizationExists: Boolean;
    begin
        GetLocalizationCode(CurrentLocalization);
        WorksOnConnectivityAppForCurrentLocalizationExists := ConnectivityAppDefinitions.WorksOnConnectivityAppForCurrentLocalizationExists(CurrentLocalization);

        if not WorksOnConnectivityAppForCurrentLocalizationExists then
            exit(false);

        CompanyInformation.Get();
        if Evaluate(CurrentCountryOrRegion, CompanyInformation."Country/Region Code") then
            ApprovedConnectivityAppsForCurrentCountryExists := ConnectivityAppDefinitions.ApprovedConnectivityAppsForCurrentCountryExists(CurrentCountryOrRegion, CurrentLocalization);

        exit(ApprovedConnectivityAppsForCurrentCountryExists and WorksOnConnectivityAppForCurrentLocalizationExists);
    end;

    procedure IsConnectivityAppsAvailableForGeo(ConnectivityAppCategory: Enum "Connectivity Apps Category"): Boolean
    var
        CompanyInformation: Record "Company Information";
        ConnectivityAppDefinitions: Codeunit "Connectivity App Definitions";
        CurrentCountryOrRegion: Enum "Conn. Apps Country/Region";
        CurrentLocalization: Enum "Connectivity Apps Localization";
        ApprovedConnectivityAppsForCurrentCountryExists: Boolean;
        WorksOnConnectivityAppForCurrentLocalizationExists: Boolean;
    begin
        GetLocalizationCode(CurrentLocalization);
        WorksOnConnectivityAppForCurrentLocalizationExists := ConnectivityAppDefinitions.WorksOnConnectivityAppForCurrentLocalizationExists(CurrentLocalization, ConnectivityAppCategory);

        if not WorksOnConnectivityAppForCurrentLocalizationExists then
            exit(false);

        CompanyInformation.Get();
        if Evaluate(CurrentCountryOrRegion, CompanyInformation."Country/Region Code") then
            ApprovedConnectivityAppsForCurrentCountryExists := ConnectivityAppDefinitions.ApprovedConnectivityAppsForCurrentCountryExists(CurrentCountryOrRegion, CurrentLocalization, ConnectivityAppCategory);

        exit(ApprovedConnectivityAppsForCurrentCountryExists and WorksOnConnectivityAppForCurrentLocalizationExists);
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
    local procedure OnGetCurrentLocalizationCode(var LocalizationCode: Text; var IsHandled: Boolean)
    begin
    end;
}
