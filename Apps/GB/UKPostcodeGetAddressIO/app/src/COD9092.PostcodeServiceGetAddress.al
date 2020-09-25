// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9092 "Postcode Service GetAddress.io"
{
    var
        PostcodeGetAddressIoConfig: Record 9092;
        PostcodeServiceManager: Codeunit 9090;
        ServiceIdentifierMsg: Label 'GetAddress.io', Locked = true;
        ServiceNameMsg: Label 'GetAddress.io', Locked = true;
        UKPostCodeTok: Label 'UKPostCodeTelemetryCategoryTok';
        AddressListCreatedMsg: Label 'The list of addresses has been created.';
        TechnicalErr: Label 'A technical error occurred while trying to reach the service.';
        WrongServiceErr: Label 'You must choose the getAddress.io service.';
        ServiceUnavailableErr: Label 'The getAddress.io service is not available right now. Try again later.';
        ExpiredTok: Label 'expired', Locked = true;
        ExpiredErr: Label 'Your account with getAddress.io has expired.';
        NotFoundErr: Label 'No addresses could be found for this postcode.';
        BadRequestErr: Label 'The postcode is not valid.';
        InvalidAPIKeyErr: Label 'Your access to the getAddress.io service has expired. Please renew your API key.';
        TooManyRequestsErr: Label 'You have made more requests than your allowed limit.';
        GeneralHttpErr: Label 'Something went wrong when connecting to the getAddress.io service. Try again later.';
        JsonParseErr: Label 'The json response from getAddress.io contains errors.';

    [EventSubscriber(ObjectType::Codeunit, 9090, 'OnDiscoverPostcodeServices', '', false, false)]
    procedure RegisterServiceOnDiscover(var TempServiceListNameValueBuffer: Record 823 temporary)
    begin
        PostcodeServiceManager.RegisterService(TempServiceListNameValueBuffer, ServiceIdentifierMsg, ServiceNameMsg);
    end;

    [EventSubscriber(ObjectType::Codeunit, 9090, 'OnCheckIsServiceConfigured', '', false, false)]
    procedure RegisterServiceOnDiscoverActive(ServiceKey: Text; var IsConfigured: Boolean)
    begin
        IF ServiceKey <> ServiceIdentifierMsg THEN
            EXIT;

        IsConfigured := IsServiceConfigured();
    end;

    [EventSubscriber(ObjectType::Codeunit, 9090, 'OnRetrieveAddressList', '', false, false)]
    procedure GetAddressListOnAddressListRetrieved(ServiceKey: Text; TempEnteredAutocompleteAddress: Record 9090 temporary; var TempAddressListNameValueBuffer: Record 823 temporary; var IsSuccessful: Boolean; var ErrorMsg: Text)
    var
        TempAutocompleteAddress: Record 9090 temporary;
        HttpClientInstance: HttpClient;
        HttpResponse: HttpResponseMessage;
        AddressJsonArray: JsonArray;
        JsonArrayToken: JsonToken;
        JsonObjectInstance: JsonObject;
        AddressJsonToken: JsonToken;
        Url: Text;
        ResponseText: Text;
        Address: Text[250];
    begin
        // Check if we're the selected service
        if ServiceKey <> ServiceIdentifierMsg then begin
            ErrorMsg := WrongServiceErr;
            IsSuccessful := false;
            Session.LogMessage('0000BUX', ErrorMsg, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UKPostCodeTok);
            exit;
        end;

        GetConfigAndIfNecessaryCreate();

        Url := BuildUrl(TempEnteredAutocompleteAddress.Postcode);
        PrepareWebRequest(HttpClientInstance);

        if not HttpClientInstance.Get(Url, HttpResponse) then begin
            // This check avoids accessing to an empty HttpResponse if the request fails. Otherwise there will be an error
            ErrorMsg := TechnicalErr;
            IsSuccessful := false;
            Session.LogMessage('0000BU2', ErrorMsg, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UKPostCodeTok);
            exit;
        end;

        ErrorMsg := HandleHttpErrors(HttpResponse);
        if ErrorMsg <> '' then begin
            IsSuccessful := false;
            Session.LogMessage('0000BU3', ErrorMsg, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UKPostCodeTok);
            exit;
        end;

        HttpResponse.Content().ReadAs(ResponseText);
        JsonObjectInstance.ReadFrom(ResponseText);

        if JsonObjectInstance.SelectToken('Addresses', JsonArrayToken) then begin
            AddressJsonArray := JsonArrayToken.AsArray();

            foreach AddressJsonToken in AddressJsonArray do begin
                Address := copyStr(AddressJsonToken.AsValue().AsText(), 1, MaxStrLen(Address));
                ParseAddress(TempAutocompleteAddress, Address, TempEnteredAutocompleteAddress.Postcode);

                IF (STRPOS(TempAutocompleteAddress.Address, TempEnteredAutocompleteAddress.Address) > 0) OR
                    (TempEnteredAutocompleteAddress.Address = '')
                THEN
                    PostcodeServiceManager.AddSelectionAddress(TempAddressListNameValueBuffer, Address, Address);
            end;

            IsSuccessful := TRUE;
            Session.LogMessage('0000BU7', AddressListCreatedMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UKPostCodeTok);
            exit;
        end else begin
            // show a general error message to user but send a technical error message in telemetry
            ErrorMsg := GeneralHttpErr;
            IsSuccessful := false;
            Session.LogMessage('0000BU4', JsonParseErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UKPostCodeTok);
            exit
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 9090, 'OnRetrieveAddress', '', false, false)]
    procedure GetFullAddressOnGetAddress(ServiceKey: Text; TempEnteredAutocompleteAddress: Record 9090 temporary; TempSelectedAddressNameValueBuffer: Record 823 temporary; var TempAutocompleteAddress: Record 9090 temporary; var IsSuccessful: Boolean; var ErrorMsg: Text)
    begin
        IF ServiceKey <> ServiceIdentifierMsg THEN
            EXIT;

        ParseAddress(TempAutocompleteAddress, TempSelectedAddressNameValueBuffer.Value, TempEnteredAutocompleteAddress.Postcode);

        IsSuccessful := TRUE;
    end;

    [EventSubscriber(ObjectType::Codeunit, 9090, 'OnShowConfigurationPage', '', false, false)]
    procedure ConfigureOnShowConfigurationPage(ServiceKey: Text; var Successful: Boolean)
    var
        GetAddressIoConfig: Page 9142;
    begin
        IF ServiceKey <> ServiceIdentifierMsg THEN
            EXIT;

        GetConfigAndIfNecessaryCreate();
        GetAddressIoConfig.SETRECORD(PostcodeGetAddressIoConfig);
        Successful := GetAddressIoConfig.RUNMODAL() = ACTION::OK;
        PostcodeGetAddressIoConfig.FINDFIRST();
        Successful := Successful AND NOT ISNULLGUID(PostcodeGetAddressIoConfig.APIKey);
    end;

    local procedure PrepareWebRequest(HTTPClientInstance: HttpClient)
    begin
        HttpClientInstance.DefaultRequestHeaders().Add('Accept-Encoding', 'utf-8');
        HttpClientInstance.DefaultRequestHeaders().Add('Accept', 'application/json');
    end;

    local procedure IsServiceConfigured(): Boolean
    begin
        IF NOT PostcodeGetAddressIoConfig.FINDFIRST() THEN
            EXIT;

        EXIT(NOT ISNULLGUID(PostcodeGetAddressIoConfig.APIKey) AND (PostcodeGetAddressIoConfig.EndpointURL <> ''));
    end;

    local procedure BuildUrl(Postcode: Text): Text
    var
        Url: Text;
    begin
        // Build URL and include property number if provided
        Url := PostcodeGetAddressIoConfig.EndpointURL + Postcode;

        Url := Url + '?api-key=' + PostcodeGetAddressIoConfig.GetAPIKey(PostcodeGetAddressIoConfig.APIKey);
        EXIT(Url);
    end;

    local procedure GetConfigAndIfNecessaryCreate()
    begin
        IF PostcodeGetAddressIoConfig.FINDFIRST() THEN
            EXIT;

        PostcodeGetAddressIoConfig.INIT();
        PostcodeGetAddressIoConfig.EndpointURL := 'https://api.getaddress.io/v2/uk/';
        PostcodeGetAddressIoConfig.INSERT();
        COMMIT();
    end;

    local procedure HandleHttpErrors(HTTPResponse: HttpResponseMessage): Text
    var
        ResponseStatus: Integer;
    begin
        IF (LOWERCASE(HTTPResponse.ReasonPhrase()).Contains(ExpiredTok)) THEN
            exit(ExpiredErr);
        ResponseStatus := HTTPResponse.HttpStatusCode();
        case ResponseStatus of
            200:
                exit(''); // no error
            400:
                exit(BadRequestErr);
            401:
                exit(InvalidAPIKeyErr);
            404:
                exit(NotFoundErr);
            429:
                exit(TooManyRequestsErr);
            503:
                exit(ServiceUnavailableErr);
        end;

        exit(GeneralHttpErr);
    end;

    local procedure TrimStart(String: Text): Text
    begin
        EXIT(DELCHR(String, '<'));
    end;

    local procedure ParseAddress(var TempAutocompleteAddress: Record 9090 temporary; AddressString: Text; EnteredPostcode: Text[20])
    begin
        // FORMAT: "line1","line2","line3","line4","locality","Town/City","County"
        TempAutocompleteAddress.INIT();
        TempAutocompleteAddress.Address := COPYSTR(TrimStart(SELECTSTR(1, AddressString)), 1, 50);
        TempAutocompleteAddress."Address 2" := COPYSTR(TrimStart(SELECTSTR(2, AddressString)), 1, 50);
        TempAutocompleteAddress.City := COPYSTR(TrimStart(SELECTSTR(6, AddressString)), 1, 30);
        TempAutocompleteAddress.Postcode := EnteredPostcode;
        TempAutocompleteAddress.County := COPYSTR(TrimStart(SELECTSTR(7, AddressString)), 1, 30);
        TempAutocompleteAddress."Country / Region" := 'GB';
    end;
}