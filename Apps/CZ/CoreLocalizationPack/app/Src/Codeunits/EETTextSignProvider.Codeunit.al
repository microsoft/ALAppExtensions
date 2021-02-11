codeunit 31081 "EET Text Sign. Provider CZL" implements "Electronic Signature Provider"
{
    Access = Internal;

    [NonDebuggable]
    procedure GetSignature(DataInStream: InStream; var SignatureKey: Record "Signature Key"; SignatureOutStream: OutStream)
    var
        CryptographyManagement: Codeunit "Cryptography Management";
    begin
        CryptographyManagement.SignData(DataInStream, SignatureKey, Enum::"Hash Algorithm"::SHA256, SignatureOutStream);
    end;
}