// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides helper functions for encryption and hashing.
/// For encryption in an on-premises versions, use it to turn encryption on or off, and import and export the encryption key.
/// Encryption is always turned on for online versions.
/// </summary>

codeunit 50102 "Digipoort Payroll Tax"
{
    Access = Public;

    var
        DigipoortManagementImpl: Codeunit "Digipoort Management Impl.";

    /// <summary>
    /// Submits payroll tax declaration in XML format to Digipoort.
    /// </summary>
    /// <param name="XmlContent">The payroll tax declartion in XML format</param>
    /// <param name="ClientCertificateCode">The client certificate code from the certificate stored in Isolated Certificate</param>
    /// <param name="ServiceCertificateCode">The service certificate code from the certificate stored in Isolated Certificate</param>
    /// <param name="MessageType">The MessageType of the message</param>
    /// <param name="Reference">The delivery reference to be send to Digipoort</param>
    /// <param name="RequestUrl">The url the tax declaration needs to be send to</param>
    /// <param name="VATReg">The VAT Registration Number to be send to Digipoort</param>
    /// <param name="MessageID">The message ID to be received back from Digipoort</param>

    procedure SubmitPayrollTaxDeclaration(XmlContent: Text; ClientCertificateCode: Code[20]; ServiceCertificateCode: Code[20]; MessageType: Text; Reference: Text; RequestUrl: Text; VATReg: Text): Text
    begin
        exit(DigipoortManagementImpl.DeliverPayrollTaxDeclaration(XmlContent, ClientCertificateCode, ServiceCertificateCode, MessageType, Reference, RequestUrl, VATReg));
    end;

}
