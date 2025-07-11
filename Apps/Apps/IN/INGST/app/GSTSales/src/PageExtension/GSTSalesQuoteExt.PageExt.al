// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Finance.GST.Sales;
using Microsoft.Finance.TaxBase;

pageextension 18153 "GST Sales Quote Ext" extends "Sales Quote"
{
    layout
    {
        modify("Document Date")
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
        modify("Ship-to Code")
        {
            trigger OnAfterValidate()
            var
                GSTSalesValidation: Codeunit "GST Sales Validation";
            begin
                CurrPage.SaveRecord();
                GSTSalesValidation.UpdateGSTJurisdictionTypeFromPlaceOfSupply(Rec);
                GSTSalesValidation.CallTaxEngineOnSalesHeader(Rec);
            end;
        }
        addfirst("Tax Info")
        {
            field("Invoice Type"; Rec."Invoice Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Type of Invoice.';
            }
            field("POS Out Of India"; Rec."POS Out Of India")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the place of supply of invoice is out of India.';
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
            field("E-Commerce Customer"; Rec."E-Commerce Customer")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the customer number for which merchant id has to be recorded.';
            }
            field("E-Comm. Merchant Id"; Rec."E-Comm. Merchant Id")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the merchant ID provided to customers by their payment processor.';
            }
            field("Reference Invoice No."; Rec."Reference Invoice No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Reference Invoice number.';
            }
            field("GST Without Payment of Duty"; Rec."GST Without Payment of Duty")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the quotation is with or without payment of duty.';

                trigger OnValidate()
                var
                    GSTSalesValidation: Codeunit "GST Sales Validation";
                begin
                    CurrPage.SaveRecord();
                    GSTSalesValidation.CallTaxEngineOnSalesHeader(Rec);
                end;
            }
            field("GST Invoice"; Rec."GST Invoice")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if GST is applicable.';
            }
            field("GST Customer Type"; Rec."GST Customer Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Customer Type';
            }
            field("Location State Code"; Rec."Location State Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the sate code mentioned in location used in the transaction.';
            }
            field("Location GST Reg. No."; Rec."Location GST Reg. No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST Registration number of the Location specified on the journal line.';
            }
            field("Customer GST Reg. No."; Rec."Customer GST Reg. No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST registration number of the Customer specified on the journal line.';
            }
        }
    }
    actions
    {
        modify(Dimensions)
        {
            trigger OnAfterAction()
            var
                PostingNoSeries: Record "Posting No. Series";
                Record: Variant;
            begin
                Record := Rec;
                PostingNoSeries.GetPostingNoSeriesCode(Record);
                Rec := Record;
                Rec.Modify(true);
            end;
        }
    }

    var
}

