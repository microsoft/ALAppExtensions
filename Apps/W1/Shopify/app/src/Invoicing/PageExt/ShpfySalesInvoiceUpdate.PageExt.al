namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.History;

/// <summary>
/// PageExtension Shpfy Sales Invoice Update (ID 30125) extends Record Posted Sales Inv. - Update.
/// </summary>
pageextension 30125 "Shpfy Sales Invoice Update" extends "Posted Sales Inv. - Update"
{
    layout
    {
        addlast(content)
        {
            group(Shopify)
            {
                Caption = 'Shopify';
                Visible = ShopifyTabVisible;

                field("Shpfy Order Id"; Rec."Shpfy Order Id")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Shopify Order Id';
                    Editable = (Rec."Shpfy Order Id" = 0) or (Rec."Shpfy Order Id" = -1) or (Rec."Shpfy Order Id" = -2);
                    ToolTip = 'Specifies the Shopify Order ID. Helps track the status of invoices within Shopify, with 0 indicating readiness to synchronize, -1 indicating an error, and -2 indicating that the shipment is skipped.';

                    trigger OnValidate()
                    begin
                        if not (Rec."Shpfy Order Id" in [0, -1, -2]) then
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
        ValueNotAllowedErr: Label 'Allowed values are 0, -1 or -2. 0 indicates readiness to synchronize, -1 indicates an error, and -2 indicates that the invoice is skipped.';
}