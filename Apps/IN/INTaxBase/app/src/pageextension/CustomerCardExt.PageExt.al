// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

using Microsoft.Sales.Customer;

pageextension 18544 "CustomerCardExt" extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            field("State Code"; Rec."State Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the customer''s state code. This state code will appear on all sales documents for the customer.';
            }
        }
        addafter(Shipping)
        {
            group("Tax Information")
            {
                field("Assessee Code"; Rec."Assessee Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Assessee Code by whom any tax or sum of money is payable';
                }
                group("PAN Details")
                {
                    field("P.A.N. No."; Rec."P.A.N. No.")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the Permanent Account No. of Party';
                    }
                    field("P.A.N. Status"; Rec."P.A.N. Status")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the PAN Status as PANAPPLIED,PANNOTAVBL,PANINVALID';
                    }
                    field("P.A.N. Reference No."; Rec."P.A.N. Reference No.")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the PAN Reference No. in case the PAN is not available or applied by the party';
                    }
                }
                field("Aggregate Turnover"; Rec."Aggregate Turnover")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the customer last year aggregate turnover is less than 10 crores or more than 10 crores';
                }
            }
        }
    }
}
