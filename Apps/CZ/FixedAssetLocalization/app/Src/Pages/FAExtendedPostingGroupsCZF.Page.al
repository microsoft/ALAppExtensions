// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

page 31245 "FA Extended Posting Groups CZF"
{
    Caption = 'FA Extended Posting Groups';
    DataCaptionFields = "FA Posting Group Code", "FA Posting Type", "Code";
    PageType = List;
    SourceTable = "FA Extended Posting Group CZF";
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("FA Posting Type"; Rec."FA Posting Type")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the fixed asset posting type (disposal, acquisition, maintenance ...).';
                }
                field("Code"; Rec.Code)
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the code for the extended fixed asset posting group.';
                }
                field("Sales Acc. On Disp. (Gain)"; Rec."Sales Acc. On Disp. (Gain)")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the sales account on FA disposal (Gain).';
                }
                field("Sales Acc. On Disp. (Loss)"; Rec."Sales Acc. On Disp. (Loss)")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the sales account on FA disposal (Los).';
                }
                field("Book Val. Acc. on Disp. (Gain)"; Rec."Book Val. Acc. on Disp. (Gain)")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the general ledger account for the book value gain account.';
                }
                field("Book Val. Acc. on Disp. (Loss)"; Rec."Book Val. Acc. on Disp. (Loss)")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the general ledger account for the book value loss account.';
                }
                field("Maintenance Expense Account"; Rec."Maintenance Expense Account")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the general ledger account number to post maintenance expenses for fixed assets to in this posting group.';
                }
                field("Maintenance Balance Account"; Rec."Maintenance Balance Account")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the general ledger maintenance balance account.';
                }
                field("Allocated Book Value % (Gain)"; Rec."Allocated Book Value % (Gain)")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the allocation gain book value percentage for fixed assets.';
                    Visible = false;
                }
                field("Allocated Book Value % (Loss)"; Rec."Allocated Book Value % (Loss)")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the allocation loss book value percentage for fixed assets.';
                    Visible = false;
                }
                field("Allocated Maintenance %"; Rec."Allocated Maintenance %")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the allocated maintenance percentage for the fixed asset posting group.';
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }
}
