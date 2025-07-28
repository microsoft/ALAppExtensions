// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

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
                Sync.SetProductFilter(ProductFilterTxt);
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
                field(ProductFilter; ProductFilterTxt)
                {
                    Caption = 'Items to sync';
                    Tooltip = 'Specifies the items to sync';
                    Visible = false;
                    ApplicationArea = All;
                }
            }
        }
    }

    var
        ProductFilterTxt: Text;
}