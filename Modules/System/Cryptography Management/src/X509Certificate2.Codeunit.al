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
        /// <param name="X509ContentType">Specifies the format of an X.509 certificate</param>
        /// <returns>True if Certificate is verified</returns>
    procedure VerifyCertificate(var CertBase64Value: Text; Password: Text; X509ContentType: Enum "X509 Content Type"): Boolean
    begin
        exit(X509Certificate2Impl.VerifyCertificate(CertBase64Value, Password, X509ContentType));
    end;

    /// <summary>
    /// Get Certificate Friendly Name based on Certificate Base64 value
    /// </summary>
    /// <param name="CertBase64Value">Certificate Base64 value</param>
    /// <param name="Password">Certificate Password</param>
    /// <param name="FriendlyName">Certificate Friendly Name</param>    
    procedure GetCertificateFriendlyName(CertBase64Value: Text; Password: Text; var FriendlyName: Text)
    begin
        X509Certificate2Impl.GetCertificateFriendlyName(CertBase64Value, Password, FriendlyName);
    end;

    /// <summary>
    /// Get Certificate Subject based on Certificate Base64 value
    /// </summary>
    /// <param name="CertBase64Value">Certificate Base64 value</param>
    /// <param name="Password">Certificate Password</param>
    /// <param name="Subject">Certificate Subject</param>    
    procedure GetCertificateSubject(CertBase64Value: Text; Password: Text; var Subject: Text)
    begin
        X509Certificate2Impl.GetCertificateSubject(CertBase64Value, Password, Subject);
    end;

    /// <summary>
    /// Get Certificate Thumbprint based on Certificate Base64 value
    /// </summary>
    /// <param name="CertBase64Value">Certificate Base64 value</param>
    /// <param name="Password">Certificate Password</param>    
    /// <param name="Thumbprint">Certificate Thumbprint</param>    
    procedure GetCertificateThumbprint(CertBase64Value: Text; Password: Text; var Thumbprint: Text)
    begin
        X509Certificate2Impl.GetCertificateThumbprint(CertBase64Value, Password, Thumbprint);
    end;

    /// <summary>
    /// Get Certificate Issuer based on Certificate Base64 value
    /// </summary>
    /// <param name="CertBase64Value">Certificate Base64 value</param>
    /// <param name="Password">Certificate Password</param>    
    /// <param name="Issuer">Certificate Issuer</param>    
    procedure GetCertificateIssuer(CertBase64Value: Text; Password: Text; var Issuer: Text)
    begin
        X509Certificate2Impl.GetCertificateIssuer(CertBase64Value, Password, Issuer);
    end;

    /// <summary>
    /// Get Certificate Expiration Date based on Certificate Base64 value
    /// </summary>
    /// <param name="CertBase64Value">Certificate Base64 value</param>   
    /// <param name="Password">Certificate Password</param> 
    /// <param name="Expiration">Certificate Expiration Date</param>   
    procedure GetCertificateExpiration(CertBase64Value: Text; Password: Text; var Expiration: DateTime)
    begin
        X509Certificate2Impl.GetCertificateExpiration(CertBase64Value, Password, Expiration);
    end;

    /// <summary>
    /// Get Certificate NotBefore Date based on Certificate Base64 value
    /// </summary>
    /// <param name="CertBase64Value">Certificate Base64 value</param> 
    /// <param name="Password">Certificate Password</param>   
    /// <param name="NotBefore">Certificate NotBefore Date</param>   
    procedure GetCertificateNotBefore(CertBase64Value: Text; Password: Text; var NotBefore: DateTime)
    begin
        X509Certificate2Impl.GetCertificateNotBefore(CertBase64Value, Password, NotBefore);
    end;

    /// <summary>
    /// Check if certificate has private key based on Certificate Base64 value
    /// </summary>
    /// <param name="CertBase64Value">Certificate Base64 value</param>  
    /// <param name="Password">Certificate Password</param>
    /// <returns>True if Certificate has private key</returns>      
    procedure HasPrivateKey(CertBase64Value: Text; Password: Text): Boolean
    begin
        exit(X509Certificate2Impl.HasPrivateKey(CertBase64Value, Password));
    end;

    /// <summary>
    /// Get Certificate details in Json object
    /// </summary>
    /// <param name="CertBase64Value">Certificate Base64 value</param>
    /// <param name="Password">Certificate Password</param>
    /// <param name="CertPropertyJson">Certificate details in json</param>
    procedure GetCertificatePropertiesAsJson(CertBase64Value: Text; Password: Text; var CertPropertyJson: Text)
    begin
        X509Certificate2Impl.GetCertificatePropertiesAsJson(CertBase64Value, Password, CertPropertyJson);
    end;
}