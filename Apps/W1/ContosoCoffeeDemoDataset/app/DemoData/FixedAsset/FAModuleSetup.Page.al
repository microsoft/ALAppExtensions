// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.FixedAsset;

page 4760 "FA Module Setup"
{
    PageType = Card;
    ApplicationArea = FixedAssets;
    Caption = 'Fixed Assets Module Setup';
    SourceTable = "FA Module Setup";
    Extensible = false;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group("Setup Data")
            {
                field("Default Depr. Book"; Rec."Default Depreciation Book")
                {
                    ToolTip = 'Specifies the default depreciation book to use for the scenarios.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InitRecord();
    end;
}
