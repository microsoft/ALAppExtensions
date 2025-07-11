// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item;

using Microsoft.Service.Reports;

pageextension 5012 "Serv. Decl. Item Card" extends "Item Card"
{
    layout
    {
        addafter(VariantMandatoryDefaultNo)
        {
            field("Service Transaction Type Code"; Rec."Service Transaction Type Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code for a service transaction type.';
                Editable = IsService;
                Visible = EnableServTransType;
            }
            field("Exclude From Service Decl."; Rec."Exclude From Service Decl.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether an item must be excluded from the service declaration.';
                Editable = IsService;
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
