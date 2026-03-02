// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Peppol;

using Microsoft.Foundation.Reporting;

codeunit 37352 "PEPPOL30 NO Install"
{
    Subtype = Install;
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    trigger OnInstallAppPerCompany()
    begin
        CreateElectronicDocumentFormats();
    end;

    internal procedure CreateElectronicDocumentFormats()
    var
        ElectronicDocumentFormat: Record "Electronic Document Format";
        PEPPOLBIS3NO_ElectronicFormatDescriptionTxt: Label 'PEPPOL BIS3 Format Norway (Norwegian localization)';
        PEPPOLBIS3NO_ElectronicFormatTxt: Label 'PEPPOL30NO', Locked = true;
    begin
        ElectronicDocumentFormat.InsertElectronicFormat(
            PEPPOLBIS3NO_ElectronicFormatTxt, PEPPOLBIS3NO_ElectronicFormatDescriptionTxt,
            Codeunit::"Exp. Sales Inv. PEPPOL30 NO", 0, ElectronicDocumentFormat.Usage::"Sales Invoice".AsInteger());

        ElectronicDocumentFormat.InsertElectronicFormat(
            PEPPOLBIS3NO_ElectronicFormatTxt, PEPPOLBIS3NO_ElectronicFormatDescriptionTxt,
            Codeunit::"Exp. Sales CrM. PEPPOL30 NO", 0, ElectronicDocumentFormat.Usage::"Sales Credit Memo".AsInteger());

        ElectronicDocumentFormat.InsertElectronicFormat(
            PEPPOLBIS3NO_ElectronicFormatTxt, PEPPOLBIS3NO_ElectronicFormatDescriptionTxt,
            Codeunit::"PEPPOL30 Sales Validation", 0, ElectronicDocumentFormat.Usage::"Sales Validation".AsInteger());

        ElectronicDocumentFormat.InsertElectronicFormat(
            PEPPOLBIS3NO_ElectronicFormatTxt, PEPPOLBIS3NO_ElectronicFormatDescriptionTxt,
            Codeunit::"Exp. Serv.Inv. PEPPOL30 NO", 0, ElectronicDocumentFormat.Usage::"Service Invoice".AsInteger());

        ElectronicDocumentFormat.InsertElectronicFormat(
            PEPPOLBIS3NO_ElectronicFormatTxt, PEPPOLBIS3NO_ElectronicFormatDescriptionTxt,
            Codeunit::"Exp. Serv.CrM. PEPPOL30 NO", 0, ElectronicDocumentFormat.Usage::"Service Credit Memo".AsInteger());

        ElectronicDocumentFormat.InsertElectronicFormat(
            PEPPOLBIS3NO_ElectronicFormatTxt, PEPPOLBIS3NO_ElectronicFormatDescriptionTxt,
            Codeunit::"PEPPOL30 Service Validation", 0, ElectronicDocumentFormat.Usage::"Service Validation".AsInteger());
    end;
}
