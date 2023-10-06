// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.Purchase;

pageextension 18083 "GST Purchase invoice Ext" extends "Purchase invoice"
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
        modify(Control81)
        {
            Visible = IsLocationVisible;
        }
        modify("Posting Date")
        {
            trigger OnAfterValidate()
            var
                GSTBaseValidation: Codeunit "GST Base Validation";
            begin
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
        modify("Order Address Code")
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
            group(Application)
            {
                field("Applies-to Doc. Type"; Rec."Applies-to Doc. Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of the posted document that this document line will be applied to.';
                }
                field("Applies-to Doc. No."; Rec."Applies-to Doc. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the posted document that this document line will be applied to.';
                }
                field("Applies-to ID"; Rec."Applies-to ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ID of the entries of the entries that will be applied to when you choose the Apply entries Action.';
                }
            }
            group("Tax Information")
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
                field("Without Bill Of Entry"; Rec."Without Bill Of Entry")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the invoice is with or without bill of entry.';

                    trigger OnValidate()
                    var
                        GSTBaseValidation: Codeunit "GST Base Validation";
                    begin
                        CurrPage.SaveRecord();
                        GSTBaseValidation.CallTaxEngineOnPurchHeader(Rec);
                    end;
                }
                field("Bill of Entry Value"; Rec."Bill of Entry Value")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the values as mentioned in bill of entry document.';
                }
                field("Invoice Type"; Rec."Invoice Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of the invoice created. For example, Self Invoice/Debit Note/Supplementary/Non-GST.';
                }
                field("GST Invoice"; Rec."GST Invoice")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if GST is applicable.';
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
                field("POS as Vendor State"; Rec."POS as Vendor State")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor state code.';

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
                    ToolTip = 'Specifies that an import transaction of services from companys Associates Vendor';
                }
                field("Location State Code"; Rec."Location State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the state code mentioned in location used in the transaction.';
                }
                field("Location GST Reg. No."; Rec."Location GST Reg. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST registration number of the location that entry belongs to.';
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
                field("Nature of Supply"; Rec."Nature of Supply")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the nature of GST transaction. For example, B2B/B2C.';
                }
                field("Vehicle No."; Rec."Vehicle No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vehicle number on the sales document.';
                }
                field("Vehicle Type"; Rec."Vehicle Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vehicle type on the sales document. For example, Regular/ODC.';
                }
                field("Distance (Km)"; Rec."Distance (Km)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the distance on the purchase document.';
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the shipping agent code. For example, DHL, FedEx etc.';
                }
                field("Rate Change Applicable"; Rec."Rate Change Applicable")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if rate change is applicable on the sales document.';
                }
                field("Supply Finish Date"; Rec."Supply Finish Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the supply finish date. For example, Before rate change/After rate change.';
                }
            }
        }
        addafter("Location Code")
        {
            field("Bill to-Location(POS)"; Rec."Bill to-Location(POS)")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Bill to Location Code which is considered as Place of Supply.';
                trigger OnValidate()
                var
                    GSTBaseValidation: Codeunit "GST Base Validation";
                begin
                    CurrPage.SaveRecord();
                    GSTBaseValidation.CallTaxEngineOnPurchHeader(Rec);
                end;
            }
        }
    }
    actions
    {
        addafter(MoveNegativeLines)
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
                    i: Integer;
                begin
                    i := 0;
                    //blank OnAction created as we have a subscriber of this action in "Reference Invoice No. Mgt." codeunit;
                end;
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
        IsLocationVisible: boolean;
}
