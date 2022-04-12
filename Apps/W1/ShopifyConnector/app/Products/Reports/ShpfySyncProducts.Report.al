/// <summary>
/// Report Shpfy Sync Products (ID 30108).
/// </summary>
report 30108 "Shpfy Sync Products"
{
    Caption = 'Shopify Sync Products';
    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Shop; "Shpfy Shop")
        {
            RequestFilterFields = Code;

            trigger OnAfterGetRecord()
            var
                Sync: Codeunit "Shpfy Sync Products";
            begin
                if OnlySyncPrices then
                    Sync.SetOnlySyncPriceOn();
                Sync.Run(Shop);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                field(OnlySyncPrice; OnlySyncPrices)
                {
                    Caption = 'Only Sync Price';
                    Tooltip = 'Only sync prices from D365BC to Shopify';
                    ApplicationArea = All;
                }
            }
        }
    }

    var
        OnlySyncPrices: Boolean;
}