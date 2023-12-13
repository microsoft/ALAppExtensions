// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Ledger;

using Microsoft.Inventory.History;
using Microsoft.Inventory.Reports;

pageextension 31010 "Item Registers CZL" extends "Item Registers"
{
    actions
    {
#pragma warning disable AL0432
        addlast(reporting)
#pragma warning restore AL0432
        {
            action(ItemRegisterQuantityCZL)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Item Register - Quantity';
                Image = GLRegisters;
                Promoted = true;
                PromotedCategory = "Report";
                ToolTip = 'Open the report for item register quantity.';


                trigger OnAction()
                var
                    ItemRegister: Record "Item Register";
                begin
                    ItemRegister.Copy(Rec);
                    ItemRegister.SetRecFilter();
                    Report.Run(Report::"Item Register - Quantity", true, false, ItemRegister);
                end;
            }
            action(ItemMovementDocumentCZL)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Item Movement Document';
                Image = Report;
                Promoted = true;
                PromotedCategory = "Report";
                ToolTip = 'Open the report for item movement documentation.';


                trigger OnAction()
                var
                    ItemRegister: Record "Item Register";
                begin
                    ItemRegister.Copy(Rec);
                    ItemRegister.SetRecFilter();
                    Report.Run(Report::"Posted Inventory Document CZL", true, false, ItemRegister);
                end;
            }
        }
    }
}
