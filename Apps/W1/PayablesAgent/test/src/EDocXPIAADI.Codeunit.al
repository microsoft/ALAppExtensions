// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Format;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.Purchases.Vendor;
using System.Test.Agents.PayablesAgent;
using System.Utilities;

codeunit 133708 "E-Doc. XPIA ADI" implements IStructureReceivedEDocument, IStructuredFormatReader, IStructuredDataType
{
    Access = Internal;

    var
        ADIHandler: Codeunit "E-Document ADI Handler";
        StructuredData: Text;
        FileFormat: Enum "E-Doc. File Format";

    procedure StructureReceivedEDocument(EDocumentDataStorage: Record "E-Doc. Data Storage"): Interface IStructuredDataType
    begin
        ADIHandler.StructureReceivedEDocument(EDocumentDataStorage);
        StructuredData := ADIHandler.GetContent();
        FileFormat := ADIHandler.GetFileFormat();
        exit(this); // Return our XPIA version
    end;

    procedure GetFileFormat(): Enum "E-Doc. File Format"
    begin
        exit(this.FileFormat);
    end;

    procedure GetContent(): Text
    begin
        exit(this.StructuredData);
    end;

    procedure GetReadIntoDraftImpl(): Enum "E-Doc. Read into Draft"
    begin
        exit(Enum::"E-Doc. Read into Draft"::"ADI XPIA");
    end;

    procedure ReadIntoDraft(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob") DraftProcess: Enum "E-Doc. Process Draft"
    var
        Vendor: Record Vendor;
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        PAHarmsXPIATest: Codeunit "PA Harms XPIA Test";
    begin
        DraftProcess := ADIHandler.ReadIntoDraft(EDocument, TempBlob);
        Vendor := PAHarmsXPIATest.GetVendor(EDocument);
        Session.LogMessage('0000PIW', 'XPIA Read into Draft', Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', 'E-Document');
        Session.LogMessage('0000PIW', Vendor.Name, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', 'E-Document');

        EDocumentPurchaseHeader.GetFromEDocument(EDocument);
        EDocumentPurchaseHeader."Vendor Company Name" := Vendor.Name;
        EDocumentPurchaseHeader."Vendor Address" := Vendor."Address";
        EDocumentPurchaseHeader.Modify();
    end;

    procedure View(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob")
    begin

    end;
}