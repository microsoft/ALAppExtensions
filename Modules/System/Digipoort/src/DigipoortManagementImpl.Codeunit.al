// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 50102 "Digipoort Management Impl."
{
    trigger OnRun()
    begin
    end;

    var
        DotNet_SecureString: Codeunit DotNet_SecureString;
        VarServicePointManagerLoc: DotNet MRCServicePointManager;
        VarSecurityProtocolTypeLoc: DotNet MRCSecurityProtocolType;

    procedure SubmitTaxDeclaration(XmlContent: Text; ClientCertificateCode: Code[20]; ServiceCertificateCode: Code[20]; MessageType: Text; IdentityType: Text; IdentityNumber: Text; Reference: Text; RequestUrl: Text; TLS: Text): Text
    var
        ClientCertificateBase64: Text;
        ServiceCertificateBase64: Text;
    begin
        GetCertificates(ClientCertificateCode, ServiceCertificateCode, ClientCertificateBase64, ServiceCertificateBase64);

        exit(DeliverTaxDeclaration(XmlContent, MessageType, IdentityType, IdentityNumber, Reference, RequestUrl, ClientCertificateBase64, ServiceCertificateBase64, TLS));
    end;

    procedure ReceiveResponseMessages(ClientCertificateCode: Code[20]; ServiceCertificateCode: Code[20]; MessageID: Text; ResponseUrl: Text; TLS: Text; VAR ElecTaxDeclResponseMsg: Record "Elec. Tax Decl. Response Msg."; ResponseNo: Integer): Text
    var
        ClientCertificateBase64: Text;
        ServiceCertificateBase64: Text;
    begin
        GetCertificates(ClientCertificateCode, ServiceCertificateCode, ClientCertificateBase64, ServiceCertificateBase64);
        GetResponseMessages(MessageID, ResponseUrl, ClientCertificateBase64, ServiceCertificateBase64, TLS, ResponseNo, ElecTaxDeclResponseMsg);
    end;

    procedure GetCertificates(ClientCertificateCode: Code[20]; ServiceCertificateCode: Code[20]; VAR ClientCertificateBase64: Text; VAR ServiceCertificateBase64: Text)
    var
        IsolatedCertificate: Record "Isolated Certificate";
        CertificateManagement: Codeunit "Certificate Management";

    begin
        IsolatedCertificate.Get(ClientCertificateCode);
        CertificateManagement.GetPasswordAsSecureString(DotNet_SecureString, IsolatedCertificate);
        ClientCertificateBase64 := CertificateManagement.GetCertAsBase64String(IsolatedCertificate);
        IsolatedCertificate.Get(ServiceCertificateCode);
        ServiceCertificateBase64 := CertificateManagement.GetCertAsBase64String(IsolatedCertificate);
    end;

    procedure DeliverTaxDeclaration(XmlContent: Text; MessageType: Text; IdentityType: Text; IdentityNumber: Text; Reference: Text; RequestUrl: Text; ClientCertificateBase64: Text; ServiceCertificateBase64: Text; TLS: Text): Text
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

        Identity.nummer := IdentityNumber;
        Identity.type := IdentityType;

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
        case TLS of
            '1.2':
                begin
                    VarServicePointManagerLoc.SecurityProtocol := VarSecurityProtocolTypeLoc.Tls12;
                end;
            '1.3':
                begin
                    VarServicePointManagerLoc.SecurityProtocol := VarSecurityProtocolTypeLoc.Tls13;
                end;
        end;

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

    procedure GetResponseMessages(MessageID: Text; ResponseUrl: Text; ClientCertificateBase64: Text; ServiceCertificateBase64: Text; TLS: Text; ResponseNo: Integer; VAR ElecTaxDeclResponseMsg: Record "Elec. Tax Decl. Response Msg.")
    var
        Request: DotNet getStatussenProcesRequest;
        StatusService: DotNet DigipoortServices;
        StatusResultatQueue: DotNet Queue;
        StatusResultat: DotNet StatusResultaat;
        DotNetSecureString: DotNet SecureString;
        MessageBLOB: OutStream;
        FoundXmlContent: Boolean;
        StatusDetails: Text;
        StatusErrorDescription: Text;
        Window: Dialog;
        WindowReceivingResponsesMsg: Label 'Receiving Electronic Tax Declaration Responses...\\Status          #1##################';
        WindowStatusProcessingMsg: Label 'Processing data';
        BlobContentStatusMsg: Label 'Extended content';
    begin
        Window.Open(WindowReceivingResponsesMsg);
        Request := Request.getStatussenProcesRequest;
        Request.kenmerk := MessageID;
        Request.autorisatieAdres := 'http://geenausp.nl';

        case TLS of
            '1.2':
                begin
                    VarServicePointManagerLoc.SecurityProtocol := VarSecurityProtocolTypeLoc.Tls12;
                end;
            '1.3':
                begin
                    VarServicePointManagerLoc.SecurityProtocol := VarSecurityProtocolTypeLoc.Tls13;
                end;
        end;

        DotNet_SecureString.GetSecureString(DotNetSecureString);
        StatusResultatQueue := StatusService.GetStatus(Request,
                ResponseUrl,
                ClientCertificateBase64,
                DotNetSecureString,
                ServiceCertificateBase64,
                30);

        Window.Update(1, WindowStatusProcessingMsg);

        while StatusResultatQueue.Count() > 0 do begin
            StatusResultat := StatusResultatQueue.Dequeue();
            if StatusResultat.statuscode() <> '-1' then begin
                ElecTaxDeclResponseMsg.Init();
                ElecTaxDeclResponseMsg."No." := ResponseNo;
                ResponseNo += 1;
                ElecTaxDeclResponseMsg.Subject := CopyStr(StatusResultat.statusomschrijving(), 1, MaxStrLen(ElecTaxDeclResponseMsg.Subject));
                ElecTaxDeclResponseMsg."Status Code" :=
                CopyStr(StatusResultat.statuscode(), 1, MaxStrLen(ElecTaxDeclResponseMsg."Status Code"));

                FoundXmlContent := false;
                ElecTaxDeclResponseMsg.Message.CreateOutStream(MessageBLOB);

                StatusErrorDescription := StatusResultat.statusFoutcode().foutbeschrijving();
                if StatusErrorDescription <> '' then
                    if StatusErrorDescription[1] = '<' then begin
                        MessageBLOB.WriteText(StatusErrorDescription);
                        FoundXmlContent := true;
                    end;

                StatusDetails := StatusResultat.statusdetails();
                if StatusDetails <> '' then
                    if StatusDetails[1] = '<' then begin
                        MessageBLOB.WriteText(StatusDetails);
                        FoundXmlContent := true;
                    end;

                if FoundXmlContent then
                    ElecTaxDeclResponseMsg."Status Description" := CopyStr(BlobContentStatusMsg, 1, MaxStrLen(ElecTaxDeclResponseMsg."Status Description"))
                else
                    if StatusErrorDescription <> '' then
                        ElecTaxDeclResponseMsg."Status Description" := CopyStr(StatusErrorDescription, 1, MaxStrLen(ElecTaxDeclResponseMsg."Status Description"))
                    else
                        ElecTaxDeclResponseMsg."Status Description" := CopyStr(StatusDetails, 1, MaxStrLen(ElecTaxDeclResponseMsg."Status Description"));

                ElecTaxDeclResponseMsg."Date Sent" := Format(StatusResultat.tijdstempelStatus());
                ElecTaxDeclResponseMsg.Status := ElecTaxDeclResponseMsg.Status::Received;
                ElecTaxDeclResponseMsg.Insert(true);
            end else
                Error(StatusResultat.statusFoutcode().foutbeschrijving());
        end;
        Window.Close();
    end;
}