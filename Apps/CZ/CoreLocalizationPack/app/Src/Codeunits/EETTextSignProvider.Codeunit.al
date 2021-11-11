codeunit 31081 "EET Text Sign. Provider CZL" implements "Electronic Signature Provider"
{
    Access = Internal;

#if not CLEAN19
#pragma warning disable AL0432
    [NonDebuggable]
    procedure GetSignature(DataInStream: InStream; var SignatureKey: Record "Signature Key"; SignatureOutStream: OutStream)
    var
        CryptographyManagement: Codeunit "Cryptography Management";
    begin
        CryptographyManagement.SignData(DataInStream, SignatureKey, Enum::"Hash Algorithm"::SHA256, SignatureOutStream);
    end;
#pragma warning restore AL0432
#else
    [NonDebuggable]
    procedure GetSignature(DataInStream: InStream; XmlString: Text; SignatureOutStream: OutStream)
    var
        CryptographyManagement: Codeunit "Cryptography Management";
    begin
        CryptographyManagement.SignData(DataInStream, XmlString, Enum::"Hash Algorithm"::SHA256, SignatureOutStream);
    end;
#endif
}