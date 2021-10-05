codeunit 132603 "GenerateBase64KeyedHash Test"
{
    // [FEATURE] [GenerateBase64KeyedHash] 
    Subtype = Test;

    [Test]
    procedure GenerateBase64KeyedHash()
    var
        LibraryAssert: Codeunit "Library Assert";
        LF: Char;
        stringtosign: Text;
        kSecret: Text;
        ldate: Text;
        Service: Text;
        Region: Text;
        aws4_request: Text;
        xlSignature: Text;
        ExpectedSignature: Text;
    begin
        // [SCENARIO 12441] Add fuction in Codeunit 1266 "Crypthography Management"

        // [GIVEN] Expected signature
        ExpectedSignature := '5d672d79c15b13162d9279b0855cfba6789a8edb4c82c400e06b5924a6f2b5d7';

        // [WHEN] Calculate signature
        LF := 10;
        stringtosign := 'AWS4-HMAC-SHA256' + format(LF) + '20150830T123600Z' + format(LF) + '20150830/us-east-1/iam/aws4_request' + format(LF) + 'f536975d06c0309214f805bb90ccff089219ecd68b2577efef23edd43b7e1a59';

        kSecret := 'wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY';
        ldate := '20150830';
        Region := 'us-east-1';
        Service := 'iam';
        aws4_request := 'aws4_request';

        xlSignature := signature(stringtosign, kSecret, ldate, Region, Service, aws4_request).ToLower();

        // [THEN] Calulcated signature is the same 
        LibraryAssert.AreEqual(ExpectedSignature, xlSignature, 'Failed to sing text with GenerateBase64KeyedHash');
    end;

    local procedure signature(stringtosign: Text; kSecret: Text; lDate: Text; Region: Text; Service: Text; aws4_request: Text): text
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        HashBytes: Text;
        kDate: text;
        kRegion: Text;
        kService: Text;
        kSigning: Text;
    begin
        kSecret := 'AWS4' + kSecret;
        kDate := CryptographyManagement.GenerateHashAsBase64String(ldate, kSecret, 2);
        kRegion := CryptographyManagement.GenerateBase64KeyedHashAsBase64String(Region, kDate, 2);
        kService := CryptographyManagement.GenerateBase64KeyedHashAsBase64String(Service, kRegion, 2);
        kSigning := CryptographyManagement.GenerateBase64KeyedHashAsBase64String(aws4_request, kService, 2);
        HashBytes := CryptographyManagement.GenerateBase64KeyedHash(stringtosign, kSigning, 2);
        exit(HashBytes);
    end;

}