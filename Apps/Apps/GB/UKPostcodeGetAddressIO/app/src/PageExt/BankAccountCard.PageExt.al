// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if CLEAN27
namespace app.app;

using Microsoft.Bank.BankAccount;
using Microsoft.Foundation.Address;

pageextension 50000 "Bank Account Card" extends "Bank Account Card"
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
                ShowPostcodeLookup(false);
            end;
        }
        modify("Country/Region Code")
        {
            trigger OnBeforeValidate()
            begin
                HandleAddressLookupVisibility();
            end;
        }
        addfirst(Communication)
        {
            group(Control1040007_GB)
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
                        ShowPostcodeLookup(true);
                    end;
                }
            }
        }
        moveafter("Address 2"; City, CountyGroup)
    }
    var
        IsAddressLookupTextEnabled: Boolean;
        LookupAddressLbl: Label 'Lookup address from postcode';

    local procedure ShowPostcodeLookup(ShowInputFields: Boolean)
    var
        TempEnteredAutocompleteAddress: Record "Autocomplete Address" temporary;
        TempAutocompleteAddress: Record "Autocomplete Address" temporary;
        PostcodeBusinessLogic: Codeunit "Postcode Business Logic GB";
    begin
        if not PostcodeBusinessLogic.SupportedCountryOrRegionCode(Rec."Country/Region Code") then
            exit;

        if not PostcodeBusinessLogic.IsConfigured() or ((Rec."Post Code" = '') and not ShowInputFields) then
            exit;

        TempEnteredAutocompleteAddress.Address := Rec.Address;
        TempEnteredAutocompleteAddress.Postcode := Rec."Post Code";

        if not PostcodeBusinessLogic.ShowLookupWindow(TempEnteredAutocompleteAddress, ShowInputFields, TempAutocompleteAddress) then
            exit;

        CopyAutocompleteFields(TempAutocompleteAddress);
        HandleAddressLookupVisibility();
    end;

    local procedure HandleAddressLookupVisibility()
    var
        PostcodeBusinessLogic: Codeunit "Postcode Business Logic GB";
    begin
        if not CurrPage.Editable or not PostcodeBusinessLogic.IsConfigured() then
            IsAddressLookupTextEnabled := false
        else
            IsAddressLookupTextEnabled := PostcodeBusinessLogic.SupportedCountryOrRegionCode(Rec."Country/Region Code");
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

    trigger OnAfterGetCurrRecord()
    begin
        HandleAddressLookupVisibility();
    end;
}
#endif