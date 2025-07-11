// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Reports;

using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using System.Utilities;

report 11718 "Quantity Shipped Check CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/QuantityShippedCheck.rdl';
    Caption = 'Quantity Shipped Check';
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
            column(gteShipmentFilter; ShipmentFilter)
            {
            }
            column(gteReturnFilter; ReturnFilter)
            {
            }
            column(Quantity_Shipped_CheckCaption; Quantity_Shipped_CheckCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(gteShipmentFilterCaption; gteShipmentFilterCaptionLbl)
            {
            }
            column(gteReturnFilterCaption; gteReturnFilterCaptionLbl)
            {
            }
        }
        dataitem("Sales Shipment Header"; "Sales Shipment Header")
        {
            DataItemTableView = sorting("Order No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Sell-to Customer No.", "Bill-to Customer No.", "Order Date", "Document Date";
            column(Sales_Shipment_Header__Order_No__; "Order No.")
            {
            }
            column(Sales_Shipment_Header__No__; "No.")
            {
            }
            column(Sales_Shipment_Header__Sell_to_Customer_No__; "Sell-to Customer No.")
            {
            }
            column(Sales_Shipment_Header__Sell_to_Customer_Name_; "Sell-to Customer Name")
            {
            }
            column(Sales_Shipment_Header__Bill_to_Customer_No__; "Bill-to Customer No.")
            {
            }
            column(Sales_Shipment_Header__Bill_to_Name_; "Bill-to Name")
            {
            }
            column(Sales_Shipment_Header__Order_No___Control1100162024; "Order No.")
            {
            }
            column(Sales_Shipment_Header__Posting_Date_; Format("Posting Date"))
            {
            }
            column(gteText; Text)
            {
            }
            column(Sales_Shipment_Header__No__Caption; Sales_Shipment_Header__No__CaptionLbl)
            {
            }
            column(Sales_Shipment_Header__Sell_to_Customer_No__Caption; Sales_Shipment_Header__Sell_to_Customer_No__CaptionLbl)
            {
            }
            column(Sales_Shipment_Header__Sell_to_Customer_Name_Caption; Sales_Shipment_Header__Sell_to_Customer_Name_CaptionLbl)
            {
            }
            column(Sales_Shipment_Header__Bill_to_Customer_No__Caption; FieldCaption("Bill-to Customer No."))
            {
            }
            column(Sales_Shipment_Header__Bill_to_Name_Caption; FieldCaption("Bill-to Name"))
            {
            }
            column(Sales_Shipment_Header__Order_No___Control1100162024Caption; FieldCaption("Order No."))
            {
            }
            column(Sales_Shipment_Header__Posting_Date_Caption; FieldCaption("Posting Date"))
            {
            }
            column(Sales_Shipment_Header__Order_No__Caption; Sales_Shipment_Header__Order_No__CaptionLbl)
            {
            }
            dataitem("Sales Shipment Line"; "Sales Shipment Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Line No.") where(Correction = const(false));
                column(Sales_Shipment_Line__No__; "No.")
                {
                }
                column(Sales_Shipment_Line_Description; Description)
                {
                }
                column(Sales_Shipment_Line_Quantity; Quantity)
                {
                }
                column(Sales_Shipment_Line__Quantity_Invoiced_; "Quantity Invoiced")
                {
                }
                column(Sales_Shipment_Line__Order_Line_No__; "Order Line No.")
                {
                }
                column(Sales_Shipment_Line__No__Caption; FieldCaption("No."))
                {
                }
                column(Sales_Shipment_Line_DescriptionCaption; FieldCaption(Description))
                {
                }
                column(Sales_Shipment_Line_QuantityCaption; FieldCaption(Quantity))
                {
                }
                column(Sales_Shipment_Line__Quantity_Invoiced_Caption; Sales_Shipment_Line__Quantity_Invoiced_CaptionLbl)
                {
                }
                column(Sales_Shipment_Line__Order_Line_No__Caption; Sales_Shipment_Line__Order_Line_No__CaptionLbl)
                {
                }
                column(Sales_Shipment_Line_Document_No_; "Document No.")
                {
                }
                column(Sales_Shipment_Line_Line_No_; "Line No.")
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
                lreSalesHeader: Record "Sales Header";
            begin
                Clear(Text);
                if not lreSalesHeader.Get(lreSalesHeader."Document Type"::Order, "Order No.") then
                    Text := StrSubstNo(OrderErr, "Order No.");
            end;
        }
        dataitem("Return Receipt Header"; "Return Receipt Header")
        {
            DataItemTableView = sorting("Return Order No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Sell-to Customer No.", "Bill-to Customer No.", "Order Date", "Document Date";
            column(Return_Receipt_Header__Return_Order_No__; "Return Order No.")
            {
            }
            column(Return_Receipt_Header__No__; "No.")
            {
            }
            column(Return_Receipt_Header__Posting_Date_; Format("Posting Date"))
            {
            }
            column(Return_Receipt_Header__Return_Order_No___Control1100162048; "Return Order No.")
            {
            }
            column(Return_Receipt_Header__Bill_to_Name_; "Bill-to Name")
            {
            }
            column(Return_Receipt_Header__Bill_to_Customer_No__; "Bill-to Customer No.")
            {
            }
            column(Return_Receipt_Header__Sell_to_Customer_Name_; "Sell-to Customer Name")
            {
            }
            column(Return_Receipt_Header__Sell_to_Customer_No__; "Sell-to Customer No.")
            {
            }
            column(gteText_Control1100162053; Text)
            {
            }
            column(Return_Receipt_Header__No__Caption; Return_Receipt_Header__No__CaptionLbl)
            {
            }
            column(Return_Receipt_Header__Posting_Date_Caption; FieldCaption("Posting Date"))
            {
            }
            column(Return_Receipt_Header__Return_Order_No___Control1100162048Caption; Return_Receipt_Header__Return_Order_No___Control1100162048CaptionLbl)
            {
            }
            column(Return_Receipt_Header__Bill_to_Name_Caption; FieldCaption("Bill-to Name"))
            {
            }
            column(Return_Receipt_Header__Bill_to_Customer_No__Caption; FieldCaption("Bill-to Customer No."))
            {
            }
            column(Return_Receipt_Header__Sell_to_Customer_Name_Caption; Return_Receipt_Header__Sell_to_Customer_Name_CaptionLbl)
            {
            }
            column(Return_Receipt_Header__Sell_to_Customer_No__Caption; Return_Receipt_Header__Sell_to_Customer_No__CaptionLbl)
            {
            }
            column(Return_Receipt_Header__Return_Order_No__Caption; Return_Receipt_Header__Return_Order_No__CaptionLbl)
            {
            }
            dataitem("Return Receipt Line"; "Return Receipt Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Line No.") where(Correction = const(false));
                column(Return_Receipt_Line__No__; "No.")
                {
                }
                column(Return_Receipt_Line_Description; Description)
                {
                }
                column(Return_Receipt_Line_Quantity; Quantity)
                {
                }
                column(Return_Receipt_Line__Quantity_Invoiced_; "Quantity Invoiced")
                {
                }
                column(Return_Receipt_Line__Return_Order_Line_No__; "Return Order Line No.")
                {
                }
                column(Return_Receipt_Line__No__Caption; FieldCaption("No."))
                {
                }
                column(Return_Receipt_Line_DescriptionCaption; FieldCaption(Description))
                {
                }
                column(Return_Receipt_Line_QuantityCaption; FieldCaption(Quantity))
                {
                }
                column(Return_Receipt_Line__Quantity_Invoiced_Caption; Return_Receipt_Line__Quantity_Invoiced_CaptionLbl)
                {
                }
                column(Return_Receipt_Line__Return_Order_Line_No__Caption; Return_Receipt_Line__Return_Order_Line_No__CaptionLbl)
                {
                }
                column(Return_Receipt_Line_Document_No_; "Document No.")
                {
                }
                column(Return_Receipt_Line_Line_No_; "Line No.")
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
                lreSalesHeader: Record "Sales Header";
            begin
                Clear(Text);
                if not lreSalesHeader.Get(lreSalesHeader."Document Type"::"Return Order", "Return Order No.") then
                    Text := StrSubstNo(RetOrderErr, "Return Order No.");
            end;
        }
    }
    trigger OnPreReport()
    begin
        ReturnFilter := "Return Receipt Header".GetFilters;
        ShipmentFilter := "Sales Shipment Header".GetFilters;
    end;

    var
        ShipmentFilter: Text;
        ReturnFilter: Text;
        Text: Text;
        OrderErr: Label 'Sales Order %1 does not exists.', Comment = '%1 = number of sales order';
        RetOrderErr: Label 'Return Order %1 does not exists.', Comment = '%1 = number of return order';
        Quantity_Shipped_CheckCaptionLbl: Label 'Quantity Shipped Check';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        gteShipmentFilterCaptionLbl: Label 'Sales Shipment Filter:';
        gteReturnFilterCaptionLbl: Label 'Return Receipt Filter:';
        Sales_Shipment_Header__No__CaptionLbl: Label 'Shipment No.';
        Sales_Shipment_Header__Sell_to_Customer_No__CaptionLbl: Label 'Customer No.';
        Sales_Shipment_Header__Sell_to_Customer_Name_CaptionLbl: Label 'Customer Name';
        Sales_Shipment_Header__Order_No__CaptionLbl: Label 'Order No.';
        Sales_Shipment_Line__Quantity_Invoiced_CaptionLbl: Label 'Qty. Invoiced';
        Sales_Shipment_Line__Order_Line_No__CaptionLbl: Label 'Order Line No.';
        Return_Receipt_Header__No__CaptionLbl: Label 'Return Receipt No.';
        Return_Receipt_Header__Return_Order_No___Control1100162048CaptionLbl: Label 'Return Order No.';
        Return_Receipt_Header__Sell_to_Customer_Name_CaptionLbl: Label 'Customer Name';
        Return_Receipt_Header__Sell_to_Customer_No__CaptionLbl: Label 'Customer No.';
        Return_Receipt_Header__Return_Order_No__CaptionLbl: Label 'Ret. Order No.';
        Return_Receipt_Line__Quantity_Invoiced_CaptionLbl: Label 'Qty. Invoiced';
        Return_Receipt_Line__Return_Order_Line_No__CaptionLbl: Label 'Order Line No.';
}
