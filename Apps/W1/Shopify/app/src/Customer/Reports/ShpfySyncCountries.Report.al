/// <summary>
/// Report Shpfy Sync Countries (ID 30110).
/// </summary>
report 30110 "Shpfy Sync Countries"
{
    ApplicationArea = All;
    Caption = 'Shopify Sync Countries';
    UsageCategory = Tasks;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Shop; "Shpfy Shop")
        {
            RequestFilterFields = Code;

            trigger OnAfterGetRecord()
            begin
                Codeunit.Run(Codeunit::"Shpfy Sync Countries", Shop)
            end;
        }
    }
}
