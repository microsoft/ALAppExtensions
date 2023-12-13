// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using System.Security.Encryption;

codeunit 31081 "EET Text Sign. Provider CZL"
{
    Access = Internal;

    [NonDebuggable]
    procedure SignData(DataText: Text; IsolatedCertificate: Record "Isolated Certificate"; SignatureOutStream: OutStream)
    var
        CertificateManagement: Codeunit "Certificate Management";
        SignatureKey: Codeunit "Signature Key";
    begin
        CertificateManagement.GetCertPrivateKey(IsolatedCertificate, SignatureKey);
        SignData(DataText, SignatureKey, SignatureOutStream);
    end;

    [NonDebuggable]
    procedure SignData(DataText: Text; SignatureKey: Codeunit "Signature Key"; SignatureOutStream: OutStream)
    var
        CryptographyManagement: Codeunit "Cryptography Management";
    begin
        CryptographyManagement.SignData(DataText, SignatureKey, Enum::"Hash Algorithm"::SHA256, SignatureOutStream);
    end;
}
