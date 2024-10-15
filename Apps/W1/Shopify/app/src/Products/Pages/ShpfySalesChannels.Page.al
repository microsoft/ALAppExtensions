using Microsoft.Integration.Shopify;

page 30166 "Shpfy Sales Channels"
{
    ApplicationArea = All;
    Caption = 'Shpfy Sales Channels';
    PageType = List;
    SourceTable = "Shpfy Sales Channel";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Id; Rec.Id) { }
                field(Name; Rec.Name) { }
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
                    ShpfySalesChannelAPI.RetreiveSalesChannelsFromShopify();
                end;
            }
        }
    }
}