namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.History;

pageextension 30123 "Shpfy Sales Shipment Update" extends "Posted Sales Shipment - Update"
{
    layout
    {
        addlast(content)
        {
            group(Shopify)
            {
                Visible = ShopifyTabVisible;
                field("Shpfy Fulfillment Id"; Rec."Shpfy Fulfillment Id")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Shopify Fulfillment Id';
                    Editable = (Rec."Shpfy Fulfillment Id" = 0) or (Rec."Shpfy Fulfillment Id" = -1) or (Rec."Shpfy Fulfillment Id" = -2);
                    ToolTip = 'Specifies the Shopify Fulfillment ID. Helps track the status of shipments within Shopify, with 0 indicating readiness to synchronize, -1 indicating an error, and -2 indicating that the shipment is skipped.';

                    trigger OnValidate()
                    begin
                        if not (Rec."Shpfy Fulfillment Id" in [0, -1, -2]) then
                            Error(ValueNotAllowedErr);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ShopifyTabVisible := Rec."Shpfy Order Id" <> 0;
    end;

    var
        ShopifyTabVisible: Boolean;
        ValueNotAllowedErr: Label 'Allowed values are 0, -1 or -2. 0 indicates readiness to synchronize, -1 indicates an error, and -2 indicates that the shipment is skipped.';
}