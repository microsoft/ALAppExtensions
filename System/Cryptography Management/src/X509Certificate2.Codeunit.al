// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides helper functions to work with the X509Certificate2 class.
/// </summary>
codeunit 1286 "X509Certificate2"
{
    Access = Public;

    var
        X509Certificate2Impl: Codeunit "X509Certificate2 Impl.";

    /// <summary>
    /// Verifes that a certificate is initialized and can be exported.
    /// </summary>
    /// <param name="CertBase64Value">Represents the certificate value encoded using the Base64 algorithm</param>
    /// <param name="Password">Certificate Password</param>
    /// <param name="X509ContentType">Specifies the format of an X.509 certificate</param>
    /// <returns>True if certificate is verified</returns>
    /// <error>When certificate cannot be initialized</error>
    /// <error>When certificate cannot be exported</error>
    [NonDebuggable]
    procedure VerifyCertificate(var CertBase64Value: Text; Password: Text; X509ContentType: Enum "X509 Content Type"): Boolean
    begin
        exit(X509Certificate2Impl.VerifyCertificate(CertBase64Value, Password, X509ContentType));
    end;

    /// <summary>
    /// Specifies the friendly name of the certificate based on it's Base64 value.
    /// </summary>
    /// <param name="CertBase64Value">Represents the certificate value encoded using the Base64 algorithm</param>
    /// <param name="Password">Certificate Password</param>
    /// <param name="FriendlyName">Represents certificate Friendly Name</param> 
    [NonDebuggable]
    procedure GetCertificateFriendlyName(CertBase64Value: Text; Password: Text; var FriendlyName: Text)
    begin
        X509Certificate2Impl.GetCertificateFriendlyName(CertBase64Value, Password, FriendlyName);
    end;

    /// <summary>
    /// Specifies the subject of the certificate based on it's Base64 value.
    /// </summary>
    /// <param name="CertBase64Value">Represents the certificate value encoded using the Base64 algorithm</param>
    /// <param name="Password">Certificate Password</param>
    /// <param name="Subject">Certificate subject distinguished name</param>
    [NonDebuggable]
    procedure GetCertificateSubject(CertBase64Value: Text; Password: Text; var Subject: Text)
    begin
        X509Certificate2Impl.GetCertificateSubject(CertBase64Value, Password, Subject);
    end;

    /// <summary>
    /// Specifies the thumbprint of the certificate based on it's Base64 value.
    /// </summary>
    /// <param name="CertBase64Value">Represents the certificate value encoded using the Base64 algorithm</param>
    /// <param name="Password">Certificate Password</param>    
    /// <param name="Thumbprint">Certificate Thumbprint</param> 
    [NonDebuggable]
    procedure GetCertificateThumbprint(CertBase64Value: Text; Password: Text; var Thumbprint: Text)
    begin
        X509Certificate2Impl.GetCertificateThumbprint(CertBase64Value, Password, Thumbprint);
    end;

    /// <summary>
    /// Specifies the issuer of the certificate based on it's Base64 value.
    /// </summary>
    /// <param name="CertBase64Value">Represents the certificate value encoded using the Base64 algorithm</param>
    /// <param name="Password">Certificate Password</param>    
    /// <param name="Issuer">Certificate Issuer</param> 
    [NonDebuggable]
    procedure GetCertificateIssuer(CertBase64Value: Text; Password: Text; var Issuer: Text)
    begin
        X509Certificate2Impl.GetCertificateIssuer(CertBase64Value, Password, Issuer);
    end;

    /// <summary>
    /// Specifies the expiration date of the certificate based on it's Base64 value.
    /// </summary>
    /// <param name="CertBase64Value">Represents the certificate value encoded using the Base64 algorithm</param>   
    /// <param name="Password">Certificate Password</param> 
    /// <param name="Expiration">Certificate Expiration Date</param> 
    [NonDebuggable]
    procedure GetCertificateExpiration(CertBase64Value: Text; Password: Text; var Expiration: DateTime)
    begin
        X509Certificate2Impl.GetCertificateExpiration(CertBase64Value, Password, Expiration);
    end;

    /// <summary>
    /// Specifies the NotBefore date of the certificate based on it's Base64 value.
    /// </summary>
    /// <param name="CertBase64Value">Represents the certificate value encoded using the Base64 algorithm</param> 
    /// <param name="Password">Certificate Password</param>   
    /// <param name="NotBefore">Certificate NotBefore Date</param>  
    [NonDebuggable]
    procedure GetCertificateNotBefore(CertBase64Value: Text; Password: Text; var NotBefore: DateTime)
    begin
        X509Certificate2Impl.GetCertificateNotBefore(CertBase64Value, Password, NotBefore);
    end;

    /// <summary>
    /// Checks whether the certificate has a private key based on it's Base64 value.
    /// </summary>
    /// <param name="CertBase64Value">Represents the certificate value encoded using the Base64 algorithm</param>  
    /// <param name="Password">Certificate Password</param>
    /// <returns>True if the certificate has private key</returns>  
    [NonDebuggable]
    procedure HasPrivateKey(CertBase64Value: Text; Password: Text): Boolean
    begin
        exit(X509Certificate2Impl.HasPrivateKey(CertBase64Value, Password));
    end;

    /// <summary>
    /// Specifies the certificate details in Json object
    /// </summary>
    /// <param name="CertBase64Value">Represents the certificate value encoded using the Base64 algorithm</param>
    /// <param name="Password">Certificate Password</param>
    /// <param name="CertPropertyJson">Certificate details in json</param>
    [NonDebuggable]
    procedure GetCertificatePropertiesAsJson(CertBase64Value: Text; Password: Text; var CertPropertyJson: Text)
    begin
        X509Certificate2Impl.GetCertificatePropertiesAsJson(CertBase64Value, Password, CertPropertyJson);
    end;
}