namespace Microsoft.Bank.StatementImport.Yodlee;

using System.Security.Encryption;

table 1453 "MS - Yodlee Bank Session"
{
    ReplicateData = false;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
        }
        field(40; "Cobrand Session Token"; BLOB)
        {
        }
        field(41; "Cob. Token Last Date Updated"; DateTime)
        {
            Editable = false;
        }
        field(42; "Consumer Session Token"; BLOB)
        {
        }
        field(43; "Cons. Token Last Date Updated"; DateTime)
        {
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert();
    begin
        TESTFIELD("Primary Key", '');
    end;

    procedure GetCobrandSessionToken(): Text;
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        AuxInStream: InStream;
        Token: Text;
    begin
        if not GET() then
            exit('');

        if "Cob. Token Last Date Updated" = 0DT then
            exit('');

        // Cobrand token is valid for 100 minutes. Provide a 20 minutes buffer till it becomes "invalid" (empty)
        if CURRENTDATETIME() - "Cob. Token Last Date Updated" >= 1000 * 60 * 80 then // duration is milliseconds
            exit('');

        CALCFIELDS("Cobrand Session Token");
        "Cobrand Session Token".CREATEINSTREAM(AuxInStream);
        AuxInStream.READ(Token);

        if CryptographyManagement.IsEncryptionEnabled() then
            exit(CryptographyManagement.Decrypt(Token));

        exit(Token);
    end;

    procedure GeConsumerSessionToken(): Text;
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        AuxInStream: InStream;
        Token: Text;
    begin
        if GetCobrandSessionToken() = '' then
            exit('');

        GET();

        if "Cons. Token Last Date Updated" = 0DT then
            exit('');

        // Consumer token is valid for 30 minutes. Provide a 10 minutes buffer till it becomes "invalid" (empty)
        if CURRENTDATETIME() - "Cons. Token Last Date Updated" >= 1000 * 60 * 20 then // duration is milliseconds
            exit('');

        CALCFIELDS("Consumer Session Token");
        "Consumer Session Token".CREATEINSTREAM(AuxInStream);
        AuxInStream.READ(Token);

        if CryptographyManagement.IsEncryptionEnabled() then
            exit(CryptographyManagement.Decrypt(Token));

        exit(Token);
    end;

    procedure UpdateCobrandSessionToken(NewToken: Text; LastDateUpdated: DateTime);
    var
        IsNew: Boolean;
    begin
        LOCKTABLE();

        IsNew := not GET();
        if IsNew then
            INIT();

        SetCobrandSessionToken(CopyStr(NewToken, 1, 215), LastDateUpdated);

        if IsNew then
            INSERT()
        else
            MODIFY();

        COMMIT();
    end;

    procedure UpdateConsumerSessionToken(NewToken: Text; LastDateUpdated: DateTime);
    var
        IsNew: Boolean;
    begin
        LOCKTABLE();

        IsNew := not GET();
        if IsNew then
            INIT();

        SetConsumerSessionToken(CopyStr(NewToken, 1, 215), LastDateUpdated);

        if IsNew then
            INSERT()
        else
            MODIFY();

        COMMIT();
    end;

    procedure UpdateSessionTokens(NewCobrandToken: Text; CobrandTokenLastDateUpdated: DateTime; NewConsumerToken: Text; ConsumerTokenLastDateUpdated: DateTime);
    var
        IsNew: Boolean;
    begin
        LOCKTABLE();

        IsNew := not GET();
        if IsNew then
            INIT();

        SetCobrandSessionToken(CopyStr(NewCobrandToken, 1, 215), CobrandTokenLastDateUpdated);
        SetConsumerSessionToken(CopyStr(NewConsumerToken, 1, 215), ConsumerTokenLastDateUpdated);

        if IsNew then
            INSERT()
        else
            MODIFY();

        COMMIT();
    end;

    procedure ResetSessionTokens();
    var
        IsNew: Boolean;
    begin
        LOCKTABLE();

        IsNew := not GET();
        if IsNew then
            INIT();

        SetCobrandSessionToken('', 0DT);
        SetConsumerSessionToken('', 0DT);

        if IsNew then
            INSERT()
        else
            MODIFY();

        COMMIT();
    end;

    local procedure SetCobrandSessionToken(NewToken: Text[215]; LastDateUpdated: DateTime);
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        AuxOutStream: OutStream;
    begin
        if NewToken <> '' then begin
            "Cob. Token Last Date Updated" := LastDateUpdated;
            "Cobrand Session Token".CREATEOUTSTREAM(AuxOutStream);
            if CryptographyManagement.IsEncryptionEnabled() then
                AuxOutStream.WRITE(CryptographyManagement.EncryptText(NewToken))
            else
                AuxOutStream.WRITE(NewToken);
        end else begin
            "Cob. Token Last Date Updated" := 0DT;
            CLEAR("Cobrand Session Token");
        end;
    end;

    local procedure SetConsumerSessionToken(NewToken: Text[215]; LastDateUpdated: DateTime);
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        AuxOutStream: OutStream;
    begin
        if NewToken <> '' then begin
            "Cons. Token Last Date Updated" := LastDateUpdated;
            "Consumer Session Token".CREATEOUTSTREAM(AuxOutStream);
            if CryptographyManagement.IsEncryptionEnabled() then
                AuxOutStream.WRITE(CryptographyManagement.EncryptText(NewToken))
            else
                AuxOutStream.WRITE(NewToken);
        end else begin
            "Cons. Token Last Date Updated" := 0DT;
            CLEAR("Consumer Session Token");
        end;
    end;
}

