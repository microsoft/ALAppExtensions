/// <summary>
/// Report Shpfy Sync Customers (ID 30100).
/// </summary>
report 30100 "Shpfy Sync Customers"
{
    ApplicationArea = All;
    Caption = 'Shopify Sync Customers';
    UsageCategory = Tasks;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Shop; "Shpfy Shop")
        {
            RequestFilterFields = Code;

            trigger OnAfterGetRecord()
            begin
                Codeunit.Run(Codeunit::"Shpfy Sync Customers", Shop)
            end;
        }
    }
}
