// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

interface SignatureAlgorithm
{
    internal procedure GetInstance(var DotNetAsymmetricAlgorithm: DotNet AsymmetricAlgorithm);
    procedure FromXmlString(XmlString: Text);
    procedure SignData(DataInStream: InStream; HashAlgorithm: Enum "Hash Algorithm"; SignatureOutStream: OutStream);
    procedure ToXmlString(IncludePrivateParameters: Boolean): Text;
    procedure VerifyData(DataInStream: InStream; HashAlgorithm: Enum "Hash Algorithm"; SignatureInStream: InStream): Boolean;
}