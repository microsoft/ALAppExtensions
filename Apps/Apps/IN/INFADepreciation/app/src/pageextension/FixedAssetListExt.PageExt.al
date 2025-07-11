// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.FixedAsset;

using Microsoft.FixedAssets.FADepreciation;

pageextension 18637 "Fixed Asset List Ext" extends "Fixed Asset List"
{
    actions
    {
        modify(CalculateDepreciation)
        {
            Visible = false;
        }
        addafter(CalculateDepreciation)
        {
            action("Calculate FA Depreciation")
            {
                ApplicationArea = FixedAssets;
                Caption = 'Calculate FA Depreciation';
                Ellipsis = true;
                Image = CalculateDepreciation;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Calculate depreciation according to conditions that you specify. If the related depreciation book is set up to integrate with the general ledger, then the calculated entries are transferred to the fixed asset general ledger journal. Otherwise, the calculated entries are transferred to the fixed asset journal. You can then review the entries and post the journal.';

                trigger OnAction()
                var
                    FixedAsset: Record "Fixed Asset";
                begin
                    FixedAsset.SetRange("No.", Rec."No.");
                    Report.RunModal(Report::"Calculate FA Depreciation", true, false, FixedAsset);
                end;
            }
        }
    }
}
