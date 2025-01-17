namespace Microsoft.SubscriptionBilling;

page 8039 "Usage Data Generic Import API"
{
    APIPublisher = 'microsoft';
    APIGroup = 'subsBilling';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    ModifyAllowed = false;
    InsertAllowed = true;
    DelayedInsert = true;
    DeleteAllowed = false;
    EntityName = 'usageDataGenericImport';
    EntitySetName = 'usageDataGenericImports';
    PageType = API;
    SourceTable = "Usage Data Generic Import";
    ODataKeyFields = SystemId;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(customerId; Rec."Customer ID") { }
                field(customerName; Rec."Customer Name") { }
                field(invoiceId; Rec."Invoice ID") { }
                field(subscriptionId; Rec."Subscription ID") { }
                field(subscriptionName; Rec."Subscription Name") { }
                field(subscriptionDescription; Rec."Subscription Description") { }
                field(subscriptionStartDate; Rec."Subscription Start Date") { }
                field(subscriptionEndDate; Rec."Subscription End Date") { }
                field(billingPeriodStartDate; Rec."Billing Period Start Date") { }
                field(billingPeriodEndDate; Rec."Billing Period End Date") { }
                field(productId; Rec."Product ID") { }
                field(productName; Rec."Product Name") { }
                field(cost; Rec.Cost) { }
                field(costAmount; Rec."Cost Amount") { }
                field(quantity; Rec.Quantity) { }
                field(discount; Rec.Discount) { }
                field(tax; Rec.Tax) { }
                field(price; Rec.Price) { }
                field(amount; Rec.Amount) { }
                field(currency; Rec.Currency) { }
                field(unit; Rec.Unit) { }
                field(text1; Rec.Text1) { }
                field(text2; Rec.Text2) { }
                field(text3; Rec.Text3) { }
                field(decimal1; Rec.Decimal1) { }
                field(decimal2; Rec.Decimal2) { }
                field(decimal3; Rec.Decimal3) { }
                field(systemId; Rec.SystemId) { }
                field(systemModifiedAt; Rec.SystemModifiedAt) { }
            }
        }
    }
}
