// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Finance.GST.Sales;

pageextension 18146 "GST Sales Credit Memo Ext" extends "Sales Credit Memo"
{
    layout
    {
        addbefore("Location Code")
        {
            field("Ship-to Customer"; Rec."Ship-to Customer")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Ship to Customer code on the sales document.';
            }
            field("Ship-to Code"; Rec."Ship-to Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Ship to Code code on the sales document.';
            }
        }
        modify("Posting Date")
        {
            trigger OnAfterValidate()
            var
                GSTSalesValidation: Codeunit "GST Sales Validation";
            begin
                GSTSalesValidation.CallTaxEngineOnSalesHeader(Rec);
            end;
        }
        modify("Location Code")
        {
            trigger OnAfterValidate()
            var
                GSTSalesValidation: Codeunit "GST Sales Validation";
            begin
                GSTSalesValidation.CallTaxEngineOnSalesHeader(Rec);
            end;
        }
        modify("Currency Code")
        {
            trigger OnAfterValidate()
            var
                GSTSalesValidation: Codeunit "GST Sales Validation";
            begin
                GSTSalesValidation.CallTaxEngineOnSalesHeader(Rec);
            end;
        }
        addfirst("Tax Info")
        {
            field("GST Bill-to State Code"; Rec."GST Bill-to State Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the bill-to state code of the customer on the sales document.';
            }
            field("GST Ship-to State Code"; Rec."GST Ship-to State Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the ship-to state code of the customer on the sales document.';
            }
            field("Location State Code"; Rec."Location State Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the sate code mentioned of the location used in the transaction.';
            }
            field("Location GST Reg. No."; Rec."Location GST Reg. No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST registration number of the Location specified on the Sales document.';
            }
            field("Customer GST Reg. No."; Rec."Customer GST Reg. No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST registration number of the customer specified on the Sales document.';
            }
            field("Ship-to GST Reg. No."; Rec."Ship-to GST Reg. No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the ship to GST registration number of the customer specified on the Sales document.';
            }
            field("Nature of Supply"; Rec."Nature of Supply")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the nature of GST transaction. For example, B2B/B2C.';
            }
            field("GST Customer Type"; Rec."GST Customer Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type of the customer. For example, Registered, Unregistered, Export etc..';
            }
            field("Ship-to GST Customer Type"; Rec."Ship-to GST Customer Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Ship to GST Customer Type mentioned on the sales document.';
            }
            field("GST Without Payment of Duty"; Rec."GST Without Payment of Duty")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the invoice is a GST invoice with or without payment of duty.';

                trigger OnValidate()
                var
                    GSTSalesValidation: Codeunit "GST Sales Validation";
                begin
                    GSTSalesValidation.CallTaxEngineOnSalesHeader(Rec);
                end;
            }
            field("Invoice Type"; Rec."Invoice Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the invoice type on the sales document. For example, Bill of supply, export, supplementary, debit note, non-GST and taxable.';
            }
            field("Bill Of Export No."; Rec."Bill Of Export No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the bill of export number. It is a document number which is submitted to custom department .';
            }
            field("Bill Of Export Date"; Rec."Bill Of Export Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the entry date defined in bill of export document.';
            }
            field("e-Commerce Customer"; Rec."e-Commerce Customer")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the customer number for which merchant id has to be recorded.';
            }
            field("E-Comm. Merchant Id"; Rec."E-Comm. Merchant Id")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the merchant ID provided to customers by their payment processor.';
            }
            field("Distance (Km)"; Rec."Distance (Km)")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the distance on the sales document.';
            }
            field("POS Out Of India"; Rec."POS Out Of India")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the place of supply of invoice is out of India.';

                trigger OnValidate()
                var
                    GSTSalesValidation: Codeunit "GST Sales Validation";
                begin
                    GSTSalesValidation.CallTaxEngineOnSalesHeader(Rec);
                end;
            }
            field("Reference Invoice No."; Rec."Reference Invoice No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Reference Invoice number.';
            }
            field("Sale Return Type"; Rec."Sale Return Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the sale return type. For example, Sales cancellation';
            }
            field("Post GST to Customer"; Rec."Post GST to Customer")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the GST amount post to Customer';
                trigger OnValidate()
                var
                    GSTSalesValidation: Codeunit "GST Sales Validation";
                begin
                    CurrPage.SaveRecord();
                    GSTSalesValidation.CallTaxEngineOnSalesHeader(Rec);
                end;
            }
        }
    }
    actions
    {
        addafter(IncomingDocument)
        {
            action("Update Reference Invoice No.")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = Basic, Suite;
                Image = ApplyEntries;
                ToolTip = 'Specifies the function through which reference number can be updated in the document.';

                trigger OnAction()
                var
                    i: integer;
                begin
                    i := 0;
                    //blank OnAction created as we have a subscriber of this action in "Reference Invoice No. Mgt." codeunit;
                end;
            }
        }
        modify(Post)
        {
            trigger OnBeforeAction()
            var
                GSTSalesValidation: Codeunit "GST Sales Validation";
            begin
                GSTSalesValidation.ValidateGSTWithoutPaymentOfDutyOnPost(Rec);
            end;
        }
        modify(PostAndSend)
        {
            trigger OnBeforeAction()
            var
                GSTSalesValidation: Codeunit "GST Sales Validation";
            begin
                GSTSalesValidation.ValidateGSTWithoutPaymentOfDutyOnPost(Rec);
            end;
        }
        modify("Preview Posting")
        {
            trigger OnBeforeAction()
            var
                GSTSalesValidation: Codeunit "GST Sales Validation";
            begin
                GSTSalesValidation.ValidateGSTWithoutPaymentOfDutyOnPost(Rec);
            end;
        }

    }

    var
}
