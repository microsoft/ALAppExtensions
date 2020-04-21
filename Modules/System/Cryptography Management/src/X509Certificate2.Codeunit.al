// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides helper functions to work with X509Certificate2 class
/// </summary>
codeunit 1286 "X509Certificate2"
{
    Access = Public;

    var
        X509Certificate2Impl: Codeunit "X509Certificate2 Impl.";

        /// <summary>
        /// Verify that Certificate is initialized and exportable
        /// </summary>
        /// <param name="CertBase64Value">Certificate Base64 value</param>
        /// <param name="Password">Certificate Password</param>
        /// <param name="ContentType">Specifies the format of an X.509 certificate</param>
        /// <returns>True if Certificate is verified</returns>
    procedure VerifyCertificate(var CertBase64Value: Text; Password: Text; ContentType: Enum "X509 Content Type"): Boolean
    begin
        exit(X509Certificate2Impl.VerifyCertificate(CertBase64Value, Password, ContentType));
    end;

    /// <summary>
    /// Get Certificate Friendly Name based on Certificate Base64 value
    /// </summary>
    /// <param name="CertBase64Value">Certificate Base64 value</param>
    /// <param name="FriendlyName">Certificate Friendly Name</param>    
    procedure GetCertificateFriendlyName(CertBase64Value: Text; var FriendlyName: Text)
    begin
        X509Certificate2Impl.GetCertificateFriendlyName(CertBase64Value, FriendlyName);
    end;

    /// <summary>
    /// Get Certificate Thumbprint based on Certificate Base64 value
    /// </summary>
    /// <param name="CertBase64Value">Certificate Base64 value</param>    
    /// <param name="Thumbprint">Certificate Thumbprint</param>    
    procedure GetCertificateThumbprint(CertBase64Value: Text; var Thumbprint: Text)
    begin
        X509Certificate2Impl.GetCertificateThumbprint(CertBase64Value, Thumbprint);
    end;

    /// <summary>
    /// Get Certificate Issuer based on Certificate Base64 value
    /// </summary>
    /// <param name="CertBase64Value">Certificate Base64 value</param>    
    /// <param name="Issuer">Certificate Issuer</param>    
    procedure GetCertificateIssuer(CertBase64Value: Text; var Issuer: Text)
    begin
        X509Certificate2Impl.GetCertificateIssuer(CertBase64Value, Issuer);
    end;

    /// <summary>
    /// Get Certificate Expiration Date based on Certificate Base64 value
    /// </summary>
    /// <param name="CertBase64Value">Certificate Base64 value</param>    
    /// <param name="Expiration">Certificate Expiration Date</param>   
    procedure GetCertificateExpiration(CertBase64Value: Text; var Expiration: DateTime)
    begin
        X509Certificate2Impl.GetCertificateExpiration(CertBase64Value, Expiration);
    end;

    /// <summary>
    /// Get Certificate NotBefore Date based on Certificate Base64 value
    /// </summary>
    /// <param name="CertBase64Value">Certificate Base64 value</param>    
    /// <param name="NotBefore">Certificate NotBefore Date</param>   
    procedure GetCertificateNotBefore(CertBase64Value: Text; var NotBefore: DateTime)
    begin
        X509Certificate2Impl.GetCertificateNotBefore(CertBase64Value, NotBefore);
    end;

    /// <summary>
    /// Check if certificate has private key based on Certificate Base64 value
    /// </summary>
    /// <param name="CertBase64Value">Certificate Base64 value</param>  
    /// <returns>True if Certificate has private key</returns>      
    procedure HasPrivateKey(CertBase64Value: Text): Boolean
    begin
        exit(X509Certificate2Impl.HasPrivateKey(CertBase64Value));
    end;

    /// <summary>
    /// Get Certificate details in Json object
    /// </summary>
    /// <param name="CertBase64Value">Certificate Base64 value</param>
    /// <param name="CertPropertyJson">Certificate details in json</param>
    procedure GetCertificatePropertiesAsJson(CertBase64Value: Text; var CertPropertyJson: Text)
    begin
        X509Certificate2Impl.GetCertificatePropertiesAsJson(CertBase64Value, CertPropertyJson);
    end;
}