namespace Microsoft.Integration.Shopify;

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
                if NumberOfRecords <> -1 then
                    Sync.SetNumberOfRecords(NumberOfRecords);
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
                field(NumberOfRecords; NumberOfRecords)
                {
                    Caption = 'Number of Records';
                    Tooltip = 'Number of records to synchronize';
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    var
        OnlySyncPrices: Boolean;
        NumberOfRecords: Integer;
}