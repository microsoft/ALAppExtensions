// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Verifactu;

using Microsoft.EServices.EDocument;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using Microsoft.Service.History;
using System.Reflection;
using System.Security.Encryption;
using System.Telemetry;
using System.Text;
using System.Utilities;

codeunit 10778 "Verifactu Export"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "E-Document" = rimd,
                  tabledata "E-Document Log" = rimd,
                  tabledata "E-Doc. Data Storage" = rimd;

    var
        CompanyInformation: Record "Company Information";
        VerifactuSetup: Record "Verifactu Setup";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        VerifactuDocUploadMgt: Codeunit "Verifactu Doc. Upload Mgt.";
        XmlNamespaceSoapenv, XmlNamespaceSum, XmlNamespaceSum1 : Text;
        FeatureNameTok: Label 'EDocument Format Verifactu', Locked = true;
        StartEventNameTok: Label 'Export initiated. IsBatch is: %1', Locked = true;
        EndEventNameTok: Label 'Export completed', Locked = true;
        MaxBatchSizeErr: Label 'Sending more than 1000 documents in a batch is not allowed.';

    procedure Export(var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; IsBatch: Boolean)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        ServiceInvoiceLine: Record "Service Invoice Line";
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
    begin
        OnBeforeExport(SourceDocumentHeader, SourceDocumentLines, TempBlob, IsBatch);
        FeatureTelemetry.LogUsage('0000OCR', FeatureNameTok, StrSubstNo(StartEventNameTok, Format(IsBatch)));
        CompanyInformation.Get();
        if not VerifactuSetup.Get() then
            VerifactuSetup.Init();

        case SourceDocumentHeader.Number of
            Database::"Sales Invoice Header":
                begin
                    SourceDocumentHeader.SetTable(SalesInvoiceHeader);
                    SalesInvoiceHeader.SetRecFilter();
                    SourceDocumentLines.SetTable(SalesInvoiceLine);
                    ExportInvoice(EDocument, SalesInvoiceHeader, SalesInvoiceLine, TempBlob, IsBatch);
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    SourceDocumentHeader.SetTable(SalesCrMemoHeader);
                    SalesCrMemoHeader.SetRecFilter();
                    SourceDocumentLines.SetTable(SalesCrMemoLine);
                    ExportCreditMemo(EDocument, SalesCrMemoHeader, SalesCrMemoLine, TempBlob, IsBatch);
                end;
            Database::"Service Invoice Header":
                begin
                    SourceDocumentHeader.SetTable(ServiceInvoiceHeader);
                    ServiceInvoiceHeader.SetRecFilter();
                    SourceDocumentLines.SetTable(ServiceInvoiceLine);
                    ExportServiceInvoice(EDocument, ServiceInvoiceHeader, ServiceInvoiceLine, TempBlob, IsBatch);
                end;
            Database::"Service Cr.Memo Header":
                begin
                    SourceDocumentHeader.SetTable(ServiceCrMemoHeader);
                    ServiceCrMemoHeader.SetRecFilter();
                    SourceDocumentLines.SetTable(ServiceCrMemoLine);
                    ExportServiceCreditMemo(EDocument, ServiceCrMemoHeader, ServiceCrMemoLine, TempBlob, IsBatch);
                end;
        end;
        FeatureTelemetry.LogUsage('0000OCT', FeatureNameTok, EndEventNameTok);
        OnAfterExport(SourceDocumentHeader, SourceDocumentLines, TempBlob, IsBatch);
    end;

    #region Invoice
    local procedure ExportInvoice(var EDocument: Record "E-Document"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesInvoiceLine: Record "Sales Invoice Line"; var TempBlob: Codeunit "Temp Blob"; IsBatch: Boolean)
    var
        TempBlobQR: Codeunit "Temp Blob";
        InvoiceType, VerifactuDateTime : Text;
        PreviousDocumentNo, PreviousHuella : Text;
        VerifactuHash: Text[64];
        PreviousPostingDate: Date;
        FileOutStream, OutStr : OutStream;
        InStr: InStream;
    begin
        SalesInvoiceHeader.CalcFields(Amount, "Amount Including VAT");
        InvoiceType := GetOptionFirstTwoChars(SalesInvoiceHeader."Invoice Type");
        VerifactuDateTime := GetCustomDateTimeFormat(CurrentDateTime());
        FindLastRegisteredDocument(PreviousDocumentNo, PreviousPostingDate, PreviousHuella);
        VerifactuHash := GenerateHash(SalesInvoiceHeader, InvoiceType, VerifactuDateTime, PreviousHuella);
        VerifactuDocUploadMgt.InsertVerifactuDocument(EDocument, SalesInvoiceHeader."No.", SalesInvoiceHeader."Posting Date", VerifactuHash);

        CreateXML(SalesInvoiceHeader, SalesInvoiceLine, IsBatch, TempBlob, FileOutStream, InvoiceType, VerifactuDateTime, VerifactuHash, PreviousDocumentNo, PreviousPostingDate, PreviousHuella);

        TempBlobQR := GenerateQRCode(SalesInvoiceHeader."No.", SalesInvoiceHeader."Posting Date", SalesInvoiceHeader."Amount Including VAT");
        TempBlobQR.CreateInStream(InStr);
        SalesInvoiceHeader."QR Code Base64".CreateOutStream(OutStr, TextEncoding::UTF8);
        CopyStream(OutStr, InStr);
        SalesInvoiceHeader."QR Code Image".ImportStream(InStr, 'image.png');
        SalesInvoiceHeader.Modify();
    end;

    local procedure CreateXML(var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesInvoiceLine: Record "Sales Invoice Line"; IsBatch: Boolean; var TempBlob: Codeunit "Temp Blob"; var FileOutStream: OutStream; InvoiceType: Text; VerifactuDateTime: Text; VerifactuHash: Text[64]; PreviousDocumentNo: Text; PreviousPostingDate: Date; PreviousHuella: Text)
    var
        HeaderXMLNode, BodyXMLNode, RegFactuSistemaFacturacionXMLNode, RootXMLNode : XmlElement;
        XMLDocOut: XmlDocument;
    begin
        TempBlob.CreateOutStream(FileOutStream, TextEncoding::UTF8);

        XmlDocument.ReadFrom(GetBasicXMLHeader(), XMLDocOut);
        XMLDocOut.GetRoot(RootXMLNode);

        InitializeNamespaces();
        HeaderXMLNode := XmlElement.Create('Header', XmlNamespaceSoapenv);
        BodyXMLNode := XmlElement.Create('Body', XmlNamespaceSoapenv);
        RegFactuSistemaFacturacionXMLNode := XmlElement.Create('RegFactuSistemaFacturacion', XmlNamespaceSum);
        InsertHeaderData(RegFactuSistemaFacturacionXMLNode);
        InsertInvoicesData(RegFactuSistemaFacturacionXMLNode, SalesInvoiceHeader, SalesInvoiceLine, IsBatch, InvoiceType, VerifactuDateTime, VerifactuHash, PreviousDocumentNo, PreviousPostingDate, PreviousHuella);

        BodyXMLNode.Add(RegFactuSistemaFacturacionXMLNode);
        RootXMLNode.Add(HeaderXMLNode);
        RootXMLNode.Add(BodyXMLNode);

        XmlDocOut.WriteTo(FileOutStream);
    end;

    local procedure InsertInvoicesData(var RootXMLNode: XmlElement; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesInvoiceLine: Record "Sales Invoice Line"; IsBatch: Boolean; InvoiceType: Text; VerifactuDateTime: Text; VerifactuHash: Text[64]; PreviousDocumentNo: Text; PreviousPostingDate: Date; PreviousHuella: Text)
    var
        InvoiceXMLNode: XmlElement;
        InvoiceCount: Integer;
    begin
        InvoiceXMLNode := XmlElement.Create('RegistroFactura', XmlNamespaceSum);

        if IsBatch then
            repeat
                InvoiceCount += 1;
                if InvoiceCount > 1000 then
                    Error(MaxBatchSizeErr);
                InsertInvoice(InvoiceXMLNode, SalesInvoiceHeader, SalesInvoiceLine, InvoiceType, VerifactuDateTime, VerifactuHash, PreviousDocumentNo, PreviousPostingDate, PreviousHuella);
            until SalesInvoiceHeader.Next() = 0
        else
            InsertInvoice(InvoiceXMLNode, SalesInvoiceHeader, SalesInvoiceLine, InvoiceType, VerifactuDateTime, VerifactuHash, PreviousDocumentNo, PreviousPostingDate, PreviousHuella);
        RootXMLNode.Add(InvoiceXMLNode);
    end;

    local procedure InsertInvoice(var RootXMLNode: XmlElement; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesInvoiceLine: Record "Sales Invoice Line"; InvoiceType: Text; VerifactuDateTime: Text; VerifactuHash: Text[64]; PreviousDocumentNo: Text; PreviousPostingDate: Date; PreviousHuella: Text)
    var
        InvoiceXMLNode: XmlElement;
    begin
        InvoiceXMLNode := XmlElement.Create('RegistroAlta', XmlNamespaceSum1);

        InsertInvoiceHeaderData(InvoiceXMLNode, SalesInvoiceHeader, InvoiceType);
        InsertInvoiceBreakdown(InvoiceXMLNode, SalesInvoiceHeader, SalesInvoiceLine);
        InsertTotals(InvoiceXMLNode, SalesInvoiceHeader);
        InsertRegistroAnterior(InvoiceXMLNode, PreviousDocumentNo, PreviousPostingDate, PreviousHuella);
        InsertInformationSystem(InvoiceXMLNode);
        InsertHuellaDigital(InvoiceXMLNode, VerifactuDateTime, VerifactuHash);

        RootXMLNode.Add(InvoiceXMLNode);
    end;

    local procedure InsertInvoiceHeaderData(var InvoiceXMLNode: XmlElement; var SalesInvoiceHeader: Record "Sales Invoice Header"; InvoiceType: Text)
    var
        IDFacturaXMLNode, DestinatariosXMLNode, IDDestinatarioXMLNode : XmlElement;
    begin
        InvoiceXMLNode.Add(XmlElement.Create('IDVersion', XmlNamespaceSum1, '1.0'));

        IDFacturaXMLNode := XmlElement.Create('IDFactura', XmlNamespaceSum1);
        IDFacturaXMLNode.Add(XmlElement.Create('IDEmisorFactura', XmlNamespaceSum1, CompanyInformation."VAT Registration No."));
        IDFacturaXMLNode.Add(XmlElement.Create('NumSerieFactura', XmlNamespaceSum1, SalesInvoiceHeader."No."));
        IDFacturaXMLNode.Add(XmlElement.Create('FechaExpedicionFactura', XmlNamespaceSum1, FormatDate(SalesInvoiceHeader."Posting Date")));
        InvoiceXMLNode.Add(IDFacturaXMLNode);

        InvoiceXMLNode.Add(XmlElement.Create('NombreRazonEmisor', XmlNamespaceSum1, CompanyInformation."Name"));
        InvoiceXMLNode.Add(XmlElement.Create('TipoFactura', XmlNamespaceSum1, InvoiceType));
        if SalesInvoiceHeader."Operation Description" = '' then
            SalesInvoiceHeader."Operation Description" := SalesInvoiceHeader."No.";
        InvoiceXMLNode.Add(XmlElement.Create('DescripcionOperacion', XmlNamespaceSum1, SalesInvoiceHeader."Operation Description"));

        DestinatariosXMLNode := XmlElement.Create('Destinatarios', XmlNamespaceSum1);
        IDDestinatarioXMLNode := XmlElement.Create('IDDestinatario', XmlNamespaceSum1);
        IDDestinatarioXMLNode.Add(XmlElement.Create('NombreRazon', XmlNamespaceSum1, CompanyInformation.Name));
        IDDestinatarioXMLNode.Add(XmlElement.Create('NIF', XmlNamespaceSum1, CompanyInformation."VAT Registration No."));
        DestinatariosXMLNode.Add(IDDestinatarioXMLNode);
        InvoiceXMLNode.Add(DestinatariosXMLNode);
    end;

    local procedure InsertInvoiceBreakdown(var InvoiceXMLNode: XmlElement; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesInvoiceLine: Record "Sales Invoice Line")
    var
        TempSalesInvoiceLine: Record "Sales Invoice Line" temporary;
        DesgloseXMLNode, DetalleIVAXMLNode : XmlElement;
    begin
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SetFilter(Type, '<>%1', SalesInvoiceLine.Type::" ");
        if SalesInvoiceLine.FindSet() then
            repeat
                if FindLineInTempSalesInvoiceLine(TempSalesInvoiceLine, SalesInvoiceLine) then begin
                    TempSalesInvoiceLine.Amount += SalesInvoiceLine.Amount;
                    TempSalesInvoiceLine."Amount Including VAT" += SalesInvoiceLine."Amount Including VAT";
                    TempSalesInvoiceLine.Modify();
                end else begin
                    TempSalesInvoiceLine.Init();
                    TempSalesInvoiceLine := SalesInvoiceLine;
                    TempSalesInvoiceLine.Insert();
                end;
            until SalesInvoiceLine.Next() = 0;

        DesgloseXMLNode := XmlElement.Create('Desglose', XmlNamespaceSum1);

        TempSalesInvoiceLine.Reset();
        TempSalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        if TempSalesInvoiceLine.FindSet() then
            repeat
                DetalleIVAXMLNode := XmlElement.Create('DetalleDesglose', XmlNamespaceSum1);
                DetalleIVAXMLNode.Add(XmlElement.Create('ClaveRegimen', XmlNamespaceSum1, GetOptionFirstTwoChars(SalesInvoiceHeader."Special Scheme Code")));
                DetalleIVAXMLNode.Add(XmlElement.Create('CalificacionOperacion', XmlNamespaceSum1, GetVATIdentifier(TempSalesInvoiceLine."VAT Identifier")));
                DetalleIVAXMLNode.Add(XmlElement.Create('TipoImpositivo', XmlNamespaceSum1, Format(TempSalesInvoiceLine."VAT %", 0, 9)));
                DetalleIVAXMLNode.Add(XmlElement.Create('BaseImponibleOimporteNoSujeto', XmlNamespaceSum1, Format(TempSalesInvoiceLine.Amount, 0, 9)));
                DetalleIVAXMLNode.Add(XmlElement.Create('CuotaRepercutida', XmlNamespaceSum1, Format(TempSalesInvoiceLine."Amount Including VAT" - TempSalesInvoiceLine.Amount, 0, 9)));
                DesgloseXMLNode.Add(DetalleIVAXMLNode);
            until TempSalesInvoiceLine.Next() = 0;
        TempSalesInvoiceLine.CalcSums(Amount, "Amount Including VAT");

        InvoiceXMLNode.Add(DesgloseXMLNode);
    end;

    local procedure InsertTotals(var InvoiceXMLNode: XmlElement; var SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        InvoiceXMLNode.Add(XmlElement.Create('CuotaTotal', XmlNamespaceSum1, SalesInvoiceHeader."Amount Including VAT" - SalesInvoiceHeader.Amount));
        InvoiceXMLNode.Add(XmlElement.Create('ImporteTotal', XmlNamespaceSum1, SalesInvoiceHeader."Amount Including VAT"));
    end;

    local procedure FindLineInTempSalesInvoiceLine(var TempSalesInvoiceLine: Record "Sales Invoice Line" temporary; var SalesInvoiceLine: Record "Sales Invoice Line"): Boolean
    begin
        TempSalesInvoiceLine.SetRange("Document No.", SalesInvoiceLine."Document No.");
        TempSalesInvoiceLine.SetRange("VAT %", SalesInvoiceLine."VAT %");
        exit(TempSalesInvoiceLine.FindFirst());
    end;

    local procedure GenerateHash(SalesInvoiceHeader: Record "Sales Invoice Header"; InvoiceType: Text; VerifactuDateTime: Text; PreviousHuella: Text): Text[64]
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
        InputString: Text;
    begin
        InputString :=
            'IDEmisorFactura=' + CompanyInformation."VAT Registration No." +
            '&' +
            'NumSerieFactura=' + SalesInvoiceHeader."No." +
            '&' +
            'FechaExpedicionFactura=' + Format(SalesInvoiceHeader."Posting Date", 0, '<Day,2>-<Month,2>-<Year4>') +
            '&' +
            'TipoFactura=' + InvoiceType +
            '&' +
            'CuotaTotal=' + Format(SalesInvoiceHeader."Amount Including VAT" - SalesInvoiceHeader.Amount, 0, 9) +
            '&' +
            'ImporteTotal=' + Format(SalesInvoiceHeader."Amount Including VAT", 0, 9) +
            '&' +
            'Huella=' + PreviousHuella +
            '&' +
            'FechaHoraHusoGenRegistro=' + VerifactuDateTime;
        exit(
            CopyStr(
                CryptographyManagement.GenerateHash(InputString, HashAlgorithmType::SHA256), 1, 64));
    end;
    #endregion
    #region Service Invoice
    local procedure ExportServiceInvoice(var EDocument: Record "E-Document"; var ServiceInvoiceHeader: Record "Service Invoice Header"; var ServiceInvoiceLine: Record "Service Invoice Line"; var TempBlob: Codeunit "Temp Blob"; IsBatch: Boolean)
    var
        InvoiceType, VerifactuDateTime : Text;
        PreviousDocumentNo, PreviousHuella : Text;
        VerifactuHash: Text[64];
        PreviousPostingDate: Date;
        FileOutStream: OutStream;
    begin
        ServiceInvoiceHeader.CalcFields(Amount, "Amount Including VAT");
        InvoiceType := GetOptionFirstTwoChars(ServiceInvoiceHeader."Invoice Type");
        VerifactuDateTime := GetCustomDateTimeFormat(CurrentDateTime());
        FindLastRegisteredDocument(PreviousDocumentNo, PreviousPostingDate, PreviousHuella);
        VerifactuHash := GenerateHash(ServiceInvoiceHeader, InvoiceType, VerifactuDateTime, PreviousHuella);
        VerifactuDocUploadMgt.InsertVerifactuDocument(EDocument, ServiceInvoiceHeader."No.", ServiceInvoiceHeader."Posting Date", VerifactuHash);

        CreateXML(ServiceInvoiceHeader, ServiceInvoiceLine, IsBatch, TempBlob, FileOutStream, InvoiceType, VerifactuDateTime, VerifactuHash, PreviousDocumentNo, PreviousPostingDate, PreviousHuella);
        ServiceInvoiceHeader.Modify();
    end;

    local procedure CreateXML(var ServiceInvoiceHeader: Record "Service Invoice Header"; var ServiceInvoiceLine: Record "Service Invoice Line"; IsBatch: Boolean; var TempBlob: Codeunit "Temp Blob"; var FileOutStream: OutStream; InvoiceType: Text; VerifactuDateTime: Text; VerifactuHash: Text[64]; PreviousDocumentNo: Text; PreviousPostingDate: Date; PreviousHuella: Text)
    var
        HeaderXMLNode, BodyXMLNode, RegFactuSistemaFacturacionXMLNode, RootXMLNode : XmlElement;
        XMLDocOut: XmlDocument;
    begin
        TempBlob.CreateOutStream(FileOutStream, TextEncoding::UTF8);

        XmlDocument.ReadFrom(GetBasicXMLHeader(), XMLDocOut);
        XMLDocOut.GetRoot(RootXMLNode);

        InitializeNamespaces();
        HeaderXMLNode := XmlElement.Create('Header', XmlNamespaceSoapenv);
        BodyXMLNode := XmlElement.Create('Body', XmlNamespaceSoapenv);
        RegFactuSistemaFacturacionXMLNode := XmlElement.Create('RegFactuSistemaFacturacion', XmlNamespaceSum);
        InsertHeaderData(RegFactuSistemaFacturacionXMLNode);
        InsertServiceInvoicesData(RegFactuSistemaFacturacionXMLNode, ServiceInvoiceHeader, ServiceInvoiceLine, IsBatch, InvoiceType, VerifactuDateTime, VerifactuHash, PreviousDocumentNo, PreviousPostingDate, PreviousHuella);

        BodyXMLNode.Add(RegFactuSistemaFacturacionXMLNode);
        RootXMLNode.Add(HeaderXMLNode);
        RootXMLNode.Add(BodyXMLNode);

        XmlDocOut.WriteTo(FileOutStream);
    end;

    local procedure InsertServiceInvoicesData(var RootXMLNode: XmlElement; var ServiceInvoiceHeader: Record "Service Invoice Header"; var ServiceInvoiceLine: Record "Service Invoice Line"; IsBatch: Boolean; InvoiceType: Text; VerifactuDateTime: Text; VerifactuHash: Text[64]; PreviousDocumentNo: Text; PreviousPostingDate: Date; PreviousHuella: Text)
    var
        InvoiceXMLNode: XmlElement;
    begin
        InvoiceXMLNode := XmlElement.Create('RegistroFactura', XmlNamespaceSum);

        if IsBatch then
            repeat
                InsertServiceInvoice(InvoiceXMLNode, ServiceInvoiceHeader, ServiceInvoiceLine, InvoiceType, VerifactuDateTime, VerifactuHash, PreviousDocumentNo, PreviousPostingDate, PreviousHuella);
            until ServiceInvoiceHeader.Next() = 0
        else
            InsertServiceInvoice(InvoiceXMLNode, ServiceInvoiceHeader, ServiceInvoiceLine, InvoiceType, VerifactuDateTime, VerifactuHash, PreviousDocumentNo, PreviousPostingDate, PreviousHuella);
        RootXMLNode.Add(InvoiceXMLNode);
    end;

    local procedure InsertServiceInvoice(var RootXMLNode: XmlElement; var ServiceInvoiceHeader: Record "Service Invoice Header"; var ServiceInvoiceLine: Record "Service Invoice Line"; InvoiceType: Text; VerifactuDateTime: Text; VerifactuHash: Text[64]; PreviousDocumentNo: Text; PreviousPostingDate: Date; PreviousHuella: Text)
    var
        InvoiceXMLNode: XmlElement;
    begin
        InvoiceXMLNode := XmlElement.Create('RegistroAlta', XmlNamespaceSum1);

        InsertServiceInvoiceHeaderData(InvoiceXMLNode, ServiceInvoiceHeader, InvoiceType);
        InsertServiceInvoiceBreakdown(InvoiceXMLNode, ServiceInvoiceHeader, ServiceInvoiceLine);
        InsertTotals(InvoiceXMLNode, ServiceInvoiceHeader);
        InsertRegistroAnterior(InvoiceXMLNode, PreviousDocumentNo, PreviousPostingDate, PreviousHuella);
        InsertInformationSystem(InvoiceXMLNode);
        InsertHuellaDigital(InvoiceXMLNode, VerifactuDateTime, VerifactuHash);

        RootXMLNode.Add(InvoiceXMLNode);
    end;

    local procedure InsertServiceInvoiceHeaderData(var InvoiceXMLNode: XmlElement; var ServiceInvoiceHeader: Record "Service Invoice Header"; InvoiceType: Text)
    var
        IDFacturaXMLNode, DestinatariosXMLNode, IDDestinatarioXMLNode : XmlElement;
    begin
        InvoiceXMLNode.Add(XmlElement.Create('IDVersion', XmlNamespaceSum1, '1.0'));

        IDFacturaXMLNode := XmlElement.Create('IDFactura', XmlNamespaceSum1);
        IDFacturaXMLNode.Add(XmlElement.Create('IDEmisorFactura', XmlNamespaceSum1, CompanyInformation."VAT Registration No."));
        IDFacturaXMLNode.Add(XmlElement.Create('NumSerieFactura', XmlNamespaceSum1, ServiceInvoiceHeader."No."));
        IDFacturaXMLNode.Add(XmlElement.Create('FechaExpedicionFactura', XmlNamespaceSum1, FormatDate(ServiceInvoiceHeader."Posting Date")));
        InvoiceXMLNode.Add(IDFacturaXMLNode);

        InvoiceXMLNode.Add(XmlElement.Create('NombreRazonEmisor', XmlNamespaceSum1, CompanyInformation."Name"));
        InvoiceXMLNode.Add(XmlElement.Create('TipoFactura', XmlNamespaceSum1, InvoiceType));
        if ServiceInvoiceHeader."Operation Description" = '' then
            ServiceInvoiceHeader."Operation Description" := ServiceInvoiceHeader."No.";
        InvoiceXMLNode.Add(XmlElement.Create('DescripcionOperacion', XmlNamespaceSum1, ServiceInvoiceHeader."Operation Description"));

        DestinatariosXMLNode := XmlElement.Create('Destinatarios', XmlNamespaceSum1);
        IDDestinatarioXMLNode := XmlElement.Create('IDDestinatario', XmlNamespaceSum1);
        IDDestinatarioXMLNode.Add(XmlElement.Create('NombreRazon', XmlNamespaceSum1, CompanyInformation.Name));
        IDDestinatarioXMLNode.Add(XmlElement.Create('NIF', XmlNamespaceSum1, CompanyInformation."VAT Registration No."));
        DestinatariosXMLNode.Add(IDDestinatarioXMLNode);
        InvoiceXMLNode.Add(DestinatariosXMLNode);
    end;

    local procedure InsertServiceInvoiceBreakdown(var InvoiceXMLNode: XmlElement; var ServiceInvoiceHeader: Record "Service Invoice Header"; var ServiceInvoiceLine: Record "Service Invoice Line")
    var
        TempServiceInvoiceLine: Record "Service Invoice Line" temporary;
        DesgloseXMLNode, DetalleIVAXMLNode : XmlElement;
    begin
        ServiceInvoiceLine.SetRange("Document No.", ServiceInvoiceHeader."No.");
        ServiceInvoiceLine.SetFilter(Type, '<>%1', ServiceInvoiceLine.Type::" ");
        if ServiceInvoiceLine.FindSet() then
            repeat
                if FindLineInTempServiceInvoiceLine(TempServiceInvoiceLine, ServiceInvoiceLine) then begin
                    TempServiceInvoiceLine.Amount += ServiceInvoiceLine.Amount;
                    TempServiceInvoiceLine."Amount Including VAT" += ServiceInvoiceLine."Amount Including VAT";
                    TempServiceInvoiceLine.Modify();
                end else begin
                    TempServiceInvoiceLine.Init();
                    TempServiceInvoiceLine := ServiceInvoiceLine;
                    TempServiceInvoiceLine.Insert();
                end;
            until ServiceInvoiceLine.Next() = 0;

        DesgloseXMLNode := XmlElement.Create('Desglose', XmlNamespaceSum1);

        TempServiceInvoiceLine.Reset();
        TempServiceInvoiceLine.SetRange("Document No.", ServiceInvoiceHeader."No.");
        if TempServiceInvoiceLine.FindSet() then
            repeat
                DetalleIVAXMLNode := XmlElement.Create('DetalleDesglose', XmlNamespaceSum1);
                DetalleIVAXMLNode.Add(XmlElement.Create('ClaveRegimen', XmlNamespaceSum1, GetOptionFirstTwoChars(ServiceInvoiceHeader."Special Scheme Code")));
                DetalleIVAXMLNode.Add(XmlElement.Create('CalificacionOperacion', XmlNamespaceSum1, GetVATIdentifier(TempServiceInvoiceLine."VAT Identifier")));
                DetalleIVAXMLNode.Add(XmlElement.Create('TipoImpositivo', XmlNamespaceSum1, Format(TempServiceInvoiceLine."VAT %", 0, 9)));
                DetalleIVAXMLNode.Add(XmlElement.Create('BaseImponibleOimporteNoSujeto', XmlNamespaceSum1, Format(TempServiceInvoiceLine.Amount, 0, 9)));
                DetalleIVAXMLNode.Add(XmlElement.Create('CuotaRepercutida', XmlNamespaceSum1, Format(TempServiceInvoiceLine."Amount Including VAT" - TempServiceInvoiceLine.Amount, 0, 9)));
                DesgloseXMLNode.Add(DetalleIVAXMLNode);
            until TempServiceInvoiceLine.Next() = 0;
        TempServiceInvoiceLine.CalcSums(Amount, "Amount Including VAT");

        InvoiceXMLNode.Add(DesgloseXMLNode);
    end;

    local procedure InsertTotals(var InvoiceXMLNode: XmlElement; var ServiceInvoiceHeader: Record "Service Invoice Header")
    begin
        InvoiceXMLNode.Add(XmlElement.Create('CuotaTotal', XmlNamespaceSum1, ServiceInvoiceHeader."Amount Including VAT" - ServiceInvoiceHeader.Amount));
        InvoiceXMLNode.Add(XmlElement.Create('ImporteTotal', XmlNamespaceSum1, ServiceInvoiceHeader."Amount Including VAT"));
    end;

    local procedure FindLineInTempServiceInvoiceLine(var TempServiceInvoiceLine: Record "Service Invoice Line" temporary; var ServiceInvoiceLine: Record "Service Invoice Line"): Boolean
    begin
        TempServiceInvoiceLine.SetRange("Document No.", ServiceInvoiceLine."Document No.");
        TempServiceInvoiceLine.SetRange("VAT %", ServiceInvoiceLine."VAT %");
        exit(TempServiceInvoiceLine.FindFirst());
    end;

    local procedure GenerateHash(ServiceInvoiceHeader: Record "Service Invoice Header"; InvoiceType: Text; VerifactuDateTime: Text; PreviousHuella: Text): Text[64]
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
        InputString: Text;
    begin
        InputString :=
            'IDEmisorFactura=' + CompanyInformation."VAT Registration No." +
            '&' +
            'NumSerieFactura=' + ServiceInvoiceHeader."No." +
            '&' +
            'FechaExpedicionFactura=' + Format(ServiceInvoiceHeader."Posting Date", 0, '<Day,2>-<Month,2>-<Year4>') +
            '&' +
            'TipoFactura=' + InvoiceType +
            '&' +
            'CuotaTotal=' + Format(ServiceInvoiceHeader."Amount Including VAT" - ServiceInvoiceHeader.Amount, 0, 9) +
            '&' +
            'ImporteTotal=' + Format(ServiceInvoiceHeader."Amount Including VAT", 0, 9) +
            '&' +
            'Huella=' + PreviousHuella +
            '&' +
            'FechaHoraHusoGenRegistro=' + VerifactuDateTime;
        exit(
            CopyStr(
                CryptographyManagement.GenerateHash(InputString, HashAlgorithmType::SHA256), 1, 64));
    end;
    #endregion
    #region Credit Memo
    local procedure ExportCreditMemo(var EDocument: Record "E-Document"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; var TempBlob: Codeunit "Temp Blob"; IsBatch: Boolean)
    var
        TempBlobQR: Codeunit "Temp Blob";
        InvoiceType, VerifactuDateTime : Text;
        PreviousDocumentNo, PreviousHuella : Text;
        VerifactuHash: Text[64];
        PreviousPostingDate: Date;
        FileOutStream, OutStr : OutStream;
        InStr: InStream;
    begin
        SalesCrMemoHeader.CalcFields(Amount, "Amount Including VAT");
        InvoiceType := GetOptionFirstTwoChars(SalesCrMemoHeader."Cr. Memo Type");
        VerifactuDateTime := GetCustomDateTimeFormat(CurrentDateTime());
        FindLastRegisteredDocument(PreviousDocumentNo, PreviousPostingDate, PreviousHuella);
        VerifactuHash := GenerateHash(SalesCrMemoHeader, InvoiceType, VerifactuDateTime, PreviousHuella);
        VerifactuDocUploadMgt.InsertVerifactuDocument(EDocument, SalesCrMemoHeader."No.", SalesCrMemoHeader."Posting Date", VerifactuHash);

        CreateXML(SalesCrMemoHeader, SalesCrMemoLine, IsBatch, TempBlob, FileOutStream, InvoiceType, VerifactuDateTime, VerifactuHash, PreviousDocumentNo, PreviousPostingDate, PreviousHuella);

        TempBlobQR := GenerateQRCode(SalesCrMemoHeader."No.", SalesCrMemoHeader."Posting Date", SalesCrMemoHeader."Amount Including VAT");
        TempBlobQR.CreateInStream(InStr);
        SalesCrMemoHeader."QR Code Base64".CreateOutStream(OutStr, TextEncoding::UTF8);
        CopyStream(OutStr, InStr);
        SalesCrMemoHeader."QR Code Image".ImportStream(InStr, 'image.png');
        SalesCrMemoHeader.Modify();
    end;

    local procedure CreateXML(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; IsBatch: Boolean; var TempBlob: Codeunit "Temp Blob"; var FileOutStream: OutStream; InvoiceType: Text; VerifactuDateTime: Text; VerifactuHash: Text[64]; PreviousDocumentNo: Text; PreviousPostingDate: Date; PreviousHuella: Text)
    var
        HeaderXMLNode, BodyXMLNode, RegFactuSistemaFacturacionXMLNode, RootXMLNode : XmlElement;
        XMLDocOut: XmlDocument;
    begin
        TempBlob.CreateOutStream(FileOutStream, TextEncoding::UTF8);

        XmlDocument.ReadFrom(GetBasicXMLHeader(), XMLDocOut);
        XMLDocOut.GetRoot(RootXMLNode);

        InitializeNamespaces();
        HeaderXMLNode := XmlElement.Create('Header', XmlNamespaceSoapenv);
        BodyXMLNode := XmlElement.Create('Body', XmlNamespaceSoapenv);
        RegFactuSistemaFacturacionXMLNode := XmlElement.Create('RegFactuSistemaFacturacion', XmlNamespaceSum);
        InsertHeaderData(RegFactuSistemaFacturacionXMLNode);
        InsertCreditMemosData(RegFactuSistemaFacturacionXMLNode, SalesCrMemoHeader, SalesCrMemoLine, IsBatch, InvoiceType, VerifactuDateTime, VerifactuHash, PreviousDocumentNo, PreviousPostingDate, PreviousHuella);

        BodyXMLNode.Add(RegFactuSistemaFacturacionXMLNode);
        RootXMLNode.Add(HeaderXMLNode);
        RootXMLNode.Add(BodyXMLNode);

        XmlDocOut.WriteTo(FileOutStream);
    end;

    local procedure InsertCreditMemosData(var RootXMLNode: XmlElement; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; IsBatch: Boolean; InvoiceType: Text; VerifactuDateTime: Text; VerifactuHash: Text[64]; PreviousDocumentNo: Text; PreviousPostingDate: Date; PreviousHuella: Text)
    var
        CreditMemoXMLNode: XmlElement;
        CreditMemoCount: Integer;
    begin
        CreditMemoXMLNode := XmlElement.Create('RegistroFactura', XmlNamespaceSum);

        if IsBatch then
            repeat
                CreditMemoCount += 1;
                if CreditMemoCount > 1000 then
                    Error(MaxBatchSizeErr);
                InsertCreditMemo(CreditMemoXMLNode, SalesCrMemoHeader, SalesCrMemoLine, InvoiceType, VerifactuDateTime, VerifactuHash, PreviousDocumentNo, PreviousPostingDate, PreviousHuella);
            until SalesCrMemoHeader.Next() = 0
        else
            InsertCreditMemo(CreditMemoXMLNode, SalesCrMemoHeader, SalesCrMemoLine, InvoiceType, VerifactuDateTime, VerifactuHash, PreviousDocumentNo, PreviousPostingDate, PreviousHuella);
        RootXMLNode.Add(CreditMemoXMLNode);
    end;

    local procedure InsertCreditMemo(var RootXMLNode: XmlElement; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; InvoiceType: Text; VerifactuDateTime: Text; VerifactuHash: Text[64]; PreviousDocumentNo: Text; PreviousPostingDate: Date; PreviousHuella: Text)
    var
        Customer: Record Customer;
        CrMemoXMLNode: XmlElement;
    begin
        Customer.Get(SalesCrMemoHeader."Bill-to Customer No.");

        CrMemoXMLNode := XmlElement.Create('RegistroAlta', XmlNamespaceSum1);

        InsertCreditMemoHeaderData(CrMemoXMLNode, SalesCrMemoHeader, InvoiceType);
        InsertCreditMemoBreakdown(CrMemoXMLNode, SalesCrMemoHeader, SalesCrMemoLine);
        InsertTotals(CrMemoXMLNode, SalesCrMemoHeader);
        InsertRegistroAnterior(CrMemoXMLNode, PreviousDocumentNo, PreviousPostingDate, PreviousHuella);
        InsertInformationSystem(CrMemoXMLNode);
        InsertHuellaDigital(CrMemoXMLNode, VerifactuDateTime, VerifactuHash);

        RootXMLNode.Add(CrMemoXMLNode);
    end;

    local procedure InsertCreditMemoHeaderData(var InvoiceXMLNode: XmlElement; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; InvoiceType: Text)
    var
        IDFacturaXMLNode, DestinatariosXMLNode, IDDestinatarioXMLNode : XmlElement;
    begin
        InvoiceXMLNode.Add(XmlElement.Create('IDVersion', XmlNamespaceSum1, '1.0'));

        IDFacturaXMLNode := XmlElement.Create('IDFactura', XmlNamespaceSum1);
        IDFacturaXMLNode.Add(XmlElement.Create('IDEmisorFactura', XmlNamespaceSum1, CompanyInformation."VAT Registration No."));
        IDFacturaXMLNode.Add(XmlElement.Create('NumSerieFactura', XmlNamespaceSum1, SalesCrMemoHeader."No."));
        IDFacturaXMLNode.Add(XmlElement.Create('FechaExpedicionFactura', XmlNamespaceSum1, FormatDate(SalesCrMemoHeader."Posting Date")));
        InvoiceXMLNode.Add(IDFacturaXMLNode);

        InvoiceXMLNode.Add(XmlElement.Create('NombreRazonEmisor', XmlNamespaceSum1, CompanyInformation."Name"));
        InvoiceXMLNode.Add(XmlElement.Create('TipoFactura', XmlNamespaceSum1, InvoiceType));
        InvoiceXMLNode.Add(XmlElement.Create('TipoRectificativa', XmlNamespaceSum1, 'I'));
        InsertFacturaRectificada(InvoiceXMLNode, SalesCrMemoHeader);
        if SalesCrMemoHeader."Operation Description" = '' then
            SalesCrMemoHeader."Operation Description" := SalesCrMemoHeader."No.";
        InvoiceXMLNode.Add(XmlElement.Create('DescripcionOperacion', XmlNamespaceSum1, SalesCrMemoHeader."Operation Description"));

        DestinatariosXMLNode := XmlElement.Create('Destinatarios', XmlNamespaceSum1);
        IDDestinatarioXMLNode := XmlElement.Create('IDDestinatario', XmlNamespaceSum1);
        IDDestinatarioXMLNode.Add(XmlElement.Create('NombreRazon', XmlNamespaceSum1, CompanyInformation.Name));
        IDDestinatarioXMLNode.Add(XmlElement.Create('NIF', XmlNamespaceSum1, CompanyInformation."VAT Registration No."));
        DestinatariosXMLNode.Add(IDDestinatarioXMLNode);
        InvoiceXMLNode.Add(DestinatariosXMLNode);
    end;

    local procedure InsertCreditMemoBreakdown(var InvoiceXMLNode: XmlElement; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesCrMemoLine: Record "Sales Cr.Memo Line")
    var
        TempSalesCrMemoLine: Record "Sales Cr.Memo Line" temporary;
        DesgloseXMLNode, DetalleIVAXMLNode : XmlElement;
    begin
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetFilter(Type, '<>%1', SalesCrMemoLine.Type::" ");
        if SalesCrMemoLine.FindSet() then
            repeat
                if FindLineInTempSalesCrMemoLine(TempSalesCrMemoLine, SalesCrMemoLine) then begin
                    TempSalesCrMemoLine.Amount += SalesCrMemoLine.Amount;
                    TempSalesCrMemoLine."Amount Including VAT" += SalesCrMemoLine."Amount Including VAT";
                    TempSalesCrMemoLine.Modify();
                end else begin
                    TempSalesCrMemoLine.Init();
                    TempSalesCrMemoLine := SalesCrMemoLine;
                    TempSalesCrMemoLine.Insert();
                end;
            until SalesCrMemoLine.Next() = 0;

        DesgloseXMLNode := XmlElement.Create('Desglose', XmlNamespaceSum1);

        TempSalesCrMemoLine.Reset();
        TempSalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        if TempSalesCrMemoLine.FindSet() then
            repeat
                DetalleIVAXMLNode := XmlElement.Create('DetalleDesglose', XmlNamespaceSum1);
                DetalleIVAXMLNode.Add(XmlElement.Create('ClaveRegimen', XmlNamespaceSum1, GetOptionFirstTwoChars(TempSalesCrMemoLine."Special Scheme Code")));
                DetalleIVAXMLNode.Add(XmlElement.Create('CalificacionOperacion', XmlNamespaceSum1, GetVATIdentifier(TempSalesCrMemoLine."VAT Identifier")));
                DetalleIVAXMLNode.Add(XmlElement.Create('TipoImpositivo', XmlNamespaceSum1, Format(TempSalesCrMemoLine."VAT %", 0, 9)));
                DetalleIVAXMLNode.Add(XmlElement.Create('BaseImponibleOimporteNoSujeto', XmlNamespaceSum1, Format(-TempSalesCrMemoLine.Amount, 0, 9)));
                DetalleIVAXMLNode.Add(XmlElement.Create('CuotaRepercutida', XmlNamespaceSum1, Format(-(TempSalesCrMemoLine."Amount Including VAT" - TempSalesCrMemoLine.Amount), 0, 9)));
                DesgloseXMLNode.Add(DetalleIVAXMLNode);
            until TempSalesCrMemoLine.Next() = 0;
        TempSalesCrMemoLine.CalcSums(Amount, "Amount Including VAT");

        InvoiceXMLNode.Add(DesgloseXMLNode);
    end;

    local procedure InsertTotals(var InvoiceXMLNode: XmlElement; var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        InvoiceXMLNode.Add(XmlElement.Create('CuotaTotal', XmlNamespaceSum1, -(SalesCrMemoHeader."Amount Including VAT" - SalesCrMemoHeader.Amount)));
        InvoiceXMLNode.Add(XmlElement.Create('ImporteTotal', XmlNamespaceSum1, -SalesCrMemoHeader."Amount Including VAT"));
    end;

    local procedure GenerateHash(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; InvoiceType: Text; VerifactuDateTime: Text; PreviousHuella: Text): Text[64]
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
        InputString: Text;
    begin
        InputString :=
            'IDEmisorFactura=' + CompanyInformation."VAT Registration No." +
            '&' +
            'NumSerieFactura=' + SalesCrMemoHeader."No." +
            '&' +
            'FechaExpedicionFactura=' + Format(SalesCrMemoHeader."Posting Date", 0, '<Day,2>-<Month,2>-<Year4>') +
            '&' +
            'TipoFactura=' + InvoiceType +
            '&' +
            'CuotaTotal=' + Format(-(SalesCrMemoHeader."Amount Including VAT" - SalesCrMemoHeader.Amount), 0, 9) +
            '&' +
            'ImporteTotal=' + Format(-SalesCrMemoHeader."Amount Including VAT", 0, 9) +
            '&' +
            'Huella=' + PreviousHuella +
            '&' +
            'FechaHoraHusoGenRegistro=' + VerifactuDateTime;
        exit(
            CopyStr(
                CryptographyManagement.GenerateHash(InputString, HashAlgorithmType::SHA256), 1, 64));
    end;

    local procedure FindLineInTempSalesCrMemoLine(var TempSalesCrMemoLine: Record "Sales Cr.Memo Line" temporary; var SalesCrMemoLine: Record "Sales Cr.Memo Line"): Boolean
    begin
        TempSalesCrMemoLine.SetRange("Document No.", SalesCrMemoLine."Document No.");
        TempSalesCrMemoLine.SetRange("VAT %", SalesCrMemoLine."VAT %");
        exit(TempSalesCrMemoLine.FindFirst());
    end;

    local procedure InsertFacturaRectificada(var InvoiceXMLNode: XmlElement; var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        FacturaRectificadaXMLNode, IDFacturaRectificadaXMLNode : XmlElement;
    begin
        SalesInvoiceHeader.Get(SalesCrMemoHeader."Corrected Invoice No.");
        FacturaRectificadaXMLNode := XmlElement.Create('FacturasRectificadas', XmlNamespaceSum1);

        IDFacturaRectificadaXMLNode := XmlElement.Create('IDFacturaRectificada', XmlNamespaceSum1);
        IDFacturaRectificadaXMLNode.Add(XmlElement.Create('IDEmisorFactura', XmlNamespaceSum1, CompanyInformation."VAT Registration No."));
        IDFacturaRectificadaXMLNode.Add(XmlElement.Create('NumSerieFactura', XmlNamespaceSum1, SalesInvoiceHeader."No."));
        IDFacturaRectificadaXMLNode.Add(XmlElement.Create('FechaExpedicionFactura', XmlNamespaceSum1, FormatDate(SalesInvoiceHeader."Posting Date")));
        FacturaRectificadaXMLNode.Add(IDFacturaRectificadaXMLNode);

        InvoiceXMLNode.Add(FacturaRectificadaXMLNode);
    end;
    #endregion
    #region Service Credit Memo
    local procedure ExportServiceCreditMemo(var EDocument: Record "E-Document"; var ServiceCrMemoHeader: Record "Service Cr.Memo Header"; var ServiceCrMemoLine: Record "Service Cr.Memo Line"; var TempBlob: Codeunit "Temp Blob"; IsBatch: Boolean)
    var
        InvoiceType, VerifactuDateTime : Text;
        PreviousDocumentNo, PreviousHuella : Text;
        VerifactuHash: Text[64];
        PreviousPostingDate: Date;
        FileOutStream: OutStream;
    begin
        ServiceCrMemoHeader.CalcFields(Amount, "Amount Including VAT");
        InvoiceType := GetOptionFirstTwoChars(ServiceCrMemoHeader."Cr. Memo Type");
        VerifactuDateTime := GetCustomDateTimeFormat(CurrentDateTime());
        FindLastRegisteredDocument(PreviousDocumentNo, PreviousPostingDate, PreviousHuella);
        VerifactuHash := GenerateHash(ServiceCrMemoHeader, InvoiceType, VerifactuDateTime, PreviousHuella);
        VerifactuDocUploadMgt.InsertVerifactuDocument(EDocument, ServiceCrMemoHeader."No.", ServiceCrMemoHeader."Posting Date", VerifactuHash);

        CreateXML(ServiceCrMemoHeader, ServiceCrMemoLine, IsBatch, TempBlob, FileOutStream, InvoiceType, VerifactuDateTime, VerifactuHash, PreviousDocumentNo, PreviousPostingDate, PreviousHuella);

        ServiceCrMemoHeader.Modify();
    end;

    local procedure CreateXML(var ServiceCrMemoHeader: Record "Service Cr.Memo Header"; var ServiceCrMemoLine: Record "Service Cr.Memo Line"; IsBatch: Boolean; var TempBlob: Codeunit "Temp Blob"; var FileOutStream: OutStream; InvoiceType: Text; VerifactuDateTime: Text; VerifactuHash: Text[64]; PreviousDocumentNo: Text; PreviousPostingDate: Date; PreviousHuella: Text)
    var
        HeaderXMLNode, BodyXMLNode, RegFactuSistemaFacturacionXMLNode, RootXMLNode : XmlElement;
        XMLDocOut: XmlDocument;
    begin
        TempBlob.CreateOutStream(FileOutStream, TextEncoding::UTF8);

        XmlDocument.ReadFrom(GetBasicXMLHeader(), XMLDocOut);
        XMLDocOut.GetRoot(RootXMLNode);

        InitializeNamespaces();
        HeaderXMLNode := XmlElement.Create('Header', XmlNamespaceSoapenv);
        BodyXMLNode := XmlElement.Create('Body', XmlNamespaceSoapenv);
        RegFactuSistemaFacturacionXMLNode := XmlElement.Create('RegFactuSistemaFacturacion', XmlNamespaceSum);
        InsertHeaderData(RegFactuSistemaFacturacionXMLNode);
        InsertServiceCreditMemosData(RegFactuSistemaFacturacionXMLNode, ServiceCrMemoHeader, ServiceCrMemoLine, IsBatch, InvoiceType, VerifactuDateTime, VerifactuHash, PreviousDocumentNo, PreviousPostingDate, PreviousHuella);

        BodyXMLNode.Add(RegFactuSistemaFacturacionXMLNode);
        RootXMLNode.Add(HeaderXMLNode);
        RootXMLNode.Add(BodyXMLNode);

        XmlDocOut.WriteTo(FileOutStream);
    end;

    local procedure InsertServiceCreditMemosData(var RootXMLNode: XmlElement; var ServiceCrMemoHeader: Record "Service Cr.Memo Header"; var ServiceCrMemoLine: Record "Service Cr.Memo Line"; IsBatch: Boolean; InvoiceType: Text; VerifactuDateTime: Text; VerifactuHash: Text[64]; PreviousDocumentNo: Text; PreviousPostingDate: Date; PreviousHuella: Text)
    var
        CreditMemoXMLNode: XmlElement;
    begin
        CreditMemoXMLNode := XmlElement.Create('RegistroFactura', XmlNamespaceSum);

        if IsBatch then
            repeat
                InsertServiceCreditMemo(CreditMemoXMLNode, ServiceCrMemoHeader, ServiceCrMemoLine, InvoiceType, VerifactuDateTime, VerifactuHash, PreviousDocumentNo, PreviousPostingDate, PreviousHuella);
            until ServiceCrMemoHeader.Next() = 0
        else
            InsertServiceCreditMemo(CreditMemoXMLNode, ServiceCrMemoHeader, ServiceCrMemoLine, InvoiceType, VerifactuDateTime, VerifactuHash, PreviousDocumentNo, PreviousPostingDate, PreviousHuella);
        RootXMLNode.Add(CreditMemoXMLNode);
    end;

    local procedure InsertServiceCreditMemo(var RootXMLNode: XmlElement; var ServiceCrMemoHeader: Record "Service Cr.Memo Header"; var ServiceCrMemoLine: Record "Service Cr.Memo Line"; InvoiceType: Text; VerifactuDateTime: Text; VerifactuHash: Text[64]; PreviousDocumentNo: Text; PreviousPostingDate: Date; PreviousHuella: Text)
    var
        Customer: Record Customer;
        CrMemoXMLNode: XmlElement;
    begin
        Customer.Get(ServiceCrMemoHeader."Bill-to Customer No.");

        CrMemoXMLNode := XmlElement.Create('RegistroAlta', XmlNamespaceSum1);

        InsertServiceCreditMemoHeaderData(CrMemoXMLNode, ServiceCrMemoHeader, InvoiceType);
        InsertServiceCreditMemoBreakdown(CrMemoXMLNode, ServiceCrMemoHeader, ServiceCrMemoLine);
        InsertTotals(CrMemoXMLNode, ServiceCrMemoHeader);
        InsertRegistroAnterior(CrMemoXMLNode, PreviousDocumentNo, PreviousPostingDate, PreviousHuella);
        InsertInformationSystem(CrMemoXMLNode);
        InsertHuellaDigital(CrMemoXMLNode, VerifactuDateTime, VerifactuHash);

        RootXMLNode.Add(CrMemoXMLNode);
    end;

    local procedure InsertServiceCreditMemoHeaderData(var InvoiceXMLNode: XmlElement; var ServiceCrMemoHeader: Record "Service Cr.Memo Header"; InvoiceType: Text)
    var
        IDFacturaXMLNode, DestinatariosXMLNode, IDDestinatarioXMLNode : XmlElement;
    begin
        InvoiceXMLNode.Add(XmlElement.Create('IDVersion', XmlNamespaceSum1, '1.0'));

        IDFacturaXMLNode := XmlElement.Create('IDFactura', XmlNamespaceSum1);
        IDFacturaXMLNode.Add(XmlElement.Create('IDEmisorFactura', XmlNamespaceSum1, CompanyInformation."VAT Registration No."));
        IDFacturaXMLNode.Add(XmlElement.Create('NumSerieFactura', XmlNamespaceSum1, ServiceCrMemoHeader."No."));
        IDFacturaXMLNode.Add(XmlElement.Create('FechaExpedicionFactura', XmlNamespaceSum1, FormatDate(ServiceCrMemoHeader."Posting Date")));
        InvoiceXMLNode.Add(IDFacturaXMLNode);

        InvoiceXMLNode.Add(XmlElement.Create('NombreRazonEmisor', XmlNamespaceSum1, CompanyInformation."Name"));
        InvoiceXMLNode.Add(XmlElement.Create('TipoFactura', XmlNamespaceSum1, InvoiceType));
        InvoiceXMLNode.Add(XmlElement.Create('TipoRectificativa', XmlNamespaceSum1, 'I'));
        InsertFacturaRectificada(InvoiceXMLNode, ServiceCrMemoHeader);
        if ServiceCrMemoHeader."Operation Description" = '' then
            ServiceCrMemoHeader."Operation Description" := ServiceCrMemoHeader."No.";
        InvoiceXMLNode.Add(XmlElement.Create('DescripcionOperacion', XmlNamespaceSum1, ServiceCrMemoHeader."Operation Description"));

        DestinatariosXMLNode := XmlElement.Create('Destinatarios', XmlNamespaceSum1);
        IDDestinatarioXMLNode := XmlElement.Create('IDDestinatario', XmlNamespaceSum1);
        IDDestinatarioXMLNode.Add(XmlElement.Create('NombreRazon', XmlNamespaceSum1, CompanyInformation.Name));
        IDDestinatarioXMLNode.Add(XmlElement.Create('NIF', XmlNamespaceSum1, CompanyInformation."VAT Registration No."));
        DestinatariosXMLNode.Add(IDDestinatarioXMLNode);
        InvoiceXMLNode.Add(DestinatariosXMLNode);
    end;

    local procedure InsertServiceCreditMemoBreakdown(var InvoiceXMLNode: XmlElement; var ServiceCrMemoHeader: Record "Service Cr.Memo Header"; var ServiceCrMemoLine: Record "Service Cr.Memo Line")
    var
        TempServiceCrMemoLine: Record "Service Cr.Memo Line" temporary;
        DesgloseXMLNode, DetalleIVAXMLNode : XmlElement;
    begin
        ServiceCrMemoLine.SetRange("Document No.", ServiceCrMemoHeader."No.");
        ServiceCrMemoLine.SetFilter(Type, '<>%1', ServiceCrMemoLine.Type::" ");
        if ServiceCrMemoLine.FindSet() then
            repeat
                if FindLineInTempServiceCrMemoLine(TempServiceCrMemoLine, ServiceCrMemoLine) then begin
                    TempServiceCrMemoLine.Amount += ServiceCrMemoLine.Amount;
                    TempServiceCrMemoLine."Amount Including VAT" += ServiceCrMemoLine."Amount Including VAT";
                    TempServiceCrMemoLine.Modify();
                end else begin
                    TempServiceCrMemoLine.Init();
                    TempServiceCrMemoLine := ServiceCrMemoLine;
                    TempServiceCrMemoLine.Insert();
                end;
            until ServiceCrMemoLine.Next() = 0;

        DesgloseXMLNode := XmlElement.Create('Desglose', XmlNamespaceSum1);

        TempServiceCrMemoLine.Reset();
        TempServiceCrMemoLine.SetRange("Document No.", ServiceCrMemoHeader."No.");
        if TempServiceCrMemoLine.FindSet() then
            repeat
                DetalleIVAXMLNode := XmlElement.Create('DetalleDesglose', XmlNamespaceSum1);
                DetalleIVAXMLNode.Add(XmlElement.Create('ClaveRegimen', XmlNamespaceSum1, GetOptionFirstTwoChars(TempServiceCrMemoLine."Special Scheme Code")));
                DetalleIVAXMLNode.Add(XmlElement.Create('CalificacionOperacion', XmlNamespaceSum1, GetVATIdentifier(TempServiceCrMemoLine."VAT Identifier")));
                DetalleIVAXMLNode.Add(XmlElement.Create('TipoImpositivo', XmlNamespaceSum1, Format(TempServiceCrMemoLine."VAT %", 0, 9)));
                DetalleIVAXMLNode.Add(XmlElement.Create('BaseImponibleOimporteNoSujeto', XmlNamespaceSum1, Format(-TempServiceCrMemoLine.Amount, 0, 9)));
                DetalleIVAXMLNode.Add(XmlElement.Create('CuotaRepercutida', XmlNamespaceSum1, Format(-(TempServiceCrMemoLine."Amount Including VAT" - TempServiceCrMemoLine.Amount), 0, 9)));
                DesgloseXMLNode.Add(DetalleIVAXMLNode);
            until TempServiceCrMemoLine.Next() = 0;
        TempServiceCrMemoLine.CalcSums(Amount, "Amount Including VAT");

        InvoiceXMLNode.Add(DesgloseXMLNode);
    end;

    local procedure InsertTotals(var InvoiceXMLNode: XmlElement; var ServiceCrMemoHeader: Record "Service Cr.Memo Header")
    begin
        InvoiceXMLNode.Add(XmlElement.Create('CuotaTotal', XmlNamespaceSum1, -(ServiceCrMemoHeader."Amount Including VAT" - ServiceCrMemoHeader.Amount)));
        InvoiceXMLNode.Add(XmlElement.Create('ImporteTotal', XmlNamespaceSum1, -ServiceCrMemoHeader."Amount Including VAT"));
    end;

    local procedure FindLineInTempServiceCrMemoLine(var TempServiceCrMemoLine: Record "Service Cr.Memo Line" temporary; var ServiceCrMemoLine: Record "Service Cr.Memo Line"): Boolean
    begin
        TempServiceCrMemoLine.SetRange("Document No.", ServiceCrMemoLine."Document No.");
        TempServiceCrMemoLine.SetRange("VAT %", ServiceCrMemoLine."VAT %");
        exit(TempServiceCrMemoLine.FindFirst());
    end;

    local procedure GenerateHash(ServiceCrMemoHeader: Record "Service Cr.Memo Header"; InvoiceType: Text; VerifactuDateTime: Text; PreviousHuella: Text): Text[64]
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
        InputString: Text;
    begin
        InputString :=
            'IDEmisorFactura=' + CompanyInformation."VAT Registration No." +
            '&' +
            'NumSerieFactura=' + ServiceCrMemoHeader."No." +
            '&' +
            'FechaExpedicionFactura=' + Format(ServiceCrMemoHeader."Posting Date", 0, '<Day,2>-<Month,2>-<Year4>') +
            '&' +
            'TipoFactura=' + InvoiceType +
            '&' +
            'CuotaTotal=' + Format(-(ServiceCrMemoHeader."Amount Including VAT" - ServiceCrMemoHeader.Amount), 0, 9) +
            '&' +
            'ImporteTotal=' + Format(-ServiceCrMemoHeader."Amount Including VAT", 0, 9) +
            '&' +
            'Huella=' + PreviousHuella +
            '&' +
            'FechaHoraHusoGenRegistro=' + VerifactuDateTime;
        exit(
            CopyStr(
                CryptographyManagement.GenerateHash(InputString, HashAlgorithmType::SHA256), 1, 64));
    end;

    local procedure InsertFacturaRectificada(var InvoiceXMLNode: XmlElement; var ServiceCrMemoHeader: Record "Service Cr.Memo Header")
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        FacturaRectificadaXMLNode, IDFacturaRectificadaXMLNode : XmlElement;
    begin
        ServiceInvoiceHeader.Get(ServiceCrMemoHeader."Corrected Invoice No.");
        FacturaRectificadaXMLNode := XmlElement.Create('FacturasRectificadas', XmlNamespaceSum1);

        IDFacturaRectificadaXMLNode := XmlElement.Create('IDFacturaRectificada', XmlNamespaceSum1);
        IDFacturaRectificadaXMLNode.Add(XmlElement.Create('IDEmisorFactura', XmlNamespaceSum1, CompanyInformation."VAT Registration No."));
        IDFacturaRectificadaXMLNode.Add(XmlElement.Create('NumSerieFactura', XmlNamespaceSum1, ServiceInvoiceHeader."No."));
        IDFacturaRectificadaXMLNode.Add(XmlElement.Create('FechaExpedicionFactura', XmlNamespaceSum1, FormatDate(ServiceInvoiceHeader."Posting Date")));
        FacturaRectificadaXMLNode.Add(IDFacturaRectificadaXMLNode);

        InvoiceXMLNode.Add(FacturaRectificadaXMLNode);
    end;
    #endregion
    #region Common Procedures
    local procedure GenerateQRCode(DocumentNo: Text; DocumentDate: Date; DocumentAmount: Decimal): Codeunit "Temp Blob"
    var
        IBarcodeImageProvider2D: Interface "Barcode Image Provider 2D";
        BarcodeImageProvider2D: Enum "Barcode Image Provider 2D";
        BarcodeString: Text;
    begin
        BarcodeString := CreateQRCodeInput(
            CompanyInformation."VAT Registration No.",
            DocumentNo,
            DocumentDate,
            DocumentAmount);

        IBarcodeImageProvider2D := BarcodeImageProvider2D::Dynamics2D;

        exit(IBarcodeImageProvider2D.EncodeImage(BarcodeString, Enum::"Barcode Symbology 2D"::"QR-Code"));
    end;


    local procedure CreateQRCodeInput(NIF: Text; InvoiceID: Text; DateOfIssue: Date; Amount: Decimal): Text
    begin
        exit(
         VerifactuSetup.GetQRCodeValidationEndpointUrl() +
            'NoVerifactu?nif=' +
            CopyStr(NIF, 1, 13) +
            '&numserie=' +
            CopyStr(InvoiceID, 1, 13) +
            '&fecha=' +
            FormatDate(DateOfIssue) +
            '&importe=' +
            Format(Amount, 0, 9));
    end;

    local procedure InsertHeaderData(var BodyXMLNode: XmlElement)
    var
        CabeceraXMLNode, MandatoryIssuanceXMLNode : XmlElement;
    begin
        CabeceraXMLNode := XmlElement.Create('Cabecera', XmlNamespaceSum);
        MandatoryIssuanceXMLNode := XmlElement.Create('ObligadoEmision', XmlNamespaceSum1);
        MandatoryIssuanceXMLNode.Add(XmlElement.Create('NombreRazon', XmlNamespaceSum1, CompanyInformation.Name));
        MandatoryIssuanceXMLNode.Add(XmlElement.Create('NIF', XmlNamespaceSum1, CompanyInformation."VAT Registration No."));
        CabeceraXMLNode.Add(MandatoryIssuanceXMLNode);
        BodyXMLNode.Add(CabeceraXMLNode);
    end;

    local procedure GetBasicXMLHeader(): Text
    begin
        exit('<?xml version="1.0" encoding="UTF-8"?>' +
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ' +
            'xmlns:sum="https://www2.agenciatributaria.gob.es/static_files/common/internet/dep/aplicaciones/es/aeat/tike/cont/ws/SuministroLR.xsd" ' +
            'xmlns:sum1="https://www2.agenciatributaria.gob.es/static_files/common/internet/dep/aplicaciones/es/aeat/tike/cont/ws/SuministroInformacion.xsd" ' +
            'xmlns:xd="http://www.w3.org/2000/09/xmldsig#" />');
    end;

    local procedure InsertHuellaDigital(var InvoiceXMLNode: XmlElement; VerifactuDateTime: Text; VerifactuHash: Text)
    begin
        InvoiceXMLNode.Add(XmlElement.Create('FechaHoraHusoGenRegistro', XmlNamespaceSum1, VerifactuDateTime));
        InvoiceXMLNode.Add(XmlElement.Create('TipoHuella', XmlNamespaceSum1, '01'));
        InvoiceXMLNode.Add(XmlElement.Create('Huella', XmlNamespaceSum1, VerifactuHash));
    end;

    local procedure InsertRegistroAnterior(var InvoiceXMLNode: XmlElement; PreviousDocumentNo: Text; PreviousPostingDate: Date; PreviousHuella: Text)
    var
        EncadenamientoXMLNode: XmlElement;
    begin
        EncadenamientoXMLNode := XmlElement.Create('Encadenamiento', XmlNamespaceSum1);

        if PreviousHuella <> '' then
            InsertLastRegisteredDocumentData(EncadenamientoXMLNode, PreviousDocumentNo, PreviousPostingDate, PreviousHuella)
        else
            EncadenamientoXMLNode.Add(XmlElement.Create('PrimerRegistro', XmlNamespaceSum1, 'S'));
        InvoiceXMLNode.Add(EncadenamientoXMLNode);
    end;

    local procedure InsertLastRegisteredDocumentData(var EncadenamientoXMLNode: XmlElement; DocumentNo: Text; PostingDate: Date; Huella: Text)
    var
        RegistroAnteriorXMLNode: XmlElement;
    begin
        RegistroAnteriorXMLNode := XmlElement.Create('RegistroAnterior', XmlNamespaceSum1);
        RegistroAnteriorXMLNode.Add(XmlElement.Create('IDEmisorFactura', XmlNamespaceSum1, CompanyInformation."VAT Registration No."));
        RegistroAnteriorXMLNode.Add(XmlElement.Create('NumSerieFactura', XmlNamespaceSum1, DocumentNo));
        RegistroAnteriorXMLNode.Add(XmlElement.Create('FechaExpedicionFactura', XmlNamespaceSum1, FormatDate(PostingDate)));
        RegistroAnteriorXMLNode.Add(XmlElement.Create('Huella', XmlNamespaceSum1, Huella));
        EncadenamientoXMLNode.Add(RegistroAnteriorXMLNode);
    end;

    local procedure InsertInformationSystem(var InvoiceXMLNode: XmlElement)
    var
        SistemaInformacionXMLNode: XmlElement;
    begin
        SistemaInformacionXMLNode := XmlElement.Create('SistemaInformatico', XmlNamespaceSum1);
        SistemaInformacionXMLNode.Add(XmlElement.Create('NombreRazon', XmlNamespaceSum1, CompanyInformation.Name));
        SistemaInformacionXMLNode.Add(XmlElement.Create('NIF', XmlNamespaceSum1, CompanyInformation."VAT Registration No."));
        SistemaInformacionXMLNode.Add(XmlElement.Create('NombreSistemaInformatico', XmlNamespaceSum1, 'BusinessCentral'));
        SistemaInformacionXMLNode.Add(XmlElement.Create('IdSistemaInformatico', XmlNamespaceSum1, '77'));
        SistemaInformacionXMLNode.Add(XmlElement.Create('Version', XmlNamespaceSum1, '1.0'));
        SistemaInformacionXMLNode.Add(XmlElement.Create('NumeroInstalacion', XmlNamespaceSum1, '001'));
        SistemaInformacionXMLNode.Add(XmlElement.Create('TipoUsoPosibleSoloVerifactu', XmlNamespaceSum1, 'N'));
        SistemaInformacionXMLNode.Add(XmlElement.Create('TipoUsoPosibleMultiOT', XmlNamespaceSum1, 'N'));
        SistemaInformacionXMLNode.Add(XmlElement.Create('IndicadorMultiplesOT', XmlNamespaceSum1, 'N'));
        InvoiceXMLNode.Add(SistemaInformacionXMLNode);
    end;

    local procedure FindLastRegisteredDocument(var DocumentNo: Text; var PostingDate: Date; var Huella: Text)
    var
        VerifactuDocument: Record "Verifactu Document";
    begin
        VerifactuDocument.SetLoadFields("Source Document No.", "Verifactu Posting Date", "Verifactu Hash");
        VerifactuDocument.SetCurrentKey("Verifactu Hash");
        VerifactuDocument.SetFilter("Verifactu Hash", '<>%1', '');
        if not VerifactuDocument.FindLast() then
            exit;

        DocumentNo := VerifactuDocument."Source Document No.";
        PostingDate := VerifactuDocument."Verifactu Posting Date";
        Huella := VerifactuDocument."Verifactu Hash";
    end;

    procedure GetCustomDateTimeFormat(LocalDT: DateTime): Text
    var
        TypeHelper: Codeunit "Type Helper";
        TimeZoneOffset: Duration;
        OffsetMinutes: Integer;
        OffsetHours: Integer;
        OffsetSign: Text[1];
        OffsetText: Text;
    begin
        TypeHelper.GetTimezoneOffset(TimeZoneOffset, GetTimeZoneFromCompany());

        OffsetMinutes := Abs(TimeZoneOffset div 60000);

        if TimeZoneOffset >= 0 then
            OffsetSign := '+'
        else
            OffsetSign := '-';

        OffsetHours := OffsetMinutes div 60;
        OffsetMinutes := OffsetMinutes mod 60;

        OffsetText := StrSubstNo('%1%2:%3',
            OffsetSign,
            FormatTime(OffsetHours),
            FormatTime(OffsetMinutes));

        exit(
            StrSubstNo('%1%2',
                Format(LocalDT, 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>'),
                OffsetText));
    end;

    local procedure GetTimeZoneFromCompany(): Text
    var
        PostCode: Record "Post Code";
    begin
        if PostCode.Get(CompanyInformation."Post Code", CompanyInformation.City) then
            exit(PostCode."Time Zone");
        exit('');
    end;

    local procedure FormatTime(Value: Integer): Text
    begin
        if Value < 10 then
            exit('0' + Format(Value))
        else
            exit(Format(Value));
    end;

    local procedure FormatDate(DateValue: Date): Text
    begin
        exit(Format(DateValue, 0, '<Day,2>-<Month,2>-<Year4>'));
    end;

    local procedure GetVATIdentifier(VATIdentifier: Code[20]): Text
    begin
        if VATIdentifier = '' then
            exit('N1')
        else
            exit('S1');
    end;

    local procedure GetOptionFirstTwoChars(OptionValue: Variant): Text[2]
    var
        OptionString: Text;
    begin
        OptionString := Format(OptionValue);
        exit(CopyStr(OptionString, 1, 2));
    end;

    local procedure InitializeNamespaces()
    begin
        XmlNamespaceSoapenv := 'http://schemas.xmlsoap.org/soap/envelope/';
        XmlNamespaceSum := 'https://www2.agenciatributaria.gob.es/static_files/common/internet/dep/aplicaciones/es/aeat/tike/cont/ws/SuministroLR.xsd';
        XmlNamespaceSum1 := 'https://www2.agenciatributaria.gob.es/static_files/common/internet/dep/aplicaciones/es/aeat/tike/cont/ws/SuministroInformacion.xsd';
    end;
    #endregion

    [IntegrationEvent(false, false)]
    local procedure OnAfterExport(var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob"; IsBatch: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExport(var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob"; IsBatch: Boolean)
    begin
    end;
}