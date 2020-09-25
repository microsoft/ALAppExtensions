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
        InStr: InStream;
        Token: Text;
    begin
        IF NOT GET() THEN
            EXIT('');

        IF "Cob. Token Last Date Updated" = 0DT THEN
            EXIT('');

        // Cobrand token is valid for 100 minutes. Provide a 20 minutes buffer till it becomes "invalid" (empty)
        IF CURRENTDATETIME() - "Cob. Token Last Date Updated" >= 1000 * 60 * 80 THEN // duration is milliseconds
            EXIT('');

        CALCFIELDS("Cobrand Session Token");
        "Cobrand Session Token".CREATEINSTREAM(InStr);
        InStr.READ(Token);

        IF CryptographyManagement.IsEncryptionEnabled() THEN
            EXIT(CryptographyManagement.Decrypt(Token));

        EXIT(Token);
    end;

    procedure GeConsumerSessionToken(): Text;
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        InStr: InStream;
        Token: Text;
    begin
        IF GetCobrandSessionToken() = '' THEN
            EXIT('');

        GET();

        IF "Cons. Token Last Date Updated" = 0DT THEN
            EXIT('');

        // Consumer token is valid for 30 minutes. Provide a 10 minutes buffer till it becomes "invalid" (empty)
        IF CURRENTDATETIME() - "Cons. Token Last Date Updated" >= 1000 * 60 * 20 THEN // duration is milliseconds
            EXIT('');

        CALCFIELDS("Consumer Session Token");
        "Consumer Session Token".CREATEINSTREAM(InStr);
        InStr.READ(Token);

        IF CryptographyManagement.IsEncryptionEnabled() THEN
            EXIT(CryptographyManagement.Decrypt(Token));

        EXIT(Token);
    end;

    procedure UpdateCobrandSessionToken(NewToken: Text; LastDateUpdated: DateTime);
    var
        IsNew: Boolean;
    begin
        LOCKTABLE();

        IsNew := NOT GET();
        IF IsNew THEN
            INIT();

        SetCobrandSessionToken(NewToken, LastDateUpdated);

        IF IsNew THEN
            INSERT()
        ELSE
            MODIFY();

        COMMIT();
    end;

    procedure UpdateConsumerSessionToken(NewToken: Text; LastDateUpdated: DateTime);
    var
        IsNew: Boolean;
    begin
        LOCKTABLE();

        IsNew := NOT GET();
        IF IsNew THEN
            INIT();

        SetConsumerSessionToken(NewToken, LastDateUpdated);

        IF IsNew THEN
            INSERT()
        ELSE
            MODIFY();

        COMMIT();
    end;

    procedure UpdateSessionTokens(NewCobrandToken: Text; CobrandTokenLastDateUpdated: DateTime; NewConsumerToken: Text; ConsumerTokenLastDateUpdated: DateTime);
    var
        IsNew: Boolean;
    begin
        LOCKTABLE();

        IsNew := NOT GET();
        IF IsNew THEN
            INIT();

        SetCobrandSessionToken(NewCobrandToken, CobrandTokenLastDateUpdated);
        SetConsumerSessionToken(NewConsumerToken, ConsumerTokenLastDateUpdated);

        IF IsNew THEN
            INSERT()
        ELSE
            MODIFY();

        COMMIT();
    end;

    procedure ResetSessionTokens();
    var
        IsNew: Boolean;
    begin
        LOCKTABLE();

        IsNew := NOT GET();
        IF IsNew THEN
            INIT();

        SetCobrandSessionToken('', 0DT);
        SetConsumerSessionToken('', 0DT);

        IF IsNew THEN
            INSERT()
        ELSE
            MODIFY();

        COMMIT();
    end;

    local procedure SetCobrandSessionToken(NewToken: Text; LastDateUpdated: DateTime);
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        OutStr: OutStream;
    begin
        IF NewToken <> '' THEN BEGIN
            "Cob. Token Last Date Updated" := LastDateUpdated;
            "Cobrand Session Token".CREATEOUTSTREAM(OutStr);
            IF CryptographyManagement.IsEncryptionEnabled() THEN
                OutStr.WRITE(CryptographyManagement.Encrypt(NewToken))
            ELSE
                OutStr.WRITE(NewToken);
        END ELSE BEGIN
            "Cob. Token Last Date Updated" := 0DT;
            CLEAR("Cobrand Session Token");
        END;
    end;

    local procedure SetConsumerSessionToken(NewToken: Text; LastDateUpdated: DateTime);
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        OutStr: OutStream;
    begin
        IF NewToken <> '' THEN BEGIN
            "Cons. Token Last Date Updated" := LastDateUpdated;
            "Consumer Session Token".CREATEOUTSTREAM(OutStr);
            IF CryptographyManagement.IsEncryptionEnabled() THEN
                OutStr.WRITE(CryptographyManagement.Encrypt(NewToken))
            ELSE
                OutStr.WRITE(NewToken);
        END ELSE BEGIN
            "Cons. Token Last Date Updated" := 0DT;
            CLEAR("Consumer Session Token");
        END;
    end;
}

