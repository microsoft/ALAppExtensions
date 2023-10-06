// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.Purchase;

pageextension 18086 "GST Purchase Quote Ext" extends "Purchase Quote"
{
    layout
    {
        modify(ShippingOptionWithLocation)
        {
            trigger OnAfterValidate()
            begin
                GstPurchaseSubscriber.SetLocationCodeVisibleForQuoteandInvoice(IsLocationVisible, ShipToOptions);
            end;
        }
        modify(Control55)
        {
            Visible = IsLocationVisible;
        }
        modify("Document Date")
        {
            trigger OnAfterValidate()
            var
                GSTBaseValidation: Codeunit "GST Base Validation";
            begin
                CurrPage.SaveRecord();
                GSTBaseValidation.CallTaxEngineOnPurchHeader(Rec);
            end;
        }
        modify("Location Code")
        {
            ShowMandatory = ShipToOptions = ShipToOptions::"Custom Address";
            trigger OnAfterValidate()
            var
                GSTBaseValidation: Codeunit "GST Base Validation";
            begin
                CurrPage.SaveRecord();
                GSTBaseValidation.CallTaxEngineOnPurchHeader(Rec);
            end;
        }
        modify("Currency Code")
        {
            trigger OnAfterValidate()
            var
                GSTBaseValidation: Codeunit "GST Base Validation";
            begin
                CurrPage.SaveRecord();
                GSTBaseValidation.CallTaxEngineOnPurchHeader(Rec);
            end;
        }
        addafter("Foreign Trade")
        {
            group("Tax Information ")
            {
                field("GST Vendor Type"; Rec."GST Vendor Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor type for GST transaction';
                }
                field("Bill of Entry Date"; Rec."Bill of Entry Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry date defined in bill of entry document.';
                }
                field("Bill of Entry No."; Rec."Bill of Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bill of entry number. It is a document number which is submitted to custom department .';
                }
                field("Bill of Entry Value"; Rec."Bill of Entry Value")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the values as mentioned in bill of entry document.';
                }
                field("Invoice Type"; Rec."Invoice Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of the quote created. For example, Self Invoice/Debit Note/Supplementary/Non-GST.';
                }
                field("POS Out Of India"; Rec."POS Out Of India")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the place of supply of invoice is out of India.';

                    trigger OnValidate()
                    var
                        GSTBaseValidation: Codeunit "GST Base Validation";
                    begin
                        CurrPage.SaveRecord();
                        GSTBaseValidation.CallTaxEngineOnPurchHeader(Rec);
                    end;
                }
                field("Associated Enterprises"; Rec."Associated Enterprises")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if Vendor is an associated enterprises';
                }
                field("Location State Code"; Rec."Location State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the state code mentioned in location used in the transaction.';
                }
                field("Location GST Reg. No."; Rec."Location GST Reg. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Registration number of the Location specified on the journal line.';
                }
                field("Vendor GST Reg. No."; Rec."Vendor GST Reg. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST registration number of the Vendor specified on the journal line.';
                }
                field("Order Address GST Reg. No."; Rec."Order Address GST Reg. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST registration number of the mentioned order address in the transaction.';
                }
                field("GST Order Address State"; Rec."GST Order Address State")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the state code of the mentioned order address in the transaction.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        GstPurchaseSubscriber.SetLocationCodeVisibleForQuoteandInvoice(IsLocationVisible, ShipToOptions);
    end;

    var
        GstPurchaseSubscriber: Codeunit "GST Purchase Subscribers";
        [InDataSet]
        IsLocationVisible: Boolean;
}
