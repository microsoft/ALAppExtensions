namespace Microsoft.EServices.EDocumentConnector.ForNAV;

using System.Security.Encryption;
codeunit 6421 "ForNAV Peppol Crypto"
{
    Access = Internal;

    internal procedure TestHash(NewHash: Text; InputString: Text; KeyValue: SecretText)
    var
        InvalidKeyErr: Label 'Invalid setup key. Contact your ForNAV partner.', Locked = true;
    begin
        if NewHash <> Hash(InputString, KeyValue) then
            Error(InvalidKeyErr);
    end;

    internal procedure Hash(InputString: Text; KeyValue: SecretText): Text
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        PeppolOauth: Codeunit "ForNAV Peppol Oauth";
    begin
        exit(CryptographyManagement.GenerateHash(InputString, SecretStrSubstNo('%1-%2', PeppolOauth.GetSetupKey(), KeyValue), 2));
    end;
}