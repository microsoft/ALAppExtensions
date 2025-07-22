// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Order Tax Lines (ID 30168).
/// </summary>
page 30168 "Shpfy Order Tax Lines"
{
    Caption = 'Shopify Order Tax Lines';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Fulfillment,Inspect';
    SourceTable = "Shpfy Order Tax Line";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Title; Rec.Title)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the title of the tax line.';
                }
                field(Rate; Rec.Rate)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the rate of the tax line.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount of the tax line.';
                }
                field("Rate %"; Rec."Rate %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the rate percentage of the tax line.';
                }
            }
        }
    }
}
