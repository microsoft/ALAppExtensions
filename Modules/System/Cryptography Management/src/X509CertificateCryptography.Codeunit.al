// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides helper functions to work with X509Certificate2 class
/// </summary>
codeunit 50100 "X509Certificate2 Cryptography"
{
    Access = Public;

    var
        CryptographyManagementImpl: Codeunit "Cryptography Management Impl.";

        /// <summary>
        /// Verify that Certificate is initialized and exportable
        /// </summary>
        /// <param name="CertBase64Value">Certificate Base64 value</param>
        /// <param name="Password">Certificate Password</param>
        /// <param name="ContentType">Specifies the format of an X.509 certificate</param>
        /// <returns>True if Certificate is verified</returns>
    procedure VerifyCertificate(var CertBase64Value: Text; Password: Text; ContentType: Enum "X509 Content Type") CertVerified: Boolean
    begin
        CertVerified := CryptographyManagementImpl.VerifyCertificate(CertBase64Value, Password, ContentType);
    end;

    /// <summary>
    /// Get Certificate Details based on Certificate Base64 value
    /// </summary>
    /// <param name="CertBase64Value">Certificate Base64 value</param>
    /// <param name="FriendlyName">Certificate Friendly Name</param>
    /// <param name="Thumbprint">Certificate Thumbprint</param>
    /// <param name="Issuer">Certificate Issuer</param>
    /// <param name="Expiration">Certificate Expiration Date</param>   
    procedure GetCertificateDetails(CertBase64Value: Text; var FriendlyName: Text; var Thumbprint: Text; var Issuer: Text; var Expiration: DateTime)
    begin
        CryptographyManagementImpl.GetCertificateDetails(CertBase64Value, FriendlyName, Thumbprint, Issuer, Expiration);
    end;

    /// <summary>
    /// Get Certificate details in Json object
    /// </summary>
    /// <param name="CertBase64Value">Certificate Base64 value</param>
    /// <returns>Certificate details in json</returns>
    procedure GetCertificatePropertiesAsJson(CertBase64Value: Text) CertPropertyJson: Text
    begin
        CertPropertyJson := CryptographyManagementImpl.GetCertificatePropertiesAsJson(CertBase64Value);
    end;
}