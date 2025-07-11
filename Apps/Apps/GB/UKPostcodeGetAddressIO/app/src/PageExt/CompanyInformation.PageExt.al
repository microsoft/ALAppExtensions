// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if CLEAN27
namespace app.app;

using Microsoft.Foundation.Company;
using Microsoft.Foundation.Address;

pageextension 50003 "Company Information" extends "Company Information"
{
    layout
    {
        modify(Address)
        {
            trigger OnBeforeValidate()
            var
                PostcodeBusinessLogic: Codeunit "Postcode Business Logic GB";
            begin
                PostcodeBusinessLogic.ShowDiscoverabilityNotificationIfNeccessary();
            end;
        }
        modify("Post Code")
        {
            trigger OnBeforeValidate()
            var
                PostcodeBusinessLogic: Codeunit "Postcode Business Logic GB";
            begin
                PostcodeBusinessLogic.ShowDiscoverabilityNotificationIfNeccessary();
                ShowPostcodeLookup(false, AddressTok);
            end;
        }
        modify("Country/Region Code")
        {
            trigger OnAfterValidate()
            begin
                HandleAddressLookupVisibility();
            end;
        }
        modify("Ship-to Country/Region Code")
        {
            trigger OnBeforeValidate()
            begin
                HandleAddressLookupVisibility();
            end;
        }
        addfirst(Shipping)
        {
            group(Control1040016_GB)
            {
                ShowCaption = false;
                Visible = IsShipToAddressLookupTextEnabled;
                field(ShipToLookupAddress_GB; LookupAddressLbl)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;

                    trigger OnDrillDown()
                    begin
                        ShowPostcodeLookup(true, ShipToTok);
                    end;
                }
            }
        }
        addfirst(General)
        {
            group(Control1040003_GB)
            {
                ShowCaption = false;
                Visible = IsAddressLookupTextEnabled;
                field(LookupAddress_GB; LookupAddressLbl)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;

                    trigger OnDrillDown()
                    begin
                        ShowPostcodeLookup(true, AddressTok);
                    end;
                }
            }
        }
    }

    var
        IsAddressLookupTextEnabled: Boolean;
        IsShipToAddressLookupTextEnabled: Boolean;
        AddressTok: Label 'ADDRESS', Locked = true;
        ShipToTok: Label 'SHIP-TO', Locked = true;
        LookupAddressLbl: Label 'Lookup address from postocde';

    local procedure ShowPostcodeLookup(ShowInputFields: Boolean; Group: Text)
    var
        TempEnteredAutocompleteAddress: Record "Autocomplete Address" temporary;
        TempAutocompleteAddress: Record "Autocomplete Address" temporary;
        PostcodeBusinessLogic: Codeunit "Postcode Business Logic GB";
    begin
        if not PostcodeBusinessLogic.IsConfigured() then
            exit;

        if Group = AddressTok then begin
            if not PostcodeBusinessLogic.SupportedCountryOrRegionCode(Rec."Country/Region Code") then
                exit;

            if (Rec."Post Code" = '') and not ShowInputFields then
                exit;

            TempEnteredAutocompleteAddress.Address := Rec.Address;
            TempEnteredAutocompleteAddress.Postcode := Rec."Post Code";
        end else
            if Group = ShipToTok then begin
                if not PostcodeBusinessLogic.SupportedCountryOrRegionCode(Rec."Country/Region Code") then
                    exit;

                if (Rec."Ship-to Post Code" = '') and not ShowInputFields then
                    exit;

                TempEnteredAutocompleteAddress.Address := Rec."Ship-to Address";
                TempEnteredAutocompleteAddress.Postcode := Rec."Ship-to Post Code";
            end;

        if not PostcodeBusinessLogic.ShowLookupWindow(TempEnteredAutocompleteAddress, ShowInputFields, TempAutocompleteAddress) then
            exit;

        if Group = AddressTok then
            CopyAutocompleteFields(TempAutocompleteAddress)
        else
            if Group = ShipToTok then
                CopyShipToAutocompleteFields(TempAutocompleteAddress);
    end;

    local procedure CopyAutocompleteFields(var TempAutocompleteAddress: Record "Autocomplete Address" temporary)
    begin
        Rec.Address := TempAutocompleteAddress.Address;
        Rec."Address 2" := TempAutocompleteAddress."Address 2";
        Rec."Post Code" := TempAutocompleteAddress.Postcode;
        Rec.City := TempAutocompleteAddress.City;
        Rec.County := TempAutocompleteAddress.County;
        Rec."Country/Region Code" := TempAutocompleteAddress."Country / Region";
    end;

    local procedure CopyShipToAutocompleteFields(var TempAutocompleteAddress: Record "Autocomplete Address" temporary)
    begin
        Rec."Ship-to Address" := TempAutocompleteAddress.Address;
        Rec."Ship-to Address 2" := TempAutocompleteAddress."Address 2";
        Rec."Ship-to Post Code" := TempAutocompleteAddress.Postcode;
        Rec."Ship-to City" := TempAutocompleteAddress.City;
        Rec."Ship-to County" := TempAutocompleteAddress.County;
        Rec."Ship-to Country/Region Code" := TempAutocompleteAddress."Country / Region";
    end;

    local procedure HandleAddressLookupVisibility()
    var
        PostcodeBusinessLogic: Codeunit "Postcode Business Logic GB";
    begin
        if not CurrPage.Editable or not PostcodeBusinessLogic.IsConfigured() then begin
            IsAddressLookupTextEnabled := false;
            IsShipToAddressLookupTextEnabled := false;
        end else begin
            IsAddressLookupTextEnabled := PostcodeBusinessLogic.SupportedCountryOrRegionCode(Rec."Country/Region Code");
            IsShipToAddressLookupTextEnabled := PostcodeBusinessLogic.SupportedCountryOrRegionCode(Rec."Ship-to Country/Region Code");
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        HandleAddressLookupVisibility();
    end;
}
#endif