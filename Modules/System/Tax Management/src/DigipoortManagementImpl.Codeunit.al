// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 50102 "Digipoort Management Impl."
{
    trigger OnRun()
    var
    begin
    end;

    procedure SubmitPayrollTaxDeclaration(XmlContent: Text; ClientCertificateCode: Code[20]; ServiceCertificateCode: Code[20]; MessageType: Text; Reference: Text; RequestUrl: Text; VATReg: Text): Text
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

        exit(DeliverPayrollTaxDeclaration(XmlContent, MessageType, Reference, RequestUrl, ClientCertificateBase64, ServiceCertificateBase64, VATReg, DotNet_SecureString));
    end;

    procedure DeliverPayrollTaxDeclaration(XmlContent: Text; MessageType: Text; Reference: Text; RequestUrl: Text; ClientCertificateBase64: Text; ServiceCertificateBase64: Text; VATReg: Text; DotNet_SecureString: Codeunit DotNet_SecureString): Text
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
        if GuiAllowed then begin
            Window.Open(WindowStatusMsg);
            Window.Update(1, WindowStatusBuildingMsg);
        end;
        Request := Request.aanleverRequest;
        Response := Response.aanleverResponse;
        Identity := Identity.identiteitType;
        Content := Content.berichtInhoudType;
        Fault := Fault.foutType;

        UTF8Encoding := UTF8Encoding.UTF8Encoding;

        Identity.nummer := VATReg;
        Identity.type := 'LHnr';

        Content.mimeType := 'application/xml';
        Content.bestandsnaam := StrSubstNo('%1.xbrl', MessageType);
        Content.inhoud := UTF8Encoding.GetBytes(XmlContent);

        Request.berichtsoort := MessageType;
        Request.aanleverkenmerk := Reference;
        Request.identiteitBelanghebbende := Identity;
        Request.rolBelanghebbende := 'Bedrijf';
        Request.berichtInhoud := Content;
        Request.autorisatieAdres := 'http://geenausp.nl';

        if GuiAllowed then
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
            Error(SubmitErr, Reference, Fault.foutcode, Fault.foutbeschrijving);

        if GuiAllowed then
            Window.Close();

        Exit(Response.kenmerk);

    end;
}