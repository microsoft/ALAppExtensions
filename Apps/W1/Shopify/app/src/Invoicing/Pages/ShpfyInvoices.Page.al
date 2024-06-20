namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Invoices (ID 30138).
/// </summary>
page 30138 "Shpfy Invoices" //TODO: Maybe this page is not needed?
{
    PageType = List;
    Caption = 'Shopify Invoices';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Shpfy Invoice Header";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Shopify Order Id"; Rec."Shopify Order Id")
                {
                    ToolTip = 'Specifies the value of the Shopify Order Id field.';
                }
                field("Shopify Order No."; Rec."Shopify Order No.")
                {
                    ToolTip = 'Specifies the value of the Shopify Order No. field.';
                }
            }
        }
    }
}