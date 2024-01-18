// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Reports;

using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using System.Utilities;

report 11717 "Quantity Received Check CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/QuantityReceivedCheck.rdl';
    Caption = 'Quantity Received Check';
    ApplicationArea = Basic, Suite;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Header; "Integer")
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(USERID; UserId)
            {
            }
            column(gteRcptFilter; RcptFilter)
            {
            }
            column(gteReturnFilter; ReturnFilter)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(gteRcptFilterCaption; gteRcptFilterCaptionLbl)
            {
            }
            column(gteReturnFilterCaption; gteReturnFilterCaptionLbl)
            {
            }
            column(Quantity_Received_CheckCaption; Quantity_Received_CheckCaptionLbl)
            {
            }
        }
        dataitem("Purch. Rcpt. Header"; "Purch. Rcpt. Header")
        {
            DataItemTableView = sorting("Order No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Buy-from Vendor No.", "Pay-to Vendor No.", "Order Date", "Posting Date", "Expected Receipt Date";
            column(Purch__Rcpt__Header__Order_No__; "Order No.")
            {
            }
            column(Purch__Rcpt__Header__No__; "No.")
            {
            }
            column(Purch__Rcpt__Header__Buy_from_Vendor_No__; "Buy-from Vendor No.")
            {
            }
            column(Purch__Rcpt__Header__Buy_from_Vendor_Name_; "Buy-from Vendor Name")
            {
            }
            column(Purch__Rcpt__Header__Pay_to_Vendor_No__; "Pay-to Vendor No.")
            {
            }
            column(Purch__Rcpt__Header__Pay_to_Name_; "Pay-to Name")
            {
            }
            column(Purch__Rcpt__Header__Order_No___Control1100170025; "Order No.")
            {
            }
            column(Purch__Rcpt__Header__Posting_Date_; Format("Posting Date"))
            {
            }
            column(Purch__Rcpt__Header__Document_Date_; "Document Date")
            {
            }
            column(gteText; Text)
            {
            }
            column(Purch__Rcpt__Header__No__Caption; Purch__Rcpt__Header__No__CaptionLbl)
            {
            }
            column(Purch__Rcpt__Header__Buy_from_Vendor_No__Caption; Purch__Rcpt__Header__Buy_from_Vendor_No__CaptionLbl)
            {
            }
            column(Purch__Rcpt__Header__Buy_from_Vendor_Name_Caption; FieldCaption("Buy-from Vendor Name"))
            {
            }
            column(Purch__Rcpt__Header__Pay_to_Vendor_No__Caption; FieldCaption("Pay-to Vendor No."))
            {
            }
            column(Purch__Rcpt__Header__Pay_to_Name_Caption; FieldCaption("Pay-to Name"))
            {
            }
            column(Purch__Rcpt__Header__Order_No___Control1100170025Caption; FieldCaption("Order No."))
            {
            }
            column(Purch__Rcpt__Header__Posting_Date_Caption; FieldCaption("Posting Date"))
            {
            }
            column(Purch__Rcpt__Header__Document_Date_Caption; FieldCaption("Document Date"))
            {
            }
            column(Purch__Rcpt__Header__Order_No__Caption; Purch__Rcpt__Header__Order_No__CaptionLbl)
            {
            }
            dataitem("Purch. Rcpt. Line"; "Purch. Rcpt. Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Line No.") where(Correction = const(false));
                column(Purch__Rcpt__Line__No__; "No.")
                {
                }
                column(Purch__Rcpt__Line_Description; Description)
                {
                }
                column(Purch__Rcpt__Line_Quantity; Quantity)
                {
                }
                column(Purch__Rcpt__Line__Quantity_Invoiced_; "Quantity Invoiced")
                {
                }
                column(Purch__Rcpt__Line__Order_Line_No__; "Order Line No.")
                {
                }
                column(Purch__Rcpt__Line__No__Caption; FieldCaption("No."))
                {
                }
                column(Purch__Rcpt__Line_DescriptionCaption; FieldCaption(Description))
                {
                }
                column(Purch__Rcpt__Line_QuantityCaption; FieldCaption(Quantity))
                {
                }
                column(Purch__Rcpt__Line__Quantity_Invoiced_Caption; Purch__Rcpt__Line__Quantity_Invoiced_CaptionLbl)
                {
                }
                column(Purch__Rcpt__Line__Order_Line_No__Caption; Purch__Rcpt__Line__Order_Line_No__CaptionLbl)
                {
                }
                column(Purch__Rcpt__Line_Document_No_; "Document No.")
                {
                }
                column(Purch__Rcpt__Line_Line_No_; "Line No.")
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Quantity = "Quantity Invoiced" then
                        CurrReport.Skip();
                end;
            }
            trigger OnAfterGetRecord()
            var
                lrePurchHeader: Record "Purchase Header";
            begin
                Clear(Text);
                if not lrePurchHeader.Get(lrePurchHeader."Document Type"::Order, "Order No.") then
                    Text := StrSubstNo(OrderErr, "Order No.");
            end;
        }
        dataitem("Return Shipment Header"; "Return Shipment Header")
        {
            DataItemTableView = sorting("Return Order No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Buy-from Vendor No.", "Pay-to Vendor No.", "Posting Date", "Expected Receipt Date";
            column(Return_Shipment_Header__Return_Order_No__; "Return Order No.")
            {
            }
            column(Return_Shipment_Header__Buy_from_Vendor_No__; "Buy-from Vendor No.")
            {
            }
            column(Return_Shipment_Header__Document_Date_; "Document Date")
            {
            }
            column(Return_Shipment_Header__Posting_Date_; "Posting Date")
            {
            }
            column(Return_Shipment_Header__Return_Order_No___Control1100170052; "Return Order No.")
            {
            }
            column(Return_Shipment_Header__Pay_to_Name_; "Pay-to Name")
            {
            }
            column(Return_Shipment_Header__Pay_to_Vendor_No__; "Pay-to Vendor No.")
            {
            }
            column(Return_Shipment_Header__Buy_from_Vendor_Name_; "Buy-from Vendor Name")
            {
            }
            column(Return_Shipment_Header__No__; "No.")
            {
            }
            column(gteText_Control1100170057; Text)
            {
            }
            column(Return_Shipment_Header__Document_Date_Caption; FieldCaption("Document Date"))
            {
            }
            column(Return_Shipment_Header__Posting_Date_Caption; FieldCaption("Posting Date"))
            {
            }
            column(Return_Shipment_Header__Return_Order_No___Control1100170052Caption; Return_Shipment_Header__Return_Order_No___Control1100170052CaptionLbl)
            {
            }
            column(Return_Shipment_Header__Pay_to_Name_Caption; FieldCaption("Pay-to Name"))
            {
            }
            column(Return_Shipment_Header__Pay_to_Vendor_No__Caption; FieldCaption("Pay-to Vendor No."))
            {
            }
            column(Return_Shipment_Header__Buy_from_Vendor_Name_Caption; FieldCaption("Buy-from Vendor Name"))
            {
            }
            column(Return_Shipment_Header__Buy_from_Vendor_No__Caption; Return_Shipment_Header__Buy_from_Vendor_No__CaptionLbl)
            {
            }
            column(Return_Shipment_Header__No__Caption; Return_Shipment_Header__No__CaptionLbl)
            {
            }
            column(Return_Shipment_Header__Return_Order_No__Caption; Return_Shipment_Header__Return_Order_No__CaptionLbl)
            {
            }
            dataitem("Return Shipment Line"; "Return Shipment Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Line No.") where(Correction = const(false));
                column(Return_Shipment_Line__Return_Order_Line_No__; "Return Order Line No.")
                {
                }
                column(Return_Shipment_Line__Quantity_Invoiced_; "Quantity Invoiced")
                {
                }
                column(Return_Shipment_Line_Quantity; Quantity)
                {
                }
                column(Return_Shipment_Line_Description; Description)
                {
                }
                column(Return_Shipment_Line__No__; "No.")
                {
                }
                column(Return_Shipment_Line__No__Caption; FieldCaption("No."))
                {
                }
                column(Return_Shipment_Line__Return_Order_Line_No__Caption; Return_Shipment_Line__Return_Order_Line_No__CaptionLbl)
                {
                }
                column(Return_Shipment_Line__Quantity_Invoiced_Caption; Return_Shipment_Line__Quantity_Invoiced_CaptionLbl)
                {
                }
                column(Return_Shipment_Line_QuantityCaption; FieldCaption(Quantity))
                {
                }
                column(Return_Shipment_Line_DescriptionCaption; FieldCaption(Description))
                {
                }
                column(Return_Shipment_Line_Document_No_; "Document No.")
                {
                }
                column(Return_Shipment_Line_Line_No_; "Line No.")
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Quantity = "Quantity Invoiced" then
                        CurrReport.Skip();
                end;
            }
            trigger OnAfterGetRecord()
            var
                lrePurchHeader: Record "Purchase Header";
            begin
                Clear(Text);
                if not lrePurchHeader.Get(lrePurchHeader."Document Type"::"Return Order", "Return Order No.") then
                    Text := StrSubstNo(RetOrderErr, "Return Order No.");
            end;
        }
    }
    trigger OnPreReport()
    begin
        RcptFilter := "Purch. Rcpt. Header".GetFilters;
        ReturnFilter := "Return Shipment Header".GetFilters;
    end;

    var
        RcptFilter: Text;
        ReturnFilter: Text;
        Text: Text;
        OrderErr: Label 'Purchase Order %1 does not exists.', Comment = '%1 = number of purchase order';
        RetOrderErr: Label 'Return Order %1 does not exists.', Comment = '%1 = number of return order';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        gteRcptFilterCaptionLbl: Label 'Purchase Receipt Filter:';
        Purch__Rcpt__Header__No__CaptionLbl: Label 'Purch. Receipt No.';
        Purch__Rcpt__Header__Buy_from_Vendor_No__CaptionLbl: Label 'Vendor No.';
        Purch__Rcpt__Header__Order_No__CaptionLbl: Label 'Order No.';
        Purch__Rcpt__Line__Quantity_Invoiced_CaptionLbl: Label 'Qty. Invoiced';
        Purch__Rcpt__Line__Order_Line_No__CaptionLbl: Label 'Order Line No.';
        gteReturnFilterCaptionLbl: Label 'Return Shipment Filter:';
        Return_Shipment_Header__Return_Order_No___Control1100170052CaptionLbl: Label 'Return Order No.';
        Return_Shipment_Header__Buy_from_Vendor_No__CaptionLbl: Label 'Vendor No.';
        Return_Shipment_Header__No__CaptionLbl: Label 'Return Shipment No.';
        Return_Shipment_Header__Return_Order_No__CaptionLbl: Label 'Order No.:';
        Return_Shipment_Line__Return_Order_Line_No__CaptionLbl: Label 'Order Line No.';
        Return_Shipment_Line__Quantity_Invoiced_CaptionLbl: Label 'Qty. Invoiced';
        Quantity_Received_CheckCaptionLbl: Label 'Quantity Received Check';
}
