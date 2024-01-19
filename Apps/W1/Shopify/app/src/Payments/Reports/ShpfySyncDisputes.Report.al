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
            DataItemTableView = where(Enabled = const(true));
            trigger OnAfterGetRecord()
            var
                Sync: codeunit "Shpfy Payments";
            begin
                Sync.SetShop(Shop);
                Sync.UpdateDisputeStatus();
            end;
        }
    }
}
