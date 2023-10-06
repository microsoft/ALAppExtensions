// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Address;

using Microsoft.Utilities;
using System.Telemetry;

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
        PaymentTok: Label 'Payment Required', Locked = true;
        ExpiredErr: Label 'Your account with getAddress.io has expired.';
        PaymentErr: Label 'Requested postal code requires a paid plan by getAddress.io';
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
        CountryRec: Record "Country/Region";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        HttpClientInstance: HttpClient;
        HttpResponse: HttpResponseMessage;
        AddressJsonArray: JsonArray;
        JsonArrayToken: JsonToken;
        JsonObjectInstance: JsonObject;
        AddressJsonToken: JsonToken;
        Url: Text;
        ResponseText: Text;
        TempJsonToken: JsonToken;
        Line1: Text;
    begin
        FeatureTelemetry.LogUptake('0000FW5', UKPostCodeFeatureNameTxt, Enum::"Feature Uptake Status"::Used);

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

        if JsonObjectInstance.SelectToken('addresses', JsonArrayToken) then begin
            AddressJsonArray := JsonArrayToken.AsArray();

            foreach AddressJsonToken in AddressJsonArray do
                if AddressJsonToken.SelectToken('line_1', TempJsonToken) then begin
                    Line1 := TempJsonToken.AsValue().AsText();

                    if AddressJsonToken.SelectToken('line_2', TempJsonToken) then
                        Line1 := Line1 + ', ' + TempJsonToken.AsValue().AsText();

                    if AddressJsonToken.SelectToken('line_3', TempJsonToken) then
                        Line1 := Line1 + ', ' + TempJsonToken.AsValue().AsText();

                    if AddressJsonToken.SelectToken('locality', TempJsonToken) then
                        Line1 := Line1 + ', ' + TempJsonToken.AsValue().AsText();

                    if AddressJsonToken.SelectToken('town_or_city', TempJsonToken) then
                        Line1 := Line1 + ', ' + TempJsonToken.AsValue().AsText();

                    if AddressJsonToken.SelectToken('county', TempJsonToken) then
                        Line1 := Line1 + ', ' + TempJsonToken.AsValue().AsText();

                    if AddressJsonToken.SelectToken('country', TempJsonToken) then begin
                        CountryRec.SetRange(Name, TempJsonToken.AsValue().AsText());
                        if CountryRec.FindFirst() then
                            Line1 := Line1 + ', ' + CountryRec.Code
                        else
                            Line1 := Line1 + ', ' + 'GB';
                    end;

                    // If Address was entered by user, then we only insert maching addresses
                    if (StrPos(Line1, TempEnteredAutocompleteAddress.Address) > 0) or (TempEnteredAutocompleteAddress.Address = '') then
                        PostcodeServiceManager.AddSelectionAddress(TempAddressListNameValueBuffer, Line1, Line1);

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
        Url := Url + '&expand=true';
        exit(Url);
    end;

    local procedure GetConfigAndIfNecessaryCreate()
    begin
        if PostcodeGetAddressIoConfig.FindFirst() then
            exit;

        PostcodeGetAddressIoConfig.Init();
        PostcodeGetAddressIoConfig.EndpointURL := 'https://api.getAddress.io/find/';
        PostcodeGetAddressIoConfig.Insert();
        Commit();
    end;

    local procedure HandleHttpErrors(HTTPResponse: HttpResponseMessage): Text
    var
        ResponseStatus: Integer;
    begin
        if (LowerCase(HTTPResponse.ReasonPhrase()).Contains(ExpiredTok)) then
            exit(ExpiredErr);
        if HTTPResponse.ReasonPhrase().Contains(PaymentTok) then
            exit(PaymentErr);
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
        Line1, Line2 : Text;
    begin
        // Input string is comma seperated following this 
        // Line1, Line2, Line3, Locality, City, County, Country
        Line1 := TrimStart(SELECTSTR(1, AddressString));
        if Line1 <> '' then begin
            if TrimStart(SELECTSTR(2, AddressString)) <> '' then
                Line1 := Line1 + ', ' + TrimStart(SELECTSTR(2, AddressString));

            if TrimStart(SELECTSTR(3, AddressString)) <> '' then
                Line1 := Line1 + ', ' + TrimStart(SELECTSTR(3, AddressString));

            Line2 := TrimStart(SELECTSTR(4, AddressString));

        end else begin
            // If there is no line_1, we default to locality
            Line1 := TrimStart(SELECTSTR(4, AddressString));
            if TrimStart(SELECTSTR(5, AddressString)) <> '' then
                Line1 := Line1 + ', ' + TrimStart(SELECTSTR(5, AddressString));

            Line2 := '';
        end;

        TempAutocompleteAddress.Address := COPYSTR(Line1, 1, MaxStrLen(TempAutocompleteAddress.Address));
        TempAutocompleteAddress."Address 2" := COPYSTR(Line2, 1, MaxStrLen(TempAutocompleteAddress."Address 2"));
        TempAutocompleteAddress.Postcode := COPYSTR(EnteredPostcode, 1, MaxStrLen(TempAutocompleteAddress.Postcode));
        TempAutocompleteAddress.City := COPYSTR(TrimStart(SELECTSTR(5, AddressString)), 1, MaxStrLen(TempAutocompleteAddress.City));
        TempAutocompleteAddress.County := COPYSTR(TrimStart(SELECTSTR(6, AddressString)), 1, MaxStrLen(TempAutocompleteAddress.County));
        TempAutocompleteAddress."Country / Region" := COPYSTR(TrimStart(SELECTSTR(7, AddressString)), 1, MaxStrLen(TempAutocompleteAddress."Country / Region"));
    end;

}
