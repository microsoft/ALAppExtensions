// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 132576 "Digipoort Test"
{

    Subtype = Test;

    trigger OnRun()
    var
        MessageId: Text;
    begin
        MessageId := VerifySubmitTaxDeclaration();
        ReceiveResponseMessages(MessageId);
    end;

    [Test]
    procedure VerifySubmitTaxDeclaration(): Text
    var
        Digipoort: Codeunit "Digipoort";
        VarXml: Text;
        VarMessageType: Text;
        VarReference: Text;
        VarUrl: Text;
        IdentityNumber: Text;
        IdentityType: Text;
        MessageID: Text;
        ServiceCertificate: Code[20];
        ClientCertificate: Code[20];
        ElecDeclarationSetup: Record "Elec. Tax Declaration Setup";
        LibraryAssert: Codeunit "Library Assert";
    begin
        // [GIVEN] Get Xml details
        VarXml := GetXml();
        VarMessageType := 'Aangifte_LH';
        VarReference := 'TestXml';
        IdentityNumber := 'NL12345678';
        IdentityType := 'Lhnr';
        MessageID := '';

        ElecDeclarationSetup.Get();
        VarUrl := ElecDeclarationSetup."Digipoort Delivery URL";
        ServiceCertificate := ElecDeclarationSetup."Service Certificate Code";
        ClientCertificate := ElecDeclarationSetup."Client Certificate Code";

        // [WHEN] Send Xml to Digipoort
        MessageID := Digipoort.SubmitTaxDeclaration(GetXml(), ClientCertificate, ServiceCertificate, VarMessageType, IdentityType, IdentityNumber, VarReference, VarUrl);

        // [THEN] Verify Result 
        LibraryAssert.AreNotEqual(MessageID, '', 'Failed to connect to Digipoort');
        Exit(MessageID);
    end;

    [Test]
    procedure ReceiveResponseMessages(MessageID: Text) // Note: This can only be run in combination with tax declaration
    var
        Digipoort: Codeunit "Digipoort";
        VarReference: Text;
        VarUrl: Text;
        TLS: Text;
        ResponseNo: Integer;
        ServiceCertificateCode: Code[20];
        ClientCertificateCode: Code[20];
        ElecDeclarationSetup: Record "Elec. Tax Declaration Setup";
        LibraryAssert: Codeunit "Library Assert";
        ElecTaxDeclResponseMsg: Record "Elec. Tax Decl. Response Msg." temporary;
    begin
        // [GIVEN] Get the declaration details and certificate
        VarReference := 'TestXml';
        TLS := '';
        ResponseNo := 1242141023;

        ElecDeclarationSetup.Get();
        VarUrl := ElecDeclarationSetup."Digipoort Status URL";
        ServiceCertificateCode := ElecDeclarationSetup."Service Certificate Code";
        ClientCertificateCode := ElecDeclarationSetup."Client Certificate Code";

        // [WHEN] Send Xml to Digipoort
        Digipoort.ReceiveResponseMessages(ClientCertificateCode, ServiceCertificateCode, MessageID, VarUrl, TLS, ResponseNo, ElecTaxDeclResponseMsg);

        // [THEN] Verify Result 
        ElecTaxDeclResponseMsg.SetFilter("No.", ResponseNo);
        ElecTaxDeclResponseMsg.FindFirst();

        LibraryAssert.RecordIsEmpty(ElecTaxDeclResponseMsg);
    end;

    local procedure GetXml(): Text
    begin
        exit('<?xml version="1.0" encoding="UTF-8"?><tax>This is a test message</tax>');
    end;

}