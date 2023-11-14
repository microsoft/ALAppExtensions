// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Counting.Journal;

reportextension 11702 "Calculate Inventory CZA" extends "Calculate Inventory"
{
    requestpage
    {
        layout
        {
            addlast(Options)
            {
                field(ItemsWithoutChangeCZA; ItemsWithoutChangeCZA)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Items without Change';
                    ToolTip = 'Specifies if you want to insert lines for items that do not change.';
                }
                field(UseItemDimensionsCZA; UseItemDimensionsCZA)
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Use Item Dimensions';
                    ToolTip = 'Specifies if the item dimensions will be used for inventory entries.';
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        OnBeforeOnPreReportCZA(ItemsWithoutChangeCZA, UseItemDimensionsCZA);
    end;

    var
        CalculateInventHandlerCZA: Codeunit "Calculate Invent. Handler CZA";
        ItemsWithoutChangeCZA, UseItemDimensionsCZA : Boolean;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnPreReportCZA(ItemsWithoutChangeCZA: Boolean; UseItemDimensionsCZA: Boolean)
    begin
    end;
}
