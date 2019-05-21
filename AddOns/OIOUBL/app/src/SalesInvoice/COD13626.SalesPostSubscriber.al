// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13626 "OIOUBL-Sales-Post Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterCheckSalesDoc', '', false, false)]
    procedure OnAfterCheckSalesDocCheckOIOUBL(SalesHeader: Record "Sales Header");
    var
        OIOXMLCheckSalesHeader: Codeunit "OIOUBL-Check Sales Header";
    begin
        OIOXMLCheckSalesHeader.RUN(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Sending Profile", 'OnBeforeSend', '', false, false)]
    procedure ExportSalesDocumentOnBeforeSend(VAR Sender: Record "Document Sending Profile"; ReportUsage: Integer; RecordVariant: Variant; DocNo: Code[20]; ToCust: Code[20]; DocName: Text[150]; CustomerFieldNo: Integer; DocumentNoFieldNo: Integer; VAR IsHandled: Boolean)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        OIOUBLExportSalesInvoice: Codeunit "OIOUBL-Export Sales Invoice";
        OIOUBLExportSalesCrMemo: Codeunit "OIOUBL-Export Sales Cr. Memo";
        OIOUBLManagement: Codeunit "OIOUBL-Management";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Sender.Disk <> Sender.Disk::"Electronic Document" then
            exit;

        if not OIOUBLManagement.IsOIOUBLSendingProfile(Sender) then
            exit;

        if not DataTypeManagement.GetRecordRef(RecordVariant, RecRef) then
            exit;

        case RecRef.Number() of
            Database::"Sales Invoice Header":
                begin
                    RecRef.SetTable(SalesInvoiceHeader);
                    OIOUBLExportSalesInvoice.ExportXML(SalesInvoiceHeader);
                    OIOUBLManagement.WriteLogSalesInvoice(SalesInvoiceHeader);
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    RecRef.SetTable(SalesCrMemoHeader);
                    OIOUBLExportSalesCrMemo.ExportXML(SalesCrMemoHeader);
                    OIOUBLManagement.WriteLogSalesCrMemo(SalesCrMemoHeader);
                end;
            else
                exit;
        end;

        IsHandled := true;
    end;
}