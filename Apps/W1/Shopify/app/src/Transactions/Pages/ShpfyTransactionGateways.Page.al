// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Transaction Gateways (ID 30133).
/// </summary>
page 30133 "Shpfy Transaction Gateways"
{

    Caption = 'Shopify Transaction Gateways';
    PageType = List;
    SourceTable = "Shpfy Transaction Gateway";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the gateway the transaction was issued through.';
                }
            }
        }
    }

}
