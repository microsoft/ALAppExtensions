// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.History;

page 30153 "Shpfy Order Fulfillment"
{
    Caption = 'Shopify Fulfillment';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    SourceTable = "Shpfy Order Fulfillment";
    UsageCategory = None;
    PromotedActionCategories = 'New,Process,Report,Fulfillment,Inspect';

    layout
    {
        area(content)
        {
            group(General)
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
            part(Lines; "Shpfy Order Fulfillment Lines")
            {
                ApplicationArea = All;
                Caption = 'Lines';
                SubPageLink = "Fulfillment Id" = field("Shopify Fulfillment Id");
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
                RunPageLink = "Shpfy Fulfillment Id" = field("Shopify Fulfillment Id");
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
