// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.FinanceCharge;

using Microsoft.Finance.TaxEngine.TaxTypeHandler;

pageextension 18171 "GST Issued Fin Charge Memo" extends "Issued Finance Charge Memo"
{
    layout
    {
        addafter(Posting)
        {
            group("Tax Information")
            {
                field("Invoice Type"; Rec."Invoice Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Invoice type as per GST law.';
                }
                field("GST Bill-to State Code"; Rec."GST Bill-to State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the state code of Customer of the entry.';
                }
                field("GST Ship-to State Code"; Rec."GST Ship-to State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ship to state code of Customer of the entry.';
                }
                field("Location State Code"; Rec."Location State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location state of the entry.';
                }
                field("Location GST Reg. No."; Rec."Location GST Reg. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Registration number of the Location specified on the entry.';
                }
                field("Customer GST Reg. No."; Rec."Customer GST Reg. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Registration number of the Customer specified on the entry.';
                }
                field("GST Customer Type"; Rec."GST Customer Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of the customer. For example, Registered, Unregistered, Export etc..';
                }
                field("Nature of Supply"; Rec."Nature of Supply")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the nature of GST transaction. For example, B2B/B2C.';
                }
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ship to code of the Customer used for this entry.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location code for the entry.';
                }
                field("GST Without Payment of Duty"; Rec."GST Without Payment of Duty")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the invoice is a GST invoice with or without payment of duty.';
                }
                field("Ship-to GST Reg. No."; Rec."Ship-to GST Reg. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Registration number of the ship to code related to the Customer specified on the entry.';
                }
            }
        }
        addfirst(factboxes)
        {
            part(TaxInformation; "Tax Information Factbox")
            {
                Provider = FinChrgMemoLines;
                // Const Table -  Issued Finance Charge Memo Line
                SubPageLink = "Table ID Filter" = const(305), "Document No. Filter" = field("Finance Charge Memo No."), "Line No. Filter" = field("Line No.");
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
