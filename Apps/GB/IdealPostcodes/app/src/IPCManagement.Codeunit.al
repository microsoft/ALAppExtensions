namespace Microsoft.Foundation.Address.IdealPostcodes;

using System.Reflection;
using System.Telemetry;

codeunit 9400 "IPC Management"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        ConfigNotSetupErr: Label 'The IdealPostcodes Provider is not configured. Set up the API key in the IdealPostcodes Provider Setup page.';
        ConnectionSuccessMsg: Label 'Connection test was successful.';
        ConnectionFailedErr: Label 'Connection test failed.';
        NoResultsMsg: Label 'No addresses found for the given postcode.';
        ApiKeyConfigErr: Label 'API Key is not configured.';
        ResponseDetailsTxt: Label 'Received response %1 %2.', Comment = '%1 - Status code, %2 - Reason phrase.';
        UnsuccessfulAddressSearchTxt: Label 'Unsuccessful address search. Response %1 %2.', Comment = '%1 - Status code, %2 - Reason phrase.', Locked = true;

    [NonDebuggable]
    procedure SearchAddress(SearchText: Text; var TempIPCAddressLookup: Record "IPC Address Lookup" temporary; var StatusCode: Integer; var ReasonPhrase: Text): Boolean
    var
        Config: Record "IPC Config";
        TypeHelper: Codeunit "Type Helper";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        HttpClient: HttpClient;
        HttpResponse: HttpResponseMessage;
        ResponseText: Text;
        RequestUrl: Text;
    begin
        if not GetConfiguration(Config) then
            Error(ConfigNotSetupErr);

        if not Config.Enabled then
            exit(false);

        FeatureTelemetry.LogUptake('0000RFE', 'IdealPostcodes', Enum::"Feature Uptake Status"::Used);
        RequestUrl := Config.APIEndpoint() + '/postcodes/' + TypeHelper.UriEscapeDataString(SearchText);
        HttpClient.DefaultRequestHeaders().Add('Authorization', SecretStrSubstNo('IDEALPOSTCODES api_key="%1"', Config.GetAPIPasswordAsSecret(Config."API Key")));
        HttpClient.DefaultRequestHeaders().Add('Accept-Encoding', 'utf-8');
        HttpClient.DefaultRequestHeaders().Add('Accept', 'application/json');

        if HttpClient.Get(RequestUrl, HttpResponse) then begin
            StatusCode := HttpResponse.HttpStatusCode();
            ReasonPhrase := HttpResponse.ReasonPhrase();
            if HttpResponse.IsSuccessStatusCode() then begin
                HttpResponse.Content.ReadAs(ResponseText);
                ParseAddressResponse(ResponseText, TempIPCAddressLookup);
                exit(not TempIPCAddressLookup.IsEmpty());
            end;
        end;
        exit(false);
    end;

    [NonDebuggable]
    procedure GetAddressDetails(AddressId: Text; var TempIPCAddressLookup: Record "IPC Address Lookup" temporary; var ReasonCode: Integer; var ReasonPhrase: Text)
    var
        Config: Record "IPC Config";
        TypeHelper: Codeunit "Type Helper";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        HttpClient: HttpClient;
        HttpResponse: HttpResponseMessage;
        ResponseText: Text;
        RequestUrl: Text;
    begin
        if not GetConfiguration(Config) then
            Error(ConfigNotSetupErr);

        if not Config.Enabled then
            exit;

        FeatureTelemetry.LogUptake('0000RFF', 'IdealPostcodes', Enum::"Feature Uptake Status"::Used);
        RequestUrl := Config.APIEndpoint() + '/' + TypeHelper.UriEscapeDataString(AddressId);
        HttpClient.DefaultRequestHeaders().Add('Authorization', SecretStrSubstNo('IDEALPOSTCODES api_key="%1"', Config.GetAPIPasswordAsSecret(Config."API Key")));

        if HttpClient.Get(RequestUrl, HttpResponse) then begin
            ReasonCode := HttpResponse.HttpStatusCode();
            ReasonPhrase := HttpResponse.ReasonPhrase();
            if HttpResponse.IsSuccessStatusCode then begin
                HttpResponse.Content.ReadAs(ResponseText);
                ParseAddressDetail(ResponseText, TempIPCAddressLookup);
            end;
        end;
    end;

    procedure LookupAddress(var Address: Text[100]; var Address2: Text[50]; var City: Text[30]; var PostCode: Code[20]; var County: Text[30]; var CountryCode: Code[10])
    var
        TempIPCAddressLookup: Record "IPC Address Lookup" temporary;
        TempSelectedIPCAddressLookup: Record "IPC Address Lookup" temporary;
        AddressLookupPage: Page "IPC Address Lookup";
        SearchText, ReasonPhrase : Text;
        StatusCode: Integer;
    begin
        SearchText := PostCode;
        if SearchText = '' then
            SearchText := City;

        if SearchText = '' then
            exit;

        if not SearchAddress(SearchText, TempIPCAddressLookup, StatusCode, ReasonPhrase) then begin
            case StatusCode of
                404, 200:
                    Message(NoResultsMsg);
                else
                    Message(ResponseDetailsTxt, StatusCode, ReasonPhrase);
            end;
            Session.LogMessage('0000RFS', StrSubstNo(UnsuccessfulAddressSearchTxt, StatusCode, ReasonPhrase), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', 'IdealPostcodes');
        end;

        AddressLookupPage.SetRecords(TempIPCAddressLookup);
        AddressLookupPage.LookupMode(true);

        if AddressLookupPage.RunModal() = Action::LookupOK then begin
            AddressLookupPage.GetSelectedAddress(TempSelectedIPCAddressLookup);
            Address := TempSelectedIPCAddressLookup.Address;
            Address2 := TempSelectedIPCAddressLookup."Address 2";
            City := TempSelectedIPCAddressLookup.City;
            PostCode := TempSelectedIPCAddressLookup."Post Code";
            County := TempSelectedIPCAddressLookup.County;
            CountryCode := TempSelectedIPCAddressLookup."Country/Region Code";
        end;
    end;

    local procedure GetConfiguration(var Config: Record "IPC Config"): Boolean
    begin
        if Config.Get() then
            exit(true);
        exit(false);
    end;

    local procedure ParseAddressResponse(ResponseText: Text; var TempIPCAddressLookup: Record "IPC Address Lookup" temporary)
    var
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        i: Integer;
    begin
        TempIPCAddressLookup.DeleteAll();

        if JsonObject.ReadFrom(ResponseText) then
            if JsonObject.Get('result', JsonToken) then begin
                JsonArray := JsonToken.AsArray();

                for i := 0 to JsonArray.Count - 1 do begin
                    JsonArray.Get(i, JsonToken);
                    AddAddressToBuffer(JsonToken.AsObject(), TempIPCAddressLookup, i + 1);
                end;
            end;
    end;

    local procedure AddAddressToBuffer(AddressJson: JsonObject; var TempIPCAddressLookup: Record "IPC Address Lookup" temporary; EntryNo: Integer)
    begin
        TempIPCAddressLookup.Init();
        TempIPCAddressLookup."Entry No." := EntryNo;
        TempIPCAddressLookup."Address ID" := CopyStr(GetJsonValue(AddressJson, 'id'), 1, MaxStrLen(TempIPCAddressLookup."Address ID"));
        TempIPCAddressLookup.Address := CopyStr(GetJsonValue(AddressJson, 'line_1'), 1, MaxStrLen(TempIPCAddressLookup.Address));
        TempIPCAddressLookup."Address 2" := CopyStr(GetJsonValue(AddressJson, 'line_2'), 1, MaxStrLen(TempIPCAddressLookup."Address 2"));
        TempIPCAddressLookup.City := CopyStr(GetJsonValue(AddressJson, 'post_town'), 1, MaxStrLen(TempIPCAddressLookup.City));
        TempIPCAddressLookup."Post Code" := CopyStr(GetJsonValue(AddressJson, 'postcode'), 1, MaxStrLen(TempIPCAddressLookup."Post Code"));
        TempIPCAddressLookup.County := CopyStr(GetJsonValue(AddressJson, 'county'), 1, MaxStrLen(TempIPCAddressLookup.County));
        TempIPCAddressLookup."Country/Region Code" := CopyStr(GetJsonValue(AddressJson, 'country_iso_2'), 1, MaxStrLen(TempIPCAddressLookup."Country/Region Code"));

        // Create display text
        TempIPCAddressLookup."Display Text" := TempIPCAddressLookup.Address;
        if TempIPCAddressLookup.City <> '' then
            TempIPCAddressLookup."Display Text" += ', ' + TempIPCAddressLookup.City;
        if TempIPCAddressLookup."Post Code" <> '' then
            TempIPCAddressLookup."Display Text" += ' ' + TempIPCAddressLookup."Post Code";

        TempIPCAddressLookup.Insert();
    end;

    local procedure ParseAddressDetail(ResponseText: Text; var TempIPCAddressLookup: Record "IPC Address Lookup")
    var
        JsonObject: JsonObject;
    begin
        if JsonObject.ReadFrom(ResponseText) then begin
            TempIPCAddressLookup.Init();
            TempIPCAddressLookup.Address := CopyStr(GetJsonValue(JsonObject, 'address'), 1, MaxStrLen(TempIPCAddressLookup.Address));
            TempIPCAddressLookup."Address 2" := CopyStr(GetJsonValue(JsonObject, 'address2'), 1, MaxStrLen(TempIPCAddressLookup."Address 2"));
            TempIPCAddressLookup.City := CopyStr(GetJsonValue(JsonObject, 'city'), 1, MaxStrLen(TempIPCAddressLookup.City));
            TempIPCAddressLookup."Post Code" := CopyStr(GetJsonValue(JsonObject, 'postcode'), 1, MaxStrLen(TempIPCAddressLookup."Post Code"));
            TempIPCAddressLookup.County := CopyStr(GetJsonValue(JsonObject, 'county'), 1, MaxStrLen(TempIPCAddressLookup.County));
            TempIPCAddressLookup."Country/Region Code" := CopyStr(GetJsonValue(JsonObject, 'country_code'), 1, MaxStrLen(TempIPCAddressLookup."Country/Region Code"));
        end;

        // Create display text
        TempIPCAddressLookup."Display Text" := TempIPCAddressLookup.Address;
        if TempIPCAddressLookup.City <> '' then
            TempIPCAddressLookup."Display Text" += ', ' + TempIPCAddressLookup.City;
        if TempIPCAddressLookup."Post Code" <> '' then
            TempIPCAddressLookup."Display Text" += ' ' + TempIPCAddressLookup."Post Code";
    end;

    local procedure GetJsonValue(JsonObject: JsonObject; KeyName: Text): Text
    var
        JsonToken: JsonToken;
    begin
        if JsonObject.Get(KeyName, JsonToken) then
            if not JsonToken.AsValue().IsNull then
                exit(JsonToken.AsValue().AsText());
        exit('');
    end;

    procedure TestConnection()
    var
        Config: Record "IPC Config";
        TempIPCAddressLookup: Record "IPC Address Lookup" temporary;
        StatusCode: Integer;
        ReasonPhrase: Text;
    begin
        if not GetConfiguration(Config) then
            Error(ConfigNotSetupErr);

        if IsNullGuid(Config."API Key") then
            Error(ApiKeyConfigErr);

        if Config.GetAPIPasswordAsSecret(Config."API Key").IsEmpty() then
            Error(ApiKeyConfigErr);

        SearchAddress('SW1A 2AE', TempIPCAddressLookup, StatusCode, ReasonPhrase);
        if StatusCode <> 200 then
            Message(ConnectionFailedErr + ' ' + StrSubstNo(ResponseDetailsTxt, StatusCode, ReasonPhrase))
        else
            Message(ConnectionSuccessMsg);
        exit;
    end;

    procedure IsConfigured(): Boolean
    var
        Config: Record "IPC Config";
    begin
        if not GetConfiguration(Config) then
            exit(false);

        exit(Config.Enabled and not IsNullGuid(Config."API Key"));
    end;
}