namespace Microsoft.Test.Sustainability;

using Microsoft.Assembly.Document;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.Journal;
using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Manufacturing.Routing;
using Microsoft.Manufacturing.WorkCenter;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Journal;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Emission;
using Microsoft.Sustainability.Setup;
using Microsoft.Sustainability.Reports;

codeunit 148212 "Sust. Item Of Concern Test"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Assert";
        LibraryJob: Codeunit "Library - Job";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryAssembly: Codeunit "Library - Assembly";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryManufacturing: Codeunit "Library - Manufacturing";
        LibrarySustainability: Codeunit "Library - Sustainability";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        IsInitialized: Boolean;
        Direction: Option Inbound,Outbound;
        AccountCodeLbl: Label 'AccountCode%1', Locked = true, Comment = '%1 = Number';
        CategoryCodeLbl: Label 'CategoryCode%1', Locked = true, Comment = '%1 = Number';
        SubcategoryCodeLbl: Label 'SubcategoryCode%1', Locked = true, Comment = '%1 = Number';
        AtLeastOneNonZeroEmissionValueErr: Label '%1, %2, %3 cannot all be zero. Please provide at least one non-zero value.', Comment = '%1, %2 , %3 = Field Caption';
        SumOfElementValueErr: Label 'Sum of %1 must be %2 in Report.', Comment = '%1 = Element Name , %2 = Element Value';
        DirectionLbl: Label 'Direction';
        CO2e_EmissionLbl: Label 'CO2e_Emission';
        Emission_CO2Lbl: Label 'Emission_CO2';
        Emission_CH4Lbl: Label 'Emission_CH4';
        Emission_N2OLbl: Label 'Emission_N2O';

    [Test]
    procedure VerifyItemOfConcernCannotBeTrueInItemIfAllEmissionsAreZero()
    var
        Item: Record Item;
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityAccount: Record "Sustainability Account";
        ItemCard: TestPage "Item Card";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 555411] Verify "Item of Concern" cannot be true if "Default CO2 Emission", "Default CH4 Emission", and "Default N2O Emission" are all zero in item.
        Initialize();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Item Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", true);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Open "Item Card".
        ItemCard.OpenView();
        ItemCard.GoToRecord(Item);

        // [GIVEN] Update "Default Sust. Account" in item.
        ItemCard."Default Sust. Account".SetValue(AccountCode);

        // [WHEN] Update "Item Of Concern" in item.
        asserterror ItemCard."Item Of Concern".SetValue(true);

        // [THEN] "Item of Concern" cannot be true if "Default CO2 Emission", "Default CH4 Emission", and "Default N2O Emission" are all zero.
        Assert.ExpectedError(
            StrSubstNo(
                AtLeastOneNonZeroEmissionValueErr,
                Item.FieldCaption("Default CO2 Emission"),
                Item.FieldCaption("Default CH4 Emission"),
                Item.FieldCaption("Default N2O Emission")));
    end;

    [Test]
    procedure VerifyAllDefaultEmissionsCannotBeToZeroInItemIfItemOfConcernIsTrue()
    var
        Item: Record Item;
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityAccount: Record "Sustainability Account";
        ItemCard: TestPage "Item Card";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 555411] Verify "Default CO2 Emission", "Default CH4 Emission" or "Default N2O Emission" cannot be zero If "Item Of Concern" is true.
        Initialize();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Item Emissions" to true in Sustainability Setup.
        SustainabilitySetup.Validate("Item Emissions", true);
        SustainabilitySetup.Modify(true);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Open "Item Card".
        ItemCard.OpenView();
        ItemCard.GoToRecord(Item);

        // [GIVEN] Update "Default Sust. Account" in item.
        ItemCard."Default Sust. Account".SetValue(AccountCode);
        ItemCard."Default CO2 Emission".SetValue(LibraryRandom.RandInt(10));
        ItemCard."Item Of Concern".SetValue(true);

        // [WHEN] Update "Item Of Concern" in item.
        asserterror ItemCard."Default CO2 Emission".SetValue(0);

        // [THEN] "Default CO2 Emission", "Default CH4 Emission" or "Default N2O Emission" cannot be zero If "Item Of Concern" is true.
        Assert.ExpectedError(
            StrSubstNo(
                AtLeastOneNonZeroEmissionValueErr,
                Item.FieldCaption("Default CO2 Emission"),
                Item.FieldCaption("Default CH4 Emission"),
                Item.FieldCaption("Default N2O Emission")));
    end;

    [Test]
    [HandlerFunctions('ProductionJournalModalPageHandler,ConfirmHandler,MessageHandler,ItemOfConcernRequestHandler')]
    procedure VerifyEmissionDataForItemOfConcernReport()
    var
        ProdItem: Record Item;
        SustainabilitySetup: Record "Sustainability Setup";
        ProdOrderLine: Record "Prod. Order Line";
        SalesLine: Record "Sales Line";
        EmissionFee: array[3] of Record "Emission Fee";
        SustainabilityAccount: Record "Sustainability Account";
        JobJournalLine: Record "Job Journal Line";
        AssemblyHeaderInbound: Record "Assembly Header";
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        ItemOfConcernReport: Report "Sust. Track Item Of Concern";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        ExpectedInboundEmissionCO2: Decimal;
        ExpectedInboundEmissionCH4: Decimal;
        ExpectedInboundEmissionN2O: Decimal;
    begin
        // [SCENARIO 555411] Verify "CO2e Emission", "Emission CO2", "Emission CH4", "Emission N2O" in Report "Track Item Of Concern".
        Initialize();

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Generate Emission.
        ExpectedInboundEmissionCO2 := LibraryRandom.RandInt(100);
        ExpectedInboundEmissionCH4 := LibraryRandom.RandInt(100);
        ExpectedInboundEmissionN2O := LibraryRandom.RandInt(100);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandIntInRange(1, 1));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create and Post Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(ProdItem, AccountCode, WorkDate(), ExpectedInboundEmissionCO2, ExpectedInboundEmissionCH4, ExpectedInboundEmissionN2O);

        // [GIVEN] Create And Post Production Order.
        CreateAndPostProductionOrder(ProdItem, ProdOrderLine, AccountCode);

        // [GIVEN] Create And Post Assembly Order.
        CreateAndPostAssemblyOrderForInbound(AssemblyHeaderInbound, ProdItem, LibraryRandom.RandInt(10));

        // [GIVEN] Update "Item Of Concern" in an Item.
        ProdItem.Get(ProdItem."No.");
        ProdItem."Item Of Concern" := true;
        ProdItem.Modify();

        // [GIVEN] Create and Post Sales Order.
        CreateAndPostSalesOrder(SalesLine, ProdItem, LibraryRandom.RandInt(10));

        // [GIVEN] Create and Job Journal Line.
        CreateAndPostJobJournalLine(JobJournalLine, ProdItem, AccountCode, LibraryRandom.RandInt(10), LibraryRandom.RandInt(200));

        // [GIVEN] Create and Post Assembly Order.
        CreateAndPostAssemblyOrderForOutbound(AssemblyHeader, AssemblyLine, ProdItem, LibraryRandom.RandInt(10));

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Run "Sust. Track Item Of Concern".
        ItemOfConcernReport.SetTableView(ProdItem);
        ItemOfConcernReport.Run();

        // [THEN] Verify "CO2e Emission", "Emission CO2", "Emission CH4", "Emission N2O" for Direction Inbound.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.SetRange(DirectionLbl, Format(Direction::Inbound));
        Assert.AreNearlyEqual(
            ProdOrderLine."Total CO2e" + AssemblyHeaderInbound."Total CO2e",
            LibraryReportDataset.Sum(CO2e_EmissionLbl),
            SustainabilitySetup."Emission Rounding Precision",
            StrSubstNo(SumOfElementValueErr, CO2e_EmissionLbl, ProdOrderLine."Total CO2e" + AssemblyHeaderInbound."Total CO2e"));
        Assert.AreNearlyEqual(
            0,
            LibraryReportDataset.Sum(Emission_CO2Lbl),
            SustainabilitySetup."Emission Rounding Precision",
            StrSubstNo(SumOfElementValueErr, Emission_CO2Lbl, 0));
        Assert.AreNearlyEqual(
            0,
            LibraryReportDataset.Sum(Emission_CH4Lbl),
            SustainabilitySetup."Emission Rounding Precision",
            StrSubstNo(SumOfElementValueErr, Emission_CH4Lbl, 0));
        Assert.AreNearlyEqual(
            0,
            LibraryReportDataset.Sum(Emission_N2OLbl),
            SustainabilitySetup."Emission Rounding Precision",
            StrSubstNo(SumOfElementValueErr, Emission_N2OLbl, 0));

        // [THEN] Verify "CO2e Emission", "Emission CO2", "Emission CH4", "Emission N2O" for Direction Outbound.
        LibraryReportDataset.SetRange(DirectionLbl, Format(Direction::Outbound));
        Assert.AreNearlyEqual(
            -SalesLine."Total CO2e" - JobJournalLine."Total CO2e" - AssemblyLine."Total CO2e",
            LibraryReportDataset.Sum(CO2e_EmissionLbl),
            SustainabilitySetup."Emission Rounding Precision",
            StrSubstNo(SumOfElementValueErr, CO2e_EmissionLbl, -SalesLine."Total CO2e" - JobJournalLine."Total CO2e" - AssemblyLine."Total CO2e"));
        Assert.AreNearlyEqual(
            0,
            LibraryReportDataset.Sum(Emission_CO2Lbl),
            SustainabilitySetup."Emission Rounding Precision",
            StrSubstNo(SumOfElementValueErr, Emission_CO2Lbl, 0));
        Assert.AreNearlyEqual(
            0,
            LibraryReportDataset.Sum(Emission_CH4Lbl),
            SustainabilitySetup."Emission Rounding Precision",
            StrSubstNo(SumOfElementValueErr, Emission_CH4Lbl, 0));
        Assert.AreNearlyEqual(
            0,
            LibraryReportDataset.Sum(Emission_N2OLbl),
            SustainabilitySetup."Emission Rounding Precision",
            StrSubstNo(SumOfElementValueErr, Emission_N2OLbl, 0));
    end;

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Sust. Item Of Concern Test");
        LibrarySustainability.CleanUpBeforeTesting();
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Sust. Item Of Concern Test");

        LibrarySales.SetCreditWarningsToNoWarnings();
        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        LibraryERMCountryData.CreateGeneralPostingSetupData();
        LibraryERMCountryData.UpdateVATPostingSetup();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERMCountryData.UpdateLocalData();
        LibrarySales.SetExtDocNo(false);
        IsInitialized := true;

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Sust. Item Of Concern Test");
    end;

    local procedure CreateSustainabilityAccount(var AccountCode: Code[20]; var CategoryCode: Code[20]; var SubcategoryCode: Code[20]; i: Integer): Record "Sustainability Account"
    begin
        CreateSustainabilitySubcategory(CategoryCode, SubcategoryCode, i);
        AccountCode := StrSubstNo(AccountCodeLbl, i);
        exit(LibrarySustainability.InsertSustainabilityAccount(
            AccountCode, '', CategoryCode, SubcategoryCode, Enum::"Sustainability Account Type"::Posting, '', true));
    end;

    local procedure CreateSustainabilitySubcategory(var CategoryCode: Code[20]; var SubcategoryCode: Code[20]; i: Integer)
    begin
        CategoryCode := StrSubstNo(CategoryCodeLbl, i);
        CreateSustainabilityCategory(CategoryCode, i);

        SubcategoryCode := StrSubstNo(SubcategoryCodeLbl, i);
        LibrarySustainability.InsertAccountSubcategory(CategoryCode, SubcategoryCode, SubcategoryCode, 1, 2, 3, false);
    end;

    local procedure CreateSustainabilityCategory(var CategoryCode: Code[20]; i: Integer)
    begin
        CategoryCode := StrSubstNo(CategoryCodeLbl, i);
        LibrarySustainability.InsertAccountCategory(
            CategoryCode, CategoryCode, Enum::"Emission Scope"::"Scope 1", Enum::"Calculation Foundation"::"Fuel/Electricity",
            true, true, true, '', false);
    end;

    local procedure CreateAndPostProductionOrder(var ProdItem: Record Item; var ProdOrderLine: Record "Prod. Order Line"; AccountCode: Code[20])
    var
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionOrder: Record "Production Order";
        RoutingHeader: Record "Routing Header";
        WorkCenter: Record "Work Center";
        CompItem: Record Item;
    begin
        LibraryManufacturing.CreateWorkCenterWithCalendar(WorkCenter);
        WorkCenter.Validate("Default Sust. Account", AccountCode);
        WorkCenter.Validate("CO2e per Unit", LibraryRandom.RandInt(10));
        WorkCenter.Modify();

        RoutingHeader.Get(CreateRoutingWithWorkCenter(WorkCenter, LibraryRandom.RandInt(100)));
        CreateCompItem(CompItem, AccountCode);
        PostInventoryForItem(CompItem."No.");

        CreateProductionBOM(ProductionBOMHeader, CompItem, LibraryRandom.RandInt(100));
        ProdItem.Get(ProdItem."No.");
        ProdItem.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ProdItem.Validate("Routing No.", RoutingHeader."No.");
        ProdItem.Modify();

        CreateAndRefreshProductionOrder(ProductionOrder, ProductionOrder.Status::Released, ProdItem."No.", LibraryRandom.RandIntInRange(10, 10));
        FindProdOrderLine(ProdOrderLine, ProductionOrder, ProdItem."No.");
        LibraryManufacturing.OpenProductionJournal(ProductionOrder, ProdOrderLine."Line No.");
    end;

    local procedure CreateRoutingWithWorkCenter(var WorkCenter: Record "Work Center"; CO2ePerUnit: Decimal): Code[20]
    var
        RoutingHeader: Record "Routing Header";
        RoutingLine: Record "Routing Line";
    begin
        LibraryManufacturing.CreateRoutingHeader(RoutingHeader, RoutingHeader.Type::Serial);
        LibraryManufacturing.CreateRoutingLine(RoutingHeader, RoutingLine, '', Format(LibraryRandom.RandInt(100)), RoutingLine.Type::"Work Center", WorkCenter."No.");
        if CO2ePerUnit <> 0 then begin
            RoutingLine.Validate("CO2e per Unit", CO2ePerUnit);
            RoutingLine.Modify();
        end;

        RoutingHeader.Validate(Status, RoutingHeader.Status::Certified);
        RoutingHeader.Modify(true);

        exit(RoutingHeader."No.");
    end;

    local procedure CreateCompItem(var CompItem: Record Item; AccountCode: Code[20])
    begin
        LibraryInventory.CreateItem(CompItem);
        CompItem.Validate("Default Sust. Account", AccountCode);
        CompItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        CompItem.Modify();
    end;

    local procedure PostInventoryForItem(ItemNo: Code[20])
    var
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
    begin
        SelectItemJournalBatch(ItemJournalBatch);
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name, ItemJournalLine."Entry Type"::Purchase, ItemNo, LibraryRandom.RandIntInRange(100, 100));
        LibraryInventory.PostItemJournalBatch(ItemJournalBatch);
    end;

    local procedure CreateProductionBOM(var ProductionBOMHeader: Record "Production BOM Header"; CompItem: Record Item; CO2ePerUnit: Decimal)
    var
        ProductionBOMLine: Record "Production BOM Line";
    begin
        LibraryManufacturing.CreateProductionBOMHeader(ProductionBOMHeader, CompItem."Base Unit of Measure");
        LibraryManufacturing.CreateProductionBOMLine(ProductionBOMHeader, ProductionBOMLine, '', ProductionBOMLine.Type::Item, CompItem."No.", 1);
        if CO2ePerUnit <> 0 then begin
            ProductionBOMLine.Validate("CO2e per Unit", CO2ePerUnit);
            ProductionBOMLine.Modify();
        end;
        LibraryManufacturing.UpdateProductionBOMStatus(ProductionBOMHeader, ProductionBOMHeader.Status::Certified);
    end;

    local procedure SelectItemJournalBatch(var ItemJournalBatch: Record "Item Journal Batch")
    var
        ItemJournalTemplate: Record "Item Journal Template";
    begin
        SelectItemJournalBatchByTemplateType(ItemJournalBatch, ItemJournalTemplate.Type::Item);
    end;

    local procedure SelectItemJournalBatchByTemplateType(var ItemJournalBatch: Record "Item Journal Batch"; TemplateType: Enum "Item Journal Template Type")
    var
        ItemJournalTemplate: Record "Item Journal Template";
    begin
        LibraryInventory.SelectItemJournalTemplateName(ItemJournalTemplate, TemplateType);
        LibraryInventory.SelectItemJournalBatchName(ItemJournalBatch, ItemJournalTemplate.Type, ItemJournalTemplate.Name);
    end;

    local procedure CreateAndRefreshProductionOrder(var ProductionOrder: Record "Production Order"; Status: Enum "Production Order Status"; SourceNo: Code[20]; Quantity: Decimal)
    begin
        LibraryManufacturing.CreateProductionOrder(ProductionOrder, Status, ProductionOrder."Source Type"::Item, SourceNo, Quantity);

        LibraryManufacturing.RefreshProdOrder(ProductionOrder, false, true, true, true, false);
    end;

    local procedure FindProdOrderLine(var ProdOrderLine: Record "Prod. Order Line"; ProductionOrder: Record "Production Order"; ItemNo: Code[20])
    begin
        ProdOrderLine.SetRange(Status, ProductionOrder.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProdOrderLine.SetRange("Item No.", ItemNo);
        ProdOrderLine.FindFirst();
    end;

    local procedure CreateEmissionFeeWithEmissionScope(var EmissionFee: array[3] of Record "Emission Fee"; EmissionScope: Enum "Emission Scope"; CountryRegionCode: Code[10])
    begin
        LibrarySustainability.InsertEmissionFee(
            EmissionFee[1],
            "Emission Type"::CH4,
            EmissionScope,
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegionCode,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));

        LibrarySustainability.InsertEmissionFee(
            EmissionFee[2],
            "Emission Type"::CO2,
            EmissionScope,
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegionCode,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));
        EmissionFee[2].Validate("Carbon Fee", LibraryRandom.RandDecInDecimalRange(0.5, 2, 1));
        EmissionFee[2].Modify();

        LibrarySustainability.InsertEmissionFee(
            EmissionFee[3],
            "Emission Type"::N2O,
            EmissionScope,
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegionCode,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));
    end;

    local procedure CreateAndPostPurchaseOrderWithSustAccount(var ProdItem: Record Item; AccountCode: Code[20]; PostingDate: Date; EmissionCO2: Decimal; EmissionCH4: Decimal; EmissionN2O: Decimal)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Modify();

        LibraryInventory.CreateItem(ProdItem);
        ProdItem.Validate("Costing Method", ProdItem."Costing Method"::Standard);
        ProdItem.Validate("Replenishment System", ProdItem."Replenishment System"::"Prod. Order");
        ProdItem.Validate("Default Sust. Account", AccountCode);
        ProdItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        ProdItem.Modify(true);

        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            ProdItem."No.",
            LibraryRandom.RandInt(10));

        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        UpdateReasonCodeinPurchaseHeader(PurchaseHeader);
        PostAndVerifyCancelCreditMemo(PurchaseHeader);
    end;

    local procedure UpdateReasonCodeinPurchaseHeader(var PurchaseHeader: Record "Purchase Header")
    var
        ReasonCode: Record "Reason Code";
    begin
        LibraryERM.CreateReasonCode(ReasonCode);

        PurchaseHeader.Validate("Reason Code", ReasonCode.Code);
        PurchaseHeader.Modify();
    end;

    local procedure PostAndVerifyCancelCreditMemo(PurchaseHeader: Record "Purchase Header")
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
        PostedDocNumber: Code[20];
    begin
        PostedDocNumber := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchInvHeader.Get(PostedDocNumber);
        CorrectPostedPurchInvoice.CancelPostedInvoice(PurchInvHeader);
    end;

    local procedure CreateAndPostSalesOrder(var SalesLine: Record "Sales Line"; ProdItem: Record Item; Quantity: Decimal)
    var
        SalesHeader: Record "Sales Header";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, CreateCustomer());
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, ProdItem."No.", Quantity);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
    end;

    local procedure CreateCustomer(): Code[20]
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        exit(Customer."No.");
    end;

    local procedure CreateAndPostJobJournalLine(var JobJournalLine: Record "Job Journal Line"; Item: Record Item; AccountCode: Code[20]; Quantity: Decimal; TotalCO2e: Decimal)
    var
        JobTask: Record "Job Task";
    begin
        CreateJobWithJobTask(JobTask);
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::Item, Item."No.", AccountCode, Quantity, TotalCO2e);
        LibraryJob.PostJobJournal(JobJournalLine);
    end;

    local procedure CreateJobWithJobTask(var JobTask: Record "Job Task")
    var
        Job: Record Job;
    begin
        LibraryJob.CreateJob(Job);
        LibraryJob.CreateJobTask(Job, JobTask);
    end;

    local procedure CreateJobJournalLine(var JobJournalLine: Record "Job Journal Line"; JobTask: Record "Job Task"; JobJournalLineType: Enum "Job Journal Line Type"; No: Code[20]; AccountCode: Code[20]; Quantity: Decimal; TotalCO2e: Decimal)
    begin
        LibraryJob.CreateJobJournalLineForType("Job Line Type"::" ", JobJournalLineType, JobTask, JobJournalLine);
        JobJournalLine.Validate("No.", No);
        JobJournalLine.Validate(Quantity, Quantity);
        JobJournalLine.Validate("Sust. Account No.", AccountCode);
        JobJournalLine.Validate("Total CO2e", TotalCO2e);
        JobJournalLine.Modify(true);
    end;

    local procedure CreateAndPostAssemblyOrderForInbound(var AssemblyHeader: Record "Assembly Header"; ProdItem: Record Item; Quantity: Decimal)
    var
        CompItem: Record Item;
        AssemblyLine: Record "Assembly Line";
    begin
        LibraryAssembly.CreateAssemblyHeader(AssemblyHeader, WorkDate() + 1, ProdItem."No.", '', Quantity, '');
        AssemblyHeader.Validate("Location Code", '');
        AssemblyHeader.Modify();

        LibraryInventory.CreateItem(CompItem);
        AddItemToInventory(CompItem, LibraryRandom.RandInt(1000));

        LibraryAssembly.CreateAssemblyLine(AssemblyHeader, AssemblyLine, AssemblyLine.Type::Item, CompItem."No.", CompItem."Base Unit of Measure", Quantity, 0, '');
        AssemblyLine.Validate("Sust. Account No.", ProdItem."Default Sust. Account");
        AssemblyLine.Validate("Total CO2e", LibraryRandom.RandInt(100));
        AssemblyLine.Modify();

        AssemblyHeader.Get(AssemblyHeader."Document Type", AssemblyHeader."No.");
        LibraryAssembly.PostAssemblyHeader(AssemblyHeader, '');
    end;

    local procedure CreateAndPostAssemblyOrderForOutbound(var AssemblyHeader: Record "Assembly Header"; var AssemblyLine: Record "Assembly Line"; CompItem: Record Item; Quantity: Decimal)
    var
        ProdItem: Record Item;
    begin
        LibraryInventory.CreateItem(ProdItem);
        ProdItem.Validate("Default Sust. Account", CompItem."Default Sust. Account");
        ProdItem.Modify();

        LibraryAssembly.CreateAssemblyHeader(AssemblyHeader, WorkDate() + 1, ProdItem."No.", '', Quantity, '');
        AssemblyHeader.Validate("Location Code", '');
        AssemblyHeader.Modify();

        AddItemToInventory(CompItem, LibraryRandom.RandInt(1000));
        LibraryAssembly.CreateAssemblyLine(AssemblyHeader, AssemblyLine, AssemblyLine.Type::Item, CompItem."No.", CompItem."Base Unit of Measure", Quantity, 0, '');
        AssemblyLine.Validate("Total CO2e", LibraryRandom.RandInt(100));
        AssemblyLine.Modify();

        AssemblyHeader.Get(AssemblyHeader."Document Type", AssemblyHeader."No.");
        LibraryAssembly.PostAssemblyHeader(AssemblyHeader, '');
    end;

    local procedure AddItemToInventory(Item: Record Item; Quantity: Decimal)
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
    begin
#pragma warning disable AA0210
        ItemJournalTemplate.SetRange(Type, ItemJournalTemplate.Type::Item);
        ItemJournalTemplate.SetRange(Recurring, false);
        ItemJournalTemplate.FindFirst();
#pragma warning restore AA0210
        ItemJournalBatch.SetRange("Journal Template Name", ItemJournalTemplate.Name);
        ItemJournalBatch.FindFirst();

        LibraryInventory.CreateItemJournalLine(
            ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
            ItemJournalLine."Entry Type"::"Positive Adjmt.", Item."No.", Quantity);

        LibraryInventory.PostItemJournalLine(ItemJournalTemplate.Name, ItemJournalBatch.Name);
    end;


    [ModalPageHandler]
    procedure ProductionJournalModalPageHandler(var ProductionJournal: TestPage "Production Journal")
    begin
        ProductionJournal.Post.Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [RequestPageHandler]
    procedure ItemOfConcernRequestHandler(var ItemOfConcern: TestRequestPage "Sust. Track Item Of Concern")
    begin
        ItemOfConcern.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;
}
