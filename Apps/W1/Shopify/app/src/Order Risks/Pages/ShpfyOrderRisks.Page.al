namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Order Risks (ID 30123).
/// </summary>
page 30123 "Shpfy Order Risks"
{
    Caption = 'Shopify Order Risks';
    PageType = List;
    SourceTable = "Shpfy Order Risk";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Provider"; Rec.Provider)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the provider of the Shopify Order Risk.';
                }
                field(Level; Rec.Level)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the level of the Shopify Order Risk.';
                }
                field("Message"; Rec.Message)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the message that''s displayed to the merchant to indicate the results of the fraud check.';
                }
                field(Sentiment; Rec.Sentiment)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sentiment of the Shopify Order Risk.';
                }
            }
        }
    }

}
