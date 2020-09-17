// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

dotnet
{
    assembly("mscorlib")
    {
        type("System.Security.Cryptography.RijndaelManaged"; "Cryptography.RijndaelManaged") { }
        type("System.Security.Cryptography.CipherMode"; "Cryptography.CipherMode") { }
        type("System.Security.Cryptography.PaddingMode"; "Cryptography.PaddingMode") { }
        type("System.Security.Cryptography.ICryptoTransform"; "Cryptography.ICryptoTransform") { }
        type("System.Security.Cryptography.CryptoStream"; "Cryptography.CryptoStream") { }
        type("System.Security.Cryptography.CryptoStreamMode"; "Cryptography.CryptoStreamMode") { }
        type("System.Security.Cryptography.KeySizes"; "Cryptography.KeySizes") { }
        type("System.Security.Cryptography.Rfc2898DeriveBytes"; "Rfc2898DeriveBytes") { }
        type("System.Security.Cryptography.SHA1Managed"; "SHA1Managed") { }
        type("System.Security.Cryptography.SymmetricAlgorithm"; "Cryptography.SymmetricAlgorithm") { }
        type("System.Security.Cryptography.DESCryptoServiceProvider"; "Cryptography.DESCryptoServiceProvider") { }
    }
}
