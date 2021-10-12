codeunit 137700 "Json Exchange and Exec. Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Json Exchange and Exec. Tests] [UT]
    end;

    var
        Assert: Codeunit Assert;
        TaxConfigTestHelper: Codeunit "Tax Config. Test Helper";
        UseCaseTreeIndent: Codeunit "Use Case Tree-Indent";
        LibrarySales: Codeunit "Library - Sales";
        JsonDeserialization: Codeunit "Tax Json Deserialization";
        EmptyGuid: Guid;
        CaseID: Guid;
        RHSLookup: Boolean;
        LHSLookup: Boolean;
        IsComponentFormulaLookup: Boolean;
        TaxTypeLbl: Label 'VAT';

    [Test]
    [HandlerFunctions('TaxTypePageHandler,RateSetupPageHandler,TaxAttributesPageHandler,TaxComponentsPageHandler,TaxEntitiesPageHandler,TaxTypePageHandler,TaxRatePageHandler,UseCasePageHandler,UseCaseConditionHandler,UseCaseConditionLookup,UseCaseConditionTableFilter,ComputationScriptHandler,ScriptVariablesHandler,InsertRecordHandler,TaxPostingSetupHandler,AttributeMappingSwitchStatementHandler,FieldLookupHandler,ArchivalLogsHandler,ScriptSymbolHandler,UseCaseRestoreCnfrmHandler,LoopThruRecordHandler,UseCaseCardPageHandler,ActionStringExprHandler,ActionRoundNumberHandler,ActionReplaceSubstringDlgHandler,ActionNumberExpressionHandler,ActionNumberCalculationHandler,ActionMessageHandler,ActionLengthOfStringHandler,ActionFindSubStringInStringHandler,ActionFindIntervalBetDateHandler,ActionExtractSubStringFrmPosHandler,ActionExtractSubStringFrmIndexHandler,ActionExtractDatePartHandler,ActionDateToDateTimeHandler,DateCalculationHandler,ConvertCaseHandler,ComponentExpreHandler,ComponentFormulaExpHandler,TaxComponentsModalPageHandler,TaxAttributeValuesHandler,TaxAttributeValuesModalHandler,TaxEntitiesHandler')]
    procedure TestCreateTaxConfigFromUI()
    begin
        Page.Run(Page::"Tax Types");
    end;

    [Test]
    [HandlerFunctions('UseCaseMsgHandler')]
    procedure TestImportTaxTypes()
    var
        TaxType: Record "Tax Type";
        TaxUseCase: Record "Tax Use Case";
        JText: Text;
    begin
        // [SCENARIO] To check if Tax Types and use cases are getting imported.

        // [GIVEN] There has to be a json file for importing
        JText := ClearTaxTypeAndGetTaxConfig();

        // [WHEN] function ImportTaxTypes is called 
        ImportTaxConfiguration(JText);

        // [THEN] It should create a record in Tax Type and Use cases.
        TaxType.SetRange(Code, TaxTypeLbl);
        Assert.RecordIsNotEmpty(TaxType);

        TaxUseCase.Reset();
        TaxUseCase.SetRange("Tax Type", TaxTypeLbl);
        TaxUseCase.FindFirst();
        Assert.RecordIsNotEmpty(TaxUseCase);
        Commit();
    end;

    [Test]
    [HandlerFunctions('UseCaseMsgHandler')]
    procedure TestExportTaxTypes()
    var
        TaxType: Record "Tax Type";
        JsonSerialization: Codeunit "Tax Json Serialization";
        JArray: JsonArray;
        JText: Text;
    begin
        // [SCENARIO] To check if Tax Types are getting exported.

        // [GIVEN] There has to be a tax type with code as VAT
        JText := ClearTaxTypeAndGetTaxConfig();
        ImportTaxConfiguration(JText);

        // [WHEN] function ImportTaxTypes is called 
        JsonSerialization.ExportTaxTypes(TaxType, JArray);
        JArray.WriteTo(JText);

        // [THEN] It should create a record in Tax Type and Use cases.
        Assert.AreNotEqual('', JText, 'JText should not be blank');
    end;

    [Test]
    [HandlerFunctions('UseCaseMsgHandler')]
    procedure TestExportNodes()
    var
        UseCaseTreeNode: Record "Use Case Tree Node";
        JText: Text;
    begin
        // [SCENARIO] To check if Use Case Tree Nodes are getting exported.

        // [GIVEN] There has to be a UseCase Tree Node already Imported
        JText := ClearTaxTypeAndGetTaxConfig();
        ImportTaxConfiguration(JText);
        ImportTaxUseCaseTree();

        // [WHEN] function Export is called 
        UseCaseTreeIndent.ExportNodes(UseCaseTreeNode);
        // [THEN] It should create a record in Tax Type and Use cases.
        Assert.AreNotEqual('', JText, 'JText should not be blank');
    end;

    [Test]
    [HandlerFunctions('UseCaseMsgHandler')]
    procedure TestUseCaseExecution()
    var
        TaxUseCase: Record "Tax Use Case";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        TaxTransactionValue: Record "Tax Transaction Value";
        TempSymbols: Record "Script Symbol Value" temporary;
        UseCaseExecution: Codeunit "Use Case Execution";
        RecID: RecordId;
        RecRef: RecordRef;
        Record: Variant;
        JText: Text;
    begin
        // [SCENARIO] Validate if Tax Engine is calculation tax on a Sales Document.

        // [GIVEN] There has to be a tax type with code as VAT and use case configured and use cases should be enabled.
        JText := ClearTaxTypeAndGetTaxConfig();
        ImportTaxConfiguration(JText);

        ImportTaxUseCaseTree();
        CreateTaxRate();

        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("VAT Bus. Posting Group", 'DOMESTIC');
        Customer.Modify();

        Item.FindFirst();
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item, Item."No.", 1);

        // [WHEN] Tax Engine executes tax calculation.

        RecRef.GetTable(SalesLine);
        Record := RecRef;

        TaxUseCase.Reset();
        TaxUseCase.SetRange("Tax Type", 'VAT');
        TaxUseCase.SetFilter("Parent Use Case ID", '<>%1', EmptyGuid);
        TaxUseCase.FindFirst();

        UseCaseExecution.ExecuteUseCaseTree(TaxUseCase.ID, Record, TempSymbols, RecID, SalesHeader."Currency Code", SalesHeader."Currency Factor");

        // [THEN] Tax Exngine should calculate tax on Sales Document and create records in transaction value for Tax Attributes and Components.
        TaxTransactionValue.SetRange("Tax Record ID", SalesLine.RecordId);
        Assert.RecordIsNotEmpty(TaxTransactionValue);
    end;


    [Test]
    [HandlerFunctions('UseCaseMsgHandler')]
    procedure TestUseCasePosting()
    var
        TaxUseCase: Record "Tax Use Case";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        TempSymbols: Record "Script Symbol Value" temporary;
        UseCaseExecution: Codeunit "Use Case Execution";
        SalesPost: Codeunit "Sales-Post";
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
        RecID: RecordId;
        RecRef: RecordRef;
        EmptyGuid: Guid;
        Record: Variant;
        JText: Text;
    begin
        // [SCENARIO] To check if Tax Engine is calculating Tax

        // [GIVEN] There has to be a tax type with code as VAT and use case configured and use cases should be enabled.
        JText := ClearTaxTypeAndGetTaxConfig();
        ImportTaxConfiguration(JText);
        ImportTaxUseCaseTree();

        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("VAT Bus. Posting Group", 'DOMESTIC');
        Customer.Modify();

        Item.FindFirst();
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item, Item."No.", 1);

        // [WHEN] Tax Engine executes tax calculation.

        RecRef.GetTable(SalesLine);
        Record := RecRef;

        TaxUseCase.Reset();
        TaxUseCase.SetRange("Tax Type", 'VAT');
        TaxUseCase.SetFilter("Parent Use Case ID", '<>%1', EmptyGuid);
        TaxUseCase.FindFirst();

        UseCaseExecution.ExecuteUseCaseTree(TaxUseCase.ID, Record, TempSymbols, RecID, SalesHeader."Currency Code", SalesHeader."Currency Factor");

        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesPost.Run(SalesHeader);
        // [THEN] It should calculate tax and create records in transaction value
        Assert.AreNotEqual(EmptyGuid, TaxPostingBufferMgmt.GetTaxID(), 'Tax ID should not be blank.');
    end;

    [Test]
    [HandlerFunctions('UseCaseMsgHandler')]
    procedure TestTaxInformationFactbox()
    var
        TaxUseCase: Record "Tax Use Case";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        UseCaseEventLibrary: Codeunit "Use Case Event Library";
        RecRef: RecordRef;
        SalesOrder: TestPage "Sales Order";
        Record: Variant;
        JText: Text;
    begin
        // [SCENARIO] To check if Tax Information is visible on Sales Order

        // [GIVEN] There has to be a tax type with code as VAT and use case configured and use cases should be enabled.
        JText := ClearTaxTypeAndGetTaxConfig();
        ImportTaxConfiguration(JText);
        ImportTaxUseCaseTree();

        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("VAT Bus. Posting Group", 'DOMESTIC');
        Customer.Modify();

        Item.FindFirst();
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item, Item."No.", 1);

        // [WHEN] Tax Engine executes tax calculation.

        RecRef.GetTable(SalesLine);
        Record := RecRef;
        TaxUseCase.Reset();
        TaxUseCase.SetRange("Tax Type", 'VAT');
        TaxUseCase.SetFilter("Parent Use Case ID", '<>%1', EmptyGuid);
        TaxUseCase.FindFirst();
        UseCaseEventLibrary.HandleBusinessUseCaseEvent('', SalesLine, SalesHeader."Currency Code", SalesHeader."Currency Factor");

        // [THEN] It should calculate tax and create records in transaction value
        SalesOrder.OpenEdit();
        SalesOrder.GoToRecord(SalesHeader);
        SalesOrder.SalesLines.First();
        SalesOrder.TaxInformation.First();

        Assert.AreEqual('Tax Information', SalesOrder.TaxInformation.Caption(), 'Caption should be Tax Information');
    end;


    [Test]
    [HandlerFunctions('UseCaseMsgHandler')]
    procedure TestUseCasePostingExecution()
    var
        TaxUseCase: Record "Tax Use Case";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesInvLine: Record "Sales Invoice Line";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        TaxTransactionValue: Record "Tax Transaction Value";
        TempSymbols: Record "Script Symbol Value" temporary;
        CalTestMgmt: Codeunit "CAL Test Management";
        UseCaseExecution: Codeunit "Use Case Execution";
        RecRef: RecordRef;
        RecID: RecordId;
        Record: Variant;
        PostedDocumentNo: Code[20];
        JText: Text;
    begin
        // [SCENARIO] To check if Tax Engine is calculating and posting tax 

        // [GIVEN] There has to be a tax type with code as VAT and use case configured and use cases should be enabled.
        JText := ClearTaxTypeAndGetTaxConfig();
        ImportTaxConfiguration(JText);
        ImportTaxUseCaseTree();

        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("VAT Bus. Posting Group", 'DOMESTIC');
        Customer.Modify();

        Item.FindFirst();
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, Customer."No.");
        CalTestMgmt.SETPUBLISHMODE();
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item, Item."No.", 1);
        CalTestMgmt.SETTESTMODE();

        RecRef.GetTable(SalesLine);
        Record := RecRef;
        TaxUseCase.Reset();
        TaxUseCase.SetRange("Tax Type", TaxTypeLbl);
        TaxUseCase.SetRange("Parent Use Case ID", EmptyGuid);
        TaxUseCase.FindFirst();
        UseCaseExecution.ExecuteUseCaseTree(TaxUseCase.ID, Record, TempSymbols, RecID, SalesHeader."Currency Code", SalesHeader."Currency Factor");

        // [WHEN] A Sales document is posted
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] It should post the tax and transfer records with posted record id's
        SalesInvLine.SetRange("Document No.", PostedDocumentNo);
        SalesInvLine.FindFirst();
        TaxTransactionValue.SetRange("Tax Record ID", SalesInvLine.RecordId);

        Assert.RecordIsNotEmpty(TaxTransactionValue);
    end;


    [MessageHandler]
    procedure UseCaseMsgHandler(Message: Text[1024])
    begin
    end;

    [PageHandler]
    procedure TaxTypePageHandler(var TaxTypes: TestPage "Tax Types")
    begin
        TaxTypes.New();
        TaxTypes.Code.SetValue(TaxTypeLbl);
        TaxTypes.Description.SetValue('Value Added Tax');

        TaxTypes.TaxEntities.Invoke();
        TaxTypes.Components.Invoke();
        TaxTypes.Attributes.Invoke();
        TaxTypes.TaxRateSetup.Invoke();
        TaxTypes.TaxRates.Invoke();
        TaxTypes.UseCases.Invoke();
        TaxTypes.ExportUseCase.Invoke();
    end;


    [PageHandler]
    procedure TaxEntitiesPageHandler(var TaxEntities: TestPage "Tax Entities")
    begin
        TaxEntities.New();
        TaxEntities."Table Name".SetValue('G/L Account');

        TaxEntities.New();
        TaxEntities."Table Name".SetValue('Customer');

        TaxEntities.New();
        TaxEntities."Table Name".SetValue('Item');

        TaxEntities.New();
        TaxEntities."Table Name".SetValue('VAT Business Posting Group');

        TaxEntities.New();
        TaxEntities."Table Name".SetValue('VAT Product Posting Group');

        TaxEntities.New();
        TaxEntities."Table Name".SetValue('Sales Header');
        TaxEntities."Entity Type".SetValue('Transaction');

        TaxEntities.New();
        TaxEntities."Table Name".SetValue('Sales Line');
        TaxEntities."Entity Type".SetValue('Transaction');

        TaxEntities.New();
        TaxEntities."Table Name".SetValue('VAT Entry');
        TaxEntities."Entity Type".SetValue('Transaction');

        TaxEntities.New();
        TaxEntities."Table Name".Lookup();
        TaxEntities."Entity Type".SetValue('Transaction');

        TaxEntities.Close();
    end;

    [PageHandler]
    procedure TaxComponentsPageHandler(var TaxComponents: TestPage "Tax Components")
    begin
        if not IsComponentFormulaLookup then begin
            TaxComponents.New();
            TaxComponents.Name.SetValue(TaxTypeLbl);

            TaxComponents.New();
            TaxComponents.Name.SetValue('VATPlus100');
            TaxComponents."Component Type".SetValue('Formula');
            TaxComponents.Next();
            TaxComponents.Previous();
            IsComponentFormulaLookup := true;
            TaxComponents.Formula.AssistEdit();
            IsComponentFormulaLookup := false;
            TaxComponents.Close();
        end else
            TaxComponents.OK().Invoke();
    end;

    [PageHandler]
    procedure TaxAttributesPageHandler(var TaxAttributes: TestPage "Tax Attributes")
    var
        TaxAttribute: TestPage "Tax Attribute";
    begin
        TaxAttribute.OpenNew();
        TaxAttribute.Name.SetValue('VATBusPostingGrp');
        TaxAttribute.Type.SetValue('Text');
        TaxAttribute."Visible on Interface".SetValue(true);
        TaxAttribute.TableNameText.SetValue('VAT Business Posting Group');
        TaxAttribute.FieldNameText.SetValue('Code');
        TaxAttribute.PageNameText.SetValue('VAT Business Posting Groups');

        TaxAttribute.LinkedEntity.New();
        TaxAttribute.LinkedEntity."Entity Name".SetValue('Customer');
        TaxAttribute.LinkedEntity."Mapping Field Name".SetValue('VAT Bus. Posting Group');

        TaxAttribute.LinkedEntity.New();
        TaxAttribute.LinkedEntity."Entity Name".SetValue('Sales Line');
        TaxAttribute.LinkedEntity."Mapping Field Name".SetValue('VAT Bus. Posting Group');
        TaxAttribute.OK().Invoke();

        TaxAttribute.OpenNew();
        TaxAttribute.Name.SetValue('OrderStatus');
        TaxAttribute.Type.SetValue('Option');
        TaxAttribute."Visible on Interface".SetValue(true);
        TaxAttribute.TableNameText.SetValue('Sales Header');
        TaxAttribute.FieldNameText.SetValue('Status');
        TaxAttribute.Values.Drilldown();
        TaxAttribute.OK().Invoke();

        TaxAttributes.Close();
    end;

    [PageHandler]
    procedure RateSetupPageHandler(var RateSetup: TestPage "Rate Setup")
    begin
        RateSetup.New();
        RateSetup."Column Type".SetValue('Tax Attributes');
        RateSetup.Name.SetValue('VATBusPostingGrp');
        RateSetup.Type.SetValue('Text');
        RateSetup.Sequence.SetValue('1');

        RateSetup.New();
        RateSetup."Column Type".SetValue('Range From');
        RateSetup.Name.SetValue('Effective');
        RateSetup.Type.SetValue('Date');
        RateSetup.Sequence.SetValue('2');

        RateSetup.New();
        RateSetup."Column Type".SetValue('Value');
        RateSetup.Name.SetValue('VatBusPostingGrp');
        RateSetup.Type.SetValue('Text');
        RateSetup.Sequence.SetValue('3');
        RateSetup.LinkedAttributeName.SetValue('VatBusPostingGrp');

        RateSetup.New();
        RateSetup."Column Type".SetValue('Value');
        RateSetup.Name.SetValue('VatBusPostingGrp');
        RateSetup.Type.SetValue('Text');
        RateSetup.Sequence.SetValue('4');
        RateSetup."Allow Blank".SetValue(true);
        RateSetup.LinkedAttributeName.Lookup();

        RateSetup.New();
        RateSetup."Column Type".SetValue('Component');
        RateSetup.Name.SetValue('VAT');
        RateSetup.Type.SetValue('Decimal');
        RateSetup.Sequence.SetValue('5');

        RateSetup.New();
        RateSetup."Column Type".SetValue('Tax Attributes');
        RateSetup.Name.SetValue('OrderStatus');
        RateSetup.Type.SetValue('Text');
        RateSetup.Sequence.SetValue('6');

        RateSetup.ShowMatrix.Invoke();
        RateSetup.Close();
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRates: TestPage "Tax Rates")
    var
        VATBusPostingGroup: Record "VAT Business Posting Group";
        LibraryERM: Codeunit "Library - ERM";
    begin
        LibraryERM.CreateVATBusinessPostingGroup(VATBusPostingGroup);

        TaxRates.New();
        TaxRates.AttributeValue1.SetValue(VATBusPostingGroup.Code);
        TaxRates.AttributeValue2.SetValue('t');
        TaxRates.AttributeValue3.SetValue(VATBusPostingGroup.Code);
        TaxRates.AttributeValue4.SetValue(VATBusPostingGroup.Code);
        TaxRates.AttributeValue5.SetValue('3');
        TaxRates.AttributeValue6.Lookup();

        clear(VATBusPostingGroup);
        LibraryERM.CreateVATBusinessPostingGroup(VATBusPostingGroup);

        TaxRates.New();
        TaxRates.AttributeValue1.SetValue(VATBusPostingGroup.Code);
        TaxRates.AttributeValue2.SetValue('t');
        TaxRates.AttributeValue3.SetValue(VATBusPostingGroup.Code);
        TaxRates.AttributeValue4.SetValue(VATBusPostingGroup.Code);
        TaxRates.AttributeValue5.SetValue('3');
        TaxRates.AttributeValue6.Lookup();
    end;

    [PageHandler]
    [HandlerFunctions('UseCaseConditionHandler,AttributeMappingSwitchStatementHandler,TaxTableRelationHandler,UseCaseComponentExprLookup,ComputationScriptHandler,ScriptVariablesHandler,InsertRecordHandler,TaxPostingSetupHandler,ArchivalLogsHandler,LoopThruRecordHandler,ActionStringExprHandler,ActionRoundNumberHandler,ActionReplaceSubstringDlgHandler,ActionNumberExpressionHandler,ActionNumberCalculationHandler,ActionMessageHandler,ActionLengthOfStringHandler,ActionFindSubStringInStringHandler,ActionFindIntervalBetDateHandler,ActionExtractSubStringFrmPosHandler,ActionExtractSubStringFrmIndexHandler,ActionExtractDatePartHandler,ActionDateToDateTimeHandler,DateCalculationHandler,ConvertCaseHandler')]
    procedure UseCasePageHandler(var UseCases: TestPage "Use Cases")
    var
        TaxUseCase: Record "Tax Use Case";
        UseCaseCard: TestPage "Use Case Card";
    begin
        CreateUseCaseRecord();
        TaxUseCase.Get(CaseID);

        UseCaseCard.OpenEdit();
        UseCaseCard.GoToRecord(TaxUseCase);

        UseCaseCard.Description.SetValue('Calculate tax on Sales Document');
        UseCaseCard."Tax Entity Name".SetValue('Sales Line');
        UseCaseCard.Condition.Drilldown();

        UseCaseCard.OpenTaxAttributesMapping.New();
        UseCaseCard.OpenTaxAttributesMapping."Attribtue Name".SetValue('VAT');

        UseCaseCard.OpenRateColumnMapping.Name.SetValue('Effective');

        UseCaseCard.ComputationScript.Invoke();

        UseCaseCard.OpenComponentCalculation.Name.SetValue('VAT');
        UseCaseCard.OpenComponentCalculation.Next();
        UseCaseCard.OpenComponentCalculation.Previous();
        UseCaseCard.OpenComponentCalculation.Formula.AssistEdit();
        UseCaseCard.PostingSetup.Invoke();

        UseCaseCard.Status.SetValue('Released');
        UseCaseCard.Status.SetValue('Draft');

        UseCaseCard.ExportUseCase.Invoke();
        UseCaseCard.ArchivedLogs.Invoke();
        UseCaseCard.CopyUseCase.Invoke();

        TaxUseCase.Get(CaseID);
        if TaxUseCase.Status = TaxUseCase.Status::Released then begin
            TaxUseCase.Validate(Status, TaxUseCase.Status::Draft);
            TaxUseCase.Modify(true);
        end;
        TaxUseCase.Delete(true);
    end;

    [ModalPageHandler]
    [HandlerFunctions('UseCaseConditionLookup')]
    procedure UseCaseConditionHandler(var ConditionsDialog: TestPage "Conditions Dialog")
    begin
        LHSLookup := false;
        RHSLookup := false;

        LHSLookup := true;
        ConditionsDialog.LHSValue.AssistEdit();
        ConditionsDialog."Conditional Operator".SetValue('Not Equals');
        LHSLookup := false;
        RHSLookup := true;
        ConditionsDialog.RHSValue.AssistEdit();

        ConditionsDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure UseCaseConditionLookup(var ScriptSymbolLookupDialog: TestPage "Script Symbol Lookup Dialog")
    begin
        if LHSLookup then begin
            ScriptSymbolLookupDialog."Source Type".SetValue('Current Record');
            ScriptSymbolLookupDialog.FieldName.SetValue('Document No.');
            ScriptSymbolLookupDialog.OK().Invoke();
        end else begin
            ScriptSymbolLookupDialog."Source Type".SetValue('Table');
            ScriptSymbolLookupDialog.FieldName.SetValue('Sales Header');
            ScriptSymbolLookupDialog.Method.SetValue('First');
            ScriptSymbolLookupDialog.FieldName.SetValue('No.');
            ScriptSymbolLookupDialog."Lookup Table Filters".AssistEdit();
            ScriptSymbolLookupDialog.OK().Invoke();
        end;
    end;

    [ModalPageHandler]
    procedure UseCaseConditionTableFilter(var LookupFieldFilterDlg: TestPage "Lookup Field Filter Dialog")
    begin
        LookupFieldFilterDlg.New();
        LookupFieldFilterDlg.TableFieldName.SetValue('Document Type');
        LookupFieldFilterDlg."Filter Type".SetValue('Equals');
        LookupFieldFilterDlg.FilterValue.SetValue('Order');

        LookupFieldFilterDlg.New();
        LookupFieldFilterDlg.TableFieldName.SetValue('Document No.');
        LookupFieldFilterDlg."Filter Type".SetValue('Equals');
        LookupFieldFilterDlg.FilterValue.SetValue('DOC-001');
        LookupFieldFilterDlg.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure AttributeMappingSwitchStatementHandler(var SwitchStatements: TestPage "Switch Statements")
    begin
        SwitchStatements.New();
        SwitchStatements.Mapping.AssistEdit();
    end;

    [ModalPageHandler]
    procedure TaxTableRelationHandler(var TaxTableRelationDialog: TestPage "Tax Table Relation Dialog")
    begin
        TaxTableRelationDialog."Lookup Table".SetValue('Customer');
    end;

    [ModalPageHandler]
    procedure ComponentExpreHandler(var TaxComponentExprDialog: TestPage "Tax Component Expr. Dialog")
    begin
        TaxComponentExprDialog.Expression.SetValue('Amount*VATPerc/100');
        TaxComponentExprDialog."Component Expr. Subform".ValueVariable.AssistEdit();
    end;

    [ModalPageHandler]
    procedure UseCaseComponentExprLookup(var ScriptSymbolLookupDialog: TestPage "Script Symbol Lookup Dialog")
    begin
        ScriptSymbolLookupDialog."Source Type".SetValue('Component Percent');
        ScriptSymbolLookupDialog.VariableName.SetValue('VAT');
        ScriptSymbolLookupDialog.OK().Invoke();
    end;

    local procedure CreateUseCaseRecord()
    var
        TaxUseCase: Record "Tax Use Case";
    begin
        TaxUseCase."Tax Type" := 'VAT';
        TaxUseCase.Insert(true);
        CaseID := TaxUseCase.ID;
    end;

    [PageHandler]
    procedure ComputationScriptHandler(var ScriptContext: TestPage "Script Context")
    var
        ScriptAction: Record "Script Action";
        ScriptEditorMgmt: Codeunit "Script Editor Mgmt.";
    begin
        ScriptAction.DeleteAll();
        ScriptContext.Variables.Invoke();
        ScriptEditorMgmt.InitActions();
        ScriptContext.OpenUseCaseTaxRules.First();

        ScriptAction.FindSet();
        repeat
            ScriptContext.OpenUseCaseTaxRules.Action.SetValue(ScriptAction.Text);
            if ScriptAction.Text In [
                'Loop Through Records',
                'Convert Case',
                'Date Calculation',
                'Date To DateTime',
                'Extract Date Part',
                'Extract Substring From Index',
                'Extract Substring From Position',
                'Find Interval Between Dates',
                'Find Substring In String',
                'Length Of String',
                'Message',
                'Number Calculation',
                'Numeric Expression',
                'Replace Substring',
                'Round Number',
                'String Expression'] then
                ScriptContext.OpenUseCaseTaxRules.Description.AssistEdit();

            if ScriptAction.Text = 'Comment' then begin
                ScriptContext.OpenUseCaseTaxRules.Description.SetValue('This is a comment Line');
                ScriptContext.OpenUseCaseTaxRules.Description.SetValue('Comment is updated');
            end;
            ScriptContext.OpenUseCaseTaxRules.Next();
        until ScriptAction.Next() = 0;

        ScriptContext.OpenUseCaseTaxRules."Insert Action".Invoke();
        ScriptContext.OpenUseCaseTaxRules.Action.SetValue('If Statement');
        ScriptContext.OpenUseCaseTaxRules."Add Else Condition".Invoke();
    end;

    [ModalPageHandler]
    procedure ScriptVariablesHandler(var Variables: TestPage "Script Variables Part")
    var
        DataTypes: List of [Text];
        DataType: Text;
    begin
        DataTypes := "Symbol Data Type".Names();
        foreach DataType in DataTypes do begin
            Variables.New();
            Variables.Name.SetValue(DataType + 'Variable');
            Variables.Datatype.SetValue(DataType);
        end;

        Variables.OK().Invoke();
    end;

    [PageHandler]
    procedure TaxPostingSetupHandler(var UseCasePosting: TestPage "Use Case Posting")
    begin
        UseCasePosting.TaxPostingEntity.SetValue('Vat Posting Setup');
        UseCasePosting.Posting.Name.SetValue('VAT');
        UseCasePosting.Posting."Account Source Type".SetValue('Lookup');
        UseCasePosting.Posting."Account Source Type".SetValue('Field');
        UseCasePosting.Posting.FieldName.SetValue('Sales');
        UseCasePosting.Posting."Accounting Impact".SetValue('Credit');
        UseCasePosting.Posting."Reverse Charge".SetValue(true);
        UseCasePosting.Posting."Account Source Type".SetValue('Lookup');
        UseCasePosting.Posting."Reversal Account Source Type".SetValue('Field');
        UseCasePosting.Posting.ReversalFieldName.AssistEdit();
        UseCasePosting.Posting.SubLedgerMapping.Drilldown();
        UseCasePosting.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure InsertRecordHandler(var TaxInsertRecordDialog: TestPage "Tax Insert Record Dialog")
    begin
        TaxInsertRecordDialog.InsertIntoTableName.SetValue('VAT Entry');
        TaxInsertRecordDialog."Run Trigger".SetValue(true);

        TaxInsertRecordDialog."Insert Record Subform".New();
        TaxInsertRecordDialog."Insert Record Subform"."Sequence No.".SetValue('1');
        TaxInsertRecordDialog."Insert Record Subform".New();
        TaxInsertRecordDialog."Insert Record Subform".TableFieldName.SetValue('Entry No.');
        TaxInsertRecordDialog."Insert Record Subform".FieldValue.SetValue('1');
        TaxInsertRecordDialog."Insert Record Subform"."Reverse Sign".SetValue(true);
        TaxInsertRecordDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure FieldLookupHandler(var FieldLookup: TestPage "Field Lookup")
    begin
        FieldLookup.First();
        FieldLookup.Next();
        FieldLookup.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ComponentFormulaExpHandler(var TaxComponentFormulaDialog: TestPage "Tax Component Formula Dialog")
    begin
        TaxComponentFormulaDialog.Expression.SetValue('VATAmount + 100');
        TaxComponentFormulaDialog."Component Expr. Subform".ValueVariable.AssistEdit();
    end;

    [PageHandler]
    procedure ArchivalLogsHandler(var UseCaseArchivalLogEntries: TestPage "Use Case Archival Log Entries")
    begin
        UseCaseArchivalLogEntries.RestoreUseCase.Invoke();
        UseCaseArchivalLogEntries.ShowUseCaseAsJson.Invoke();
        UseCaseArchivalLogEntries.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure TaxComponentsModalPageHandler(var TaxComponents: TestPage "Tax Components")
    begin
        if not IsComponentFormulaLookup then begin
            TaxComponents.New();
            TaxComponents.Name.SetValue('VAT');

            TaxComponents.New();
            TaxComponents.Name.SetValue('VATPlus100');
            TaxComponents."Component Type".SetValue('Formula');
            TaxComponents.Next();
            TaxComponents.Previous();
            IsComponentFormulaLookup := true;
            TaxComponents.Formula.AssistEdit();
            IsComponentFormulaLookup := false;
            TaxComponents.Close();
        end else
            TaxComponents.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ScriptSymbolHandler(var ScriptSymbols: TestPage "Script Symbols")
    begin
        ScriptSymbols.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure UseCaseRestoreCnfrmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [PageHandler]
    procedure UseCaseCardPageHandler(var UseCaseCard: TestPage "Use Case Card")
    begin
        UseCaseCard.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure LoopThruRecordHandler(var ActionLoopThroughRecDlg: TestPage "Action Loop Through Rec. Dlg")
    begin
        ActionLoopThroughRecDlg.GetRecordFromTableName.SetValue('Sales Header');
        ActionLoopThroughRecDlg.Distinct.SetValue(true);
        ActionLoopThroughRecDlg."Loop Through Rec. Subform".New();
        ActionLoopThroughRecDlg."Loop Through Rec. Subform".TableFieldName.SetValue('Document Type');

        ActionLoopThroughRecDlg."Loop Through Rec. Subform".New();
        ActionLoopThroughRecDlg."Loop Through Rec. Subform".TableFieldName.SetValue('No.');
        ActionLoopThroughRecDlg."Loop Through Rec. Subform".VariableName.SetValue('StringVariable');
        ActionLoopThroughRecDlg.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ConvertCaseHandler(var ActionConvertCaseDialog: TestPage "Action Convert Case Dialog")
    begin
        ActionConvertCaseDialog.VariableName.SetValue('StringVariable');
        ActionConvertCaseDialog.VariableLookup.SetValue('ABCD');
        ActionConvertCaseDialog."Convert To Case".SetValue('Lower Case');
        ActionConvertCaseDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure DateCalculationHandler(var ActionDateCalculationDialog: TestPage "Action Date Calculation Dialog")
    begin
        ActionDateCalculationDialog.VariableName.SetValue('DateVariable');
        ActionDateCalculationDialog.Date.SetValue(Today());
        ActionDateCalculationDialog."Arithmetic operators".SetValue('plus');
        ActionDateCalculationDialog.Number.SetValue('10');
        ActionDateCalculationDialog.Duration.SetValue('Months');
        ActionDateCalculationDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionDateToDateTimeHandler(var ActionDateToDateTimeDialog: TestPage "Action Date To DateTime Dialog")
    begin
        ActionDateToDateTimeDialog.VariableName.SetValue('DateTimeVariable');
        ActionDateToDateTimeDialog.Date.SetValue(Today());
        ActionDateToDateTimeDialog.TimeVariable.SetValue('8:00');
        ActionDateToDateTimeDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionExtractDatePartHandler(var ActionExtractDatePartDlg: TestPage "Action Extract Date Part Dlg")
    begin
        ActionExtractDatePartDlg.VariableName.SetValue('NumberVariable');
        ActionExtractDatePartDlg."Date Lookup".SetValue(Today());
        ActionExtractDatePartDlg."Date Part".SetValue('Year');
        ActionExtractDatePartDlg.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionExtractSubStringFrmIndexHandler(var ActionExtSubstrFromIndex: TestPage "Action Ext. Substr. From Index")
    begin
        ActionExtSubstrFromIndex.VariableName.SetValue('StringVariable');
        ActionExtSubstrFromIndex.String.SetValue('ABCD');
        ActionExtSubstrFromIndex.FromIndex.SetValue('1');
        ActionExtSubstrFromIndex.Length.SetValue('2');
        ActionExtSubstrFromIndex.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionExtractSubStringFrmPosHandler(var ActionExtSubstrFromPos: TestPage "Action Ext. Substr. From Pos.")
    begin
        ActionExtSubstrFromPos.VariableName.SetValue('StringVariable');
        ActionExtSubstrFromPos.String.SetValue('ABCD');
        ActionExtSubstrFromPos.Position.SetValue('start');
        ActionExtSubstrFromPos.Length.SetValue('2');
        ActionExtSubstrFromPos.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionFindIntervalBetDateHandler(var ActionFindDateIntervalDlg: TestPage "Action Find Date Interval Dlg")
    begin
        ActionFindDateIntervalDlg.VariableName.SetValue('NumberVariable');
        ActionFindDateIntervalDlg.Date1.SetValue(Today());
        ActionFindDateIntervalDlg.Date2.SetValue(CalcDate('<CM>', Today()));
        ActionFindDateIntervalDlg.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionFindSubStringInStringHandler(var ActionFindSubstringDialog: TestPage "Action Find Substring Dialog")
    begin
        ActionFindSubstringDialog.VariableName.SetValue('StringVariable');
        ActionFindSubstringDialog.Substring.SetValue('BC');
        ActionFindSubstringDialog.String.SetValue('ABCD');
        ActionFindSubstringDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionLengthOfStringHandler(var ActionLengthOfStringDialog: TestPage "Action Length Of String Dialog")
    begin
        ActionLengthOfStringDialog.VariableName.SetValue('NumberVariable');
        ActionLengthOfStringDialog."String Lookup".SetValue('ABCD');
    end;

    [ModalPageHandler]
    procedure ActionMessageHandler(var ActionMessageDialog: TestPage "Action Message Dialog")
    begin
        ActionMessageDialog.Message.SetValue('This is a Error Message.');
        ActionMessageDialog."Throw Error".SetValue(true);
    end;

    [ModalPageHandler]
    procedure ActionNumberCalculationHandler(var ActionNumberCalcDialog: TestPage "Action Number Calc. Dialog")
    begin
        ActionNumberCalcDialog.OutputToVariableName.SetValue('NumberVariable');
        ActionNumberCalcDialog.LHSValue.SetValue('2');
        ActionNumberCalcDialog."Arithmetic operators".SetValue('Multiply By');
        ActionNumberCalcDialog.RHSValue2.SetValue('2');
        ActionNumberCalcDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionNumberExpressionHandler(var ActionNumberExprDialog: TestPage "Action Number Expr. Dialog")
    begin
        ActionNumberExprDialog.VariableName.SetValue('NumberVariable');
        ActionNumberExprDialog.Expression.SetValue('LineAmount + 1000');
        ActionNumberExprDialog."Number Expr. Subform".ValueVariable.SetValue('10000');
        ActionNumberExprDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionReplaceSubstringDlgHandler(var ActionReplaceSubstringDlg: TestPage "Action Replace Substring Dlg")
    begin
        ActionReplaceSubstringDlg.VariableName.SetValue('StringVariable');
        ActionReplaceSubstringDlg.Substring.SetValue('ABCD');
        ActionReplaceSubstringDlg.NewString.SetValue('ABCD');
        ActionReplaceSubstringDlg.String.SetValue('StringVariable');
        ActionReplaceSubstringDlg.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionRoundNumberHandler(var ActionRoundNumberDialog: TestPage "Action Round Number Dialog")
    begin
        ActionRoundNumberDialog.VariableName.SetValue('NumberVariable');
        ActionRoundNumberDialog.NumberLookupValue.SetValue('1000.25');
        ActionRoundNumberDialog.PrecisionLookupValue2.SetValue('1');
        ActionRoundNumberDialog.Direction.SetValue('Up');
        ActionRoundNumberDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionStringExprHandler(var ActionStringExprDialog: TestPage "Action String Expr. Dialog")
    begin
        ActionStringExprDialog.VariableName.SetValue('StringVariable');
        ActionStringExprDialog.Expression.SetValue('Hi {Value1}');
        ActionStringExprDialog."String Expr. Subform".ValueVariable.SetValue('User Name');
        ActionStringExprDialog.OK().Invoke();
    end;

    [PageHandler]
    procedure TaxAttributeValuesHandler(var TaxAttributeValues: TestPage "Tax Attribute Values")
    begin
        TaxAttributeValues.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure TaxAttributeValuesModalHandler(var TaxAttributeValues: TestPage "Tax Attribute Values")
    begin
        TaxAttributeValues.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure TaxEntitiesHandler(var AllObjects: TestPage "All Objects")
    begin
        AllObjects.OK().Invoke();
    end;

    local procedure CreateTaxRate()
    var
        TaxRate: Record "Tax Rate";
        TaxRateValue: Record "Tax Rate Value";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        TaxSetupMatrixMgmt: Codeunit "Tax Setup Matrix Mgmt.";
        RateID: Text;
        ConfigID: Guid;
    begin
        ScriptSymbolsMgmt.SetContext('VAT', EmptyGuid, EmptyGuid);
        ConfigID := CreateGuid();
        TaxRate.ID := ConfigID;
        TaxRate."Tax Type" := 'VAT';
        TaxRate.Insert();

        TaxRateValue.Init();
        TaxRateValue."Tax Type" := 'VAT';
        TaxRateValue."Config ID" := ConfigID;
        TaxRateValue.ID := CreateGuid();
        TaxRateValue."Column ID" := 7301;
        TaxRateValue."Column Type" := "Column Type"::"Tax Attributes";
        TaxRateValue.Value := 'DOMESTIC';
        TaxRateValue."Decimal Value" := 0;
        TaxRateValue."Date Value" := 0D;
        TaxRateValue."Date Value To" := 0D;
        TaxRateValue.Insert();

        TaxRateValue.Init();
        TaxRateValue."Tax Type" := 'VAT';
        TaxRateValue."Config ID" := ConfigID;
        TaxRateValue.ID := CreateGuid();
        TaxRateValue."Column ID" := 7302;
        TaxRateValue."Column Type" := "Column Type"::"Tax Attributes";
        TaxRateValue.Value := 'VAT25';
        TaxRateValue."Decimal Value" := 0;
        TaxRateValue."Date Value" := 0D;
        TaxRateValue."Date Value To" := 0D;
        TaxRateValue.Insert();

        TaxRateValue.Init();
        TaxRateValue."Tax Type" := 'VAT';
        TaxRateValue."Config ID" := ConfigID;
        TaxRateValue.ID := CreateGuid();
        TaxRateValue."Column ID" := 7303;
        TaxRateValue."Column Type" := "Column Type"::"Range From";
        TaxRateValue.Value := format(Today());
        TaxRateValue."Decimal Value" := 0;
        TaxRateValue."Date Value" := 0D;
        TaxRateValue."Value To" := Format(Today(), 0, 9);
        TaxRateValue."Date Value To" := 0D;
        TaxRateValue.Insert();

        TaxRateValue.Init();
        TaxRateValue."Tax Type" := 'VAT';
        TaxRateValue."Config ID" := ConfigID;
        TaxRateValue.ID := CreateGuid();
        TaxRateValue."Column ID" := 7304;
        TaxRateValue."Column Type" := "Column Type"::Component;
        TaxRateValue.Value := '5';
        TaxRateValue."Decimal Value" := 5;
        TaxRateValue."Date Value" := 0D;
        TaxRateValue."Date Value To" := 0D;
        TaxRateValue.Insert();

        RateID := TaxSetupMatrixMgmt.GenerateTaxRateID(ConfigID, 'VAT');
        TaxRateValue.SetRange("Config ID", ConfigID);
        if TaxRateValue.FindSet() then
            TaxRateValue.ModifyAll("Tax Rate ID", RateID);

        TaxRate."Tax Setup ID" := TaxSetupMatrixMgmt.GenerateTaxSetupID(ConfigID, 'VAT');
        TaxRate."Tax Rate ID" := RateID;
        TaxRate.Modify();
    end;

    local procedure ClearTaxTypeAndGetTaxConfig() JText: Text
    var
        TaxType: Record "Tax Type";
        TaxUseCase: Record "Tax Use Case";
        UseCaseMgmt: Codeunit "Use Case Mgmt.";
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
    begin
        TaxType.SetHideDialog(true);
        TaxType.SetRange(Code, TaxTypeLbl);
        if TaxType.FindFirst() then begin
            TaxUseCase.SetRange("Tax Type", TaxTypeLbl);
            UseCaseMgmt.DisableSelectedUseCases(TaxUseCase);
            TaxTypeObjectHelper.DisableSelectedTaxTypes(TaxType);
            TaxType.Delete(true);
        end;
        JText := TaxConfigTestHelper.GetJsonInText();
    end;

    local procedure ImportTaxConfiguration(JText: Text)
    var
        JArray: JsonArray;
    begin
        JArray.ReadFrom(JText);
        JsonDeserialization.SetCanImportUseCases(true);
        JsonDeserialization.ImportTaxTypes(JText);
    end;

    local procedure ImportTaxUseCaseTree()
    var
        JText: Text;
    begin
        JText := TaxConfigTestHelper.GetUseCaseTree();
        UseCaseTreeIndent.ReadUseCaseTree(JText);
        UseCaseTreeIndent.Indent();
    end;
}