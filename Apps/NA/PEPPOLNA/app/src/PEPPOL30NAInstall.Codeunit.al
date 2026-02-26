// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Peppol;

using Microsoft.Foundation.Reporting;

codeunit 37351 "PEPPOL30 NA Install"
{
    Subtype = Install;
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    internal procedure CreateElectronicDocumentFormats()
    var
        ElectronicDocumentFormat: Record "Electronic Document Format";
        PEPPOLBIS3_ElectronicFormatDescriptionTxt: Label 'PEPPOL BIS3 Format (Pan-European Public Procurement Online)';
        PEPPOLBIS3_ElectronicFormatTok: Label 'PEPPOL30NA', Locked = true;
    begin
        ElectronicDocumentFormat.InsertElectronicFormat(
            PEPPOLBIS3_ElectronicFormatTok, PEPPOLBIS3_ElectronicFormatDescriptionTxt,
            Codeunit::"Exp. Sales Inv. PEPPOL30", 0, ElectronicDocumentFormat.Usage::"Sales Invoice".AsInteger());

        ElectronicDocumentFormat.InsertElectronicFormat(
            PEPPOLBIS3_ElectronicFormatTok, PEPPOLBIS3_ElectronicFormatDescriptionTxt,
            Codeunit::"Exp. Sales CrM. PEPPOL30", 0, ElectronicDocumentFormat.Usage::"Sales Credit Memo".AsInteger());

        ElectronicDocumentFormat.InsertElectronicFormat(
            PEPPOLBIS3_ElectronicFormatTok, PEPPOLBIS3_ElectronicFormatDescriptionTxt,
            Codeunit::"PEPPOL30 Sales Validation", 0, ElectronicDocumentFormat.Usage::"Sales Validation".AsInteger());

        ElectronicDocumentFormat.InsertElectronicFormat(
            PEPPOLBIS3_ElectronicFormatTok, PEPPOLBIS3_ElectronicFormatDescriptionTxt,
            Codeunit::"Exp. Serv.Inv. PEPPOL30", 0, ElectronicDocumentFormat.Usage::"Service Invoice".AsInteger());

        ElectronicDocumentFormat.InsertElectronicFormat(
            PEPPOLBIS3_ElectronicFormatTok, PEPPOLBIS3_ElectronicFormatDescriptionTxt,
            Codeunit::"Exp. Serv.CrM. PEPPOL30", 0, ElectronicDocumentFormat.Usage::"Service Credit Memo".AsInteger());

        ElectronicDocumentFormat.InsertElectronicFormat(
            PEPPOLBIS3_ElectronicFormatTok, PEPPOLBIS3_ElectronicFormatDescriptionTxt,
            Codeunit::"PEPPOL30 Service Validation", 0, ElectronicDocumentFormat.Usage::"Service Validation".AsInteger());
    end;
}
