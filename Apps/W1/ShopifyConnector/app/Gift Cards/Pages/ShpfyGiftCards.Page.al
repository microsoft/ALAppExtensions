/// <summary>
/// Page Shpfy Gift Cards (ID 30110).
/// </summary>
page 30110 "Shpfy Gift Cards"
{

    ApplicationArea = All;
    Caption = 'Shopify Gift Cards';
    PageType = List;
    SourceTable = "Shpfy Gift Card";
    UsageCategory = Documents;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Id; Rec.Id)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the id of the Shopify gift card.';
                }
                field(LastCharacters; Rec."Last Characters")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the last characters of the gift card code.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount of the Shopify gift card.';
                }
                field(KnownUsedAmount; Rec."Known Used Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the balance of the gift card.';
                }
            }
            part(Transaction; "Shpfy Gift Card Transactions")
            {
                ApplicationArea = All;
                Caption = 'Known Transactions';
                SubPageLink = "Gift Card Id" = field(Id);
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

}
