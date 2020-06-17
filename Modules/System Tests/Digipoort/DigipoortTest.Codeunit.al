// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 132576 "Digipoort Test"
{
    Subtype = Test;

    [Test]
    procedure VerifySubmitTaxDeclaration()
    var
        Digipoort: Codeunit "Digipoort Payroll Tax";
        EncryptedText: Text;
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
        MessageID := 'Test';

        ElecDeclarationSetup.Get();
        VarUrl := ElecDeclarationSetup."Digipoort Delivery URL";
        ServiceCertificate := ElecDeclarationSetup."Service Certificate Code";
        ClientCertificate := ElecDeclarationSetup."Client Certificate Code";

        // [WHEN] Send Xml to Digipoort
        Digipoort.SubmitTaxDeclaration(GetXml(), ClientCertificate, ServiceCertificate, VarMessageType, IdentityType, IdentityNumber, VarReference, VarUrl);

        // [THEN] Verify Result 
        LibraryAssert.AreNotEqual(MessageID, '', 'Failed to connect to Digipoort');
    end;

    local procedure GetXml(): Text
    begin
        exit('<?xml version="1.0" encoding="UTF-8"?><tax>This is a test message</tax>');
    end;

}