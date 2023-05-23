/// <summary>
/// Report Shpfy Sync Images (ID 30107).
/// </summary>
report 30107 "Shpfy Sync Images"
{
    Caption = 'Shopify Sync Images';
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
                Sync: Codeunit "Shpfy Sync Product Image";
            begin
                Sync.Run(Shop);
            end;
        }
    }
}