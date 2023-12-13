// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Dimension;

pageextension 31261 "Account Type Default Dim. CZA" extends "Account Type Default Dim."
{
    layout
    {
        addlast(Control1)
        {
            field("Automatic Create CZA"; Rec."Automatic Create CZA")
            {
                ApplicationArea = Dimensions;
                ToolTip = 'Specifies if a value will be created automatically.';
            }
            field("Dim. Description Field ID CZA"; Rec."Dim. Description Field ID CZA")
            {
                ApplicationArea = Dimensions;
                ToolTip = 'Specifies the ID of dimension description field.';
            }
            field("Dim. Description Fld. Name CZA"; Rec."Dim. Description Fld. Name CZA")
            {
                ApplicationArea = Dimensions;
                ToolTip = 'Specifies the name of dimension description field.';
                Visible = false;
                DrillDown = false;
            }
            field("Dim. Description Update CZA"; Rec."Dim. Description Update CZA")
            {
                ApplicationArea = Dimensions;
                ToolTip = 'Specifies the rule for dimension description update.';
            }
            field("Dim. Description Format CZA"; Rec."Dim. Description Format CZA")
            {
                ApplicationArea = Dimensions;
                ToolTip = 'Specifies a description format for the dimension value.';
            }
            field("Auto. Create Value Posting CZA"; Rec."Auto. Create Value Posting CZA")
            {
                ApplicationArea = Dimensions;
                ToolTip = 'Specifies a value posting for automatically created dimension value.';
            }
        }
    }

    actions
    {
        addlast("F&unctions")
        {
            action(UpdateAutomaticDefaultDimensionsCZA)
            {
                ApplicationArea = Dimensions;
                Caption = 'Update automatic default dimensions';
                ToolTip = 'Enables to update default dimension values.';
                Image = MapDimensions;

                trigger OnAction()
                var
                    SelectedDefaultDimension: Record "Default Dimension";
                    DimensionAutoCreateMgt: Codeunit "Dimension Auto.Create Mgt. CZA";
                begin
                    CurrPage.SetSelectionFilter(SelectedDefaultDimension);
                    DimensionAutoCreateMgt.UpdateAllAutomaticDimValues(SelectedDefaultDimension);
                end;
            }
        }
    }
}
