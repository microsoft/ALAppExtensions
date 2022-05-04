/// <summary>
/// Page Shpfy Tax Areas (ID 30109).
/// </summary>
page 30109 "Shpfy Tax Areas"
{
    Caption = 'Shopify Tax Areas';
    PageType = ListPart;
    SourceTable = "Shpfy Tax Area";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(County; Rec.County)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sub-regions for a county, such as provinces or states.';
                }
                field(TaxAreaCode; Rec."Tax Area Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the tax area applicable to the state.';
                }
                field(VATBusPostingGroup; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the VAT business posting group applicable to the state.';
                }
            }
        }
    }
}