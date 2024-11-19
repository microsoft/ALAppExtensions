namespace Microsoft.SubscriptionBilling;

page 8007 "Overdue Service Commitments"
{
    Caption = 'Overdue Service Commitments';
    PageType = List;
    SourceTable = "Overdue Service Commitments";
    Editable = false;
    UsageCategory = None;
    SourceTableTemporary = true;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Partner; Rec.Partner)
                {
                    ToolTip = 'Specifies whether the service will will be invoiced as credit (Purchase Invoice) or as debit (Sales Invoice).';
                }
                field("Partner Name"; Rec."Partner Name")
                {
                    ToolTip = 'Specifies the name of the partner who will receive the contractual services and be billed by default.';
                }
                field("Contract No."; Rec."Contract No.")
                {
                    ToolTip = 'Specifies in which Contract the Service Commitment will be invoiced.';
                }
                field("Contract Description"; Rec."Contract Description")
                {
                    ToolTip = 'Specifies the description of the Contract to which the Service Commitments are assigned to.';
                }
                field("Service Commitment Description"; Rec."Service Commitment Description")
                {
                    ToolTip = 'Specifies the description of the Service Commitment.';
                    trigger OnAssistEdit()
                    begin
                        Rec.OpenServiceObjectCard();
                    end;
                }
                field("Next Billing Date"; Rec."Next Billing Date")
                {
                    ToolTip = 'Specifies the date of the next billing possible.';
                }
                field(Quantity; Rec."Quantity Decimal")
                {
                    ToolTip = 'Specifies the quantity from Service Object.';
                }
                field(Price; Rec.Price)
                {
                    ToolTip = 'Specifies the Unit Price for the service billing period without discount.';
                }
                field("Service Amount"; Rec."Service Amount")
                {
                    ToolTip = 'Specifies the amount for the service including discount.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the Item No. of the Service Object.';
                }
                field("Contract Type"; Rec."Contract Type")
                {
                    ToolTip = 'Specifies the classification of the contract.';
                }
                field("Billing Rhythm"; Rec."Billing Rhythm")
                {
                    ToolTip = 'Specifies the Dateformula for rhythm in which the service is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                    Visible = false;
                }
                field("Service Start Date"; Rec."Service Start Date")
                {
                    ToolTip = 'Specifies the date from which the service is valid and will be invoiced.';
                    Visible = false;
                }
                field("Service End Date"; Rec."Service End Date")
                {
                    ToolTip = 'Specifies the date up to which the service is valid.';
                    Visible = false;
                }
                field("Service Object No."; Rec."Service Object No.")
                {
                    ToolTip = 'Specifies the number of the Service Object.';
                    Visible = false;
                    trigger OnAssistEdit()
                    begin
                        Rec.OpenServiceObjectCard();
                    end;
                }
                field("Service Object Description"; Rec."Service Object Description")
                {
                    ToolTip = 'Specifies the description of the Service Object.';
                    Visible = false;
                    trigger OnAssistEdit()
                    begin
                        Rec.OpenServiceObjectCard();
                    end;
                }
                field("Discount %"; Rec."Discount %")
                {
                    ToolTip = 'Specifies the percent of the discount for the service.';
                    Visible = false;
                }
            }
        }
    }
}
