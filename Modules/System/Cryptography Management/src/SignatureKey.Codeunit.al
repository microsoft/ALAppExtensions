// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Represents the key of asymmetric algorithm.
/// </summary>
codeunit 1474 "Signature Key"
{
    Access = Public;

    var
        SignatureKeyImpl: Codeunit "Signature Key Impl.";

    /// <summary>
    /// Saves an key value from the key information from an XML string.
    /// </summary>
    /// <param name="XmlString">The XML string containing key information.</param>
    [NonDebuggable]
    procedure FromXmlString(XmlString: Text)
    begin
        SignatureKeyImpl.FromXmlString(XmlString);
    end;

    /// <summary>
    /// Saves an key value from an certificate in Base64 format
    /// </summary>
    /// <param name="CertBase64Value">Represents the certificate value encoded using the Base64 algorithm</param>
    /// <param name="Represents the password of the certificate">Certificate Password</param>
    /// <param name="IncludePrivateParameters">true to include private parameters; otherwise, false.</param>
    [NonDebuggable]
    procedure FromBase64String(CertBase64Value: Text; Password: Text; IncludePrivateParameters: Boolean)
    begin
        SignatureKeyImpl.FromBase64String(CertBase64Value, Password, IncludePrivateParameters);
    end;

    /// <summary>
    /// Gets an XML string containing the key of the saved key value.
    /// </summary>
    /// <returns>An XML string containing the key of the saved key value.</returns>
    internal procedure ToXmlString(): Text
    begin
        exit(SignatureKeyImpl.ToXmlString());
    end;
}