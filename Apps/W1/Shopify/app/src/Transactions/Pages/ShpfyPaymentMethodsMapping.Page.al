// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Payment Methods Mapping(ID 30132).
/// </summary>
page 30132 "Shpfy Payment Methods Mapping"
{

    Caption = 'Shopify Payment Methods Mapping';
    PageType = List;
    SourceTable = "Shpfy Payment Method Mapping";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Gateway; Rec.Gateway)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the Shopify Transaction Gateway.';
                }
                field(CreditCardCompany; Rec."Credit Card Company")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the Shopify Credit Card Company.';
                }
                field(PaymentMethod; Rec."Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the corresponding payment method in D365BC.';
                }
            }
        }
    }

}