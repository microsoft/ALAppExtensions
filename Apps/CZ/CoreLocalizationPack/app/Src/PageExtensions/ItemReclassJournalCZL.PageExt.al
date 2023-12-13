// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Journal;

pageextension 11713 "Item Reclass. Journal CZL" extends "Item Reclass. Journal"
{
    layout
    {
        addafter("Document Date")
        {
            field("Invt. Movement Template CZL"; Rec."Invt. Movement Template CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the template for item movement.';

                trigger OnLookup(var Text: Text): Boolean
                var
                    InvtMovementTemplateCZL: Record "Invt. Movement Template CZL";
                begin
                    InvtMovementTemplateCZL.SetRange("Entry Type", Rec."Entry Type"::Transfer);
                    if Page.RunModal(0, InvtMovementTemplateCZL) = Action::LookupOK then
                        Rec.Validate("Invt. Movement Template CZL", InvtMovementTemplateCZL.Name);
                end;
            }
        }
    }
}
