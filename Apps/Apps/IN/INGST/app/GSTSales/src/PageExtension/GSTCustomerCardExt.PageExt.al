// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Customer;

pageextension 18142 "GST Customer Card Ext" extends "Customer Card"
{
    layout
    {
        addlast("Tax Information")
        {
            group("GST")
            {
                field("GST customer Type"; Rec."GST customer Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of GST registration for the customer. For example, Registered/Un-registered/Export/Deemed Export etc..';
                }
                field("GST Registration Type"; Rec."GST Registration Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the goods and services Tax registration type of party.';
                }
                field("GST Registration No."; Rec."GST Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the customer''s goods and service tax registration number issued by authorized body.';
                }
                field("E-Commerce Operator"; Rec."E-Commerce Operator")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the party is e-commerce operator.';
                }
                field("ARN No."; Rec."ARN No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ARN number in case goods and service tax registration number is not available or applied by the party';
                }
            }
        }
    }
}
