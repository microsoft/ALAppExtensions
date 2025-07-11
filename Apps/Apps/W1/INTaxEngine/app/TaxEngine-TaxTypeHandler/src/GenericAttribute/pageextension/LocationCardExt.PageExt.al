﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.TaxTypeHandler;

using Microsoft.Inventory.Location;

pageextension 20234 "Location Card Ext" extends "Location Card"
{
    layout
    {

        addafter(Control1905767507)
        {
            part(TaxAttributes; "Entity Value Factbox")
            {
                Visible = ShowTaxAttributes;
                Caption = 'Tax Attributes';
                UpdatePropagation = Both;
                ApplicationArea = Basic, Suite;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        AttributeManagement: Codeunit "Tax Attribute Management";
    begin
        AttributeManagement.UpdateTaxAttributeFactbox(Rec);
        ShowTaxAttributes := CurrPage.TaxAttributes.Page.SetRecordFilter(RecordId());
    end;

    var
        ShowTaxAttributes: Boolean;
}
