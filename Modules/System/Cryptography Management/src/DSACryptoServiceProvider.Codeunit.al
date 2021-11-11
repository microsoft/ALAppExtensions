// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Defines a wrapper object to access the cryptographic service provider (CSP) implementation of the DSA algorithm.
/// </summary>
codeunit 1447 "DSACryptoServiceProvider"
{
    Access = Public;

    var
        [NonDebuggable]
        DSACryptoServiceProviderImpl: Codeunit "DSACryptoServiceProvider Impl.";

    /// <summary>
    /// Creates and returns an XML string representation of the current DSA object.
    /// </summary>
    /// <param name="IncludePrivateParameters">true to include private parameters; otherwise, false.</param>
    /// <returns>An XML string encoding of the current DSA object.</returns>
    [NonDebuggable]
    procedure ToXmlString(IncludePrivateParameters: Boolean): Text
    begin
        exit(DSACryptoServiceProviderImpl.ToXmlString(IncludePrivateParameters));
    end;

    /// <summary>
    /// Computes the hash value of the specified stream using the specified hash algorithm and signs the resulting hash value.
    /// </summary>
    /// <param name="XmlString">The XML string containing DSA key information.</param>
    /// <param name="DataInStream">The input stream to hash and sign.</param>
    /// <param name="HashAlgorithm">The hash algorithm to use to create the hash value.</param>
    /// <param name="SignatureOutStream">The DSA signature stream for the specified data.</param>
    [NonDebuggable]
    procedure SignData(XmlString: Text; DataInStream: InStream; HashAlgorithm: Enum "Hash Algorithm"; SignatureOutStream: OutStream)
    begin
        DSACryptoServiceProviderImpl.SignData(XmlString, DataInStream, HashAlgorithm, SignatureOutStream);
    end;

    /// <summary>
    /// Verifies that a digital signature is valid by calculating the hash value of the specified stream using the specified hash algorithm and comparing it to the provided signature.
    /// </summary>
    /// <param name="XmlString">The XML string containing DSA key information.</param>
    /// <param name="DataInStream">The input stream of data that was signed.</param>
    /// <param name="HashAlgorithm">The name of the hash algorithm used to create the hash value of the data.</param>
    /// <param name="SignatureInStream">The stream of signature data to be verified.</param>
    /// <returns>True if the signature is valid; otherwise, false.</returns>
    [NonDebuggable]
    procedure VerifyData(XmlString: Text; DataInStream: InStream; HashAlgorithm: Enum "Hash Algorithm"; SignatureInStream: InStream): Boolean
    begin
        exit(DSACryptoServiceProviderImpl.VerifyData(XmlString, DataInStream, HashAlgorithm, SignatureInStream));
    end;
}