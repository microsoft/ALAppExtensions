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
    }
}
