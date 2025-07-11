namespace Microsoft.Integration.Shopify;

/// <summary>
/// Report Shpfy Sync Companies (ID 30114).
/// </summary>
report 30114 "Shpfy Sync Companies"
{
    ApplicationArea = All;
    Caption = 'Shopify Sync Companies';
    UsageCategory = Tasks;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Shop; "Shpfy Shop")
        {
            RequestFilterFields = Code;

            trigger OnAfterGetRecord()
            begin
                Codeunit.Run(Codeunit::"Shpfy Sync Companies", Shop);
            end;
        }
    }
}
