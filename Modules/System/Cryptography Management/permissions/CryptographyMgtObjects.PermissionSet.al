// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1258 "Cryptography Mgt. - Objects"
{
    Assignable = false;

    IncludedPermissionSets = "Base64 Convert - Objects",
                             "Environment Info. - Objects";

    Permissions = Codeunit "CertificateRequest Impl." = X,
                  Codeunit "Cryptography Management Impl." = X,
                  Codeunit "Cryptography Management" = X,
                  Codeunit "DESCryptoServiceProvider Impl." = X,
                  Codeunit "DSACryptoServiceProvider Impl." = X,
                  Codeunit "DSACryptoServiceProvider" = X,
                  Codeunit "Rfc2898DeriveBytes" = X,
                  Codeunit "Rijndael Cryptography" = X,
                  Codeunit "RSACryptoServiceProvider Impl." = X,
                  Codeunit "RSACryptoServiceProvider" = X,
                  Codeunit "SignedXml Impl." = X,
                  Codeunit "X509Certificate2 Impl." = X,
                  Codeunit "X509Certificate2" = X,
                  Codeunit "Xml DotNet Convert" = X,
                  Codeunit CertificateRequest = X,
                  Codeunit DESCryptoServiceProvider = X,
                  Codeunit SignedXml = X,
                  Codeunit "AesCryptoServiceProvider Impl." = X,
                  Codeunit "TripleDESCryptoSvcProv. Impl." = X,
                  Codeunit EncryptedXml = X,
                  Codeunit "EncryptedXml Impl." = X,
                  Codeunit "Signature Key" = X,
                  Codeunit "Signature Key Impl." = X,
#if not CLEAN19
#pragma warning disable AL0432
                  Table "Signature Key" = X,
#pragma warning restore                  
#endif           
                  Page "Data Encryption Management" = X;
}
