codeunit 18816 "Import TCS Use Case"
{
    trigger OnRun()
    begin
        ImportTCSUseCase(GetResourceForUseCase('TCS'));
    end;

    local procedure ImportTCSUseCase(FolderName: Text)
    var
        TaxEngineResourceHelper: Codeunit "Tax Engine Resource Helper";
        IStream: InStream;
        JsonText: Text;
        FileName: Text;
        FileNameList: List of [Text];
        FileDictionary: Dictionary of [Text, Text];
    begin
        FileNameList := NavApp.ListResources(FolderName);

        foreach FileName in FileNameList do begin
            NavApp.GetResource(FileName, IStream);
            JsonText := TaxEngineResourceHelper.ReadJsonFromStream(IStream);
            FileDictionary.Add(FileName, JsonText);
        end;

        TaxEngineResourceHelper.ProcessStoredUseCases(FileDictionary);
    end;

    procedure GetConfigJsonText(CaseID: Guid; FolderName: Text): Text
    var
        TaxEngineResourceHelper: Codeunit "Tax Engine Resource Helper";
        IStream: InStream;
        FileName: Text;
    begin
        FileName := FolderName + '/' + TaxEngineResourceHelper.GetCleanGuid(CaseID) + '.json';
        NavApp.GetResource(FileName, IStream);

        exit(TaxEngineResourceHelper.ReadJsonFromStream(IStream));
    end;

    procedure GetResourceForTaxType(TaxType: Text): Text
    var
        TaxEngineResourceHelper: Codeunit "Tax Engine Resource Helper";
        IStream: InStream;
        JsonText: Text;
    begin
        NavApp.GetResource(IndiaTCSResourcesLbl, IStream);

        JsonText := TaxEngineResourceHelper.ReadJsonFromStream(IStream);
        exit(TaxEngineResourceHelper.GetTaxType(JsonText, TaxType));
    end;

    procedure GetResourceForUseCase(TaxType: Text): Text
    var
        TaxEngineResourceHelper: Codeunit "Tax Engine Resource Helper";
        IStream: InStream;
        JsonText: Text;
    begin
        NavApp.GetResource(IndiaTCSResourcesLbl, IStream);

        JsonText := TaxEngineResourceHelper.ReadJsonFromStream(IStream);
        exit(TaxEngineResourceHelper.GetUseCase(JsonText, TaxType));
    end;

    procedure FindBCAppResourceFile(FolderName: Text; CaseID: Guid): Boolean
    var
        TaxEngineResoureceHelper: Codeunit "Tax Engine Resource Helper";
        FileNameList: List of [Text];
    begin
        FileNameList := NavApp.ListResources(FolderName);

        exit(TaxEngineResoureceHelper.CheckFileExists(FileNameList, FolderName, CaseID));
    end;

    var
        IndiaTCSResourcesLbl: Label 'IndiaTCSResources.json', Locked = true;
}