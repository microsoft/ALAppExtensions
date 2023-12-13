// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Transfer;

pageextension 31239 "Transfer Order CZA" extends "Transfer Order"
{
    layout
    {
        addafter("In-Transit Code")
        {
            field("Gen.Bus.Post.Group Ship CZA"; Rec."Gen.Bus.Post.Group Ship CZA")
            {
                ApplicationArea = Location;
                ToolTip = 'Specifies general bussiness posting group for items ship.';

                trigger OnValidate()
                begin
                    UpdateLinesAfterValidateGenBusPostGroup();
                end;
            }
            field("Gen.Bus.Post.Group Receive CZA"; Rec."Gen.Bus.Post.Group Receive CZA")
            {
                ApplicationArea = Location;
                ToolTip = 'Specifies general bussiness posting group for items receive.';

                trigger OnValidate()
                begin
                    UpdateLinesAfterValidateGenBusPostGroup();
                end;
            }
        }
    }

    local procedure UpdateLinesAfterValidateGenBusPostGroup()
    begin
        CurrPage.TransferLines.PAGE.UpdateForm(false);
    end;
}
