// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9092 "Postcode Service GetAddress.io"
{
    var
        PostcodeGetAddressIoConfig: Record "Postcode GetAddress.io Config";
        PostcodeServiceManager: Codeunit "Postcode Service Manager";
        ServiceIdentifierMsg: Label 'GetAddress.io', Locked = true;
        ServiceNameMsg: Label 'GetAddress.io', Locked = true;
        UKPostCodeFeatureNameTxt: Label 'GetAddress.io UK Postcodes', Locked = true;
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Postcode Service Manager", 'OnDiscoverPostcodeServices', '', false, false)]
    procedure RegisterServiceOnDiscover(var TempServiceListNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        PostcodeServiceManager.RegisterService(TempServiceListNameValueBuffer, ServiceIdentifierMsg, ServiceNameMsg);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Postcode Service Manager", 'OnCheckIsServiceConfigured', '', false, false)]
    procedure RegisterServiceOnDiscoverActive(ServiceKey: Text; var IsConfigured: Boolean)
    begin
        if ServiceKey <> ServiceIdentifierMsg then
            exit;

        IsConfigured := IsServiceConfigured();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Postcode Service Manager", 'OnRetrieveAddressList', '', false, false)]
    procedure GetAddressListOnAddressListRetrieved(ServiceKey: Text; TempEnteredAutocompleteAddress: Record "Autocomplete Address" temporary; var TempAddressListNameValueBuffer: Record "Name/Value Buffer" temporary; var IsSuccessful: Boolean; var ErrorMsg: Text)
    var
        TempAutocompleteAddress: Record "Autocomplete Address" temporary;
        FeatureTelemetry: Codeunit "Feature Telemetry";
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
        FeatureTelemetry.LogUptake('0000FW5', UKPostCodeFeatureNameTxt, Enum::"Feature Uptake Status"::Used, false, true);

        // Check if we're the selected service
        if ServiceKey <> ServiceIdentifierMsg then begin
            ErrorMsg := WrongServiceErr;
            IsSuccessful := false;
            FeatureTelemetry.LogError('0000BUX', UKPostCodeFeatureNameTxt, 'Checking the selected service', ErrorMsg);
            exit;
        end;

        GetConfigAndIfNecessaryCreate();

        Url := BuildUrl(TempEnteredAutocompleteAddress.Postcode);
        PrepareWebRequest(HttpClientInstance);

        if not HttpClientInstance.Get(Url, HttpResponse) then begin
            // This check avoids accessing to an empty HttpResponse if the request fails. Otherwise there will be an error
            ErrorMsg := TechnicalErr;
            IsSuccessful := false;
            FeatureTelemetry.LogError('0000BU2', UKPostCodeFeatureNameTxt, 'Sending HTTP request', ErrorMsg);
            exit;
        end;

        ErrorMsg := HandleHttpErrors(HttpResponse);
        if ErrorMsg <> '' then begin
            IsSuccessful := false;
            FeatureTelemetry.LogError('0000BU3', UKPostCodeFeatureNameTxt, 'Getting HTTP response', ErrorMsg);
            exit;
        end;

        HttpResponse.Content().ReadAs(ResponseText);
        JsonObjectInstance.ReadFrom(ResponseText);

        if JsonObjectInstance.SelectToken('Addresses', JsonArrayToken) then begin
            AddressJsonArray := JsonArrayToken.AsArray();

            foreach AddressJsonToken in AddressJsonArray do begin
                Address := copyStr(AddressJsonToken.AsValue().AsText(), 1, MaxStrLen(Address));
                ParseAddress(TempAutocompleteAddress, Address, TempEnteredAutocompleteAddress.Postcode);

                if (StrPos(TempAutocompleteAddress.Address, TempEnteredAutocompleteAddress.Address) > 0) or
                    (TempEnteredAutocompleteAddress.Address = '')
                then
                    PostcodeServiceManager.AddSelectionAddress(TempAddressListNameValueBuffer, Address, Address);
            end;

            IsSuccessful := true;
            FeatureTelemetry.LogUsage('0000BU7', UKPostCodeFeatureNameTxt, 'List of addresses created');
            exit;
        end else begin
            // show a general error message to user but send a technical error message in telemetry
            ErrorMsg := GeneralHttpErr;
            IsSuccessful := false;
            FeatureTelemetry.LogError('0000BU4', UKPostCodeFeatureNameTxt, 'Getting list of addresses', JsonParseErr);
            exit
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Postcode Service Manager", 'OnRetrieveAddress', '', false, false)]
    procedure GetFullAddressOnGetAddress(ServiceKey: Text; TempEnteredAutocompleteAddress: Record "Autocomplete Address" temporary; TempSelectedAddressNameValueBuffer: Record "Name/Value Buffer" temporary; var TempAutocompleteAddress: Record "Autocomplete Address" temporary; var IsSuccessful: Boolean; var ErrorMsg: Text)
    begin
        if ServiceKey <> ServiceIdentifierMsg then
            exit;

        ParseAddress(TempAutocompleteAddress, TempSelectedAddressNameValueBuffer.Value, TempEnteredAutocompleteAddress.Postcode);

        IsSuccessful := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Postcode Service Manager", 'OnShowConfigurationPage', '', false, false)]
    procedure ConfigureOnShowConfigurationPage(ServiceKey: Text; var Successful: Boolean)
    var
        GetAddressIoConfig: Page "GetAddress.io Config";
    begin
        if ServiceKey <> ServiceIdentifierMsg then
            exit;

        GetConfigAndIfNecessaryCreate();
        GetAddressIoConfig.SetRecord(PostcodeGetAddressIoConfig);
        Successful := GetAddressIoConfig.RunModal() = ACTION::OK;
        PostcodeGetAddressIoConfig.FindFirst();
        Successful := Successful AND not IsNullGuid(PostcodeGetAddressIoConfig.APIKey);
    end;

    local procedure PrepareWebRequest(HTTPClientInstance: HttpClient)
    begin
        HttpClientInstance.DefaultRequestHeaders().Add('Accept-Encoding', 'utf-8');
        HttpClientInstance.DefaultRequestHeaders().Add('Accept', 'application/json');
    end;

    local procedure IsServiceConfigured(): Boolean
    begin
        if not PostcodeGetAddressIoConfig.FindFirst() then
            exit;

        exit(not IsNullGuid(PostcodeGetAddressIoConfig.APIKey) AND (PostcodeGetAddressIoConfig.EndpointURL <> ''));
    end;

    local procedure BuildUrl(Postcode: Text): Text
    var
        Url: Text;
    begin
        // Build URL and include property number if provided
        Url := PostcodeGetAddressIoConfig.EndpointURL + Postcode;

        Url := Url + '?api-key=' + PostcodeGetAddressIoConfig.GetAPIKey(PostcodeGetAddressIoConfig.APIKey);
        exit(Url);
    end;

    local procedure GetConfigAndIfNecessaryCreate()
    begin
        if PostcodeGetAddressIoConfig.FindFirst() then
            exit;

        PostcodeGetAddressIoConfig.Init();
        PostcodeGetAddressIoConfig.EndpointURL := 'https://api.getaddress.io/v2/uk/';
        PostcodeGetAddressIoConfig.Insert();
        Commit();
    end;

    local procedure HandleHttpErrors(HTTPResponse: HttpResponseMessage): Text
    var
        ResponseStatus: Integer;
    begin
        if (LowerCase(HTTPResponse.ReasonPhrase()).Contains(ExpiredTok)) then
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
        exit(DelChr(String, '<'));
    end;

    local procedure ParseAddress(var TempAutocompleteAddress: Record "Autocomplete Address" temporary; AddressString: Text; EnteredPostcode: Text[20])
    var
        pos: Integer;
        addr2: Text;
    begin
        // Format: "line1","line2","line3","line4","locality","Town/City","County"
        // "Address" = the last non-empty line in ["line1", "line2"...] + "locality"
        // "Address 2" = the rest of the non-empty lines in ["line1"...]
        pos := 4;
        while pos > 0 do begin
            if TrimStart(SELECTSTR(pos, AddressString)) <> '' then break;
            pos := pos - 1;
        end;

        TempAutocompleteAddress.Init();

        if pos < 1 then
            TempAutocompleteAddress.Address := COPYSTR(TrimStart(SELECTSTR(5, AddressString)), 1, 100)
        else
            TempAutocompleteAddress.Address := COPYSTR(TrimStart(SELECTSTR(pos, AddressString)) + GetLineByPosition(5, AddressString), 1, 100);

        pos := pos - 1;
        while pos > 0 do begin
            if addr2 = '' then
                addr2 := TrimStart(SELECTSTR(pos, AddressString))
            else
                addr2 := addr2 + GetLineByPosition(pos, AddressString);
            pos := pos - 1;
        end;

        TempAutocompleteAddress."Address 2" := COPYSTR(addr2, 1, 50);
        TempAutocompleteAddress.City := COPYSTR(TrimStart(SELECTSTR(6, AddressString)), 1, 30);
        TempAutocompleteAddress.Postcode := EnteredPostcode;
        TempAutocompleteAddress.County := COPYSTR(TrimStart(SELECTSTR(7, AddressString)), 1, 30);
        TempAutocompleteAddress."Country / Region" := 'GB';
    end;

    local procedure GetLineByPosition(pos: Integer; AddressString: Text) Result: Text
    begin
        Result := TrimStart(SELECTSTR(pos, AddressString));
        if Result <> '' then Result := ', ' + Result;
    end;
}
