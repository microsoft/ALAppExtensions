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
                Payments: Codeunit "Shpfy Payments";
            begin
                Payments.SetShop(Shop);
                Payments.SyncDisputes();
            end;
        }
    }
}