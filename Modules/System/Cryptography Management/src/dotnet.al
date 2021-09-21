// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

dotnet
{
    assembly("mscorlib")
    {
        type("System.Security.Cryptography.RijndaelManaged"; "Cryptography.RijndaelManaged") { }
        type("System.Security.Cryptography.CipherMode"; "Cryptography.CipherMode") { }
        type("System.Security.Cryptography.PaddingMode"; "Cryptography.PaddingMode") { }
        type("System.Security.Cryptography.ICryptoTransform"; "Cryptography.ICryptoTransform") { }
        type("System.Security.Cryptography.CryptoStream"; "Cryptography.CryptoStream") { }
        type("System.Security.Cryptography.CryptoStreamMode"; "Cryptography.CryptoStreamMode") { }
        type("System.Security.Cryptography.KeySizes"; "Cryptography.KeySizes") { }
        type("System.Security.Cryptography.Rfc2898DeriveBytes"; "Rfc2898DeriveBytes") { }
        type("System.Security.Cryptography.SHA1Managed"; "SHA1Managed") { }
        type("System.Security.Cryptography.SymmetricAlgorithm"; "Cryptography.SymmetricAlgorithm") { }
        type("System.Security.Cryptography.DESCryptoServiceProvider"; "Cryptography.DESCryptoServiceProvider") { }
        type("System.Security.Cryptography.RSASignaturePadding"; RSASignaturePadding) { }
        type("System.Security.Cryptography.TripleDESCryptoServiceProvider"; "Cryptography.TripleDESCryptoServiceProvider") { }
    }

    assembly("System")
    {
        type("System.Security.Cryptography.X509Certificates.X509BasicConstraintsExtension"; X509BasicConstraintsExtension) { }
        type("System.Security.Cryptography.X509Certificates.X509EnhancedKeyUsageExtension"; X509EnhancedKeyUsageExtension) { }
        type("System.Security.Cryptography.X509Certificates.X509KeyUsageExtension"; X509KeyUsageExtension) { }
        type("System.Security.Cryptography.X509Certificates.X509KeyUsageFlags"; X509KeyUsageFlags) { }
        type("System.Security.Cryptography.OidCollection"; OidCollection) { }
        type("System.Security.Cryptography.Oid"; Oid) { }
    }

    assembly("System.Core")
    {
        type("System.Security.Cryptography.X509Certificates.CertificateRequest"; CertificateRequest) { }
        type("System.Security.Cryptography.AesCryptoServiceProvider"; "Cryptography.AesCryptoServiceProvider") { }
    }

    assembly("System.Security")
    {
        type("System.Security.Cryptography.Xml.EncryptedXml"; "EncryptedXml") { }
        type("System.Security.Cryptography.Xml.EncryptedData"; "EncryptedData") { }
        type("System.Security.Cryptography.Xml.EncryptionMethod"; "EncryptionMethod") { }
        type("System.Security.Cryptography.Xml.EncryptedKey"; "EncryptedKey") { }
        type("System.Security.Cryptography.Xml.CipherData"; "CipherData") { }
        type("System.Security.Cryptography.Xml.KeyInfoX509Data"; "KeyInfoX509Data") { }
        type("System.Security.Cryptography.Xml.KeyInfoEncryptedKey"; "KeyInfoEncryptedKey") { }
    }
}
