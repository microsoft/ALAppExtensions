// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 132612 "Signed Xml Module Test"
{
    Subtype = Test;

    var
        SignedXml: Codeunit SignedXml;
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure CheckXmlSignatureUsingKeyInSignature()
    var
        SignedXmlDocument: XmlDocument;
        SignatureElement: XmlElement;
    begin
        GetValidSignedXml(SignedXmlDocument);
        GetSignatureElement(SignedXmlDocument, SignatureElement);

        SignedXml.InitializeSignedXml(SignedXmlDocument);
        SignedXml.LoadXml(SignatureElement);

        LibraryAssert.IsTrue(SignedXml.CheckSignature(), 'Failed to verify the xml signature.');
    end;

    [Test]
    procedure CheckInvalidXmlSignatureUsingKeyInSignature()
    var
        SignedXmlDocument: XmlDocument;
        SignatureElement: XmlElement;
    begin
        GetInvalidSignedXml(SignedXmlDocument);
        GetSignatureElement(SignedXmlDocument, SignatureElement);

        SignedXml.InitializeSignedXml(SignedXmlDocument);
        SignedXml.LoadXml(SignatureElement);

        LibraryAssert.IsFalse(SignedXml.CheckSignature(), 'Signature verified even though it is invalid.');
    end;

    [Test]
    procedure VerifyXmlSignatureUsingKeyXmlString()
    var
        XmlString: Text;
        SignedXmlDocument: XmlDocument;
        SignatureElement: XmlElement;
    begin
        GetValidSignedXml(SignedXmlDocument);
        GetSignatureElement(SignedXmlDocument, SignatureElement);

        SignedXml.InitializeSignedXml(SignedXmlDocument);
        SignedXml.LoadXml(SignatureElement);

        GetSignatureKeyXmlString(XmlString);

        LibraryAssert.IsTrue(SignedXml.CheckSignature(XmlString), 'Failed to verify the xml signature.');
    end;

    [Test]
    procedure VerifyXmlSignatureUsingCertificate()
    var
        SignedXmlDocument: XmlDocument;
        SignatureElement: XmlElement;
        CertBase64Data: Text;
    begin
        GetValidSignedXml(SignedXmlDocument);
        GetSignatureElement(SignedXmlDocument, SignatureElement);

        SignedXml.InitializeSignedXml(SignedXmlDocument);
        SignedXml.LoadXml(SignatureElement);

        CertBase64Data := GetCertificateData();

        LibraryAssert.IsTrue(SignedXml.CheckSignature(CertBase64Data, '', true), 'Failed to verify the xml signature.');
    end;

    local procedure GetSignatureElement(SignedXmlDocument: XmlDocument; var SignatureElement: XmlElement)
    var
        NSMgr: XmlNamespaceManager;
        SignatureNode: XmlNode;
    begin
        NSMgr.NameTable(SignedXmlDocument.NameTable());
        NSMgr.AddNamespace('dsig', 'http://www.w3.org/2000/09/xmldsig#');

        SignedXmlDocument.SelectSingleNode('//dsig:Signature', NSMgr, SignatureNode);

        SignatureElement := SignatureNode.AsXmlElement();
    end;

    local procedure GetValidSignedXml(var SignedXml: XmlDocument)
    var
        XmlReadOptions: XmlReadOptions;
    begin
        XmlReadOptions.PreserveWhitespace := true;

        XmlDocument.ReadFrom(
            '<Data xmlns="http://www.example.com/data">' +
            '<Item>' +
            '<No>1</No>' +
            '<Description>A</Description>' +
            '</Item>' +
            '<Item>' +
            '<No>2</No>' +
            '<Description>B</Description>' +
            '</Item>' +
            '<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">' +
            '<SignedInfo><CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" />' +
            '<SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256" />' +
            '<Reference URI="">' +
            '<Transforms>' +
            '<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature" />' +
            '</Transforms>' +
            '<DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256" />' +
            '<DigestValue>R1TlSCUFGs6DIIp3I/W5ztsYNv4Y2AD8IGkpTAUt6NI=</DigestValue>' +
            '</Reference>' +
            '</SignedInfo>' +
            '<SignatureValue>ID0agWZ8wIeuak7XcgKEVtmuKYQGAU2dd4HDElKFCm1pLtoLybW21S6LyDmUwxSou4gaXmYBNbkG787EeQRXC7MDyfo4vygh0jryPSrvxxjE9oPktf0hqou7Dx+wB6rc+chxDOysflPSGwfvtBZl7tgcgT7DOqj3Xr4kn4vJ1gw=</SignatureValue>' +
            '<KeyInfo>' +
            '<KeyValue>' +
            '<RSAKeyValue>' +
            '<Modulus>xgEGvHk+U/RY0j9l3MP7o+S2a6uf4XaRBhu1ztdCHz8tMG8Kj4/qJmgsSZQD17sRctHGBTUJWp4CLtBwCf0zAGVzySwUkcHSu1/2mZ/w7Nr0TQHKeWr/j8pvXH534DKEvugr21DAHbi4c654eLUL+JW/wJJYqJh7qHM3W3Fh7ys=</Modulus>' +
            '<Exponent>AQAB</Exponent>' +
            '</RSAKeyValue>' +
            '</KeyValue>' +
            '</KeyInfo>' +
            '</Signature>' +
            '</Data>',
            XmlReadOptions,
            SignedXml);
    end;

    local procedure GetInvalidSignedXml(var SignedXml: XmlDocument)
    var
        XmlReadOptions: XmlReadOptions;
    begin
        XmlReadOptions.PreserveWhitespace := true;

        XmlDocument.ReadFrom(
            '<Data xmlns="http://www.example.com/data">' +
            '<Item>' +
            '<No>1</No>' +
            '<Description>A</Description>' +
            '</Item>' +
            '<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">' +
            '<SignedInfo><CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" />' +
            '<SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256" />' +
            '<Reference URI="">' +
            '<Transforms>' +
            '<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature" />' +
            '</Transforms>' +
            '<DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256" />' +
            '<DigestValue>R1TlSCUFGs6DIIp3I/W5ztsYNv4Y2AD8IGkpTAUt6NI=</DigestValue>' +
            '</Reference>' +
            '</SignedInfo>' +
            '<SignatureValue>ID0agWZ8wIeuak7XcgKEVtmuKYQGAU2dd4HDElKFCm1pLtoLybW21S6LyDmUwxSou4gaXmYBNbkG787EeQRXC7MDyfo4vygh0jryPSrvxxjE9oPktf0hqou7Dx+wB6rc+chxDOysflPSGwfvtBZl7tgcgT7DOqj3Xr4kn4vJ1gw=</SignatureValue>' +
            '<KeyInfo>' +
            '<KeyValue>' +
            '<RSAKeyValue>' +
            '<Modulus>xgEGvHk+U/RY0j9l3MP7o+S2a6uf4XaRBhu1ztdCHz8tMG8Kj4/qJmgsSZQD17sRctHGBTUJWp4CLtBwCf0zAGVzySwUkcHSu1/2mZ/w7Nr0TQHKeWr/j8pvXH534DKEvugr21DAHbi4c654eLUL+JW/wJJYqJh7qHM3W3Fh7ys=</Modulus>' +
            '<Exponent>AQAB</Exponent>' +
            '</RSAKeyValue>' +
            '</KeyValue>' +
            '</KeyInfo>' +
            '</Signature>' +
            '</Data>',
            XmlReadOptions,
            SignedXml);
    end;

    local procedure GetSignatureKeyXmlString(var XmlString: Text)
    begin
        XmlString :=
            '<RSAKeyValue>' +
            '<Modulus>xgEGvHk+U/RY0j9l3MP7o+S2a6uf4XaRBhu1ztdCHz8tMG8Kj4/qJmgsSZQD17sRctHGBTUJWp4CLtBwCf0zAGVzySwUkcHSu1/2mZ/w7Nr0TQHKeWr/j8pvXH534DKEvugr21DAHbi4c654eLUL+JW/wJJYqJh7qHM3W3Fh7ys=</Modulus>' +
            '<Exponent>AQAB</Exponent>' +
            '<P>/KDieObcq+Os3DgLemqOz3n1S4luULvj8X6B5mZg1dlEKnjOV7WYODve1QUroDrN/qriHQAui6LWJf+jfhOMtw==</P>' +
            '<Q>yKWD2JNCrAgtjk2bfF1HYt24tq8+q7x2ek3/cUhqwInkrZqOFokex3+yBB879TuUOadvBXndgMHHcJQKSAJlLQ==</Q>' +
            '<DP>XRuGnHyptAhTe06EnHeNbtZKG67pI4Q8PJMdmSb+ZZKP1v9zPUxGb+NQ+z3OmF1T8ppUf8/DV9+KAbM4NI1L/Q==</DP>' +
            '<DQ>dGBsBKYFObrUkYE5+fwwd4uao3sponqBTZcH3jDemiZg2MCYQUHu9E+AdRuYrziLVJVks4xniVLb1tRG0lVxUQ==</DQ>' +
            '<InverseQ>SfjdGT81HDJSzTseigrM+JnBKPPrzpeEp0RbTP52Lm23YARjLCwmPMMdAwYZsvqeTuHEDQcOHxLHWuyN/zgP2A==</InverseQ>' +
            '<D>XzxrIwgmBHeIqUe5FOBnDsOZQlyAQA+pXYjCf8Rll2XptFwUdkzAUMzWUGWTG5ZspA9l8Wc7IozRe/bhjMxuVK5yZhPDKbjqRdWICA95Jd7fxlIirHOVMQRdzI7xNKqMNQN05MLJfsEHUYtOLhZE+tfhJTJnnmB7TMwnJgc4O5E=</D>' +
            '</RSAKeyValue>';
    end;

    local procedure GetCertificateData(): Text
    begin
        exit(
            'MIICVjCCAb8CAg37MA0GCSqGSIb3DQEBBQUAMIGbMQswCQYDVQQGEwJKUDEOMAwG' +
            'A1UECBMFVG9reW8xEDAOBgNVBAcTB0NodW8ta3UxETAPBgNVBAoTCEZyYW5rNERE' +
            'MRgwFgYDVQQLEw9XZWJDZXJ0IFN1cHBvcnQxGDAWBgNVBAMTD0ZyYW5rNEREIFdl' +
            'YiBDQTEjMCEGCSqGSIb3DQEJARYUc3VwcG9ydEBmcmFuazRkZC5jb20wHhcNMTIw' +
            'ODIyMDUyNzIzWhcNMTcwODIxMDUyNzIzWjBKMQswCQYDVQQGEwJKUDEOMAwGA1UE' +
            'CAwFVG9reW8xETAPBgNVBAoMCEZyYW5rNEREMRgwFgYDVQQDDA93d3cuZXhhbXBs' +
            'ZS5jb20wgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBAMYBBrx5PlP0WNI/ZdzD' +
            '+6Pktmurn+F2kQYbtc7XQh8/LTBvCo+P6iZoLEmUA9e7EXLRxgU1CVqeAi7QcAn9' +
            'MwBlc8ksFJHB0rtf9pmf8Oza9E0Bynlq/4/Kb1x+d+AyhL7oK9tQwB24uHOueHi1' +
            'C/iVv8CSWKiYe6hzN1txYe8rAgMBAAEwDQYJKoZIhvcNAQEFBQADgYEAASPdjigJ' +
            'kXCqKWpnZ/Oc75EUcMi6HztaW8abUMlYXPIgkV2F7YanHOB7K4f7OOLjiz8DTPFf' +
            'jC9UeuErhaA/zzWi8ewMTFZW/WshOrm3fNvcMrMLKtH534JKvcdMg6qIdjTFINIr' +
            'evnAhf0cwULaebn+lMs8Pdl7y37+sfluVok=');
    end;
}