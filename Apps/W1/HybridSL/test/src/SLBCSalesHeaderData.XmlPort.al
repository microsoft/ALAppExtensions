// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Sales.Document;

xmlport 147655 "SL BC Sales Header Data Temp"
{
    Caption = 'BC Sales Header data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("Sales Header"; "Sales Header")
            {
                AutoSave = false;
                XmlName = 'SalesHeader';
                UseTemporary = true;

                textelement(DocumentType)
                {
                }
                textelement("No.")
                {
                }
                textelement(SellToCustomerNo)
                {
                }
                textelement(BillToCustomerNo)
                {
                }
                textelement(ShipToName)
                {
                }
                textelement(ShipToAddress)
                {
                }
                textelement(ShipToAddress2)
                {
                }
                textelement(ShipToCity)
                {
                }
                textelement(ShipToContact)
                {
                }
                textelement(OrderDate)
                {
                }
                textelement(PostingDate)
                {
                }
                textelement(PostingDescription)
                {
                }
                textelement(ShipmentMethodCode)
                {
                }
                textelement(ShipToZIPCode)
                {
                }
                textelement(ShipToState)
                {
                }
                textelement(ShipToCountryRegionCode)
                {
                }
                textelement(DocumentDate)
                {
                }
                textelement(PostingNoSeries)
                {
                }
                textelement(ShippingNoSeries)
                {
                }
                textelement(Status)
                {
                }
                textelement(ShippingAdvice)
                {
                }

                trigger OnPreXmlItem()
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;
                end;

                trigger OnBeforeInsertRecord()
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    Evaluate(TempSalesHeader."Document Type", DocumentType);
                    TempSalesHeader."No." := "No.";
                    TempSalesHeader."Sell-to Customer No." := SellToCustomerNo;
                    TempSalesHeader."Bill-to Customer No." := BillToCustomerNo;
                    TempSalesHeader."Ship-to Name" := ShipToName;
                    TempSalesHeader."Ship-to Address" := ShipToAddress;
                    TempSalesHeader."Ship-to Address 2" := ShipToAddress2;
                    TempSalesHeader."Ship-to City" := ShipToCity;
                    TempSalesHeader."Ship-to Contact" := ShipToContact;
                    Evaluate(TempSalesHeader."Order Date", OrderDate);
                    Evaluate(TempSalesHeader."Posting Date", PostingDate);
                    TempSalesHeader."Posting Description" := PostingDescription;
                    TempSalesHeader."Shipment Method Code" := ShipmentMethodCode;
                    TempSalesHeader."Ship-to Post Code" := ShipToZIPCode;
                    TempSalesHeader."Ship-to County" := ShipToState;
                    TempSalesHeader."Ship-to Country/Region Code" := ShipToCountryRegionCode;
                    Evaluate(TempSalesHeader."Document Date", DocumentDate);
                    TempSalesHeader."Posting No. Series" := PostingNoSeries;
                    TempSalesHeader."Shipping No. Series" := ShippingNoSeries;
                    if Status <> '' then
                        Evaluate(TempSalesHeader.Status, Status);
                    if ShippingAdvice <> '' then
                        Evaluate(TempSalesHeader."Shipping Advice", ShippingAdvice);
                    TempSalesHeader.Insert(false);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        CaptionRow := true;
    end;

    procedure GetExpectedSalesHeaders(var NewTempSalesHeader: Record "Sales Header" temporary)
    begin
        if TempSalesHeader.FindSet() then begin
            repeat
                NewTempSalesHeader.Copy(TempSalesHeader);
                NewTempSalesHeader.Insert();
            until TempSalesHeader.Next() = 0;
        end;
    end;

    var
        CaptionRow: Boolean;
        TempSalesHeader: Record "Sales Header" temporary;
}