pageextension 1856 PurchaseOrderForecastExtension extends "Purchase Order"
{
    layout
    {
        addafter(WorkflowStatus)
        {
            part(ItemForecast; "Sales Forecast")
            {
                ApplicationArea = Suite;
                Provider = PurchLines;
                SubPageLink = "No." = Field ("No.");
                UpdatePropagation = Both;
            }
        }
    }
}

