// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Address;

page 10505 "Postcode Search GB"
{
    Caption = 'Postcode Search';
    DataCaptionExpression = '';
    PageType = StandardDialog;
    SourceTable = "Autocomplete Address";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            field(PostcodeField; Rec.Postcode)
            {
                ApplicationArea = Invoicing, Basic, Suite;
                Caption = 'Postcode';
                Lookup = true;
                ShowMandatory = true;
            }
            field(DeliveryPoint; Rec.Address)
            {
                ApplicationArea = Invoicing, Basic, Suite;
                Caption = 'Delivery Point';
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        TempFullAutocompleteAddress: Record "Autocomplete Address" temporary;
    begin
        TempFullAutocompleteAddress.Init();
        Rec := TempFullAutocompleteAddress;
        Rec.Postcode := AutocompletePostcode;
        Rec.Address := AutcompleteDeliveryPoint;
        Rec."Country / Region" := 'GB';
        Rec.Insert();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::Cancel then
            exit(true);
    end;

    var
        AutocompletePostcode: Text[20];
        AutcompleteDeliveryPoint: Text[50];

    [Scope('OnPrem')]
    procedure SetValues(NewPostcode: Text[20]; NewDeliveryPoint: Text[50])
    begin
        AutocompletePostcode := NewPostcode;
        AutcompleteDeliveryPoint := NewDeliveryPoint;
    end;

    [Scope('OnPrem')]
    procedure GetValues(var ResultPostcode: Text; var ResultDeliveryPoint: Text)
    begin
        ResultPostcode := Rec.Postcode;
        ResultDeliveryPoint := Rec.Address;
    end;
}

