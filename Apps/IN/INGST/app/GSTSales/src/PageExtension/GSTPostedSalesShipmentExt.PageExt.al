// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.History;

pageextension 18145 "GST Posted Sales Shipment Ext" extends "Posted Sales Shipment"
{
    layout
    {
        addafter("Billing")
        {
            group("Tax Information")
            {
                field("GST Bill-to State Code"; Rec."GST Bill-to State Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the bill-to state code of the customer on the sales document.';
                }
                field("GST Ship-to State Code"; Rec."GST Ship-to State Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the ship-to state code of the customer on the sales document.';
                }
                field("Location State Code"; Rec."Location State Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the sate code mentioned of the location on the sales document.';
                }
                field("Invoice Type"; Rec."Invoice Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the invoice type on the sales document. For example, Bill of supply, export, supplementary, debit note, non-GST and taxable.';
                }
                field("Nature of Supply"; Rec."Nature of Supply")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the nature of GST transaction. For example, B2B/B2C.';
                }
                field("GST Customer Type"; Rec."GST Customer Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the type of the customer. For example, Registered, Unregistered, Export etc..';
                }
                field("GST Without Payment of Duty"; Rec."GST Without Payment of Duty")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies if the invoice is a GST invoice with or without payment of duty.';
                }

                field("Bill Of Export No."; Rec."Bill Of Export No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the bill of export number. It is a document number which is submitted to custom department.';
                }
                field("Bill Of Export Date"; Rec."Bill Of Export Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the entry date defined in bill of export document.';
                }
                field("E-Commerce Customer"; Rec."E-Commerce Customer")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the customer number for which merchant id has to be recorded.';
                }
                field("E-Comm. Merchant Id"; Rec."E-Comm. Merchant Id")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the merchant ID provided to customers by their payment processor.';
                }
                field("POS Out Of India"; Rec."POS Out Of India")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies if the place of supply of invoice is out of India.';
                }
                field("Date of Removal"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Date of Removal';
                    ToolTip = 'Specifies the date of removal.';
                }
                field("Time of Removal"; Rec."Time of Removal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the time of removal.';
                }
                field("Mode of Transport"; Rec."Mode of Transport")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transportation mode e.g. by road, by air etc.';
                }
            }
        }
    }

    var
}
