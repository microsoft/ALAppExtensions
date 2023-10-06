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
                    Editable = (Rec."Shpfy Fulfillment Id" = 0) or (Rec."Shpfy Fulfillment Id" = -1);
                    ToolTip = 'Specifies the Shopify Fulfillment ID.';

                    trigger OnValidate()
                    begin
                        if (Rec."Shpfy Fulfillment Id" <> 0) and (Rec."Shpfy Fulfillment Id" <> -1) then
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
        ValueNotAllowedErr: Label 'Allowed values are 0 or -1';
}