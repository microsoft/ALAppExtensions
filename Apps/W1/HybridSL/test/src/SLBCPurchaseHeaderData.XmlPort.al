// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Purchases.Document;

xmlport 147643 "SL BC Purch. Header Data Temp"
{
    Caption = 'BC Purchase Header data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("Purchase Header"; "Purchase Header")
            {
                AutoSave = false;
                XmlName = 'PurchaseHeader';
                UseTemporary = true;

                textelement(DocumentType)
                {
                }
                textelement("No.")
                {
                }
                textelement(BuyFromVendorNo)
                {
                }
                textelement(VendorNo)
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
                textelement(PricesIncludingTax)
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
                textelement(OrderAddressCode)
                {
                }
                textelement(DocumentDate)
                {
                }
                textelement(PostingNoSeries)
                {
                }
                textelement(ReceivingNoSeries)
                {
                }
                textelement(Status)
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

                    Evaluate(TempPurchaseHeader."Document Type", DocumentType);
                    TempPurchaseHeader."No." := "No.";
                    TempPurchaseHeader."Buy-from Vendor No." := BuyFromVendorNo;
                    TempPurchaseHeader."Pay-to Vendor No." := VendorNo;
                    TempPurchaseHeader."Ship-to Name" := ShipToName;
                    TempPurchaseHeader."Ship-to Address" := ShipToAddress;
                    TempPurchaseHeader."Ship-to Address 2" := ShipToAddress2;
                    TempPurchaseHeader."Ship-to City" := ShipToCity;
                    TempPurchaseHeader."Ship-to Contact" := ShipToContact;
                    Evaluate(TempPurchaseHeader."Order Date", OrderDate);
                    Evaluate(TempPurchaseHeader."Posting Date", PostingDate);
                    TempPurchaseHeader."Posting Description" := PostingDescription;
                    TempPurchaseHeader."Shipment Method Code" := ShipmentMethodCode;
                    Evaluate(TempPurchaseHeader."Prices Including VAT", PricesIncludingTax);
                    TempPurchaseHeader."Ship-to Post Code" := ShipToZIPCode;
                    TempPurchaseHeader."Ship-to County" := ShipToState;
                    TempPurchaseHeader."Ship-to Country/Region Code" := ShipToCountryRegionCode;
                    TempPurchaseHeader."Order Address Code" := OrderAddressCode;
                    Evaluate(TempPurchaseHeader."Document Date", DocumentDate);
                    TempPurchaseHeader."Posting No. Series" := PostingNoSeries;
                    TempPurchaseHeader."Receiving No. Series" := ReceivingNoSeries;
                    if Status <> '' then
                        Evaluate(TempPurchaseHeader.Status, Status);
                    TempPurchaseHeader.Insert(false);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        CaptionRow := true;
    end;

    procedure GetExpectedPurchaseHeaders(var NewTempPurchaseHeader: Record "Purchase Header" temporary)
    begin
        if TempPurchaseHeader.FindSet() then begin
            repeat
                NewTempPurchaseHeader.Copy(TempPurchaseHeader);
                NewTempPurchaseHeader.Insert();
            until TempPurchaseHeader.Next() = 0;
        end;
    end;

    var
        CaptionRow: Boolean;
        TempPurchaseHeader: Record "Purchase Header" temporary;
}