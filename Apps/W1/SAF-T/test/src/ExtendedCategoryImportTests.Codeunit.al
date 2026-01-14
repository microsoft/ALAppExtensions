codeunit 139537 "Extended Category Import Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Audit File Export] [SAF-T] [Extended Category]
    end;

    var
        Assert: Codeunit Assert;
        LibraryUtility: Codeunit "Library - Utility";

    [Test]
    procedure ImportGroupingCodeWith20CharsStoredAsNo()
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        CategoryCode: Code[20];
        Description: Text[250];
    begin
        // [SCENARIO] Import a grouping code with exactly 20 characters stores value in No. field
        // [GIVEN] XML buffer with a 20-character category code
        CategoryCode := CopyStr(LibraryUtility.GenerateRandomAlphabeticText(20, 0), 1, MaxStrLen(CategoryCode));
        Description := 'Category Description';
        BuildGroupingCodeXML(TempXMLBuffer, CategoryCode, Description, 'ACC001', 'Account 1');

        // [WHEN] Import standard accounts with grouping codes
        CleanupMappingData();
        ImportGroupingCodes(TempXMLBuffer);

        // [THEN] Category is stored with No. = CategoryCode and Extended No. is empty
        VerifyStandardAccountCategory(CategoryCode, Description, '');
    end;

    [Test]
    procedure ImportGroupingCodeWith21CharsGeneratesAutoNo()
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        ExtendedCategoryCode: Text[250];
        Description: Text[250];
    begin
        // [SCENARIO] Import a grouping code with 21 characters generates CAT000001 and stores original in Extended No.
        // [GIVEN] XML buffer with a 21-character category code
        ExtendedCategoryCode := LibraryUtility.GenerateRandomAlphabeticText(21, 0);
        Description := 'Extended Category';
        BuildGroupingCodeXML(TempXMLBuffer, ExtendedCategoryCode, Description, 'ACC001', 'Account 1');

        // [WHEN] Import standard accounts with grouping codes
        CleanupMappingData();
        ImportGroupingCodes(TempXMLBuffer);

        // [THEN] Category is stored with No. = CAT000001 and Extended No. = original value
        VerifyStandardAccountCategory('CAT000001', Description, ExtendedCategoryCode);
    end;

    [Test]
    procedure ImportMultipleLongCategoriesGeneratesSequentialNos()
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        ExtendedCode1, ExtendedCode2, ExtendedCode3 : Text[100];
    begin
        // [SCENARIO] Import multiple long category codes generates sequential CAT numbers
        // [GIVEN] XML buffer with three long category codes
        ExtendedCode1 := LibraryUtility.GenerateRandomAlphabeticText(30, 0);
        ExtendedCode2 := LibraryUtility.GenerateRandomAlphabeticText(30, 0);
        ExtendedCode3 := LibraryUtility.GenerateRandomAlphabeticText(30, 0);

        BuildMultipleGroupingCodesXML(TempXMLBuffer, ExtendedCode1, ExtendedCode2, ExtendedCode3);

        // [WHEN] Import standard accounts with grouping codes
        CleanupMappingData();
        ImportGroupingCodes(TempXMLBuffer);

        // [THEN] Categories are stored with sequential CAT numbers
        VerifyStandardAccountCategory('CAT000001', 'Desc 1', ExtendedCode1);
        VerifyStandardAccountCategory('CAT000002', 'Desc 2', ExtendedCode2);
        VerifyStandardAccountCategory('CAT000003', 'Desc 3', ExtendedCode3);
    end;

    [Test]
    procedure ImportMixedLengthCategoriesHandledCorrectly()
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        ShortCode: Code[20];
        LongCode: Text[100];
    begin
        // [SCENARIO] Import mix of short (<=20) and long (>20) category codes handles both correctly
        // [GIVEN] XML buffer with one short and one long category code
        ShortCode := CopyStr(LibraryUtility.GenerateRandomAlphabeticText(15, 0), 1, MaxStrLen(ShortCode));
        LongCode := LibraryUtility.GenerateRandomAlphabeticText(50, 0);

        BuildMixedGroupingCodesXML(TempXMLBuffer, ShortCode, LongCode);

        // [WHEN] Import standard accounts with grouping codes
        CleanupMappingData();
        ImportGroupingCodes(TempXMLBuffer);

        // [THEN] Short code stored in No. field, long code generates CAT number
        VerifyStandardAccountCategory(ShortCode, 'Short Desc', '');
        VerifyStandardAccountCategory('CAT000001', 'Long Desc', LongCode);
    end;

    [Test]
    procedure ImportSameLongCategoryMultipleTimesReusesNo()
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        StandardAccountCategory: Record "Standard Account Category";
        StandardAccount: Record "Standard Account";
        ExtendedCategoryCode: Text[100];
    begin
        // [SCENARIO] Import same long category code multiple times reuses the generated CAT number
        // [GIVEN] XML buffer with same long category code for multiple accounts
        ExtendedCategoryCode := LibraryUtility.GenerateRandomAlphabeticText(50, 0);
        BuildRepeatedGroupingCodeXML(TempXMLBuffer, ExtendedCategoryCode, 'Category Desc', 'ACC001', 'ACC002', 'ACC003');

        // [WHEN] Import standard accounts with grouping codes
        CleanupMappingData();
        ImportGroupingCodes(TempXMLBuffer);

        // [THEN] Only one category record exists with CAT000001
        StandardAccountCategory.SetRange("Standard Account Type", "Standard Account Type"::"Standard Account SAF-T");
        Assert.AreEqual(1, StandardAccountCategory.Count, 'Expected exactly one category record');
        VerifyStandardAccountCategory('CAT000001', 'Category Desc', ExtendedCategoryCode);

        // [THEN] All three accounts are linked to CAT000001
        StandardAccount.SetRange(Type, "Standard Account Type"::"Standard Account SAF-T");
        StandardAccount.SetRange("Category No.", 'CAT000001');
        Assert.AreEqual(3, StandardAccount.Count, 'Expected three accounts linked to the category');
    end;

    [Test]
    procedure ImportShortCategoryAfterLongCategoryContinuesSequence()
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        LongCode1, LongCode2 : Text[100];
        ShortCode: Code[20];
    begin
        // [SCENARIO] Import long category, then short, then long again maintains correct sequence
        // [GIVEN] XML buffer with alternating long and short category codes
        LongCode1 := LibraryUtility.GenerateRandomAlphabeticText(40, 0);
        ShortCode := CopyStr(LibraryUtility.GenerateRandomAlphabeticText(10, 0), 1, MaxStrLen(ShortCode));
        LongCode2 := LibraryUtility.GenerateRandomAlphabeticText(40, 0);

        BuildAlternatingGroupingCodesXML(TempXMLBuffer, LongCode1, ShortCode, LongCode2);

        // [WHEN] Import standard accounts with grouping codes
        CleanupMappingData();
        ImportGroupingCodes(TempXMLBuffer);

        // [THEN] Long codes get CAT000001 and CAT000002, short code uses its value
        VerifyStandardAccountCategory('CAT000001', 'Long Desc 1', LongCode1);
        VerifyStandardAccountCategory(ShortCode, 'Short Desc', '');
        VerifyStandardAccountCategory('CAT000002', 'Long Desc 2', LongCode2);
    end;

    [Test]
    procedure ImportWithCategoryDescriptionNodeSkipped()
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        ExtendedCategoryCode: Text[100];
    begin
        // [SCENARIO] Import handles CategoryDescription node correctly for long category codes
        // [GIVEN] XML buffer with CategoryDescription node and long category code
        ExtendedCategoryCode := LibraryUtility.GenerateRandomAlphabeticText(50, 0);
        BuildGroupingCodeXMLWithCategoryDescription(TempXMLBuffer, ExtendedCategoryCode, 'Category Desc', 'Extra Desc', 'ACC001', 'Account 1');

        // [WHEN] Import standard accounts with grouping codes
        CleanupMappingData();
        ImportGroupingCodes(TempXMLBuffer);

        // [THEN] Category is stored correctly, CategoryDescription node is skipped
        VerifyStandardAccountCategory('CAT000001', 'Category Desc', ExtendedCategoryCode);
    end;

    [Test]
    procedure ImportUpdatesExistingCategoryWithLongCode()
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        StandardAccountCategory: Record "Standard Account Category";
        ExtendedCategoryCode: Text[100];
    begin
        // [SCENARIO] Re-importing same long category code updates existing record
        // [GIVEN] Existing category with CAT000001
        CleanupMappingData();
        ExtendedCategoryCode := LibraryUtility.GenerateRandomAlphabeticText(50, 0);

        StandardAccountCategory.Init();
        StandardAccountCategory."Standard Account Type" := "Standard Account Type"::"Standard Account SAF-T";
        StandardAccountCategory."No." := 'CAT000001';
        StandardAccountCategory.Description := 'Old Description';
        StandardAccountCategory."Extended No." := ExtendedCategoryCode;
        StandardAccountCategory.Insert();

        // [GIVEN] XML buffer with same extended code but different description
        BuildGroupingCodeXML(TempXMLBuffer, ExtendedCategoryCode, 'New Description', 'ACC001', 'Account 1');

        // [WHEN] Import standard accounts with grouping codes
        ImportGroupingCodes(TempXMLBuffer);

        // [THEN] Category description is updated
        StandardAccountCategory.Get("Standard Account Type"::"Standard Account SAF-T", 'CAT000001');
        Assert.AreEqual('New Description', StandardAccountCategory.Description, 'Description should be updated');
    end;

    [Test]
    procedure ImportAccountsLinkedToCorrectCategory()
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        StandardAccount: Record "Standard Account";
        ExtendedCategoryCode: Text[100];
    begin
        // [SCENARIO] Imported accounts are correctly linked to their category
        // [GIVEN] XML buffer with long category code and multiple accounts
        ExtendedCategoryCode := LibraryUtility.GenerateRandomAlphabeticText(50, 0);
        BuildRepeatedGroupingCodeXML(TempXMLBuffer, ExtendedCategoryCode, 'Category', 'ACC001', 'ACC002', 'ACC003');

        // [WHEN] Import standard accounts with grouping codes
        CleanupMappingData();
        ImportGroupingCodes(TempXMLBuffer);

        // [THEN] Each account is linked to CAT000001
        StandardAccount.Get("Standard Account Type"::"Standard Account SAF-T", 'CAT000001', 'ACC001');
        StandardAccount.Get("Standard Account Type"::"Standard Account SAF-T", 'CAT000001', 'ACC002');
        StandardAccount.Get("Standard Account Type"::"Standard Account SAF-T", 'CAT000001', 'ACC003');
    end;

    [Test]
    procedure ImportPreservesAccountDescriptions()
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        StandardAccount: Record "Standard Account";
        ExtendedCategoryCode: Text[100];
    begin
        // [SCENARIO] Account descriptions are preserved during import with long category codes
        // [GIVEN] XML buffer with long category code
        ExtendedCategoryCode := LibraryUtility.GenerateRandomAlphabeticText(50, 0);
        BuildGroupingCodeXML(TempXMLBuffer, ExtendedCategoryCode, 'Category Desc', 'ACC001', 'Account Description 1');

        // [WHEN] Import standard accounts with grouping codes
        CleanupMappingData();
        ImportGroupingCodes(TempXMLBuffer);

        // [THEN] Account description is preserved
        StandardAccount.Get("Standard Account Type"::"Standard Account SAF-T", 'CAT000001', 'ACC001');
        Assert.AreEqual('Account Description 1', StandardAccount.Description, 'Account description should be preserved');
    end;

    [Test]
    procedure ExtendedNoExceeds256CharsThrowsError()
    var
        GLAccountMappingHeader: Record "G/L Account Mapping Header";
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        StandardAccountCategory: Record "Standard Account Category";
        AuditFileExportHeader: Record "Audit File Export Header";
        AuditDataCheckSAFT: Codeunit "Audit Data Check SAF-T";
        ExtendedNo257Chars: Text[500];
    begin
        // [FEATURE] [AI test]
        // [SCENARIO] CheckExtendedCategoryNoLengthNotExceed256Chars throws error when Extended No. exceeds 256 characters

        // [GIVEN] Standard Account Category "C" with Extended No. containing 257 characters
        CleanupMappingData();
        ExtendedNo257Chars := PadStr('', 257, 'X');

        StandardAccountCategory.Init();
        StandardAccountCategory."Standard Account Type" := "Standard Account Type"::"Standard Account SAF-T";
        StandardAccountCategory."No." := 'CAT000001';
        StandardAccountCategory.Description := 'Test Category';
        StandardAccountCategory."Extended No." := ExtendedNo257Chars;
        StandardAccountCategory.Insert();

        // [GIVEN] G/L Account Mapping Header with mapping line referencing category "C"
        CreateGLAccountMappingWithCategoryLine(GLAccountMappingHeader, GLAccountMappingLine, 'CAT000001');

        // [GIVEN] Audit File Export Header with the mapping code
        AuditFileExportHeader.Init();
        AuditFileExportHeader.Insert(true);
        AuditFileExportHeader."G/L Account Mapping Code" := GLAccountMappingHeader.Code;
        AuditFileExportHeader."Starting Date" := WorkDate();
        AuditFileExportHeader."Ending Date" := WorkDate();
        AuditFileExportHeader.Modify();

        // [WHEN] CheckAuditDocReadyToExport is called
        asserterror AuditDataCheckSAFT.CheckAuditDocReadyToExport(AuditFileExportHeader);

        // [THEN] Error is thrown indicating Extended No. exceeds 256 characters
        Assert.ExpectedError('The Extended No. field cannot exceed 256 characters');
    end;

    local procedure CreateGLAccountMappingWithCategoryLine(var GLAccountMappingHeader: Record "G/L Account Mapping Header"; var GLAccountMappingLine: Record "G/L Account Mapping Line"; CategoryNo: Code[20])
    var
        StandardAccount: Record "Standard Account";
    begin
        GLAccountMappingHeader.Init();
        GLAccountMappingHeader.Code := LibraryUtility.GenerateGUID();
        GLAccountMappingHeader."Standard Account Type" := "Standard Account Type"::"Standard Account SAF-T";
        GLAccountMappingHeader."Starting Date" := WorkDate();
        GLAccountMappingHeader."Ending Date" := WorkDate();
        GLAccountMappingHeader.Insert();

        // Create a Standard Account linked to the category
        StandardAccount.Init();
        StandardAccount.Type := "Standard Account Type"::"Standard Account SAF-T";
        StandardAccount."Category No." := CategoryNo;
        StandardAccount."No." := 'STDACC001';
        StandardAccount.Description := 'Test Standard Account';
        StandardAccount.Insert();

        GLAccountMappingLine.Init();
        GLAccountMappingLine."G/L Account Mapping Code" := GLAccountMappingHeader.Code;
        GLAccountMappingLine."G/L Account No." := LibraryUtility.GenerateGUID();
        GLAccountMappingLine."Standard Account Type" := "Standard Account Type"::"Standard Account SAF-T";
        GLAccountMappingLine."Standard Account Category No." := CategoryNo;
        GLAccountMappingLine."Standard Account No." := StandardAccount."No.";
        GLAccountMappingLine.Insert();
    end;

    local procedure BuildGroupingCodeXML(var TempXMLBuffer: Record "XML Buffer" temporary; CategoryCode: Text; CategoryDesc: Text; AccountNo: Text; AccountDesc: Text)
    var
        XmlText: Text;
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.DeleteAll();

        XmlText := StrSubstNo(
            '<Root><GroupingCode><CategoryCode>%1</CategoryCode><CategoryDescription>%2</CategoryDescription><AccountNo>%3</AccountNo><AccountDescription>%4</AccountDescription></GroupingCode></Root>',
            CategoryCode, CategoryDesc, AccountNo, AccountDesc);
        TempXMLBuffer.LoadFromText(XmlText);

        TempXMLBuffer.FindNodesByXPath(TempXMLBuffer, '/Root/GroupingCode');
    end;

    local procedure BuildGroupingCodeXMLWithCategoryDescription(var TempXMLBuffer: Record "XML Buffer" temporary; CategoryCode: Text; CategoryDesc: Text; ExtraDesc: Text; AccountNo: Text; AccountDesc: Text)
    var
        XmlText: Text;
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.DeleteAll();

        // Include extra CategoryDescription node to test skipping
        XmlText := StrSubstNo(
            '<Root><GroupingCode><CategoryCode>%1</CategoryCode><CategoryDescription>%2</CategoryDescription><CategoryDescription>%3</CategoryDescription><AccountNo>%4</AccountNo><AccountDescription>%5</AccountDescription></GroupingCode></Root>',
            CategoryCode, CategoryDesc, ExtraDesc, AccountNo, AccountDesc);
        TempXMLBuffer.LoadFromText(XmlText);

        TempXMLBuffer.FindNodesByXPath(TempXMLBuffer, '/Root/GroupingCode');
    end;

    local procedure BuildMultipleGroupingCodesXML(var TempXMLBuffer: Record "XML Buffer" temporary; Code1: Text; Code2: Text; Code3: Text)
    var
        XmlText: Text;
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.DeleteAll();

        XmlText := '<Root>' +
            StrSubstNo('<GroupingCode><CategoryCode>%1</CategoryCode><CategoryDescription>Desc 1</CategoryDescription><AccountNo>ACC001</AccountNo><AccountDescription>Account 1</AccountDescription></GroupingCode>', Code1) +
            StrSubstNo('<GroupingCode><CategoryCode>%1</CategoryCode><CategoryDescription>Desc 2</CategoryDescription><AccountNo>ACC002</AccountNo><AccountDescription>Account 2</AccountDescription></GroupingCode>', Code2) +
            StrSubstNo('<GroupingCode><CategoryCode>%1</CategoryCode><CategoryDescription>Desc 3</CategoryDescription><AccountNo>ACC003</AccountNo><AccountDescription>Account 3</AccountDescription></GroupingCode>', Code3) +
            '</Root>';
        TempXMLBuffer.LoadFromText(XmlText);

        TempXMLBuffer.FindNodesByXPath(TempXMLBuffer, '/Root/GroupingCode');
    end;

    local procedure BuildMixedGroupingCodesXML(var TempXMLBuffer: Record "XML Buffer" temporary; ShortCode: Code[20]; LongCode: Text)
    var
        XmlText: Text;
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.DeleteAll();

        XmlText := '<Root>' +
            StrSubstNo('<GroupingCode><CategoryCode>%1</CategoryCode><CategoryDescription>Short Desc</CategoryDescription><AccountNo>ACC001</AccountNo><AccountDescription>Account 1</AccountDescription></GroupingCode>', ShortCode) +
            StrSubstNo('<GroupingCode><CategoryCode>%1</CategoryCode><CategoryDescription>Long Desc</CategoryDescription><AccountNo>ACC002</AccountNo><AccountDescription>Account 2</AccountDescription></GroupingCode>', LongCode) +
            '</Root>';
        TempXMLBuffer.LoadFromText(XmlText);

        TempXMLBuffer.FindNodesByXPath(TempXMLBuffer, '/Root/GroupingCode');
    end;

    local procedure BuildAlternatingGroupingCodesXML(var TempXMLBuffer: Record "XML Buffer" temporary; LongCode1: Text; ShortCode: Code[20]; LongCode2: Text)
    var
        XmlText: Text;
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.DeleteAll();

        XmlText := '<Root>' +
            StrSubstNo('<GroupingCode><CategoryCode>%1</CategoryCode><CategoryDescription>Long Desc 1</CategoryDescription><AccountNo>ACC001</AccountNo><AccountDescription>Account 1</AccountDescription></GroupingCode>', LongCode1) +
            StrSubstNo('<GroupingCode><CategoryCode>%1</CategoryCode><CategoryDescription>Short Desc</CategoryDescription><AccountNo>ACC002</AccountNo><AccountDescription>Account 2</AccountDescription></GroupingCode>', ShortCode) +
            StrSubstNo('<GroupingCode><CategoryCode>%1</CategoryCode><CategoryDescription>Long Desc 2</CategoryDescription><AccountNo>ACC003</AccountNo><AccountDescription>Account 3</AccountDescription></GroupingCode>', LongCode2) +
            '</Root>';
        TempXMLBuffer.LoadFromText(XmlText);

        TempXMLBuffer.FindNodesByXPath(TempXMLBuffer, '/Root/GroupingCode');
    end;

    local procedure BuildRepeatedGroupingCodeXML(var TempXMLBuffer: Record "XML Buffer" temporary; CategoryCode: Text; CategoryDesc: Text; AccountNo1: Text; AccountNo2: Text; AccountNo3: Text)
    var
        XmlText: Text;
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.DeleteAll();

        XmlText := '<Root>' +
            StrSubstNo('<GroupingCode><CategoryCode>%1</CategoryCode><CategoryDescription>%2</CategoryDescription><AccountNo>%3</AccountNo><AccountDescription>Account 1</AccountDescription></GroupingCode>', CategoryCode, CategoryDesc, AccountNo1) +
            StrSubstNo('<GroupingCode><CategoryCode>%1</CategoryCode><CategoryDescription>%2</CategoryDescription><AccountNo>%3</AccountNo><AccountDescription>Account 2</AccountDescription></GroupingCode>', CategoryCode, CategoryDesc, AccountNo2) +
            StrSubstNo('<GroupingCode><CategoryCode>%1</CategoryCode><CategoryDescription>%2</CategoryDescription><AccountNo>%3</AccountNo><AccountDescription>Account 3</AccountDescription></GroupingCode>', CategoryCode, CategoryDesc, AccountNo3) +
            '</Root>';
        TempXMLBuffer.LoadFromText(XmlText);

        TempXMLBuffer.FindNodesByXPath(TempXMLBuffer, '/Root/GroupingCode');
    end;

    local procedure ImportGroupingCodes(var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        ImportAuditDataMgt: Codeunit "Import Audit Data Mgt.";
    begin
        ImportAuditDataMgt.ImportStandardAccountsWithGroupingCodesFromXMLBuffer(TempXMLBuffer, "Standard Account Type"::"Standard Account SAF-T");
    end;

    local procedure CleanupMappingData()
    var
        StandardAccountCategory: Record "Standard Account Category";
        StandardAccount: Record "Standard Account";
    begin
        StandardAccountCategory.SetRange("Standard Account Type", "Standard Account Type"::"Standard Account SAF-T");
        StandardAccountCategory.DeleteAll(true);

        StandardAccount.SetRange(Type, "Standard Account Type"::"Standard Account SAF-T");
        StandardAccount.DeleteAll();
    end;

    local procedure VerifyStandardAccountCategory(ExpectedNo: Code[20]; ExpectedDescription: Text; ExpectedExtendedNo: Text)
    var
        StandardAccountCategory: Record "Standard Account Category";
    begin
        StandardAccountCategory.Get("Standard Account Type"::"Standard Account SAF-T", ExpectedNo);
        Assert.AreEqual(ExpectedDescription, StandardAccountCategory.Description, StrSubstNo('Description mismatch for category %1', ExpectedNo));
        Assert.AreEqual(ExpectedExtendedNo, StandardAccountCategory."Extended No.", StrSubstNo('Extended No. mismatch for category %1', ExpectedNo));
    end;
}
