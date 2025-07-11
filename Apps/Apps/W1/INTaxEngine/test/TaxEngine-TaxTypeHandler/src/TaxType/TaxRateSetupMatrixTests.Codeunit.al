codeunit 136802 "Tax Rate Setup Matrix Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Tax Rate Setup Matrix] [UT]
    end;

    var
        Assert: Codeunit Assert;

    [Test]
    [HandlerFunctions('TaxRatesPageHandler')]
    procedure TestInitializeTaxRates()
    var
        TaxRate: Record "Tax Rate";
        TaxRateValue: Record "Tax Rate Value";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        TaxRates: Page "Tax Rates";
        Type: Option Option,Text,Integer,Decimal,Boolean,Date;
        VATBusPostingGrpID, VATProdPostingGrpID, VATComponentID, RateSetupCol1, RateSetupCol2, RateSetupCol3, RateSetupCol4 : Integer;
    begin
        // [SCENARIO] To check if Tax Rates are created 

        // [GIVEN] There should be a Tax Rate Column Setup
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        LibraryTaxTypeTests.CreateTaxEntntiy('VAT', Database::"VAT Business Posting Group", 'VAT Business Posting Group', false);
        LibraryTaxTypeTests.CreateTaxEntntiy('VAT', Database::"VAT Product Posting Group", 'VAT Product Posting Group', false);

        VATBusPostingGrpID := LibraryTaxTypeTests.CreateTaxAttribute('VAT', 'VATBusPostingGrp', Type::Text, Database::"VAT Business Posting Group", 1, Page::"VAT Business Posting Groups", false);
        VATProdPostingGrpID := LibraryTaxTypeTests.CreateTaxAttribute('VAT', 'VATProdPostingGrp', Type::Text, Database::"VAT Product Posting Group", 1, Page::"VAT Product Posting Groups", false);

        VATComponentID := LibraryTaxTypeTests.CreateComponent('VAT', 'VAT', "Rounding Direction"::Nearest, 1, false);

        RateSetupCol1 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::"Tax Attributes", VATBusPostingGrpID, 1, Type::Text, 0, 'VATBusPostingGrp');
        RateSetupCol2 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::"Tax Attributes", VATProdPostingGrpID, 2, Type::Text, 0, 'VATProdPostingGrp');
        RateSetupCol3 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::"Range From", 0, 3, Type::Date, 0, 'Effective From');
        RateSetupCol4 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::Component, VATComponentID, 4, Type::Decimal, 0, 'VAT');

        // [WHEN] The Tax Rates page is opened for entering tax Rates
        TaxRate.SetRange("Tax Type", 'VAT');
        TaxRates.SetTaxType('VAT');
        TaxRates.SetTableView(TaxRate);
        TaxRates.RunModal();

        // [THEN] it should craete a record Tax Rate Value table
        TaxRateValue.SetRange("Tax Type", 'VAT');
        TaxRateValue.SetRange("Column ID", RateSetupCol1);
        Assert.RecordIsNotEmpty(TaxRateValue);
    end;

    [Test]
    [HandlerFunctions('TaxRatesPageLookupHandler,VATBusPostingGrpHandler')]
    procedure TestUpdateTaxRates()
    var
        TaxRate: Record "Tax Rate";
        TaxRateValue: Record "Tax Rate Value";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        TaxRates: Page "Tax Rates";
        Type: Option Option,Text,Integer,Decimal,Boolean,Date;
        VATBusPostingGrpID, VATProdPostingGrpID, VATComponentID, RateSetupCol1, RateSetupCol2, RateSetupCol3, RateSetupCol4 : Integer;
    begin
        // [SCENARIO] To check if Tax Rates are updated 

        // [GIVEN] There should be a Tax Rate Column Setup
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        LibraryTaxTypeTests.CreateTaxEntntiy('VAT', Database::"VAT Business Posting Group", 'VAT Business Posting Group', false);
        LibraryTaxTypeTests.CreateTaxEntntiy('VAT', Database::"VAT Product Posting Group", 'VAT Product Posting Group', false);

        VATBusPostingGrpID := LibraryTaxTypeTests.CreateTaxAttribute('VAT', 'VATBusPostingGrp', Type::Text, Database::"VAT Business Posting Group", 1, Page::"VAT Business Posting Groups", false);
        VATProdPostingGrpID := LibraryTaxTypeTests.CreateTaxAttribute('VAT', 'VATProdPostingGrp', Type::Text, Database::"VAT Product Posting Group", 1, Page::"VAT Product Posting Groups", false);

        VATComponentID := LibraryTaxTypeTests.CreateComponent('VAT', 'VAT', "Rounding Direction"::Nearest, 1, false);

        RateSetupCol1 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::"Tax Attributes", VATBusPostingGrpID, 1, Type::Text, 0, 'VATBusPostingGrp');
        RateSetupCol2 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::"Tax Attributes", VATProdPostingGrpID, 2, Type::Text, 0, 'VATProdPostingGrp');
        RateSetupCol3 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::"Range From", 0, 3, Type::Date, 0, 'Effective From');
        RateSetupCol4 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::Component, VATComponentID, 4, Type::Decimal, 0, 'VAT');

        // [WHEN] The Tax Rates page is opened for entering tax Rates
        TaxRate.SetRange("Tax Type", 'VAT');
        TaxRate.DeleteAll();
        TaxRates.SetTaxType('VAT');
        TaxRates.SetTableView(TaxRate);
        TaxRates.RunModal();

        // [THEN] It should update the value of VatBusPostginGrp column to something other than DOMESTIC
        TaxRateValue.SetRange("Tax Type", 'VAT');
        TaxRateValue.SetRange("Column ID", RateSetupCol1);
        Assert.AreNotEqual(TaxRateValue.Value, 'DOMESTIC', 'Value should not be DOMESTIC');
    end;

    [Test]
    [HandlerFunctions('TaxRatesPageCountryLookupHandler,CountryCodeHandler')]
    procedure TestUpdateLinkdAttributeOnTaxRates()
    var
        TaxRate: Record "Tax Rate";
        TaxRateValue: Record "Tax Rate Value";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        TaxRates: Page "Tax Rates";
        Type: Option Option,Text,Integer,Decimal,Boolean,Date;
        VATBusPostingGrpID, VATProdPostingGrpID, VATComponentID, CountryID, RateSetupCol1, RateSetupCol2, RateSetupCol3, RateSetupCol4, RateSetupCol5 : Integer;
    begin
        // [SCENARIO] To check if Tax Rates are created for Value column type

        // [GIVEN] There should be a Tax Rate Column Setup
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        LibraryTaxTypeTests.CreateTaxEntntiy('VAT', Database::"VAT Business Posting Group", 'VAT Business Posting Group', false);
        LibraryTaxTypeTests.CreateTaxEntntiy('VAT', Database::"VAT Product Posting Group", 'VAT Product Posting Group', false);

        VATBusPostingGrpID := LibraryTaxTypeTests.CreateTaxAttribute('VAT', 'VATBusPostingGrp', Type::Text, Database::"VAT Business Posting Group", 1, Page::"VAT Business Posting Groups", false);
        VATProdPostingGrpID := LibraryTaxTypeTests.CreateTaxAttribute('VAT', 'VATProdPostingGrp', Type::Text, Database::"VAT Product Posting Group", 1, Page::"VAT Product Posting Groups", false);
        VATProdPostingGrpID := LibraryTaxTypeTests.CreateTaxAttribute('VAT', 'VATProdPostingGrp', Type::Text, Database::"VAT Product Posting Group", 1, Page::"VAT Product Posting Groups", false);
        CountryID := LibraryTaxTypeTests.CreateTaxAttribute('', 'Country', Type::Text, Database::"Country/Region", 1, Page::"Countries/Regions", false);

        VATComponentID := LibraryTaxTypeTests.CreateComponent('VAT', 'VAT', "Rounding Direction"::Nearest, 1, false);

        RateSetupCol1 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::"Tax Attributes", VATBusPostingGrpID, 1, Type::Text, 0, 'VATBusPostingGrp');
        RateSetupCol2 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::"Tax Attributes", VATProdPostingGrpID, 2, Type::Text, 0, 'VATProdPostingGrp');
        RateSetupCol3 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::"Range From", 0, 3, Type::Date, 0, 'Effective From');
        RateSetupCol4 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::Component, VATComponentID, 4, Type::Decimal, 0, 'VAT');
        RateSetupCol5 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::Value, 0, 5, Type::Text, CountryID, 'Country');

        // [WHEN] The Tax Rates page is opened for entering tax Rates
        TaxRate.SetRange("Tax Type", 'VAT');
        TaxRate.DeleteAll(true);
        TaxRates.SetTaxType('VAT');
        TaxRates.SetTableView(TaxRate);
        TaxRates.RunModal();

        // [THEN] it should create a record for Country attribute
        TaxRateValue.SetRange("Tax Type", 'VAT');
        TaxRateValue.SetRange("Column ID", RateSetupCol5);
        Assert.RecordIsNotEmpty(TaxRateValue);
    end;

    [Test]
    [HandlerFunctions('TaxRatesPageRangeHandler')]
    procedure TestUpdateFromAndToRangeAttributeOnTaxRates()
    var
        TaxRate: Record "Tax Rate";
        TaxRateValue: Record "Tax Rate Value";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        TaxRates: Page "Tax Rates";
        Type: Option Option,Text,Integer,Decimal,Boolean,Date;
        VATBusPostingGrpID, VATProdPostingGrpID, VATComponentID, CountryID, RateSetupCol1, RateSetupCol2, RateSetupCol3, RateSetupCol4, RateSetupCol5, RateSetupCol6 : Integer;
    begin
        // [SCENARIO] To check if Tax Rates are created 

        // [GIVEN] There should be a update Tax Rates for From and To Range Attribute
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        LibraryTaxTypeTests.CreateTaxEntntiy('VAT', Database::"VAT Business Posting Group", 'VAT Business Posting Group', false);
        LibraryTaxTypeTests.CreateTaxEntntiy('VAT', Database::"VAT Product Posting Group", 'VAT Product Posting Group', false);

        VATBusPostingGrpID := LibraryTaxTypeTests.CreateTaxAttribute('VAT', 'VATBusPostingGrp', Type::Text, Database::"VAT Business Posting Group", 1, Page::"VAT Business Posting Groups", false);
        VATProdPostingGrpID := LibraryTaxTypeTests.CreateTaxAttribute('VAT', 'VATProdPostingGrp', Type::Text, Database::"VAT Product Posting Group", 1, Page::"VAT Product Posting Groups", false);
        VATProdPostingGrpID := LibraryTaxTypeTests.CreateTaxAttribute('VAT', 'VATProdPostingGrp', Type::Text, Database::"VAT Product Posting Group", 1, Page::"VAT Product Posting Groups", false);
        CountryID := LibraryTaxTypeTests.CreateTaxAttribute('', 'Country', Type::Text, Database::"Country/Region", 1, Page::"Countries/Regions", false);

        VATComponentID := LibraryTaxTypeTests.CreateComponent('VAT', 'VAT', "Rounding Direction"::Nearest, 1, false);

        RateSetupCol1 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::"Tax Attributes", VATBusPostingGrpID, 1, Type::Text, 0, 'VATBusPostingGrp');
        RateSetupCol2 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::"Tax Attributes", VATProdPostingGrpID, 2, Type::Text, 0, 'VATProdPostingGrp');
        RateSetupCol3 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::"Range From", 0, 3, Type::Date, 0, 'Effective From');
        RateSetupCol4 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::Component, VATComponentID, 4, Type::Decimal, 0, 'VAT');
        RateSetupCol5 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::Value, 0, 5, Type::Text, CountryID, 'Country');
        RateSetupCol6 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::"Range From and Range To", 0, 6, Type::Decimal, 0, 'Amount');

        // [WHEN] The Tax Rates page is opened for entering tax Rates
        TaxRate.SetRange("Tax Type", 'VAT');
        TaxRates.SetTaxType('VAT');
        TaxRates.SetTableView(TaxRate);
        TaxRates.RunModal();

        // [THEN] It should have record with column ID in RateSetupCol6.
        TaxRateValue.SetRange("Tax Type", 'VAT');
        TaxRateValue.SetRange("Column ID", RateSetupCol6);
        Assert.RecordIsNotEmpty(TaxRateValue);
    end;


    [Test]
    [HandlerFunctions('TaxRatesPageRangeHandlerForError')]
    procedure TestUpdateFromAndToRangeAttributeForError()
    var
        TaxRate: Record "Tax Rate";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        TaxRates: Page "Tax Rates";
        Type: Option Option,Text,Integer,Decimal,Boolean,Date;
        VATBusPostingGrpID, VATProdPostingGrpID, VATComponentID, CountryID, RateSetupCol1, RateSetupCol2, RateSetupCol3, RateSetupCol4, RateSetupCol5, RateSetupCol6 : Integer;
        DateValueErr: Label 'Validation error for Field: AttributeValue7,  Message = ''%1 should not be less than %2.''', Comment = '%1 = Decimal2 , %2 = Decimal1';
    begin
        // [SCENARIO] To check if Tax Rates is throwing error when wrong range value is entered

        // [GIVEN] There should be a Tax Rate Column Setup
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        LibraryTaxTypeTests.CreateTaxEntntiy('VAT', Database::"VAT Business Posting Group", 'VAT Business Posting Group', false);
        LibraryTaxTypeTests.CreateTaxEntntiy('VAT', Database::"VAT Product Posting Group", 'VAT Product Posting Group', false);

        VATBusPostingGrpID := LibraryTaxTypeTests.CreateTaxAttribute('VAT', 'VATBusPostingGrp', Type::Text, Database::"VAT Business Posting Group", 1, Page::"VAT Business Posting Groups", false);
        VATProdPostingGrpID := LibraryTaxTypeTests.CreateTaxAttribute('VAT', 'VATProdPostingGrp', Type::Text, Database::"VAT Product Posting Group", 1, Page::"VAT Product Posting Groups", false);
        VATProdPostingGrpID := LibraryTaxTypeTests.CreateTaxAttribute('VAT', 'VATProdPostingGrp', Type::Text, Database::"VAT Product Posting Group", 1, Page::"VAT Product Posting Groups", false);
        CountryID := LibraryTaxTypeTests.CreateTaxAttribute('', 'Country', Type::Text, Database::"Country/Region", 1, Page::"Countries/Regions", false);

        VATComponentID := LibraryTaxTypeTests.CreateComponent('VAT', 'VAT', "Rounding Direction"::Nearest, 1, false);

        RateSetupCol1 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::"Tax Attributes", VATBusPostingGrpID, 1, Type::Text, 0, 'VATBusPostingGrp');
        RateSetupCol2 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::"Tax Attributes", VATProdPostingGrpID, 2, Type::Text, 0, 'VATProdPostingGrp');
        RateSetupCol3 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::"Range From", 0, 3, Type::Date, 0, 'Effective From');
        RateSetupCol4 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::Component, VATComponentID, 4, Type::Decimal, 0, 'VAT');
        RateSetupCol5 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::Value, 0, 5, Type::Text, CountryID, 'Country');
        RateSetupCol6 := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::"Range From and Range To", 0, 6, Type::Decimal, 0, 'Amount');

        // [WHEN] The Tax Rates page is opened for entering tax Rates
        TaxRate.SetRange("Tax Type", 'VAT');
        TaxRates.SetTaxType('VAT');
        TaxRates.SetTableView(TaxRate);
        TaxRates.RunModal();

        // [THEN] Table ID should It should throw an error for entering from Amount as 2000 and To Amount as 1000
        Assert.AreEqual(GetLastErrorText, StrSubstNo(DateValueErr, '1,000', '2,000'), 'wrong error meesage');
    end;

    [ModalPageHandler]
    procedure TaxRatesPageHandler(var TaxRates: TestPage "Tax Rates")
    begin
        TaxRates.New();
        TaxRates.AttributeValue1.SetValue('DOMESTIC');
        TaxRates.AttributeValue2.SetValue('NO VAT');
        TaxRates.AttributeValue3.SetValue('t');
        TaxRates.AttributeValue4.SetValue('2');
    end;

    [Test]
    procedure TestUpdateTaxAttributeFactbox()
    var
        Customer: Record Customer;
        RecordAttributeMapping: Record "Record Attribute Mapping";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        TaxAttributeMgmt: Codeunit "Tax Attribute Management";
        AttributeID: Integer;
        Type: Option Option,Text,Integer,Decimal,Boolean,Date;
    begin
        // [SCENARIO] To check if function UpdateTaxAttributeFactbox is updating Record Attribute Mapping tables

        // [GIVEN] There should be a Tax Attribute created 
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        AttributeID := LibraryTaxTypeTests.CreateTaxAttribute('VAT', 'VATBusPostingGrp', Type::Text, Database::"VAT Business Posting Group", 1, Page::"VAT Business Posting Groups", false);
        LibraryTaxTypeTests.CreateEntityAttributeMapping(AttributeID, Database::Customer);
        Customer.FindFirst();

        // [WHEN] when function UpdateTaxAttributeFactbox is called
        TaxAttributeMgmt.UpdateTaxAttributeFactbox(Customer);

        // [THEN] it should craete a new record in "Record Attribute Mapping" table
        RecordAttributeMapping.SetRange("Attribute Record ID", Customer.RecordId());
        Assert.RecordIsNotEmpty(RecordAttributeMapping);
    end;

    [Test]
    procedure TestGetAttributeOptionText()
    var
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        TaxAttributeMgmt: Codeunit "Tax Attribute Management";
        AttributeID: Integer;
        Type: Option Option,Text,Integer,Decimal,Boolean,Date;
        AttributeValue: Text;
    begin
        // [SCENARIO] To check if function GetAttributeOptionText returns correct option value

        // [GIVEN] There should be a Tax Attribute created 
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        AttributeID := LibraryTaxTypeTests.CreateTaxAttribute('VAT', 'VATBusPostingGrp', Type::Text, Database::"VAT Business Posting Group", 1, Page::"VAT Business Posting Groups", false);
        LibraryTaxTypeTests.CreateTaxAttributeValue(AttributeID, 1, 'Value 1');

        // [WHEN] when function GetAttributeOptionText is called
        AttributeValue := TaxAttributeMgmt.GetAttributeOptionText('', AttributeID, 1);

        // [THEN] it should return value 1 as the option value
        Assert.AreEqual('Value 1', AttributeValue, 'option should be Value 1');
    end;

    [Test]
    procedure TestGetAttributeOptionIndex()
    var
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        TaxAttributeMgmt: Codeunit "Tax Attribute Management";
        AttributeID: Integer;
        Type: Option Option,Text,Integer,Decimal,Boolean,Date;
        AttributeValueIndex: Integer;
    begin
        // [SCENARIO] To check if function GetAttributeOptionIndex returns correct option Index

        // [GIVEN] There should be a Tax Attribute created 
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        AttributeID := LibraryTaxTypeTests.CreateTaxAttribute('VAT', 'VATBusPostingGrp', Type::Text, Database::"VAT Business Posting Group", 1, Page::"VAT Business Posting Groups", false);
        LibraryTaxTypeTests.CreateTaxAttributeValue(AttributeID, 1, 'Value 1');

        // [WHEN] when function GetAttributeOptionIndex is called
        AttributeValueIndex := TaxAttributeMgmt.GetAttributeOptionIndex('', AttributeID, 'Value 1');

        // [THEN] it should return 1 as the option Index
        Assert.AreEqual(1, AttributeValueIndex, 'option index be 1');
    end;

    [Test]
    [HandlerFunctions('TaxAttributeValuesHandler')]
    procedure TestGetAttributeOptionValue()
    var
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        TaxAttributeMgmt: Codeunit "Tax Attribute Management";
        AttributeID: Integer;
        Type: Option Option,Text,Integer,Decimal,Boolean,Date;
        AttributeValue: Text[250];
    begin
        // [SCENARIO] To check if function GetAttributeOptionValue returns correct value

        // [GIVEN] There should be a Tax Attribute created 
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        AttributeID := LibraryTaxTypeTests.CreateTaxAttribute('VAT', 'OrderStatus', Type::Option, Database::"Sales Header", 1, 0, false);
        LibraryTaxTypeTests.CreateTaxAttributeValue(AttributeID, 1, 'Value 1');

        // [WHEN] when function GetAttributeOptionValue is called
        TaxAttributeMgmt.GetAttributeOptionValue('VAT', AttributeID, AttributeValue);

        // [THEN] it should return value 1 
        Assert.AreEqual('Quote', AttributeValue, 'option should be Value 1');
    end;

    [ModalPageHandler]
    procedure TaxRatesPageLookupHandler(var TaxRates: TestPage "Tax Rates")
    begin
        TaxRates.First();
        TaxRates.AttributeValue1.Lookup();
    end;

    [ModalPageHandler]
    procedure TaxAttributeValuesHandler(var TaxAttributeValues: TestPage "Tax Attribute Values")
    begin
        TaxAttributeValues.OK().Invoke();
    end;


    [ModalPageHandler]
    procedure TaxRatesPageCountryLookupHandler(var TaxRates: TestPage "Tax Rates")
    begin
        TaxRates.New();
        TaxRates.AttributeValue1.SetValue('DOMESTIC');
        TaxRates.AttributeValue2.SetValue('NO VAT');
        TaxRates.AttributeValue3.SetValue('10202020D');
        TaxRates.AttributeValue4.SetValue('2');
        TaxRates.AttributeValue5.Lookup();
    end;

    [ModalPageHandler]
    procedure TaxRatesPageRangeHandler(var TaxRates: TestPage "Tax Rates")
    begin
        TaxRates.New();
        TaxRates.AttributeValue1.SetValue('DOMESTIC');
        TaxRates.AttributeValue2.SetValue('NO VAT');
        TaxRates.AttributeValue3.SetValue('10202020D');
        TaxRates.AttributeValue4.SetValue('2');
        TaxRates.AttributeValue5.SetValue('US');
        TaxRates.AttributeValue6.SetValue('1000');
        TaxRates.AttributeValue7.SetValue('2000');
    end;

    [ModalPageHandler]
    procedure TaxRatesPageRangeHandlerForError(var TaxRates: TestPage "Tax Rates")
    begin
        TaxRates.New();
        TaxRates.AttributeValue1.SetValue('DOMESTIC');
        TaxRates.AttributeValue2.SetValue('NO VAT');
        TaxRates.AttributeValue3.SetValue('10202020D');
        TaxRates.AttributeValue4.SetValue('2');
        TaxRates.AttributeValue5.SetValue('US');
        TaxRates.AttributeValue6.SetValue('2000');
        asserterror TaxRates.AttributeValue7.SetValue('1000');
    end;

    [ModalPageHandler]
    procedure VATBusPostingGrpHandler(var VatBusPostingGroup: TestPage "VAT Business Posting Groups")
    begin
        VatBusPostingGroup.Filter.SetFilter(Description, '<>DOMESTIC');
        VatBusPostingGroup.First();
        VatBusPostingGroup.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CountryCodeHandler(var Countries: TestPage "Countries/Regions")
    begin
        Countries.First();
        Countries.OK().Invoke();
    end;
}