// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.FixedAsset;

using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FADepreciation;

pageextension 18636 "Fixed Asset Card Ext" extends "Fixed Asset Card"
{
    layout
    {
        addafter(Blocked)
        {
            field("Add. Depr. Applicable"; Rec."Add. Depr. Applicable")
            {
                ToolTip = 'Specifies if additional depreciation is applicable for the asset for Income Tax Depreciation Book.';
                ApplicationArea = FixedAssets;
            }
        }
        addafter(DepreciationBook)
        {
            group(Posting)
            {
                field("FA Block Code"; Rec."FA Block Code")
                {
                    ToolTip = 'Specifies the FA Block Code for Income tax Depreciation Book.';
                    ApplicationArea = FixedAssets;

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                    end;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ToolTip = 'Specifies the general product posting group for the fixed asset.';
                    ApplicationArea = FixedAssets;
                }
            }
        }
    }

    actions
    {
        addbefore("Depreciation &Books")
        {
            action("Calculate FA Depreciation")
            {
                ApplicationArea = FixedAssets;
                Caption = 'Calculate FA Depreciation';
                Ellipsis = true;
                Image = CalculateDepreciation;
                ToolTip = 'Calculates depreciation according to conditions that you specify. if the related depreciation book is set up to integrate with the general ledger, then the calculated entries are transferred to the fixed asset general ledger journal. Otherwise, the calculated entries are transferred to the fixed asset journal. You can then review the entries and post the journal.';

                trigger OnAction()
                var
                    FixedAsset: Record "Fixed Asset";
                begin
                    FixedAsset.SetRange("No.", Rec."No.");
                    Report.RunModal(Report::"Calculate FA Depreciation", true, false, FixedAsset);
                end;
            }
            action("&Shift")
            {
                ApplicationArea = FixedAssets;
                Caption = 'Fixed Asset Shift';
                Ellipsis = true;
                Image = CalculateDepreciation;
                ToolTip = 'Calculates depreciation according to conditions that you specify. if the related depreciation book is set up to integrate with the general ledger, then the calculated entries are transferred to the fixed asset general ledger journal. Otherwise, the calculated entries are transferred to the fixed asset journal. You can then review the entries and post the journal.';

                trigger OnAction()
                var
                    FADeprBook: Record "FA Depreciation Book";
                    FixedAssetShifts: Record "Fixed Asset Shift";
                    FixedAssetShiftPage: Page "Fixed Asset Shifts";
                begin
                    CurrPage.DepreciationBook.Page.GetRecord(FADeprBook);
                    if not (FADeprBook."FA Book Type" = FADeprBook."FA Book Type"::" ") then
                        exit;

                    FixedAssetShifts.Reset();
                    FixedAssetShifts.SetRange("FA No.", FADeprBook."FA No.");
                    FixedAssetShifts.SetRange("Depreciation Book Code", FADeprBook."Depreciation Book Code");
                    FixedAssetShifts.SetRange("Fixed Asset Posting Group", FADeprBook."FA Posting Group");
                    if not FixedAssetShifts.FindLast() then begin
                        FixedAssetShifts."FA No." := FADeprBook."FA No.";
                        FixedAssetShifts."Depreciation Book Code" := FixedAssetShifts."Depreciation Book Code";
                        FixedAssetShifts."Depreciation Starting Date" := FADeprBook."Depreciation Starting Date";
                    end;

                    FixedAssetShiftPage.SetTableView(FixedAssetShifts);
                    FixedAssetShiftPage.Run();
                end;
            }
        }
    }
}
