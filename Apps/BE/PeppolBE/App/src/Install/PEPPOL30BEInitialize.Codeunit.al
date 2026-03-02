// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Peppol.BE;

using Microsoft.Foundation.Reporting;
using Microsoft.Peppol;

codeunit 37312 "PEPPOL30 BE Initialize"
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
        PEPPOLBIS3BE_ElectronicFormatDescriptionTxt: Label 'PEPPOL BIS3 Format Belgium (Belgian localization)';
        PEPPOLBIS3BE_ElectronicFormatTxt: Label 'PEPPOL30BE', Locked = true;
    begin
        ElectronicDocumentFormat.InsertElectronicFormat(
            PEPPOLBIS3BE_ElectronicFormatTxt, PEPPOLBIS3BE_ElectronicFormatDescriptionTxt,
            Codeunit::"Exp. Sales Inv. PEPPOL30", 0, ElectronicDocumentFormat.Usage::"Sales Invoice".AsInteger());

        ElectronicDocumentFormat.InsertElectronicFormat(
            PEPPOLBIS3BE_ElectronicFormatTxt, PEPPOLBIS3BE_ElectronicFormatDescriptionTxt,
            Codeunit::"Exp. Sales CrM. PEPPOL30", 0, ElectronicDocumentFormat.Usage::"Sales Credit Memo".AsInteger());

        ElectronicDocumentFormat.InsertElectronicFormat(
            PEPPOLBIS3BE_ElectronicFormatTxt, PEPPOLBIS3BE_ElectronicFormatDescriptionTxt,
            Codeunit::"PEPPOL30 BE Sales Validation", 0, ElectronicDocumentFormat.Usage::"Sales Validation".AsInteger());

        ElectronicDocumentFormat.InsertElectronicFormat(
            PEPPOLBIS3BE_ElectronicFormatTxt, PEPPOLBIS3BE_ElectronicFormatDescriptionTxt,
            Codeunit::"Exp. Serv.Inv. PEPPOL30", 0, ElectronicDocumentFormat.Usage::"Service Invoice".AsInteger());

        ElectronicDocumentFormat.InsertElectronicFormat(
            PEPPOLBIS3BE_ElectronicFormatTxt, PEPPOLBIS3BE_ElectronicFormatDescriptionTxt,
            Codeunit::"Exp. Serv.CrM. PEPPOL30", 0, ElectronicDocumentFormat.Usage::"Service Credit Memo".AsInteger());

        ElectronicDocumentFormat.InsertElectronicFormat(
            PEPPOLBIS3BE_ElectronicFormatTxt, PEPPOLBIS3BE_ElectronicFormatDescriptionTxt,
            Codeunit::"PEPPOL30 Service Validation", 0, ElectronicDocumentFormat.Usage::"Service Validation".AsInteger());
    end;
}
