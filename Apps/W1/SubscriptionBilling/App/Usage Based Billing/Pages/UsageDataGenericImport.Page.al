namespace Microsoft.SubscriptionBilling;

page 8038 "Usage Data Generic Import"
{
    ApplicationArea = All;
    Caption = 'Usage Data Generic Import';
    PageType = List;
    SourceTable = "Usage Data Generic Import";
    UsageCategory = Lists;
    LinksAllowed = false;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Processing Status"; Rec."Processing Status")
                {
                    Style = Attention;
                    StyleExpr = Rec."Processing Status" = Rec."Processing Status"::Error;
                    ToolTip = 'Specifies whether the row has been processed. In case of an error during processing, it is displayed in the "Reason" field.';
                }
                field("Reason Preview"; Rec."Reason Preview")
                {
                    ToolTip = 'Specifies the preview why the last processing step failed.';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowReason();
                    end;
                }
                field("Service Object No."; Rec."Service Object No.")
                {
                    ToolTip = 'Specifices to which Service Object the usage data refers.';
                }
                field(CustomerId; Rec."Customer ID")
                {
                    ToolTip = 'Specifies the number of the customer at the supplier to which the usage data refers.';
                }
                field(CustomerName; Rec."Customer Name")
                {
                    ToolTip = 'Specifies the name of the customer at the supplier to which the usage data refers.';
                }
                field(InvoiceId; Rec."Invoice ID")
                {
                    ToolTip = 'Specifies the number of the invoice to which the usage data refers.';
                }
                field(SubscriptionId; Rec."Subscription ID")
                {
                    ToolTip = 'Specifies the ID of the subscription at the supplier to which the usage data refers. The ID of the subscription is stored in the "Usage data item references".';
                }
                field(SubscriptionName; Rec."Subscription Name")
                {
                    ToolTip = 'Specifies the name of the subscription at the supplier to which the usage data refers.';
                }
                field(SubscriptionDescription; Rec."Subscription Description")
                {
                    ToolTip = 'Specifies an additional description of the supplier''s subscription.';
                }
                field(SubscriptionStartDate; Rec."Subscription Start Date")
                {
                    ToolTip = 'Specifies the start date of the subscription at the supplier.';
                }
                field(SubscriptionEndDate; Rec."Subscription End Date")
                {
                    ToolTip = 'Specifies the end date of the subscription at the supplier.';
                }
                field(BillingPeriodStartDate; Rec."Billing Period Start Date")
                {
                    ToolTip = 'Specifies the start date of the billing period.';
                }
                field(BillingPeriodEndDate; Rec."Billing Period End Date")
                {
                    ToolTip = 'Specifies the end date of the billing period.';
                }
                field(ProductId; Rec."Product ID")
                {
                    ToolTip = 'Specifies the vendor''s product ID associated with the subscription. The product ID is stored in the "Usage data item references".';
                }
                field(ProductName; Rec."Product Name")
                {
                    ToolTip = 'Specifies the supplier''s product name associated with the subscription.';
                }
                field(Cost; Rec.Cost)
                {
                    ToolTip = 'Specifies the cost price for the usage data row.';
                }
                field("Cost Amount"; Rec."Cost Amount")
                {
                    ToolTip = 'Specifies the cost amount for the usage data row.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the quantity for the usage data row.';
                }
                field(Discount; Rec.Discount)
                {
                    ToolTip = 'Specifies the discount of the usage data row.';
                }
                field(Tax; Rec.Tax)
                {
                    ToolTip = 'Specifies the tax of the usage data row.';
                }
                field(Price; Rec.Price)
                {
                    ToolTip = 'Specifies the sales price for the usage data line.';
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the total amount of the usage data row.';
                }
                field(Currency; Rec.Currency)
                {
                    ToolTip = 'Specifies the currency of the usage data row.';
                }
                field(Unit; Rec.Unit)
                {
                    ToolTip = 'Specifies the unit of the usage data row.';
                }
                field(Text1; Rec.Text1)
                {
                    ToolTip = 'This field can be used for any text.';
                    Visible = false;
                }
                field(Text2; Rec.Text2)
                {
                    ToolTip = 'This field can be used for any text.';
                    Visible = false;
                }
                field(Text3; Rec.Text3)
                {
                    ToolTip = 'This field can be used for any text.';
                    Visible = false;
                }
                field(Decimal1; Rec.Decimal1)
                {
                    ToolTip = 'This field can be used for any number.';
                    Visible = false;
                }
                field(Decimal2; Rec.Decimal2)
                {
                    ToolTip = 'This field can be used for any number.';
                    Visible = false;
                }
                field(Decimal3; Rec.Decimal3)
                {
                    ToolTip = 'This field can be used for any number.';
                    Visible = false;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ExtendContract)
            {
                Caption = 'Extend Contract';
                ToolTip = 'Opens the action for creating a service object with services that directly extend the specified contracts.';
                Image = AddAction;

                trigger OnAction()
                var
                    UsageDataImport: Record "Usage Data Import";
                    UsageDataSubscription: Record "Usage Data Subscription";
                    UsageDataCustomer: Record "Usage Data Customer";
                    ExtendContractPage: Page "Extend Contract";
                begin
                    UsageDataImport.Get(Rec."Usage Data Import Entry No.");
                    UsageDataSubscription.SetRange("Supplier Reference", Rec."Subscription ID");
                    if UsageDataSubscription.FindFirst() then;
                    UsageDataCustomer.SetRange("Supplier Reference", Rec."Customer ID");
                    if UsageDataCustomer.FindFirst() then;

                    ExtendContractPage.SetParameters(UsageDataCustomer."Customer No.", '', Rec."Subscription Start Date", true);
                    ExtendContractPage.SetUsageBasedParameters(UsageDataImport."Supplier No.", UsageDataSubscription."Entry No.");
                    ExtendContractPage.RunModal();
                    CurrPage.Update();
                end;
            }
        }
        area(navigation)
        {
            action("Usage Data Customers")
            {
                Caption = 'Usage Data Customers';
                ToolTip = 'Opens the Usage data Customers.';
                Image = CustomerList;
                Scope = Repeater;

                trigger OnAction()
                var
                    UsageDataCustomer: Record "Usage Data Customer";
                    UsageDataImport: Record "Usage Data Import";
                begin
                    UsageDataImport.Get(Rec."Usage Data Import Entry No.");
                    UsageDataCustomer.SetRange("Supplier Reference", Rec."Customer ID");
                    UsageDataCustomer.SetRange("Supplier No.", UsageDataImport."Supplier No.");
                    Page.Run(0, UsageDataCustomer);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(ExtendContract_Promoted; ExtendContract)
                {
                }
                actionref("Usage Data Customers_Promoted"; "Usage Data Customers")
                {
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if Rec.GetFilter("Usage Data Import Entry No.") <> '' then
            if Rec.GetRangeMin("Usage Data Import Entry No.") <> 0 then
                Rec."Usage Data Import Entry No." := Rec.GetRangeMin("Usage Data Import Entry No.");
    end;

}
