namespace Microsoft.SubscriptionBilling;

page 8035 "Usage Data Billings"
{
    Caption = 'Usage Data Billings';
    SourceTable = "Usage Data Billing";
    PageType = List;
    InsertAllowed = false;
    ModifyAllowed = false;
    LinksAllowed = false;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the sequential number assigned to the record when it was created.';
                    Visible = false;
                }
                field("Usage Data Import Entry No."; Rec."Usage Data Import Entry No.")
                {
                    ToolTip = 'Specifies the sequential number of the related import that was assigned to it when it was created.';
                    Visible = false;
                }
                field("Supplier No."; Rec."Supplier No.")
                {
                    ToolTip = 'Specifies the number of the supplier to which this usage data refers.';
                    Visible = false;
                }
                field(Partner; Rec.Partner)
                {
                    ToolTip = 'Specifies whether the service partner is a customer or a vendor.';
                }
                field("Contract No."; Rec."Contract No.")
                {
                    ToolTip = 'Specifies the contract on which the usage data is billed.';
                }
                field("Contract Line No."; Rec."Contract Line No.")
                {
                    ToolTip = 'Specifies the contract line through which the usage data is billed.';
                }
                field("Service Object No."; Rec."Service Object No.")
                {
                    ToolTip = 'Specifies the number of the related service object.';
                }
                field("Service Object Description"; Rec."Service Object Description")
                {
                    ToolTip = 'Specifies the description of the related service object.';
                }
                field("Service Commitment Description"; Rec."Service Commitment Description")
                {
                    ToolTip = 'Specifies the service commitment for which the usage data is billed.';
                }
                field("Processing Date"; Rec."Processing Date")
                {
                    ToolTip = 'Specifies the date of processing.';
                }
                field("Processing Time"; Rec."Processing Time")
                {
                    ToolTip = 'Specifies the time of processing.';
                }
                field("Reason (Preview)"; Rec."Reason (Preview)")
                {
                    ToolTip = 'Specifies the preview why the last processing step failed.';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowReason();
                    end;
                }
                field("Charge Start Date"; Rec."Charge Start Date")
                {
                    ToolTip = 'Specifies the start date of the usage.';
                }
                field("Charge End Date"; Rec."Charge End Date")
                {
                    ToolTip = 'Specifies the end date of the usage.';
                }
                field("Charged Period (Days)"; Rec."Charged Period (Days)")
                {
                    ToolTip = 'Specifies the calculated period (in days).';
                }
                field("Charged Period (Hours)"; Rec."Charged Period (Hours)")
                {
                    ToolTip = 'Specifies the calculated period (in hours).';
                    Visible = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the quantity.';
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ToolTip = 'Specifies the unit cost.';
                }
                field("Cost Amount"; Rec."Cost Amount")
                {
                    ToolTip = 'Specifies the total cost.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ToolTip = 'Specifies the unit price.';
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the total amount.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the currency code.';
                }
                field("Usage Base Pricing"; Rec."Usage Base Pricing")
                {
                    ToolTip = 'Specifies the criterion used to calculate the usage based pricing.';
                }
                field("Pricing Unit Cost Surcharge %"; Rec."Pricing Unit Cost Surcharge %")
                {
                    ToolTip = 'Specifies the EK surcharge for usage-dependent pricing.';
                }
                field("Billing Line Entry No."; Rec."Billing Line Entry No.")
                {
                    ToolTip = 'Specifies the billing line through which the usage data is billed.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the document type through which the usage data will be invoiced.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the document number via which the usage data is billed.';
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ToolTip = 'Specifies the document line for which the usage data will be billed.';
                }
            }
        }
    }
}
