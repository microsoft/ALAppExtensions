namespace Microsoft.SubscriptionBilling;

page 8007 "Overdue Service Commitments"
{
    Caption = 'Overdue Subscription Lines';
    PageType = List;
    SourceTable = "Overdue Subscription Line";
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
                    ToolTip = 'Specifies whether the Subscription Line will will be invoiced as credit (Purchase Invoice) or as debit (Sales Invoice).';
                }
                field("Partner Name"; Rec."Partner Name")
                {
                    ToolTip = 'Specifies the name of the partner who will receive the contract components and be billed by default.';
                }
                field("Contract No."; Rec."Subscription Contract No.")
                {
                    ToolTip = 'Specifies in which Contract the Subscription Line will be invoiced.';
                }
                field("Contract Description"; Rec."Sub. Contract Description")
                {
                    ToolTip = 'Specifies the description of the Contract to which the Subscription Lines are assigned to.';
                }
                field("Service Commitment Description"; Rec."Subscription Line Description")
                {
                    ToolTip = 'Specifies the description of the Subscription Line.';
                    trigger OnAssistEdit()
                    begin
                        Rec.OpenServiceObjectCard();
                    end;
                }
                field("Next Billing Date"; Rec."Next Billing Date")
                {
                    ToolTip = 'Specifies the date of the next billing possible.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the quantity from Subscription.';
                }
                field(Price; Rec.Price)
                {
                    ToolTip = 'Specifies the Unit Price for the subscription line billing period without discount.';
                }
                field("Service Amount"; Rec.Amount)
                {
                    ToolTip = 'Specifies the amount for the Subscription Line including discount.';
                }
#if not CLEAN26
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the Item No. of the Subscription.';
                    ObsoleteReason = 'Replaced by field Source No.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '26.0';
                    Visible = false;
                }
#endif
                field("Source Type"; Rec."Source Type")
                {
                    ToolTip = 'Specifies the type of the Subscription.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ToolTip = 'Specifies the No. of the Item or G/L Account of the Subscription.';
                }
                field("Contract Type"; Rec."Subscription Contract Type")
                {
                    ToolTip = 'Specifies the classification of the contract.';
                }
                field("Billing Rhythm"; Rec."Billing Rhythm")
                {
                    ToolTip = 'Specifies the Dateformula for rhythm in which the Subscription Line is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                    Visible = false;
                }
                field("Service Start Date"; Rec."Subscription Line Start Date")
                {
                    ToolTip = 'Specifies the date from which the Subscription Line is valid and will be invoiced.';
                    Visible = false;
                }
                field("Service End Date"; Rec."Subscription Line End Date")
                {
                    ToolTip = 'Specifies the date up to which the Subscription Line is valid.';
                    Visible = false;
                }
                field("Service Object No."; Rec."Subscription Header No.")
                {
                    ToolTip = 'Specifies the number of the Subscription.';
                    Visible = false;
                    trigger OnAssistEdit()
                    begin
                        Rec.OpenServiceObjectCard();
                    end;
                }
                field("Service Object Description"; Rec."Subscription Description")
                {
                    ToolTip = 'Specifies the description of the Subscription.';
                    Visible = false;
                    trigger OnAssistEdit()
                    begin
                        Rec.OpenServiceObjectCard();
                    end;
                }
                field("Discount %"; Rec."Discount %")
                {
                    ToolTip = 'Specifies the percent of the discount for the Subscription Line.';
                    Visible = false;
                }
            }
        }
    }
}
