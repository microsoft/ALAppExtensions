// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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
                if RecordCount <> -1 then
                    Sync.SetNumberOfRecords(RecordCount);
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
                    Tooltip = 'Specifies if only prices are synchronized from Business Central to Shopify';
                    ApplicationArea = All;
                }
                field(NumberOfRecords; RecordCount)
                {
                    Caption = 'Number of Records';
                    Tooltip = 'Specifies the of records to synchronize';
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    var
        OnlySyncPrices: Boolean;
        RecordCount: Integer;
}