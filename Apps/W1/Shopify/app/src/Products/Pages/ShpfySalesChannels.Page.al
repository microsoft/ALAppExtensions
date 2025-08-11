// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

page 30167 "Shpfy Sales Channels"
{
    ApplicationArea = All;
    Caption = 'Shopify Sales Channels';
    PageType = List;
    SourceTable = "Shpfy Sales Channel";
    InsertAllowed = false;
    DeleteAllowed = false;
    UsageCategory = None;


    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Id; Rec.Id) { }
                field(Name; Rec.Name) { }
                field("Use for publication"; Rec."Use for publication") { }
                field(Default; Rec.Default) { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetSalesChannels)
            {
                ApplicationArea = All;
                Caption = 'Get Sales Channels';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = UpdateDescription;
                ToolTip = 'Retrieves the sales channels from Shopify.';

                trigger OnAction()
                var
                    ShpfySalesChannelAPI: Codeunit "Shpfy Sales Channel API";
                begin
                    ShpfySalesChannelAPI.RetrieveSalesChannelsFromShopify(CopyStr(Rec.GetFilter("Shop Code"), 1, 20));
                end;
            }
        }
    }
}