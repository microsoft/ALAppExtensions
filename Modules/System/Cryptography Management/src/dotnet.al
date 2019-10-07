dotnet
{
    assembly("mscorlib")
    {
        type("System.Security.Cryptography.RijndaelManaged"; "RijndaelManaged") { }
        type("System.Security.Cryptography.CipherMode"; "ChiperMode") { }
        type("System.Security.Cryptography.PaddingMode"; "PaddingMode") { }
        type("System.Security.Cryptography.ICryptoTransform"; "ICryptoTransform") { }
        type("System.Security.Cryptography.CryptoStream"; "CryptoStream") { }
        type("System.Security.Cryptography.CryptoStreamMode"; "CryptoStreamMode") { }
        type("System.Security.Cryptography.KeySizes"; "KeySizes") { }
    }
}