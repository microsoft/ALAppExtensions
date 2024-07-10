// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Sales.History;
using Microsoft.Inventory.Item;

table 7275 "Sales Line AI Suggestions"
{
    TableType = Temporary;
    InherentEntitlements = X;
    InherentPermissions = RIMDX;
    Caption = 'Sales Line AI Suggestion';
    Access = Internal;

    fields
    {
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; Type; Enum "Sales Line Type")
        {
            Caption = 'Type';
        }
        field(6; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = Item where(Blocked = const(false), "Sales Blocked" = const(false));
            ValidateTableRelation = false;
        }
        field(7; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            ToolTip = 'Specifies the variant of the item on the line.';
            TableRelation = if (Type = const(Item)) "Item Variant".Code where("Item No." = field("No."), Blocked = const(false), "Sales Blocked" = const(false));
            ValidateTableRelation = false;
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(15; Quantity; Decimal)
        {
            Caption = 'Quantity';
            ToolTip = 'Specifies the Quantity in the Sales Unit of Measure defined on the Item card.';
            DecimalPlaces = 0 : 5;
        }
        field(16; Confidence; Enum "Search Confidence")
        {
            Caption = 'Confidence';
        }
        field(20; "Primary Search Terms"; Blob)
        {
            Caption = 'Primary Search Terms';
        }
        field(21; "Additional Search Terms"; Blob)
        {
            Caption = 'Secondary Search Terms';
        }
        field(30; "Source Line Record ID"; RecordId)
        {
            Caption = 'Source Line Record ID';
        }
        field(35; "Line Style"; Text[30])
        {
            Caption = 'Line Style';
        }
        field(5407; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            ToolTip = 'Specifies the unit of measure code of the item on the line.';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("No."));
            ValidateTableRelation = false;
        }
    }

    keys
    {
        key(Key1; "Line No.")
        {
        }
    }

    internal procedure SetSourceDocument(RecID: RecordId)
    begin
        Rec."Source Line Record ID" := RecID;
    end;

    internal procedure SetPrimarySearchTerms(SearchTerms: List of [Text])
    var
        SearchTermOutStream: OutStream;
    begin
        Clear(Rec."Primary Search Terms");
        Rec."Primary Search Terms".CreateOutStream(SearchTermOutStream, TextEncoding::UTF8);
        SearchTermOutStream.WriteText(ListOfTextToText(SearchTerms));
    end;

    internal procedure SetAdditionalSearchTerms(SearchTerms: List of [Text])
    var
        SearchTermOutStream: OutStream;
    begin
        Clear(Rec."Additional Search Terms");
        Rec."Additional Search Terms".CreateOutStream(SearchTermOutStream, TextEncoding::UTF8);
        SearchTermOutStream.WriteText(ListOfTextToText(SearchTerms));
    end;

    local procedure ListOfTextToText(var TextList: List of [Text]) Result: Text
    var
        Txt: Text;
    begin
        foreach Txt in TextList do
            Result += Txt + ', ';
        Result := Result.TrimEnd(', ');
    end;

    internal procedure GetPrimarySearchTerms() Result: Text
    var
        SearchTermInStream: InStream;
    begin
        Rec.CalcFields("Primary Search Terms");
        Rec."Primary Search Terms".CreateInStream(SearchTermInStream, TextEncoding::UTF8);
        SearchTermInStream.ReadText(Result);
    end;

    internal procedure GetAdditionalSearchTerms() Result: Text
    var
        SearchTermInStream: InStream;
    begin
        Rec.CalcFields("Additional Search Terms");
        Rec."Additional Search Terms".CreateInStream(SearchTermInStream, TextEncoding::UTF8);
        SearchTermInStream.ReadText(Result);
    end;

    local procedure GetSourceHeader(): RecordId
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        case Rec."Source Line Record ID".TableNo of
            Database::"Sales Line":
                begin
                    Rec."Source Line Record ID".GetRecord().SetTable(SalesLine);
                    SalesHeader.SetLoadFields("Document Type", "No.");
                    SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
                    exit(SalesHeader.RecordId);
                end;
            Database::"Sales Invoice Line":
                begin
                    Rec."Source Line Record ID".GetRecord().SetTable(SalesInvoiceLine);
                    SalesInvoiceHeader.SetLoadFields("No.");
                    SalesInvoiceHeader.Get(SalesInvoiceLine."Document No.");
                    exit(SalesInvoiceHeader.RecordId);
                end;
            Database::"Sales Shipment Line":
                begin
                    Rec."Source Line Record ID".GetRecord().SetTable(SalesShipmentLine);
                    SalesShipmentHeader.SetLoadFields("No.");
                    SalesShipmentHeader.Get(SalesShipmentLine."Document No.");
                    exit(SalesShipmentHeader.RecordId);
                end;
        end;
    end;

    internal procedure GetSourceDocumentInfo(var DocumentType: Text; var DocumentNo: Text; var DocumentDate: Date; var CustomerName: Text)
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SourceHeaderRecordId: RecordId;
    begin
        SourceHeaderRecordId := GetSourceHeader();
        case SourceHeaderRecordId.TableNo of
            Database::"Sales Header":
                begin
                    SourceHeaderRecordId.GetRecord().SetTable(SalesHeader);
                    SalesHeader.SetLoadFields("Document Type", "No.", "Document Date", "Sell-to Customer Name");
                    SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
                    DocumentType := SalesHeader.GetDocTypeTxt();
                    DocumentNo := SalesHeader."No.";
                    DocumentDate := SalesHeader."Document Date";
                    CustomerName := SalesHeader."Sell-to Customer Name";
                end;
            Database::"Sales Invoice Header":
                begin
                    SourceHeaderRecordId.GetRecord().SetTable(SalesInvoiceHeader);
                    SalesInvoiceHeader.SetLoadFields("No.", "Document Date", "Sell-to Customer Name");
                    SalesInvoiceHeader.Get(SalesInvoiceHeader."No.");
                    DocumentType := 'Posted Sales Invoice';
                    DocumentNo := SalesInvoiceHeader."No.";
                    DocumentDate := SalesInvoiceHeader."Document Date";
                    CustomerName := SalesInvoiceHeader."Sell-to Customer Name";
                end;
            Database::"Sales Shipment Header":
                begin
                    SourceHeaderRecordId.GetRecord().SetTable(SalesShipmentHeader);
                    SalesShipmentHeader.SetLoadFields("No.", "Document Date", "Sell-to Customer Name");
                    SalesShipmentHeader.Get(SalesShipmentHeader."No.");
                    DocumentType := 'Posted Sales Shipment';
                    DocumentNo := SalesShipmentHeader."No.";
                    DocumentDate := SalesShipmentHeader."Document Date";
                    CustomerName := SalesShipmentHeader."Sell-to Customer Name";
                end;
        end;
    end;

    internal procedure ShowSourceHeaderDocument()
    var
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SourceLineRecId: RecordId;
    begin
        SourceLineRecId := GetSourceHeader();
        case SourceLineRecId.TableNo of
            Database::"Sales Header":
                begin
                    SourceLineRecId.GetRecord().SetTable(SalesHeader);
                    RunSalesHeaderPage(SalesHeader);
                end;
            Database::"Sales Shipment Header":
                begin
                    SourceLineRecId.GetRecord().SetTable(SalesShipmentHeader);
                    PAGE.RunModal(Page::"Posted Sales Shipment", SalesShipmentHeader);
                end;
            Database::"Sales Invoice Header":
                begin
                    SourceLineRecId.GetRecord().SetTable(SalesInvHeader);
                    PAGE.RunModal(Page::"Posted Sales Invoice", SalesInvHeader);
                end;
        end;
    end;

    local procedure RunSalesHeaderPage(var SalesHeader: Record "Sales Header")
    begin
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                PAGE.RunModal(Page::"Sales Order", SalesHeader);
            SalesHeader."Document Type"::Invoice:
                PAGE.RunModal(Page::"Sales Invoice", SalesHeader);
            SalesHeader."Document Type"::"Credit Memo":
                PAGE.RunModal(Page::"Sales Credit Memo", SalesHeader);
            SalesHeader."Document Type"::"Blanket Order":
                PAGE.RunModal(Page::"Blanket Sales Order", SalesHeader);
            SalesHeader."Document Type"::"Return Order":
                PAGE.RunModal(Page::"Sales Return Order", SalesHeader);
            SalesHeader."Document Type"::Quote:
                PAGE.RunModal(Page::"Sales Quote", SalesHeader);
        end;
    end;
}