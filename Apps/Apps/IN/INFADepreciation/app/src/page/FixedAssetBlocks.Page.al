// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.FADepreciation;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Depreciation;

page 18632 "Fixed Asset Blocks"
{
    Caption = 'Fixed Asset Blocks';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Fixed Asset Block";

    layout
    {
        area(content)
        {
            repeater("")
            {
                field("FA Class Code"; Rec."FA Class Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the FA Class Code for FA Block.';
                    ApplicationArea = FixedAssets;
                }
                field(Code; Rec.Code)
                {
                    ToolTip = 'Specifies the code for FA Block.';
                    ApplicationArea = FixedAssets;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description for FA Block.';
                    ApplicationArea = FixedAssets;
                }
                field("Book Value"; Rec."Book Value")
                {
                    ToolTip = 'Specifies the total book value for FA Block.';
                    ApplicationArea = FixedAssets;
                }
                field("Depreciation %"; Rec."Depreciation %")
                {
                    ToolTip = 'Specifies the applicable depreciation % for FA Block.';
                    ApplicationArea = FixedAssets;
                }
                field("Add. Depreciation %"; Rec."Add. Depreciation %")
                {
                    ToolTip = 'Specifies the additional depreciation % for FA Block.';
                    ApplicationArea = FixedAssets;
                }
                field("No. of Assets"; Rec."No. of Assets")
                {
                    Visible = true;
                    ToolTip = 'Specifies the number of assets in FA Block.';
                    ApplicationArea = FixedAssets;

                    trigger OnDrillDown()
                    var
                        FixedAsset: Record "Fixed Asset";
                        FADeprBook: Record "FA Depreciation Book";
                    begin
                        FixedAsset.Reset();
                        FADeprBook.Reset();
                        FADeprBook.SetRange("FA Block Code", Rec.Code);
                        FADeprBook.SetRange("FA Book Type", FADeprBook."FA Book Type"::"Income Tax");
                        FADeprBook.SetRange("Disposal Date", 0D);
                        if FADeprBook.FindSet() then
                            repeat
                                FixedAsset.Get(FADeprBook."FA No.");
                                FixedAsset.Mark(true);
                            until FADeprBook.Next() = 0;
                        FixedAsset.MarkedOnly(true);
                        Page.RunModal(Page::"Fixed Asset List", FixedAsset);
                    end;
                }
            }
        }
    }
}
