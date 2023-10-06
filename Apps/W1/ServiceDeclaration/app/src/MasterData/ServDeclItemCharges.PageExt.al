// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item;

using Microsoft.Service.Reports;

pageextension 5013 "Serv. Decl. Item Charges" extends "Item Charges"
{
    layout
    {
        addafter("Search Description")
        {
            field("Service Transaction Type Code"; Rec."Service Transaction Type Code")
            {
                ApplicationArea = ItemCharges;
                ToolTip = 'Specifies the code for a service transaction type.';
                Visible = EnableServTransType;
            }
            field("Exclude From Service Decl."; Rec."Exclude From Service Decl.")
            {
                ApplicationArea = ItemCharges;
                ToolTip = 'Specifies whether an item must be excluded from the service declaration.';
                Visible = UseServDeclaration;
            }
        }
    }

    var
        UseServDeclaration: Boolean;
        EnableServTransType: Boolean;

    trigger OnOpenPage()
    var
        ServiceDeclarationMgt: Codeunit "Service Declaration Mgt.";
    begin
        UseServDeclaration := ServiceDeclarationMgt.IsFeatureEnabled();
        EnableServTransType := ServiceDeclarationMgt.IsServTransTypeEnabled();
    end;
}
