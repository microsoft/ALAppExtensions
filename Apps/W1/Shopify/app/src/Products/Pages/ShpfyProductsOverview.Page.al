namespace Microsoft.Integration.Shopify;

page 30143 "Shpfy Products Overview"
{
    PageType = List;
    SourceTable = "Shpfy Product";
    Caption = 'Available Shopify products';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Control)
            {
                field(Id; Rec.Id)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a unique identifier for the product. Each id is unique across the Shopify system. No two products will have the same id, even if they''re from different shops.';
                }
                field(Title; Rec.Title)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the product in Shopify.';
                }
                field("Shop Code"; "Shop Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the shop in Shopify.';
                }
                field(URLVar; URLVar)
                {
                    ApplicationArea = All;
                    ExtendedDatatype = URL;
                    Caption = 'URL';
                    ToolTip = 'Specifies the url to the product on the webshop.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Rec."Preview URL" <> '' then
            URLVar := Rec."Preview URL";
        if Rec.URL <> '' then
            URLVar := Rec.URL;
    end;

    var
        URLVar: Text[250];
}