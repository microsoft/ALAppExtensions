/// <summary>
/// Report Shpfy Create Sales Orders (ID 30103).
/// </summary>
report 30103 "Shpfy Create Sales Orders"
{
    ApplicationArea = All;
    Caption = 'Shopify Create Sales Orders';
    Description = 'Create a Sales Order in Dynamics 365 Business Central from you Shopify Order';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(Shop; "Shpfy Shop")
        {
            RequestFilterFields = Code;

            dataitem(ShopifyOrder; "Shpfy Order Header")
            {
                RequestFilterFields = "Fulfillment Status", "Financial Status";
            }

            trigger OnAfterGetRecord();
            var
                ProcessShopifyOrders: Codeunit "Shpfy Process Orders";
            begin
                ProcessShopifyOrders.SetShopifyOrderFilter(ShopifyOrder.GetView());
                ProcessShopifyOrders.Run(Shop);
            end;


        }
    }
}