// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Inventory.Tracking;

xmlport 147621 "SL BC Item Tracking Code Data"
{
    Caption = 'BC Item Tracking Code data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("Item Tracking Code"; "Item Tracking Code")
            {
                AutoSave = false;
                XmlName = 'ItemTrackingCode';

                textelement("Code")
                {
                }
                textelement("Description")
                {
                }
                textelement("ManWarrantyDateEntryReqd")
                {
                }
                textelement("ManExpirDateEntryReqd")
                {
                }
                textelement("StrictExpirationPosting")
                {
                }
                textelement("UseExpirationDates")
                {
                }
                textelement("SNSpecificTracking")
                {
                }
                textelement("SNInfoInboundMustExist")
                {
                }
                textelement("SNInfoOutboundMustExist")
                {
                }
                textelement("SNWarehouseTracking")
                {
                }
                textelement("SNPurchaseInboundTracking")
                {
                }
                textelement("SNPurchaseOutboundTracking")
                {
                }
                textelement("SNSalesInboundTracking")
                {
                }
                textelement("SNSalesOutboundTracking")
                {
                }
                textelement("SNPosAdjmtInbTracking")
                {
                }
                textelement("SNPosAdjmtOutbTracking")
                {
                }
                textelement("SNNegAdjmtInbTracking")
                {
                }
                textelement("SNNegAdjmtOutbTracking")
                {
                }
                textelement("SNTransferTracking")
                {
                }
                textelement("SNManufInboundTracking")
                {
                }
                textelement("SNManufOutboundTracking")
                {
                }
                textelement("SNAssemblyInboundTracking")
                {
                }
                textelement("SNAssemblyOutboundTracking")
                {
                }
                textelement("LotSpecificTracking")
                {
                }
                textelement("LotInfoInboundMustExist")
                {
                }
                textelement("LotInfoOutboundMustExist")
                {
                }
                textelement("LotWarehouseTracking")
                {
                }
                textelement("LotPurchaseInboundTracking")
                {
                }
                textelement("LotPurchaseOutboundTracking")
                {
                }
                textelement("LotSalesInboundTracking")
                {
                }
                textelement("LotSalesOutboundTracking")
                {
                }
                textelement("LotPosAdjmtInbTracking")
                {
                }
                textelement("LotPosAdjmtOutbTracking")
                {
                }
                textelement("LotNegAdjmtInbTracking")
                {
                }
                textelement("LotNegAdjmtOutbTracking")
                {
                }
                textelement("LotTransferTracking")
                {
                }
                textelement("LotManufInboundTracking")
                {
                }
                textelement("LotManufOutboundTracking")
                {
                }
                textelement("LotAssemblyInboundTracking")
                {
                }
                textelement("LotAssemblyOutboundTracking")
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
                var
                    ItemTrackingCode: Record "Item Tracking Code";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    ItemTrackingCode.Code := Code;
                    ItemTrackingCode.Description := Description;
                    Evaluate(ItemTrackingCode."Man. Warranty Date Entry Reqd.", ManWarrantyDateEntryReqd);
                    Evaluate(ItemTrackingCode."Man. Expir. Date Entry Reqd.", ManExpirDateEntryReqd);
                    Evaluate(ItemTrackingCode."Strict Expiration Posting", StrictExpirationPosting);
                    Evaluate(ItemTrackingCode."Use Expiration Dates", UseExpirationDates);
                    Evaluate(ItemTrackingCode."SN Specific Tracking", SNSpecificTracking);
                    Evaluate(ItemTrackingCode."SN Info. Inbound Must Exist", SNInfoInboundMustExist);
                    Evaluate(ItemTrackingCode."SN Info. Outbound Must Exist", SNInfoOutboundMustExist);
                    Evaluate(ItemTrackingCode."SN Warehouse Tracking", SNWarehouseTracking);
                    Evaluate(ItemTrackingCode."SN Purchase Inbound Tracking", SNPurchaseInboundTracking);
                    Evaluate(ItemTrackingCode."SN Purchase Outbound Tracking", SNPurchaseOutboundTracking);
                    Evaluate(ItemTrackingCode."SN Sales Inbound Tracking", SNSalesInboundTracking);
                    Evaluate(ItemTrackingCode."SN Sales Outbound Tracking", SNSalesOutboundTracking);
                    Evaluate(ItemTrackingCode."SN Pos. Adjmt. Inb. Tracking", SNPosAdjmtInbTracking);
                    Evaluate(ItemTrackingCode."SN Pos. Adjmt. Outb. Tracking", SNPosAdjmtOutbTracking);
                    Evaluate(ItemTrackingCode."SN Neg. Adjmt. Inb. Tracking", SNNegAdjmtInbTracking);
                    Evaluate(ItemTrackingCode."SN Neg. Adjmt. Outb. Tracking", SNNegAdjmtOutbTracking);
                    Evaluate(ItemTrackingCode."SN Transfer Tracking", SNTransferTracking);
                    Evaluate(ItemTrackingCode."SN Manuf. Inbound Tracking", SNManufInboundTracking);
                    Evaluate(ItemTrackingCode."SN Manuf. Outbound Tracking", SNManufOutboundTracking);
                    Evaluate(ItemTrackingCode."SN Assembly Inbound Tracking", SNAssemblyInboundTracking);
                    Evaluate(ItemTrackingCode."SN Assembly Outbound Tracking", SNAssemblyOutboundTracking);
                    Evaluate(ItemTrackingCode."Lot Specific Tracking", LotSpecificTracking);
                    Evaluate(ItemTrackingCode."Lot Info. Inbound Must Exist", LotInfoInboundMustExist);
                    Evaluate(ItemTrackingCode."Lot Info. Outbound Must Exist", LotInfoOutboundMustExist);
                    Evaluate(ItemTrackingCode."Lot Warehouse Tracking", LotWarehouseTracking);
                    Evaluate(ItemTrackingCode."Lot Purchase Inbound Tracking", LotPurchaseInboundTracking);
                    Evaluate(ItemTrackingCode."Lot Purchase Outbound Tracking", LotPurchaseOutboundTracking);
                    Evaluate(ItemTrackingCode."Lot Sales Inbound Tracking", LotSalesInboundTracking);
                    Evaluate(ItemTrackingCode."Lot Sales Outbound Tracking", LotSalesOutboundTracking);
                    Evaluate(ItemTrackingCode."Lot Pos. Adjmt. Inb. Tracking", LotPosAdjmtInbTracking);
                    Evaluate(ItemTrackingCode."Lot Pos. Adjmt. Outb. Tracking", LotPosAdjmtOutbTracking);
                    Evaluate(ItemTrackingCode."Lot Neg. Adjmt. Inb. Tracking", LotNegAdjmtInbTracking);
                    Evaluate(ItemTrackingCode."Lot Neg. Adjmt. Outb. Tracking", LotNegAdjmtOutbTracking);
                    Evaluate(ItemTrackingCode."Lot Transfer Tracking", LotTransferTracking);
                    Evaluate(ItemTrackingCode."Lot Manuf. Inbound Tracking", LotManufInboundTracking);
                    Evaluate(ItemTrackingCode."Lot Manuf. Outbound Tracking", LotManufOutboundTracking);
                    Evaluate(ItemTrackingCode."Lot Assembly Inbound Tracking", LotAssemblyInboundTracking);
                    Evaluate(ItemTrackingCode."Lot Assembly Outbound Tracking", LotAssemblyOutboundTracking);
                    ItemTrackingCode.Insert(true);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        ItemTrackingCode.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        ItemTrackingCode: Record "Item Tracking Code";
}