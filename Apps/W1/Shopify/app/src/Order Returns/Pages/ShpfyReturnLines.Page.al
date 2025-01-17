namespace Microsoft.Integration.Shopify;

page 30149 "Shpfy Return Lines"
{
    Caption = 'Return Lines';
    PageType = ListPart;
    SourceTable = "Shpfy Return Line";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'The quantity being returned.';
                }
                field("Return Reason"; Rec."Return Reason")
                {
                    ApplicationArea = All;
                    ToolTip = 'The reason for returning the item.';
                }
                field("Refundable Quantity"; Rec."Refundable Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'The quantity that can be refunded.';
                }
                field("Refunded Quantity"; Rec."Refunded Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'The quantity that was refunded.';
                }
                field("Discounted Total Amount"; Rec."Discounted Total Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'The total line price after all discounts on the line item, including both line item level discounts and code-based line item discounts, are applied.';
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                    ToolTip = 'The weight value using the unit.';
                }
                field("Weight Unit"; Rec."Weight Unit")
                {
                    ApplicationArea = All;
                    ToolTip = 'The unit of measurement.';
                }
            }
            group(ReturnReason)
            {
                Caption = 'Return Reason';
                Visible = ReturnReasonNoteVisible;

                field("Return Reason Note"; Rec.GetReturnReasonNote())
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ShowCaption = false;
                    ToolTip = 'The reason for returning the item.';
                }
            }
            group(CustomerNote)
            {
                Caption = 'Customer Note';
                Visible = CustomerNoteVisible;

                field("Customer Note"; Rec.GetCustomerNote())
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ShowCaption = false;
                    ToolTip = 'A note from the customer that describes the item to be returned.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RetrievedShopifyData)
            {
                ApplicationArea = All;
                Caption = 'Retrieved Shopify Data';
                Image = Entry;
                ToolTip = 'View the data retrieved from Shopify.';

                trigger OnAction();
                var
                    DataCapture: Record "Shpfy Data Capture";
                begin
                    DataCapture.SetCurrentKey("Linked To Table", "Linked To Id");
                    DataCapture.SetRange("Linked To Table", Database::"Shpfy Return Line");
                    DataCapture.SetRange("Linked To Id", Rec.SystemId);
                    Page.Run(Page::"Shpfy Data Capture List", DataCapture);
                end;
            }
        }
    }

    var
        ReturnReasonNoteVisible: Boolean;
        CustomerNoteVisible: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        ReturnReasonNoteVisible := Rec."Return Reason Note".HasValue();
        CustomerNoteVisible := Rec."Customer Note".HasValue();
    end;
}