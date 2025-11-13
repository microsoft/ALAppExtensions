// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Address;

using Microsoft.Utilities;

page 10506 "Postcode Service Lookup GB"
{
    Caption = 'Postal code service selection';
    DelayedInsert = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = "Name/Value Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = Invoicing, Basic, Suite;
                    ToolTip = 'Specifies the name of the service to automatically insert post codes, such as GetAdress.io.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        // Add Disabled option
        PostcodeServiceManager.RegisterService(Rec, DisabledLbl, DisabledLbl);
        PostcodeServiceManager.DiscoverPostcodeServices(Rec);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        IsSuccessful: Boolean;
    begin
        if CloseAction = ACTION::LookupCancel then
            exit(true);

        // Get selection
        CurrPage.SetSelectionFilter(TempNameValueBuffer);
        Rec.SetFilter(ID, TempNameValueBuffer.GetFilter(ID));
        Rec.FindFirst();
        TempNameValueBuffer := Rec;

        if TempNameValueBuffer.Value = DisabledLbl then
            exit(true);

        PostcodeServiceManager.ShowConfigurationPage(TempNameValueBuffer.Value, IsSuccessful);

        exit(IsSuccessful);
    end;

    var
        PostcodeServiceManager: Codeunit "Postcode Service Manager";
        DisabledLbl: Label 'Disabled';
}

