table 9092 "Postcode GetAddress.io Config"
{
    Permissions = TableData 1261 = rimd;
    ReplicateData = false;

    fields
    {
        field(1; EndpointURL; Text[250]) { }
        field(2; APIKey; Guid) { }
        field(3; "Primary Key"; Code[10]) { }
    }

    keys
    {
        key(Key1; "Primary Key") { }
    }

    procedure GetAPIKey(APIKeyGUID: Guid): Text
    var
        ServicePassword: Record 1261;
    begin
        IF ISNULLGUID(APIKeyGUID) OR NOT ServicePassword.GET(APIKeyGUID) THEN
            EXIT('');

        EXIT(ServicePassword.GetPassword());
    end;

    procedure SaveAPIKey(var APIKeyGUID: Guid; APIKeyValue: Text[250])
    var
        ServicePassword: Record 1261;
    begin
        IF NOT ISNULLGUID(APIKeyGUID) AND (APIKeyValue = '') THEN BEGIN
            ServicePassword.GET(APIKeyGUID);
            CLEAR(APIKey);
            ServicePassword.DELETE();
        END ELSE
            IF ISNULLGUID(APIKey) OR NOT ServicePassword.GET(APIKeyGUID) THEN BEGIN
                ServicePassword.SavePassword(APIKeyValue);
                ServicePassword.INSERT(TRUE);
                APIKey := ServicePassword.Key;
                MODIFY();
            END ELSE BEGIN
                ServicePassword.SavePassword(APIKeyValue);
                ServicePassword.MODIFY();
            END;
        COMMIT();
    end;
}

