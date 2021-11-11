// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1468 "TripleDESCryptoSvcProv. Impl." implements SymmetricAlgorithm
{
    Access = Internal;

    var
        DotNetTripleDESCryptoServiceProvider: Dotnet "Cryptography.TripleDESCryptoServiceProvider";
        XmlEncrypmentMethodUrlTok: Label 'http://www.w3.org/2001/04/xmlenc#tripledes-cbc', Locked = true;

    [NonDebuggable]
    procedure GetInstance(var DotNetSymmetricAlgorithm: DotNet "Cryptography.SymmetricAlgorithm")
    begin
        DotNetTripleDESCryptoServiceProvider := DotNetTripleDESCryptoServiceProvider.TripleDESCryptoServiceProvider();
        DotNetSymmetricAlgorithm := DotNetTripleDESCryptoServiceProvider;
    end;

    procedure XmlEncrypmentMethodUrl(): Text
    begin
        exit(XmlEncrypmentMethodUrlTok);
    end;
}