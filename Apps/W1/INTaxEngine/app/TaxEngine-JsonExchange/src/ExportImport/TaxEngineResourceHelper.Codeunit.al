codeunit 20137 "Tax Engine Resource Helper"
{
    procedure ProcessStoredUseCases(FileDictionary: Dictionary of [Text, Text])
    var
        UseCase: Text;
    begin
        foreach UseCase in FileDictionary.Keys do
            ImportUseCases(FileDictionary.Get(UseCase));
    end;

    procedure GetTaxType(JsonText: Text; TaxType: Text): Text
    var
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
        JsonToken: JsonToken;
    begin
        JsonToken := GetJsonToken(JsonText, 'taxTypes');

        exit(TaxJsonDeserialization.ExtractJTokenValue(JsonToken, TaxType));
    end;

    procedure GetUseCase(JsonText: Text; TaxType: Text): Text
    var
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
        JsonToken: JsonToken;
    begin
        JsonToken := GetJsonToken(JsonText, 'useCases');

        exit(TaxJsonDeserialization.ExtractJTokenValue(JsonToken, TaxType));
    end;

    procedure ReadJsonFromStream(IStream: InStream): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.ReadAsTextWithSeparator(IStream, ''));
    end;

    procedure CheckFileExists(FileNameList: List of [Text]; FolderName: Text; CaseID: Guid): Boolean
    var
        FileName: Text;
        FileExists: Boolean;
    begin
        OnBeforeCheckFileExists(FileNameList, FolderName, CaseID, FileExists);

        FileName := GetCleanGuid(CaseID);

        if not FileExists then
            FileExists := FileNameList.Contains(FolderName + '/' + FileName + '.json');

        exit(FileExists);
    end;

    procedure GetCleanGuid(GuidValue: Guid): Text
    var
        CleanGuid: Text;
    begin
        // Remove curly braces and convert to lowercase
        CleanGuid := LOWERCASE(COPYSTR(GuidValue.ToText(), 2, STRLEN(GuidValue.ToText()) - 2));
        exit(CleanGuid);
    end;

    local procedure ImportUseCases(JsonText: Text)
    var
        TaxJsonDeSerializationImport: Codeunit "Tax Json Deserialization";
        IsHandled: Boolean;
    begin
        OnBeforeImportUseCasesFromAssistedSetup(JsonText, IsHandled);
        if IsHandled then
            exit;

        TaxJsonDeSerializationImport.SkipVersionCheck(true);
        TaxJsonDeSerializationImport.SkipUseCaseIndentation(true);
        TaxJsonDeSerializationImport.ImportUseCases(JsonText);
    end;

    local procedure GetJsonToken(JsonText: Text; ResourceType: Text): JsonToken
    var
        JObject: JsonObject;
        JsonToken: JsonToken;
    begin
        JObject.ReadFrom(JsonText);
        JObject.Get(ResourceType, JsonToken);
        exit(JsonToken);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeImportUseCasesFromAssistedSetup(JsonText: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckFileExists(FileNameList: List of [Text]; FolderName: Text; CaseID: Guid; var FileExists: Boolean)
    begin
    end;
}