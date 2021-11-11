// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1467 "AesCryptoServiceProvider Impl." implements SymmetricAlgorithm
{
    Access = Internal;

    var
        DotNetAesCryptoServiceProvider: Dotnet "Cryptography.AesCryptoServiceProvider";
        XmlEncrypmentMethodUrlTok: Label 'http://www.w3.org/2001/04/xmlenc#aes256-cbc', Locked = true;

    [NonDebuggable]
    procedure GetInstance(var DotNetSymmetricAlgorithm: DotNet "Cryptography.SymmetricAlgorithm")
    begin
        DotNetAesCryptoServiceProvider := DotNetAesCryptoServiceProvider.AesCryptoServiceProvider();
        DotNetSymmetricAlgorithm := DotNetAesCryptoServiceProvider;
    end;

    procedure XmlEncrypmentMethodUrl(): Text
    begin
        exit(XmlEncrypmentMethodUrlTok);
    end;
}