// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 132573 "SignedXml Test"
{
    Subtype = Test;

    var
        SignedXml: Codeunit SignedXml;
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure VerifyXmlSignature()
    var
        SignatureKey: Record "Signature Key";
        SigningXmlDocument: XmlDocument;
        CertBase64Value: Text;
        KeyValue: Text;
    begin
        GetXml(SigningXmlDocument);
        SignedXml.InitializeSignedXml(SigningXmlDocument);
        SignatureKey.FromXmlString();

        SignedXml.SetSigningKey(SignatureKey);

        // Add the key to the SignedXml document. 
        signedXml.SigningKey = Key;

        // Create a reference to be signed.
        Reference reference = new Reference();
        reference.Uri = "";

        // Add an enveloped transformation to the reference.
        XmlDsigEnvelopedSignatureTransform env = new XmlDsigEnvelopedSignatureTransform();
        reference.AddTransform(env);

        // Add the reference to the SignedXml object.
        signedXml.AddReference(reference);

        // Compute the signature.
        signedXml.ComputeSignature();

        // Get the XML representation of the signature and save
        // it to an XmlElement object.
        XmlElement xmlDigitalSignature = signedXml.GetXml();

        // Append the element to the XML document.
        doc.DocumentElement.AppendChild(doc.ImportNode(xmlDigitalSignature, true));

        if (doc.FirstChild is XmlDeclaration)  
        {
            doc.RemoveChild(doc.FirstChild);
        }

        // Save the signed XML document to a file specified
        // using the passed string.
        XmlTextWriter xmltw = new XmlTextWriter(SignedFileName, new UTF8Encoding(false));
        doc.WriteTo(xmltw);
        xmltw.Close();


        // [WHEN] Initialize record from Base64 value 
        SignatureKey.FromBase64String(CertBase64Value, 'Test', true);

        // [THEN] Verify that "Key Value Blob" BLOB has Value
        LibraryAssert.IsTrue(SignatureKey.ToXmlString() <> '', 'Failed to verify certificate.');
    end;

    local procedure GetXml(var XmlDoc: XmlDocument)
    var
    begin
        XmlDocument.ReadFrom(
            '<?xml version="1.0" encoding="UTF-8"?>' +
            '<example>' +
            '  <name>John</name>' +
            '  <age>23</age>' +
            '</example>',
            XmlDoc);
    end;
}