// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

page 31249 "Tax Depreciation Groups CZF"
{
    ApplicationArea = FixedAssets;
    Caption = 'Tax Depreciation Groups';
    PageType = List;
    SourceTable = "Tax Depreciation Group CZF";
    UsageCategory = Administration;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Code; Rec.Code)
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the depreciation group code.';
                    ShowMandatory = true;
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the validity date of the tax depreciation group setting.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies description for deprecation groups.';
                }
                field("Depreciation Group"; Rec."Depreciation Group")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the depreciation group name.';
                }
                field("Depreciation Type"; Rec."Depreciation Type")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the method of tax depreciation – straight-line or accelerated. Intangible fixed asset has special setting.';
                }
                field("No. of Depreciation Years"; Rec."No. of Depreciation Years")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the number of years over which the asset will be depreciated.';
                }
                field("No. of Depreciation Months"; Rec."No. of Depreciation Months")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the number of months over which the asset will be depreciated.';
                }
                field("Min. Months After Appreciation"; Rec."Min. Months After Appreciation")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies minimum number of depreciation months of intangible assets after their appreciaton.';
                }
                field("Straight First Year"; Rec."Straight First Year")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies percentage rate for the first year of depreciaton.';
                }
                field("Straight Next Years"; Rec."Straight Next Years")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies percentage rate for the next years of depreciation.';
                }
                field("Straight Appreciation"; Rec."Straight Appreciation")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies percentage rate for depreciation after appreciation of assets.';
                }
                field("Declining First Year"; Rec."Declining First Year")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the coefficient for calculating depreciation in the first year of depreciation.';
                }
                field("Declining Next Years"; Rec."Declining Next Years")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the coefficient for calculating depreciation in the next years of depreciation.';
                }
                field("Declining Appreciation"; Rec."Declining Appreciation")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the coefficient for calculating depreciation after appreciation of assets.';
                }
                field("Declining Depr. Increase %"; Rec."Declining Depr. Increase %")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies percentage increase in the first year of depreciation.';
                }
            }
        }
        area(FactBoxes)
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
