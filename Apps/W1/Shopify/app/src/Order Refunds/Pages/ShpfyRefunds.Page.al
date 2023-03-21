page 30144 "Shpfy Refunds"
{
    ApplicationArea = All;
    Caption = 'Shopify Refunds';
    PageType = List;
    SourceTable = "Shpfy Refund Header";
    UsageCategory = Documents;
    Editable = false;
    CardPageId = "Shpfy Refund";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Refund Id"; Rec."Refund Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Refund Id.';
                }
                field("Shopify Order No."; Rec."Shopify Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The unique identifier for the order that appears on the order page in the Shopify admin and the order status page. For example, "#1001", "EN1001", or "1001-A".';
                }
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = All;
                    ToolTip = 'The date and time when the refund was created in Shopify.';
                }
                field("Updated At"; Rec."Updated At")
                {
                    ApplicationArea = All;
                    ToolTip = 'The date and time when the refund was update in Shopify';
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Sell-to Customer No.';
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Sell-to Customer Name';
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Bill-to Customer No.';
                }
                field("Bill-to Customer Name"; Rec."Bill-to Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Bill-to Customer Name.';
                }
                field("Total Refunded Amount"; Rec."Total Refunded Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'The total amount across all transactions for the refund.';
                }
                field("Is Processed"; Rec."Is Processed")
                {
                    ApplicationArea = All;
                    ToolTip = 'If this refunds already is processed into a BC document';
                }
            }
        }
        area(FactBoxes)
        {
            part(LinkedBCDocuments; "Shpfy Linked BC Documents")
            {
                Caption = 'Linked BC Documents';
                SubPageLink = "Shopify Document Type" = const("Shpfy Document Type"::"Shopify Refund"), "Shopify Document Id" = field("Refund Id");
            }
        }
    }
}
