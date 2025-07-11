// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Finance.GST.Sales;
using Microsoft.Finance.TaxBase;

pageextension 18150 "GST Sales Order Ext" extends "Sales Order"
{
    layout
    {
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
        addafter("Ship-to Code")
        {
            field("Ship-to Customer"; Rec."Ship-to Customer")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the alternate customer code which will be used as Ship-to-Customer, this provision is only applicable for GST calculation of export customers.';

                trigger OnValidate()
                var
                    GSTSalesValidation: Codeunit "GST Sales Validation";
                begin
                    CurrPage.SaveRecord();
                    GSTSalesValidation.CallTaxEngineOnSalesHeader(Rec);
                end;
            }
        }
        addfirst("Tax Info")
        {
            field("Invoice Type"; Rec."Invoice Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Invoice type as per GST law.';
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
                ToolTip = 'Specifies the customer number for which merchant id has to be recorded.';
            }
            field("Reference Invoice No."; Rec."Reference Invoice No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Reference Invoice number.';
            }
            field("GST Without Payment of Duty"; Rec."GST Without Payment of Duty")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the GST order is with or without payment of duty.';

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
                ToolTip = 'Specifies the type of the customer. For example, Registered/Unregistered/Export etc.';
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
            field("Payment Date"; Rec."Payment Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the payment date. For example, Before rate change/After rate change.';
            }
            field("Vehicle No."; Rec."Vehicle No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the vehicle number on the sales document.';
            }
            field("Vehicle Type"; Rec."Vehicle Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the vehicle type on the sales document. For example, Regular/ODC.  ';
            }
            field("Distance (Km)"; Rec."Distance (Km)")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the distance on the sales document.';
            }
            field(Trading; Rec.Trading)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if trading is applicable.';
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
                    i: Integer;
                begin
                    i := 0;
                    //blank OnAction created as we have a subscriber of this action in "Reference Invoice No. Mgt." codeunit;
                end;
            }
        }
        modify(PreviewPosting)
        {
            trigger OnBeforeAction()
            var
                GSTSalesValidation: Codeunit "GST Sales Validation";
            begin
                GSTSalesValidation.ValidateGSTWithoutPaymentOfDutyOnPost(Rec);
            end;
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
        modify(PostAndNew)
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
