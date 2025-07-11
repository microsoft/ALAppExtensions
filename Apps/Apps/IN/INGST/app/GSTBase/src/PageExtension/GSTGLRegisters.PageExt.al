// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Ledger;

using Microsoft.Finance.GST.Base;

pageextension 18017 "GST G/L Registers" extends "G/L Registers"
{
    actions
    {
        addafter("Item Ledger Relation")
        {
            action("GST Ledger Entries")
            {
                ApplicationArea = Basic, Suite;
                Image = CollectedTax;
                ToolTip = ' View the GST Ledger Entries that resulted in the current register entry.';

                trigger OnAction()
                var
                    GSTBaseValidation: Codeunit "GST Base Validation";
                begin
                    GSTBaseValidation.OpenGSTEntries(Rec."From Entry No.", Rec."To Entry No.");
                end;
            }
            action("Detailed GST Ledger Entries")
            {
                ApplicationArea = Basic, Suite;
                Image = CollectedTax;
                ToolTip = 'View the GST Ledger entries in detail line wise that resulted in the current register entry.';

                trigger OnAction()
                var
                    GSTBaseValidation: Codeunit "GST Base Validation";
                begin
                    GSTBaseValidation.OpenDetailedGSTEntries(Rec."From Entry No.", Rec."To Entry No.");
                end;
            }
        }
    }
}
