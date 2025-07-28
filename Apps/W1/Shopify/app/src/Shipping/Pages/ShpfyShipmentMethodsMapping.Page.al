// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Shipment Methods Mapping (ID 30129).
/// </summary>
page 30129 "Shpfy Shipment Methods Mapping"
{
    Caption = 'Shopify Shipment Methods';
    PageType = List;
    SourceTable = "Shpfy Shipment Method Mapping";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the delivery method in Shopify.';
                }
                field("Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping method in D365BC.';
                }
                field("Shipping Charges Type"; Rec."Shipping Charges Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipping Charges Type field.';
                }
                field("Shipping Charges No."; Rec."Shipping Charges No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = Rec."Shipping Charges Type" <> Rec."Shipping Charges Type"::" ";
                    ToolTip = 'Specifies the value of the Shipping Charges No. field.';
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the shipping agent who is transporting the items.';
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the service, such as a one-day delivery, that is offered by the shipping agent.';
                }
            }
        }
    }

}
