// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 50102 "Digipoort Payroll Tax"
{
    trigger OnRun()
    var
    begin
    end;

    procedure FuncSubmitPayrollTaxDeclaration(XmlContent: Text; ClientCertificateCode: Code[20]; ServiceCertificateCode: Code[20]; MessageType: Text; Reference: Text; RequestUrl: Text; VATReg: Text; Var MessageID: Text)
    var
        ElecTaxDeclarationMgt: Codeunit "Elec. Tax Declaration Mgt.";
        DotNet_SecureString: Codeunit DotNet_SecureString;
        ElecTaxDeclarationSetup: Record "Elec. Tax Declaration Setup";
        IsolatedCertificate: Record "Isolated Certificate";
        CertificateManagement: Codeunit "Certificate Management";
        ClientCertificateBase64: Text;
        ServiceCertificateBase64: Text;
    begin
        ElecTaxDeclarationSetup.Get();
        IsolatedCertificate.Get(ClientCertificateCode);
        CertificateManagement.GetPasswordAsSecureString(DotNet_SecureString, IsolatedCertificate);
        ClientCertificateBase64 := CertificateManagement.GetCertAsBase64String(IsolatedCertificate);
        IsolatedCertificate.Get(ServiceCertificateCode);
        ServiceCertificateBase64 := CertificateManagement.GetCertAsBase64String(IsolatedCertificate);

        DeliverPayrollTaxDeclaration(XmlContent, MessageType, Reference, RequestUrl, ClientCertificateBase64, ServiceCertificateBase64, VATReg, DotNet_SecureString, MessageID);
    end;

    procedure DeliverPayrollTaxDeclaration(XmlContent: Text; MessageType: Text; Reference: Text; RequestUrl: Text; ClientCertificateBase64: Text; ServiceCertificateBase64: Text; VATReg: Text; DotNet_SecureString: Codeunit DotNet_SecureString; Var MessageID: Text)
    var
        DeliveryService: DotNet DigipoortServices;
        Request: DotNet aanleverRequest;
        Response: DotNet aanleverResponse;
        Identity: DotNet identiteitType;
        Content: DotNet berichtInhoudType;
        DotNetSecureString: DotNet SecureString;
        Fault: DotNet foutType;
        UTF8Encoding: DotNet UTF8Encoding;
        Window: Dialog;
        WindowStatusBuildingMsg: Label 'Building document';
        WindowStatusSendMsg: Label 'Transmitting document';
        WindowStatusSaveMsg: Label 'Saving document ID';
        WindowStatusMsg: Label 'Submitting Electronic Tax Declaration...\\Status          #1##################';
        SubmitSuccessMsg: Label 'Declaration %1 was submitted successfully.';
        SubmitErr: Label 'Submission of declaration %1 failed with error code %2 and the following message: \\%3';
    begin
        Window.Open(WindowStatusMsg);
        Window.Update(1, WindowStatusBuildingMsg);
        Request := Request.aanleverRequest;
        Response := Response.aanleverResponse;
        Identity := Identity.identiteitType;
        Content := Content.berichtInhoudType;
        Fault := Fault.foutType;

        UTF8Encoding := UTF8Encoding.UTF8Encoding;

        with Identity do begin
            nummer := VATReg;
            type := 'LHnr';
        end;

        with Content do begin
            mimeType := 'application/xml';
            bestandsnaam := StrSubstNo('%1.xbrl', MessageType);
            inhoud := UTF8Encoding.GetBytes(XmlContent);
        end;

        with Request do begin
            berichtsoort := MessageType;
            aanleverkenmerk := Reference;
            identiteitBelanghebbende := Identity;
            rolBelanghebbende := 'Bedrijf';
            berichtInhoud := Content;
            autorisatieAdres := 'http://geenausp.nl'
        end;

        Window.Update(1, WindowStatusSendMsg);

        DotNet_SecureString.GetSecureString(DotNetSecureString);

        Response := DeliveryService.Deliver(Request,
            RequestUrl,
            ClientCertificateBase64,
            DotNetSecureString,
            ServiceCertificateBase64,
            30);

        Fault := Response.statusFoutcode;
        if Fault.foutcode <> '' then
            Error(StrSubstNo(SubmitErr, Reference, Fault.foutcode, Fault.foutbeschrijving));

        MessageID := Response.kenmerk;
        Window.Close();
    end;
}