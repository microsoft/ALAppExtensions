// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides helper functions for encryption and hashing.
/// For encryption in an on-premises versions, use it to turn encryption on or off, and import and export the encryption key.
/// Encryption is always turned on for online versions.
/// </summary>

codeunit 50102 "Digipoort"
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
    /// <param name="MessageType">The Message Type of the message</param>
    /// <param name="IdentityType">The Identity Type of the tax declaration</param>
    /// <param name="IdentityNumber">The Identity Number of the tax declaration</param>
    /// <param name="Reference">The delivery reference to be send to Digipoort</param>
    /// <param name="RequestUrl">The url the tax declaration needs to be send to</param>
    /// <param name="MessageID">The message ID to be received back from Digipoort</param>
    /// <param name="TLS">The VarSecurityProtocolType the request has to be send with. Leave empty to take the default value.</param>
    procedure SubmitTaxDeclaration(XmlContent: Text; ClientCertificateCode: Code[20]; ServiceCertificateCode: Code[20]; MessageType: Text; IdentityType: Text; IdentityNumber: Text; Reference: Text; RequestUrl: Text; TLS: Text): Text
    begin
        exit(DigipoortManagementImpl.SubmitTaxDeclaration(XmlContent, ClientCertificateCode, ServiceCertificateCode, MessageType, IdentityType, IdentityNumber, Reference, RequestUrl, TLS));
    end;

    /// <summary>
    /// Receive responses messages from Digipoort.
    /// </summary>
    /// <param name="ClientCertificateCode">The client certificate code from the certificate stored in Isolated Certificate</param>
    /// <param name="ServiceCertificateCode">The service certificate code from the certificate stored in Isolated Certificate</param>
    /// <param name="MessageID">The message ID received from Digipoort</param>
    /// <param name="ResponseUrl">The url the response message need to be requested from</param>
    /// <param name="TLS">The VarSecurityProtocolType the request has to be send with. Leave empty to take the default value.</param>
    /// <param name="ResponseNo">ResponseNo of the first response message</param>
    /// <param name="ElecTaxDeclResponseMsg">Record where the response messages will get stored in</param>
    procedure ReceiveResponseMessages(ClientCertificateCode: Code[20]; ServiceCertificateCode: Code[20]; MessageID: Text; ResponseUrl: Text; TLS: Text; ResponseNo: Integer; VAR ElecTaxDeclResponseMsg: Record "Elec. Tax Decl. Response Msg."): Text
    begin
        exit(DigipoortManagementImpl.ReceiveResponseMessages(ClientCertificateCode, ServiceCertificateCode, MessageID, ResponseUrl, TLS, ResponseNo, ElecTaxDeclResponseMsg));
    end;

}
