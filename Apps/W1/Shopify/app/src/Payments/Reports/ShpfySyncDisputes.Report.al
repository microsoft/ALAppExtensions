namespace Microsoft.Integration.Shopify;

report 30120 "Shpfy Sync Disputes"
{
    ApplicationArea = All;
    Caption = 'Shopify Sync Disputes';
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
                Sync.SetShop(Shop);
                Sync.UpdateUnfinishedDisputes();
                Sync.ImportNewDisputes();
            end;
        }
    }
}