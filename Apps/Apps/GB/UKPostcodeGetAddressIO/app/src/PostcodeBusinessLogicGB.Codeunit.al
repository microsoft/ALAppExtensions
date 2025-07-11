// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Address;

using Microsoft.Utilities;

codeunit 9099 "Postcode Business Logic GB"
{
    Permissions = TableData "Post Code" = rimd;

    trigger OnRun()
    begin
        SavePostcode := true;
    end;

    var
        PostcodeServiceManager: Codeunit "Postcode Service Manager";
        SavePostcode: Boolean;
        UKPostcodeAutocompleteLbl: Label 'UK Postcode Service';
        NoDataRetrievedErr: Label 'Postal code service did not return any results.';
        SavePostcodeSet: Boolean;
        DiscoverabilityMessageMsg: Label 'You can retrieve and validate addresses based on postcodes.';
        ConfigureTok: Label 'Configure';
        DontShowAgainTok: Label 'Don''t show again';
        NotificationIdTok: Label '3c379efc-509e-4f20-8c0e-e65f9d535a04', Locked = true;
        DisabledTok: Label 'Disabled', Locked = true;

    procedure ShowLookupWindow(var TempEnteredAutocompleteAddress: Record "Autocomplete Address" temporary; ShowInputPage: Boolean; var TempAutocompleteAddress: Record "Autocomplete Address" temporary): Boolean
    var
        TempAddressListNameValueBuffer: Record "Name/Value Buffer" temporary;
        RepeatProcess: Boolean;
    begin
        // Scenarios:
        // 1.
        // -- Postcode input page is opened address enetered
        // -  - Postocode input page is cancaled => EXIT(FALSE)
        // -  - Postcode input page is confirmed
        // -    - Address selection is canceled => return to postcode input
        // -    - Address selection is confirmed => set the address and EXIT(TRUE)
        // 2.
        // -- Postcode is provided, therefore postcode input is skipped
        // -- Address selection window opened with a list of possible addresses
        // -  - Address selection is canceled => EXIT(FALSE), do not show postcode input page
        // -  - Address selection is confirmed => set the address and EXIT(TRUE)

        if not ShowInputPage then
            TempEnteredAutocompleteAddress.Address := '';

        RepeatProcess := true;
        if not SavePostcodeSet then
            SavePostcode := true; // Default to true

        while RepeatProcess do begin
            if ShowInputPage then
                if not ShowPostcodeInputFields(TempEnteredAutocompleteAddress.Postcode, TempEnteredAutocompleteAddress.Address) then
                    exit(false);

            // TRIM
            TempEnteredAutocompleteAddress.Postcode := DelChr(TempEnteredAutocompleteAddress.Postcode, '<>', ' ');
            TempEnteredAutocompleteAddress.Address := DelChr(TempEnteredAutocompleteAddress.Address, '<>', ' ');

            Clear(TempAddressListNameValueBuffer);
            if not PostcodeServiceManager.GetAddressList(TempEnteredAutocompleteAddress, TempAddressListNameValueBuffer) then
                exit;

            // No data retrieved - raise error
            if TempAddressListNameValueBuffer.IsEmpty() then
                Error(NoDataRetrievedErr);

            if ShowAddressSelection(TempAddressListNameValueBuffer) then
                RepeatProcess := false // Everything finished OK
            else
                if not ShowInputPage then // ONLY Repeat the process if we showed the input page
                    exit;
        end;

        PostcodeServiceManager.GetAddress(TempAddressListNameValueBuffer, TempEnteredAutocompleteAddress, TempAutocompleteAddress);

        if SavePostcode then
            CreateNewPostcodeIfNotExists(TempAutocompleteAddress);

        exit(true);
    end;

    procedure ShowDiscoverabilityNotificationIfNeccessary()
    var
        PostcodeNotificationMemory: Record "Postcode Notification Memory";
        TempServiceListNameValueBuffer: Record "Name/Value Buffer" temporary;
        PostcodeServiceConfig: Record "Postcode Service Config";
        DiscoverabilityNotification: Notification;
        RecExists: Boolean;
    begin
        PostcodeServiceManager.DiscoverPostcodeServices(TempServiceListNameValueBuffer);
        if TempServiceListNameValueBuffer.IsEmpty() then
            exit;

        if PostcodeNotificationMemory.Get(UserId) then
            exit;

        RecExists := PostcodeServiceConfig.FindFirst();
        if RecExists and (PostcodeServiceConfig.GetServiceKey() <> DisabledTok) then
            exit;

        DiscoverabilityNotification.Id(NotificationIdTok);
        DiscoverabilityNotification.Message(DiscoverabilityMessageMsg);
        DiscoverabilityNotification.AddAction(ConfigureTok, CODEUNIT::"Postcode Business Logic GB", 'NotificationOnConfigure');
        DiscoverabilityNotification.AddAction(DontShowAgainTok, CODEUNIT::"Postcode Business Logic GB", 'NotificationOnDontShowAgain');
        DiscoverabilityNotification.Send();
    end;

    procedure NotificationOnConfigure(Notification: Notification)
    begin
        PAGE.Run(PAGE::"Postcode Configuration Page");
        DisableNotificationForUser();
    end;

    procedure NotificationOnDontShowAgain(Notification: Notification)
    begin
        DisableNotificationForUser();
    end;

    procedure IsConfigured(): Boolean
    begin
        exit(PostcodeServiceManager.IsConfigured());
    end;

    procedure SetSavePostcode(NewValue: Boolean)
    begin
        SavePostcode := NewValue;
        SavePostcodeSet := true; // Mark that we set the value
    end;

    procedure IsSavePostcodeEnabled(): Boolean
    begin
        exit(SavePostcode);
    end;

    internal procedure SupportedCountryOrRegionCode(CountryOrRegionCode: Code[10]): Boolean
    begin
        exit(CountryOrRegionCode in ['GB', 'UK', '']);
    end;

    local procedure CreateNewPostcodeIfNotExists(var TempAutocompleteAddress: Record "Autocomplete Address" temporary)
    var
        PostCode: Record "Post Code";
    begin
        if (TempAutocompleteAddress.City = '') or
           (TempAutocompleteAddress.Postcode = '')
        then
            exit;

        // Entered postcode already exists
        PostCode.SetRange(Code, TempAutocompleteAddress.Postcode);
        PostCode.SetRange(City, TempAutocompleteAddress.City);
        if not PostCode.IsEmpty() then
            exit;

        // Otherwise create one
        PostCode.Init();
        PostCode.Code := TempAutocompleteAddress.Postcode;
        PostCode.City := TempAutocompleteAddress.City;
        PostCode."Search City" := UpperCase(TempAutocompleteAddress.City);
        PostCode."Country/Region Code" := TempAutocompleteAddress."Country / Region";
        PostCode.County := TempAutocompleteAddress.County;
        PostCode.Insert();
        Commit();
    end;

    local procedure DisableNotificationForUser()
    var
        PostcodeNotificationMemory: Record "Postcode Notification Memory";
    begin
        if PostcodeNotificationMemory.Get(UserId) then
            exit;

        PostcodeNotificationMemory.Init();
        PostcodeNotificationMemory.UserId := UserId;
        PostcodeNotificationMemory.Insert();
    end;

    local procedure ShowPostcodeInputFields(var Postcode: Text[20]; var DeliveryPoint: Text[100]): Boolean
    var
        PostcodeSearch: Page "Postcode Search";
    begin
        PostcodeSearch.SetValues(Postcode, '');
        if PostcodeSearch.RunModal() = ACTION::Cancel then
            exit(false);

        PostcodeSearch.GetValues(Postcode, DeliveryPoint);
        exit(true);
    end;

    local procedure ShowAddressSelection(var TempAddressNameValueBuffer: Record "Name/Value Buffer" temporary): Boolean
    var
        PostcodeSelectAddress: Page "Postcode Select Address";
        PageResultAction: Action;
    begin
        // Show lookup window only if there are multiple records, otherwise input s output
        if TempAddressNameValueBuffer.Count > 1 then begin
            PostcodeSelectAddress.LookupMode(true);
            PostcodeSelectAddress.SetAddressList(TempAddressNameValueBuffer);

            PageResultAction := PostcodeSelectAddress.RunModal();
            if (PageResultAction = ACTION::Cancel) or (PageResultAction = ACTION::LookupCancel) then
                exit(false);

            // Retrieve choosen address
            Clear(TempAddressNameValueBuffer);
            PostcodeSelectAddress.GetSelectedAddress(TempAddressNameValueBuffer);
        end;

        exit(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Connection", 'OnRegisterServiceConnection', '', false, false)]
    local procedure RegisterServiceOnRegisterServiceConnection(var ServiceConnection: Record "Service Connection")
    var
        PostcodeServiceConfig: Record "Postcode Service Config";
    begin
        if PostcodeServiceManager.IsConfigured() then
            ServiceConnection.Status := ServiceConnection.Status::Enabled
        else
            ServiceConnection.Status := ServiceConnection.Status::Disabled;

        if not PostcodeServiceConfig.FindFirst() then begin
            PostcodeServiceConfig.Init();
            PostcodeServiceConfig.Insert();
            PostcodeServiceConfig.SaveServiceKey('Disabled');
        end;

        ServiceConnection.InsertServiceConnection(ServiceConnection, PostcodeServiceConfig.RecordId,
          UKPostcodeAutocompleteLbl, '', PAGE::"Postcode Configuration Page");
    end;
}

