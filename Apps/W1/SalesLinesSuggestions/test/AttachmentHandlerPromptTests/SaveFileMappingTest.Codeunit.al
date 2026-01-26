namespace Microsoft.Sales.Document.Test;

using Microsoft.Sales.Document.Attachment;

codeunit 133526 "Save File Mapping Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Sales with AI]:[Attachment]
    end;

    var
        Assert: Codeunit Assert;
        TestUtility: Codeunit "SLS Test Utility";
        IsInitialized: Boolean;

    [Test]
    procedure SaveToJsonTest()
    var
        FileHandlerResult: Codeunit "File Handler Result";
        ColumnNames: List of [Text];
        ColumnTypes: List of [Text];
        MappingAsJsonObject: JsonObject;
        MappingAsJsonString: Text;
        ExpectedJsonStringLbl: Label '{"Column_Delimiter":"$","Product_Column_Index":[20,30,40],"Quantity_Column_Index":60,"UoM_Column_Index":70,"Contains_Header_Row":1,"Column_Names":["Column1","Column2","Column3"],"Column_Types":["Text","Boolean","Random text"]}', Locked = true;
    begin
        // [FEATURE] [Sales Line From Attachment with AI] 
        // [SCENARIO] FileHandlerResult can be converted to a jsonobject and saved as a jsonstring.
        Initialize();

        // [GIVEN] Create a new file handler result with column delimiter '$', product column indexes 20, 30, 40, quantity column index 60, UoM column index 70, contains header row true, column names and column types
        Clear(FileHandlerResult);
        FileHandlerResult.SetColumnDelimiter('$');
        FileHandlerResult.AddProductColumnIndex(20);
        FileHandlerResult.AddProductColumnIndex(30);
        FileHandlerResult.AddProductColumnIndex(40);
        FileHandlerResult.SetQuantityColumnIndex(60);
        FileHandlerResult.SetUoMColumnIndex(70);
        FileHandlerResult.SetContainsHeaderRow(true);
        ColumnNames.Add('Column1');
        ColumnNames.Add('Column2');
        ColumnNames.Add('Column3');
        FileHandlerResult.SetColumnNames(ColumnNames);
        ColumnTypes.Add('Text');
        ColumnTypes.Add('Boolean');
        ColumnTypes.Add('Random text');
        FileHandlerResult.SetColumnTypes(ColumnTypes);

        // [WHEN] Save the file handler result as a json object
        MappingAsJsonObject := FileHandlerResult.ToJson();

        // [THEN] Check the json object is valid
        Assert.IsTrue(MappingAsJsonObject.WriteTo(MappingAsJsonString), 'Mapping Json object is not valid');
        // [THEN] Check the json string is as expected
        Assert.AreEqual(ExpectedJsonStringLbl, MappingAsJsonString, 'Mapping Json string is not expected');
    end;

    [Test]
    procedure LoadFileHandlerResultFromJsonTest()
    var
        FileHandlerResult: Codeunit "File Handler Result";
        ExpectedColumnNames: List of [Text];
        ExpectedColumnTypes: List of [Text];
        ExpectedProductColumnIndex: List of [Integer];
        MappingAsJsonObject: JsonObject;
        ExpectedJsonStringLbl: Label '{"Column_Delimiter":"$","Product_Column_Index":[20,30,40],"Quantity_Column_Index":60,"UoM_Column_Index":70,"Contains_Header_Row":1,"Column_Names":["Column1","Column2","Column3"],"Column_Types":["Text","Boolean","Random text"]}', Locked = true;
        ArrayElementText: Text;
        ArrayElementInt: Integer;
    begin
        // [FEATURE] [Sales Line From Attachment with AI] 
        // [SCENARIO] FileHandlerResult can be initialized from a jsonobject.
        Initialize();

        // [GIVEN] Create a json object from json string
        MappingAsJsonObject.ReadFrom(ExpectedJsonStringLbl);

        // [WHEN] Initialize the file handler result from the json object
        FileHandlerResult.FromJson(MappingAsJsonObject);

        // [THEN] Properties on the File handler result is as expected
        Assert.AreEqual('$', FileHandlerResult.GetColumnDelimiter(), 'Column delimiter is not expected');
        Assert.AreEqual(3, FileHandlerResult.GetProductColumnIndex().Count(), 'Product column indexes are not expected');
        ExpectedProductColumnIndex.Add(20);
        ExpectedProductColumnIndex.Add(40);
        ExpectedProductColumnIndex.Add(30);
        foreach ArrayElementInt in ExpectedProductColumnIndex do
            Assert.IsTrue(FileHandlerResult.GetProductColumnIndex().Contains(ArrayElementInt), 'Product column index is not expected');
        Assert.AreEqual(60, FileHandlerResult.GetQuantityColumnIndex(), 'Quantity column index is not expected');
        Assert.AreEqual(70, FileHandlerResult.GetUoMColumnIndex(), 'UoM column index is not expected');
        Assert.AreEqual(true, FileHandlerResult.GetContainsHeaderRow(), 'Contains header row is not expected');
        Assert.AreEqual(3, FileHandlerResult.GetColumnNames().Count(), 'Column names are not expected');
        ExpectedColumnNames.Add('Column1');
        ExpectedColumnNames.Add('Column2');
        ExpectedColumnNames.Add('Column3');
        foreach ArrayElementText in ExpectedColumnNames do
            Assert.IsTrue(FileHandlerResult.GetColumnNames().Contains(ArrayElementText), 'Column names are not expected');
        Assert.AreEqual(3, FileHandlerResult.GetColumnTypes().Count(), 'Column types are not expected');
        ExpectedColumnTypes.Add('Text');
        ExpectedColumnTypes.Add('Boolean');
        ExpectedColumnTypes.Add('Random text');
        foreach ArrayElementText in ExpectedColumnTypes do
            Assert.IsTrue(FileHandlerResult.GetColumnTypes().Contains(ArrayElementText), 'Column types are not expected');
    end;

    [Test]
    procedure MappingCacheManagementTest()
    var
        MappingCache: Record "Mapping Cache";
        FileHandlerResult: Codeunit "File Handler Result";
        MappingCacheManagement: Codeunit "Mapping Cache Management";
        MappingAsJsonObject: JsonObject;
        FileHandlerResultJsonStringLbl: Label '{"Column_Delimiter":"$","Product_Column_Index":[20,30,40],"Quantity_Column_Index":60,"UoM_Column_Index":70,"Contains_Header_Row":1,"Column_Names":["Column1","Column2","Column3"],"Column_Types":["Text","Boolean","Random text"]}', Locked = true;
        PartOfFileToSaveLbl: Label 'Column1,Column2,Column3,Column4,Column5', Locked = true;
        FileInfoAsHash: Text;
        ExpectedMappingAsJsonText: Text;
    begin
        // [FEATURE] [Sales Line From Attachment with AI] 
        // [SCENARIO] MappingCacheManagement functions help in saving and restoring the mappings.
        Initialize();

        // [GIVEN] Create a hash of the passed text. In the product, it would typically be the text in the first line when header is present
        FileInfoAsHash := MappingCacheManagement.GenerateFileHashInHex(PartOfFileToSaveLbl);
        if MappingCache.Get(FileInfoAsHash) then // Ensure cache is empty
            MappingCache.Delete();

        // [WHEN] MappingExists method is run in the MappingCacheMapping codeunit.
        // [THEN] Mapping should not exist
        Assert.IsFalse(MappingCacheManagement.MappingExists(FileInfoAsHash), 'Mapping should not exist');

        // [WHEN] GetMapping method is run in the MappingCacheMapping codeunit.
        // [THEN] Mapping should not exist
        Assert.IsFalse(MappingCacheManagement.GetMapping(FileInfoAsHash, ExpectedMappingAsJsonText), 'Mapping should exist');

        // [GIVEN] Save the file handler result json string to the mapping cache
        MappingCacheManagement.SaveMapping(FileInfoAsHash, FileHandlerResultJsonStringLbl);
        // [WHEN] MappingExists method is run in the MappingCacheMapping codeunit.
        // [THEN] Mapping should exist
        Assert.IsTrue(MappingCacheManagement.MappingExists(FileInfoAsHash), 'Mapping should not exist');
        // [WHEN] GetMapping method is run in the MappingCacheMapping codeunit.
        // [THEN] Mapping should exist
        Assert.IsTrue(MappingCacheManagement.GetMapping(FileInfoAsHash, ExpectedMappingAsJsonText), 'Mapping should exist');

        // [WHEN] The cache value is loaded to a JsonObject
        // [THEN] The JsonObject should be valid
        MappingAsJsonObject.ReadFrom(ExpectedMappingAsJsonText);
        FileHandlerResult.FromJson(MappingAsJsonObject);
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        TestUtility.RegisterCopilotCapability();

        IsInitialized := true;
    end;
}