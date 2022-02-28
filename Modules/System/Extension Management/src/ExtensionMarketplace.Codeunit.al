// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This codeunit is used as a helper for managing interactions between
/// Business Central and the AppSource marketplace. The marketplace provides a gallery
/// that users can use to select and install Extensions published (an thus
/// available) on Business Central.
/// When and item is selected from the gallery, a JSON object is returned
/// and needs to be parsed for the key information we need to perform an
/// install.
/// At current the key pieces of that object look like this:
/// "msgType":"&lt;type name string&gt;",
/// "data":
///    "applicationId":"&lt;string identifier for selected extension&gt;",
///    "telemetryUrl":"&lt;url&gt;",
/// </summary>
codeunit 2501 "Extension Marketplace"
{
    Access = Internal;
    Permissions = tabledata "Published Application" = r;

    var
        HttpWebRequest: DotNet HttpWebRequest;
        GlobalPropertyValue: Text;
        ParseFailureErr: Label 'Failed to extract ''%1'' property from JSON object.', Comment = 'JSON parsing error. %1=target property name';
        TelemetryBodyTxt: Label '{"acquisitionResult":"%1", "detail":"%2"}', Comment = '%1=AppSource operation result option, %2=details describing the context or reason for the result', Locked = true;
        ParseApplicationIdErr: Label 'Failed to extract ''%1'' token from Application Id.', Comment = '%1=Name of token that we expected   ';
        Token: Option PUBID,AID,PACKID,PAPPID;
        MarketplaceDisabledSecretTxt: Label 'extmgmt-marketplace-disable', Locked = true;
        MarketPlaceSuccInstallTxt: Label 'The extension was successfully installed.';
        MarketPlaceUnsuccInstallTxt: Label 'The market place extension installation has failed with the result ''%1''. Error message: ''%2''', Comment = '%1 - OperationResult parameter value, %2 - Error message';
        AlreadyInstalledMsg: Label 'The extension %1 is already installed.', Comment = '%1=name of app';
        AppsourceTxt: Label 'https://appsource.microsoft.com', Locked = true;
        EmbedRelativeTxt: Label '/embed/en-us/marketplace?product=dynamics-365-business-central', Locked = true;
        ExtensionNotFoundErr: Label 'Selected extension could not be installed because a valid App Id or package ID is not passed.', Comment = 'Error message for trying to install an extension where a valid id is not passed;';
        TelemetryExtensionNotFoundErr: Label 'Selected extension could not be installed because a valid App Id or package ID is not passed. Application ID : %1.', Comment = 'Telemetry error message for trying to install an extension a valid id is not passed; %1 is the applicaiton id recieved from appsource.';
        MissingAppIdErr: Label 'Selected extension could not be installed because the extension is not published and a valid App Id is not passed. Application ID : %1.', Comment = 'Telemetry error message for trying to install an extension a valid id is not passed; %1 is the applicaiton id recieved from appsource.';
        TelemetryTok: Label 'ExtensionManagementTelemetryCategoryTok', Locked = true;
        ExtensionInstallationFailureErr: Label 'The extension %1 failed to install.', Comment = '"%1=name of extension"';
        OperationResult: Option UserNotAuthorized,DeploymentFailedDueToPackage,DeploymentFailed,Successful,UserCancel,UserTimeOut;

    local procedure GetValue(JObject: DotNet JObject; Property: Text; ThrowError: Boolean): Text
    begin
        // Helper for extracting a property value out of a JObject
        if TryGetValue(JObject, Property) then
            exit(GlobalPropertyValue);

        if ThrowError then
            Error(ParseFailureErr, Property);

        exit('');
    end;

    [TryFunction]
    local procedure TryGetValue(JObject: DotNet JObject; Property: Text)
    var
        StringComparison: DotNet StringComparison;
        JToken: DotNet JToken;
    begin
        // Helper to 'safely' extract the value of a JProperty. Ignores case and 'catches' exceptions
        JToken := JObject.GetValue(Property, StringComparison.OrdinalIgnoreCase);
        GlobalPropertyValue := JToken.ToString();
    end;

    procedure MapMarketplaceIdToPackageId(ApplicationId: Text): Guid
    var
        GlobalId: Text;
        NullGUID: Guid;
    begin
        // When an ISV submits an extension to AppSource for publication to
        // the marketplace, their artifact (.NAVX) is associated with an
        // id created internally by the AppSource team.
        // The .NAVX and other associated data are then submitted to our
        // Certification/Validation service. The id that AppSource created for
        // this item is included as part of this payload. Unfortunately,
        // the id isn't provided to our service using the same name: 'applicationId'.
        // It is currently not known what name is used during this initial
        // submission, but once known it will be our responsibility to create
        // a mapping path between that service, the extension, and this codeunit.
        // Format:
        // PUBID.<value>|AID.<value>|PACKID.<package id>{|-preview}

        if TryParseApplicationId(ApplicationId, Token::PACKID, GlobalId) then
            exit(GlobalId);

        exit(NullGUID);
    end;

    procedure GetTelementryUrlFromData(JObject: DotNet JObject): Text
    var
        TempObject: DotNet JObject;
    begin
        // Extracts the telemetryUrl property, out of the data object, return by the AppSource site
        // NOTE: the temp object is needed here. While JObject.Parse looks like a static call
        // to the JObject type, it will in fact reload and modify the underlying referenced object
        // as well as return the result of a 'parse'
        TempObject := TempObject.Parse(GetValue(JObject, 'data', false));
        exit(GetValue(TempObject, 'responseUrl', false));
    end;

    [TryFunction]
    local procedure TryMakeMarketplaceTelemetryCallback(ResponseURL: Text; OperationResult: Option UserNotAuthorized,DeploymentFailedDueToPackage,DeploymentFailed,Successful,UserCancel,UserTimeOut)
    var
        TempBlob: Codeunit "Temp Blob";
        HttpWebResponse: DotNet HttpWebResponse;
        ResponseInStream: InStream;
    begin
        InitializeHTTPRequest(ResponseUrl);
        HttpWebRequest.Accept := '*/*';
        HttpWebRequest.ContentType := 'application/json';
        HttpWebRequest.Method := 'POST';
        AddBodyAsText(Format(OperationResult));
        TempBlob.CreateInStream(ResponseInStream);

        ClearLastError();
        HttpWebResponse := HttpWebRequest.GetResponse();
        HttpWebResponse.GetResponseStream().CopyTo(ResponseInStream);
    end;

    [TryFunction]
    local procedure TryParseApplicationId(ApplicationId: Text; ExpectedToken: Option PUBID,AID,PACKID,PAPPID; var GlobalId: Text)
    var
        actualToken: Text;
        TokenFound: Boolean;
        CurrentToken: Text;
    begin
        // Extract token value from Formats:
        // PUBID.<value>|AID.<value>|PACKID.<package id>{|-preview}
        // PUBID.<value>|AID.<value>|PAPPID.<app id>{|-preview}

        // Since 'split' in AL depends on comma delimiters, make sure we remove existing commas
        GlobalId := ConvertStr(ApplicationId, ',', ';');

        // Create 'split' points at pipes
        GlobalId := ConvertStr(GlobalId, '|', ',');

        // Flag to indicate if expected token found or not
        TokenFound := false;

        // Iterate over tokens
        while GlobalId <> '' do begin
            CurrentToken := SelectStr(1, GlobalId);

            // Remove the scanned token from GlobalID
            GlobalId := DelStr(GlobalId, 1, StrLen(CurrentToken) + 1);

            // Create 'split' point at token\value separator
            CurrentToken := ConvertStr(CurrentToken, '.', ',');

            // Get token
            actualToken := SelectStr(1, CurrentToken);
            if actualToken = Format(ExpectedToken) then begin
                TokenFound := true;
                break;
            end;
        end;

        if not TokenFound then
            Error(ParseApplicationIdErr, ExpectedToken);

        // Select the value of the token
        GlobalId := SelectStr(2, CurrentToken);
    end;

    procedure MapMarketplaceIdToAppId(ApplicationId: Text): Guid
    var
        GlobalId: Text;
        NullGuid: Guid;
    begin
        // When an ISV submits an Extension to AppSource for publication to
        // the marketplace, their artifact (.NAVX) is associated with an
        // ID created internally by the AppSource team.
        // The .NAVX and other associated data are then submitted to our
        // Certification/Validation service. The id created by AppSource for
        // this item is included as part of this payload. Unfortunately,
        // the id isn't provided to our service using the same name: 'applicationId'.
        // It is currently not known what name is used during this initial
        // submission, but once known it will be our responsibility to create
        // a mapping path between that service, the extension, and this codeunit.
        // Format:
        // PUBID.<value>|AID.<value>|PACKID.<package id>{|-preview}

        if TryParseApplicationId(ApplicationId, Token::PAPPID, GlobalId) then
            exit(GlobalId);

        exit(NullGuid);
    end;

    procedure MakeMarketplaceTelemetryCallback(ResponseURL: Text; OperationResult: Option UserNotAuthorized,DeploymentFailedDueToPackage,DeploymentFailed,Successful,UserCancel,UserTimeOut)
    begin
        if not TryMakeMarketplaceTelemetryCallback(ResponseURL, OperationResult) then
            if OperationResult = OperationResult::Successful then
                Session.LogMessage('00008LZ', MarketPlaceSuccInstallTxt, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', 'Extensions')
            else
                Session.LogMessage('00008M0', StrSubstNo(MarketPlaceUnsuccInstallTxt, OperationResult, GetLastErrorText()), Verbosity::Warning, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', 'AL Extensions');
    end;

    procedure InstallMarketplaceExtension(ApplicationId: Guid; ResponseURL: Text; lcid: Integer)
    var
        PublishedApplication: Record "Published Application";
        ExtensionInstallationImpl: Codeunit "Extension Installation Impl";
        ExtensionOperationImpl: Codeunit "Extension Operation Impl";
    begin
        if IsNullGuid(ApplicationId) then
            Error(TelemetryExtensionNotFoundErr, ApplicationId);

        PublishedApplication.SetRange("Package ID", ExtensionOperationImpl.GetLatestVersionPackageIdByAppId(ApplicationId));
        PublishedApplication.SetRange("Tenant Visible", true);
        if not PublishedApplication.FindFirst() then begin
            // If the extension is not found, send the request to the regional service.
            ExtensionOperationImpl.DeployExtension(ApplicationId, lcid, true);
            exit;
        end;

        // Check if the extension is already installed
        if ExtensionInstallationImpl.IsInstalledByAppId(ApplicationId) then begin
            Message(StrSubstNo(AlreadyInstalledMsg, PublishedApplication.Name));
            exit;
        end;

        // If it is a first party extension, install it locally
        if IsFirstPartyExtension(PublishedApplication) then
            InstallApp(PublishedApplication."Package ID", ResponseURL, lcid)
        else
            // If the extension is found and it's from a third party, then send the request to regional service.
            ExtensionOperationImpl.DeployExtension(ApplicationId, lcid, true);
    end;


    [TryFunction]
    PROCEDURE InstallAppsourceExtension(ApplicationID: Text; TelemetryURL: Text);
    VAR
        PublishedApplication: Record "Published Application";
        ExtensionInstallation: Page "Extension Installation";
        APPID: GUID;
        PackageID: GUID;
    BEGIN
        APPID := MapMarketplaceIdToAppId(ApplicationID);
        if not IsNullGuid(APPID) then begin
            PublishedApplication.SETFILTER(ID, '%1', APPID);
            PublishedApplication.ID := APPID;
        end else begin
            PackageID := MapMarketplaceIdToPackageId(ApplicationID);
            if IsNullGuid(PackageID) then begin
                Session.LogMessage('0088AQQ', StrSubstNo(TelemetryExtensionNotFoundErr, ApplicationID), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryTok);
                ERROR(ExtensionNotFoundErr);
            end;

            PublishedApplication.SETFILTER("Package ID", '%1', PackageID);
            if PublishedApplication.IsEmpty then begin
                Session.LogMessage('0088BQQ', StrSubstNo(MissingAppIdErr, ApplicationID), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryTok);
                ERROR(ExtensionNotFoundErr);
            end;

            PublishedApplication."Package ID" := PackageID;
        end;

        PublishedApplication.responseUrl := CopyStr(TelemetryUrl, 1, MaxStrLen(PublishedApplication.responseUrl));
        ExtensionInstallation.SETRECORD(PublishedApplication);
        IF ExtensionInstallation.RUNMODAL() = ACTION::OK THEN
            EXIT;
        PublishedApplication.RESET();
        ExtensionInstallation.GETRECORD(PublishedApplication);

        IF NOT AppIsInstalled(APPID, PackageID) then
            ERROR(ExtensionInstallationFailureErr);
    END;

    local procedure AppIsInstalled(APPID: Guid; PackageID: Guid): Boolean;
    var
        ExtensionInstallationImpl: Codeunit "Extension Installation Impl";
    begin
        if not IsNullGuid(APPID) then
            exit(ExtensionInstallationImpl.IsInstalledByAppId(APPID));

        if not IsNullGuid(PackageID) then
            exit(ExtensionInstallationImpl.IsInstalledByPackageId(PackageID));

        // This condition is ckecked before and a proper error and telemetry signal is sent
        exit(false);
    end;

    [TryFunction]
    procedure InstallExtension(ApplicationID: Text; ResponseURL: Text)
    var
        MarketplaceExtnDeployment: Page "Marketplace Extn Deployment";
        ID: Guid;
    begin
        ID := MapMarketplaceIdToAppId(ApplicationID);

        MarketplaceExtnDeployment.SetAppID(ID);
        MarketplaceExtnDeployment.RunModal();

        if MarketplaceExtnDeployment.GetInstalledSelected() then
            InstallMarketplaceExtension(ID, ResponseURL, MarketplaceExtnDeployment.GetLanguageId());
    end;

    procedure IsMarketplaceEnabled(): Boolean
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        DisabledSecret: Text;
        DisabledValue: Boolean;
    begin
        // Try to retrieve config value from keyvault, but if we fail (not there, or not boolean) then assume true
        if AzureKeyVault.GetAzureKeyVaultSecret(MarketplaceDisabledSecretTxt, DisabledSecret) then
            if Evaluate(DisabledValue, DisabledSecret) then
                exit(not DisabledValue);

        exit(true);
    end;

    procedure InitializeHTTPRequest(URL: Text)
    var
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        if not EnvironmentInfo.IsSaaS() then
            OnOverrideUrl(URL);

        HttpWebRequest := HttpWebRequest.Create(URL);
        SetHttpRequestDefaults();
    end;

    local procedure SetHttpRequestDefaults()
    var
        CookieContainer: DotNet CookieContainer;
    begin
        HttpWebRequest.KeepAlive := true;
        HttpWebRequest.AllowAutoRedirect := true;
        HttpWebRequest.UseDefaultCredentials := true;
        HttpWebRequest.Timeout := 60000;
        CookieContainer := CookieContainer.CookieContainer();
        HttpWebRequest.CookieContainer := CookieContainer;
    end;

    local procedure AddBodyAsText(OperationResult: Text)
    var
        RequestStr: DotNet Stream;
        StreamWriter: DotNet StreamWriter;
        Encoding: DotNet Encoding;
        BodyText: Text;
    begin
        // BodyText is an enum string that AppSource recognizes, as defined by the OperationResult.
        BodyText := StrSubstNo(TelemetryBodyTxt, OperationResult, 'ExtensionInstallation');
        RequestStr := HttpWebRequest.GetRequestStream();
        StreamWriter := StreamWriter.StreamWriter(RequestStr, Encoding);
        StreamWriter.Write(BodyText);
        StreamWriter.Flush();
        StreamWriter.Close();
        StreamWriter.Dispose();
    end;

    local procedure InstallApp(PackageId: Guid; ResponseURL: Text; lcid: Integer)
    var
        ExtensionInstallationImpl: Codeunit "Extension Installation Impl";
        HasSucceeded: Boolean;
    begin

        HasSucceeded := ExtensionInstallationImpl.InstallExtensionWithConfirmDialog(PackageId, lcid);


        if HasSucceeded = true then
            MakeMarketplaceTelemetryCallback(ResponseURL, OperationResult::Successful)
        else
            MakeMarketplaceTelemetryCallback(ResponseURL, OperationResult::DeploymentFailedDueToPackage);
    end;

    local procedure IsFirstPartyExtension(PublishedApplication: Record "Published Application"): Boolean
    begin
        if PublishedApplication.Publisher = 'Microsoft' then
            exit(true);

        exit(false);
    end;


    PROCEDURE GetMarketplaceEmbeddedUrl(): Text;
    BEGIN
        EXIT(AppsourceTxt + EmbedRelativeTxt);
    END;

    PROCEDURE GetMessageType(JObject: DotNet JObject): Text;
    BEGIN
        // Extracts the 'msgType' property from the
        EXIT(GetValue(JObject, 'msgType', TRUE));
    END;

    PROCEDURE GetApplicationIdFromData(JObject: DotNet JObject): Text;
    VAR
        TempObject: DotNet JObject;
    BEGIN
        // Extracts the applicationId property out of the data object return by the SPZA site
        TempObject := TempObject.Parse(GetValue(JObject, 'data', TRUE));
        EXIT(GetValue(TempObject, 'applicationId', true));
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", 'InvokeExtensionInstallation', '', false, false)]
    local procedure InvokeExtensionInstallation(AppId: Text; ResponseUrl: Text)
    begin
        if not InstallExtension(AppId, ResponseUrl) then
            Message(GetLastErrorText());
    end;

    [InternalEvent(false)]
    internal procedure OnOverrideUrl(var Url: Text)
    begin
        // Provides an option to rewrite URL in non SaaS environments.
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", 'OpenAppSourceMarket', '', false, false)]
    local procedure OpenAppSourceMarket()
    begin
        page.Run(Page::"Extension Marketplace");
    end;
}
