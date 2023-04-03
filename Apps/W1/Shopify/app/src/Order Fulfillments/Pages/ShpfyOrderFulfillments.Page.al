/// <summary>
/// Page Shpfy Order Fulfillments (ID 30112).
/// </summary>
page 30112 "Shpfy Order Fulfillments"
{
    Caption = 'Shopify Order Fulfillments';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Fulfillment,Inspect';
    SourceTable = "Shpfy Order Fulfillment";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ShopifyFulfillmentId; Rec."Shopify Fulfillment Id")
                {
                    ApplicationArea = All;
                    Visible = true;
                    ToolTip = 'Specifies the id for the fulfillment in Shopify.';
                }
                field(ShopifyOrderId; Rec."Shopify Order Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the id for the order in Shopify.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of the fulfillment in Shopify. Valid values are: pending, open, success, cancelled, error, failure.';
                }
                field(CreatedAt; Rec."Created At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time when the fulfillment was created.';
                }
                field(UpdatedAt; Rec."Updated At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time when the fulfillment was last modified.';
                }
                field(TrackingNumber; Rec."Tracking Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the tracking number of the fulfillment provided by the shipping company.';
                }
                field(TrackingUrl; Rec."Tracking URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the url of the tracking page for the fulfillment.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = All;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Sales Shipment")
            {
                ApplicationArea = All;
                Caption = 'Sales Shipment';
                Image = Shipment;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Posted Sales Shipment";
                RunPageLink = "Shpfy Fulfillment Id" = FIELD("Shopify Fulfillment Id");
                RunPageMode = View;
                ToolTip = 'View related posted sales shipments.';
            }

            action("Retrieved Shopify Data")
            {
                ApplicationArea = All;
                Caption = 'Retrieved Shopify Data';
                Image = Entry;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'View the data retrieved from Shopify.';

                trigger OnAction();
                var
                    DataCapture: Record "Shpfy Data Capture";
                begin
                    DataCapture.SetCurrentKey("Linked To Table", "Linked To Id");
                    DataCapture.SetRange("Linked To Table", Database::"Shpfy Order Fulfillment");
                    DataCapture.SetRange("Linked To Id", Rec.SystemId);
                    Page.Run(Page::"Shpfy Data Capture List", DataCapture);
                end;
            }

        }
    }
}
