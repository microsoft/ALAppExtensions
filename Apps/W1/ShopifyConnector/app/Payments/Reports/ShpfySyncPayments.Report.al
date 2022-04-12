/// <summary>
/// Report Shpfy Sync Payments (ID 30105).
/// </summary>
report 30105 "Shpfy Sync Payments"
{
    ApplicationArea = All;
    Caption = 'Shopify Sync Payments';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(Shop; "Shpfy Shop")
        {
            RequestFilterFields = Code;

            trigger OnAfterGetRecord()
            var
                Sync: Codeunit "Shpfy Payments";
            begin
                Sync.Run(Shop);
            end;
        }
    }
}
