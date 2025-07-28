// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Document;
using Microsoft.Sales.History;

codeunit 30259 "Shpfy BC Document Type Convert"
{
    var
        NotSupportedErr: Label 'Not Supported';

    procedure Convert(SalesDocumentType: enum "Sales Document Type"): enum "Shpfy Document Type";
    begin
        case SalesDocumentType of
            SalesDocumentType::Order:
                exit("Shpfy Document Type"::"Sales Order");
            SalesDocumentType::Invoice:
                exit("Shpfy Document Type"::"Sales Invoice");
            SalesDocumentType::"Return Order":
                exit("Shpfy Document Type"::"Sales Return Order");
            SalesDocumentType::"Credit Memo":
                exit("Shpfy Document Type"::"Sales Credit Memo");
        end;
        exit("Shpfy Document Type"::" ");
    end;

    procedure CanConvert(RecordVariant: Variant): Boolean
    var
        RecordRef: RecordRef;
    begin
        if RecordVariant.IsRecord then begin
            RecordRef.GetTable(RecordVariant);
            case RecordRef.Number of
                Database::"Sales Header",
                Database::"Sales Shipment Header",
                Database::"Sales Invoice Header",
                Database::"Return Receipt Header",
                Database::"Sales Cr.Memo Header":
                    exit(true);
            end;
        end;
    end;

    procedure Convert(RecordVariant: Variant): enum "Shpfy Document Type";
    var
        RecordRef: RecordRef;
        SalesDocumentType: enum "Sales Document Type";
    begin
        if RecordVariant.IsRecord then begin
            RecordRef.GetTable(RecordVariant);
            case RecordRef.Number of
                Database::"Sales Header":
                    begin
                        SalesDocumentType := RecordRef.Field(1).Value;
                        exit(Convert(SalesDocumentType));
                    end;
                Database::"Sales Shipment Header":
                    exit("Shpfy Document Type"::"Posted Sales Shipment");
                Database::"Sales Invoice Header":
                    exit("Shpfy Document Type"::"Posted Sales Invoice");
                Database::"Return Receipt Header":
                    exit("Shpfy Document Type"::"Posted Return Receipt");
                Database::"Sales Cr.Memo Header":
                    exit("Shpfy Document Type"::"Posted Sales Credit Memo");
            end;
        end;
        Error(NotSupportedErr);
    end;

    procedure CanConvert(BCDocumentType: enum "Shpfy Document Type"): Boolean
    begin
        case BCDocumentType of
            "Shpfy Document Type"::"Sales Order",
            "Shpfy Document Type"::"Sales Invoice",
            "Shpfy Document Type"::"Sales Return Order",
            "Shpfy Document Type"::"Sales Credit Memo":
                exit(true);
        end;
    end;

    procedure Convert(BCDocumentType: enum "Shpfy Document Type"): enum "Sales Document Type";
    var
        DummySalesDocumentType: enum "Sales Document Type";
    begin
        case BCDocumentType of
            "Shpfy Document Type"::"Sales Order":
                exit(DummySalesDocumentType::Order);
            "Shpfy Document Type"::"Sales Invoice":
                exit(DummySalesDocumentType::Invoice);
            "Shpfy Document Type"::"Sales Return Order":
                exit(DummySalesDocumentType::"Return Order");
            "Shpfy Document Type"::"Sales Credit Memo":
                exit(DummySalesDocumentType::"Credit Memo");
        end;
        Error(NotSupportedErr);
    end;
}