// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148170 "Elster ERM Batch Reports"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Elster]
    end;

    var
        Assert: Codeunit Assert;
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        IsInitialized: Boolean;
        VATStatementNameWarningMessageErr: Label 'Please make sure that as well category %1 and %2 are defined in %3 %4.', Comment = '%1 = Tax Pair Category; %2 = Tax Pair Category; %3 = VAT Statement Name Table Caption; %4 = VAT Statement Name Table Name';

    [Test]
    [HandlerFunctions('VatStatementPreviewPageHandler,VatStatementTemplateListPageHandler')]
    procedure VATStatementPreviewWithPurchaseInvoice()
    var
        Item: Record Item;
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        VATStatementLine: Record "VAT Statement Line";
        VATStatementName: Record "VAT Statement Name";
        Vendor: Record Vendor;
    begin
        // Setup: Create VAT Statement Template, Name and lines. Create and post Purchase Invoice. Calculate Base and Amount total of Vat Entries on WORKDATE.
        Initialize();
        UpdateSalesVATAdvNotificationOnVATStatementName();
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CreateItemWithVATProductPostingGroup(Item, VATPostingSetup."VAT Prod. Posting Group");
        CreateVendorWithVATBusinessPostingGroup(Vendor, VATPostingSetup."VAT Bus. Posting Group");
        CreateAndUpdateVATStatementLines(VATStatementName, VATPostingSetup, VATStatementLine."Gen. Posting Type"::Purchase);
        CreateAndPostPurchaseInvoice(Vendor."No.", Item."No.");
        CalculateBaseAndAmountOnVATEntry(VATEntry, VATPostingSetup, VATEntry.Type::Purchase);

        // Exercise: Open VAT Statement Preview page from VAT Statement.
        EnqueueValuesForVATStatementPreviewPageHandler(VATEntry, VATStatementName."Statement Template Name", Format(1), Format(2));
        OpenVATStatementPreviewPageFromVATStatement(VATStatementName.Name);

        // Verify: Verification is done in VatStatementPreviewPageHandler.

        // Tear Down.
        VATStatementName.Delete(true);
    end;

    [Test]
    [HandlerFunctions('VatStatementPreviewPageHandler,VatStatementTemplateListPageHandler')]
    procedure VATStatementPreviewWithSalesInvoice()
    var
        Customer: Record Customer;
        Item: Record Item;
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        VATStatementLine: Record "VAT Statement Line";
        VATStatementName: Record "VAT Statement Name";
    begin
        // Setup: Create VAT Statement Template, Name and lines. Create and post Sales Invoice. Calculate Base and Amount total of Vat Entries on WORKDATE.
        Initialize();
        UpdateSalesVATAdvNotificationOnVATStatementName();
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CreateItemWithVATProductPostingGroup(Item, VATPostingSetup."VAT Prod. Posting Group");
        CreateCustomerWithVATBusinessPostingGroup(Customer, VATPostingSetup."VAT Bus. Posting Group");
        CreateAndUpdateVATStatementLines(VATStatementName, VATPostingSetup, VATStatementLine."Gen. Posting Type"::Sale);
        CreateAndPostSalesInvoice(Customer."No.", Item."No.");
        CalculateBaseAndAmountOnVATEntry(VATEntry, VATPostingSetup, VATEntry.Type::Sale);

        // Exercise: Open VAT Statement Preview page from VAT Statement.
        EnqueueValuesForVATStatementPreviewPageHandler(VATEntry, VATStatementName."Statement Template Name", Format(1), Format(2));
        OpenVATStatementPreviewPageFromVATStatement(VATStatementName.Name);

        // Verify: Verification is done in VatStatementPreviewPageHandler.

        // Tear Down.
        VATStatementName.Delete(true);
    end;

    [Test]
    [HandlerFunctions('CreateXMLFileVATAdvNotifHandler')]
    procedure ErrorOnCreateXMLFileOnSalesVATAdvNotificationCard()
    var
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        VATStatementLine: Record "VAT Statement Line";
        VATStatementName: Record "VAT Statement Name";
        Vendor: Record Vendor;
        SalesVATAdvNotifCard: TestPage "Sales VAT Adv. Notif. Card";
        No: Code[20];
    begin
        // Setup: Find VAT Posting Setup with Zero Percent. Create VAT Statement Template, Name and lines. Create and post Purchase Invoice. Create Sales VAT Advance Notification card.
        Initialize();
        UpdateSalesVATAdvNotificationOnVATStatementName();
        FindVATPostingSetupWithZeroVATPercent(VATPostingSetup);
        CreateItemWithVATProductPostingGroup(Item, VATPostingSetup."VAT Prod. Posting Group");
        CreateVendorWithVATBusinessPostingGroup(Vendor, VATPostingSetup."VAT Bus. Posting Group");
        CreateVATStatementTemplateWithName(VATStatementName);

        // Values required for Row No.
        CreateAndUpdateVATStatementLine(
          VATStatementName, VATPostingSetup, '78', VATStatementLine."Gen. Posting Type"::Purchase,
          VATStatementLine."Amount Type"::Base);  // Value 78 required for Row No.
        CreateAndUpdateVATStatementLine(
          VATStatementName, VATPostingSetup, '79', VATStatementLine."Gen. Posting Type"::Purchase,
          VATStatementLine."Amount Type"::Amount);  // Value 79 required for Row No.
        CreateAndPostPurchaseInvoice(Vendor."No.", Item."No.");
        No := LibraryUtility.GenerateGUID();
        CreateSalesVATAdvanceNotificationCard(No);

        // Exercise.
        SalesVATAdvNotifCard.OpenEdit();
        Commit();  // COMMIT is required to handle CreateXMLFileVATAdvNotif Request page.
        SalesVATAdvNotifCard.Filter.SetFilter("No.", No);
        asserterror SalesVATAdvNotifCard.CreateXMLFile.Invoke();

        // Verify.
        Assert.ExpectedError(StrSubstNo(VATStatementNameWarningMessageErr, 78, 79, VATStatementName.TableCaption(),
            VATStatementName.Name));  // Value 78 and 79 required for Row No.

        // Tear Down.
        VATStatementName.Delete(true);
    end;

    [Test]
    [HandlerFunctions('VatStatementPreviewVerifyFiltersPageHandler')]
    procedure VATStatementPreviewInheritFiltersFromSalesAdvNotificationCard()
    var
        VATStatementLine: Record "VAT Statement Line";
        VATStatementName: Record "VAT Statement Name";
        VATPostingSetup: Record "VAT Posting Setup";
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        SalesVATAdvNotifCard: TestPage "Sales VAT Adv. Notif. Card";
        No: Code[20];
    begin
        // [FETURE] [UI]
        // [SCENARIO 395630] Stan see the same data in the VAT statement preview page that he had specified in the Sales advance notification card

        Initialize();
        UpdateSalesVATAdvNotificationOnVATStatementName();
        CreateAndUpdateVATStatementLines(VATStatementName, VATPostingSetup, VATStatementLine."Gen. Posting Type"::Purchase);
        Commit();
        No := LibraryUtility.GenerateGUID();
        CreateSalesVATAdvanceNotificationCard(No);

        // [GIVEN] Sales VAT advance notification with "Incl. VAT Entries (Period)" = "Within Period", "Incl. VAT Entries (Closing)" = "Open and Closed"
        // [GIVEN] and "Starting Date" = 01.01.2020
        SalesVATAdvanceNotif.Get(No);
        SalesVATAdvanceNotif.Validate("Incl. VAT Entries (Period)", SalesVATAdvanceNotif."Incl. VAT Entries (Period)"::"Within Period");
        SalesVATAdvanceNotif.Validate("Incl. VAT Entries (Closing)", SalesVATAdvanceNotif."Incl. VAT Entries (Closing)"::"Open and Closed");
        SalesVATAdvanceNotif.Validate(Period, SalesVATAdvanceNotif.Period::Month);
        SalesVATAdvanceNotif.Modify(true);
        LibraryVariableStorage.Enqueue(SalesVATAdvanceNotif."Starting Date");
        LibraryVariableStorage.Enqueue(SalesVATAdvanceNotif."Incl. VAT Entries (Period)");
        LibraryVariableStorage.Enqueue(SalesVATAdvanceNotif."Incl. VAT Entries (Closing)");

        // [GIVEN] Sales VAT advance notification card is opened
        SalesVATAdvNotifCard.OpenEdit();
        SalesVATAdvNotifCard.Filter.SetFilter("No.", No);

        // [WHEN] Stan press "Preview"
        SalesVATAdvNotifCard."P&review".Invoke();

        // [THEN] Stan can see the following values in the VAT statement preview page
        // [THEN] "Period" = "Within Period", "Selection" = "Open and Close", "Date filter" = "01.01.2020"
        // TFS ID 404200: A date filter passed to the VAT Statemenet Preview page from the Sales VAT Adv. Notification Card page correctly
        // Verified in VatStatementPreviewVerifyFiltersPageHandler

        LibraryVariableStorage.AssertEmpty();

        // Tear Down.
        VATStatementName.Delete(true);
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Elster ERM Batch Reports");
        LibraryVariableStorage.Clear();
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Elster ERM Batch Reports");

        IsInitialized := TRUE;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Elster ERM Batch Reports");
    end;

    local procedure CalculateBaseAndAmountOnVATEntry(var VATEntry: Record "VAT Entry"; VATPostingSetup: Record "VAT Posting Setup"; Type: Option)
    begin
        VATEntry.SetRange("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        VATEntry.SetRange("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        VATEntry.SetRange(Type, Type);
        VATEntry.SetRange("Posting Date", WorkDate());
        VATEntry.CalcSums(Base, Amount);
    end;

    local procedure CreateAndPostPurchaseInvoice(VendorNo: Code[20]; ItemNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendorNo);
        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, ItemNo, LibraryRandom.RandDec(10, 2));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDec(10, 2));
        PurchaseLine.Modify(true);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);  // Post as Receive and Invoice.
    end;

    local procedure CreateAndPostSalesInvoice(CustomerNo: Code[20]; ItemNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, CustomerNo);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, ItemNo, LibraryRandom.RandDec(10, 2));
        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(10, 2));
        SalesLine.Modify(true);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);  // Post as Ship and Invoice.
    end;

    local procedure CreateAndUpdateVATStatementLine(VATStatementName: Record "VAT Statement Name"; VATPostingSetup: Record "VAT Posting Setup"; RowNo: Code[10]; GeneralPostingType: Option; AmountType: Option)
    var
        VATStatementLine: Record "VAT Statement Line";
    begin
        LibraryERM.CreateVATStatementLine(VATStatementLine, VATStatementName."Statement Template Name", VATStatementName.Name);
        VATStatementLine.Validate("Row No.", RowNo);
        VATStatementLine.Validate(Type, VATStatementLine.Type::"VAT Entry Totaling");
        VATStatementLine.Validate("Gen. Posting Type", GeneralPostingType);
        VATStatementLine.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        VATStatementLine.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        VATStatementLine.Validate("Amount Type", AmountType);
        VATStatementLine.Modify(true);
    end;

    local procedure CreateAndUpdateVATStatementLines(var VATStatementName: Record "VAT Statement Name"; var VATPostingSetup: Record "VAT Posting Setup"; GenPostingType: Option)
    var
        VATStatementLine: Record "VAT Statement Line";
    begin
        CreateVATStatementTemplateWithName(VATStatementName);
        CreateAndUpdateVATStatementLine(
          VATStatementName, VATPostingSetup, Format(1), GenPostingType,
          VATStatementLine."Amount Type"::Base);  // Value 1 required for Row No.
        CreateAndUpdateVATStatementLine(
          VATStatementName, VATPostingSetup, Format(2), GenPostingType,
          VATStatementLine."Amount Type"::Amount);  // Value 2 required for Row No.
    end;

    local procedure CreateCustomerWithVATBusinessPostingGroup(var Customer: Record Customer; VATBusinessPostingGroup: Code[20])
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("VAT Bus. Posting Group", VATBusinessPostingGroup);
        Customer.Modify(true);
    END;

    local procedure CreateItemWithVATProductPostingGroup(var Item: Record Item; VATProductPostingGroup: Code[20])
    begin
        LibraryInventory.CreateItem(Item);
        Item.Validate("VAT Prod. Posting Group", VATProductPostingGroup);
        Item.Modify(true);
    end;

    local procedure CreateSalesVATAdvanceNotificationCard(No: Code[20])
    var
        SalesVATAdvNotifCard: TestPage "Sales VAT Adv. Notif. Card";
    begin
        SalesVATAdvNotifCard.OpenNew();
        SalesVATAdvNotifCard."No.".SetValue(No);
        SalesVATAdvNotifCard."Starting Date".SetValue(DMY2Date(1, 1, Date2DMY(WorkDate(), 3)));
        SalesVATAdvNotifCard."Contact for Tax Office".SetValue(No);
        SalesVATAdvNotifCard.OK().Invoke();
    end;

    local procedure CreateVATStatementTemplateWithName(var VATStatementName: Record "VAT Statement Name")
    var
        VATStatementTemplate: Record "VAT Statement Template";
    begin
        LibraryERM.CreateVATStatementTemplate(VATStatementTemplate);
        LibraryERM.CreateVATStatementName(VATStatementName, VATStatementTemplate.Name);
        VATStatementName.Validate("Sales VAT Adv. Notif.", true);
        VATStatementName.Modify(true);
    end;

    local procedure CreateVendorWithVATBusinessPostingGroup(var Vendor: Record Vendor; VATBusinessPostingGroup: Code[20])
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("VAT Bus. Posting Group", VATBusinessPostingGroup);
        Vendor.Modify(true);
    end;

    local procedure EnqueueValuesForVATStatementPreviewPageHandler(VATEntry: Record "VAT Entry"; VATStatementTemplateName: Code[10]; RowNo: Code[10]; RowNo2: Code[10])
    begin
        LibraryVariableStorage.Enqueue(VATStatementTemplateName);  // Enqueue for VatStatementTemplateListPageHandler.
        LibraryVariableStorage.Enqueue(VATEntry.Base);  // Enqueue for VatStatementPreviewPageHandler.
        LibraryVariableStorage.Enqueue(VATEntry.Amount);  // Enqueue for VatStatementPreviewPageHandler.
        LibraryVariableStorage.Enqueue(RowNo);  // Enqueue for VatStatementPreviewPageHandler.
        LibraryVariableStorage.Enqueue(RowNo2);  // Enqueue for VatStatementPreviewPageHandler.
    end;

    local procedure FindVATPostingSetupWithZeroVATPercent(var VATPostingSetup: Record "VAT Posting Setup")
    begin
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        VATPostingSetup.SetRange("VAT %", 0);
        VATPostingSetup.FindFirst();
    end;

    local procedure OpenVATStatementPreviewPageFromVATStatement(CurrentStatementName: Code[10])
    var
        VATStatement: TestPage "VAT Statement";
    begin
        VATStatement.OpenEdit();
        VATStatement.CurrentStmtName.SetValue(CurrentStatementName);
        VATStatement."P&review".Invoke();
    end;

    local procedure UpdateSalesVATAdvNotificationOnVATStatementName()
    var
        VATStatementName: Record "VAT Statement Name";
    begin
        VATStatementName.SetRange("Sales VAT Adv. Notif.", true);
        VATStatementName.ModifyAll("Sales VAT Adv. Notif.", false);
    end;

    [PageHandler]
    procedure VatStatementPreviewPageHandler(var VATStatementPreview: TestPage "VAT Statement Preview")
    var
        TotalBase: Variant;
        TotalAmount: Variant;
        RowNo: Variant;
    begin
        LibraryVariableStorage.Dequeue(TotalBase);
        LibraryVariableStorage.Dequeue(TotalAmount);
        LibraryVariableStorage.Dequeue(RowNo);
        VATStatementPreview.DateFilter.SetValue(WorkDate());
        VATStatementPreview.PeriodSelection.SetValue(VATStatementPreview.PeriodSelection.GetOption(2));  // Option 2 used for Within Period.
        VATStatementPreview.VATStatementLineSubForm.Filter.SetFilter("Row No.", RowNo);
        VATStatementPreview.VATStatementLineSubForm.TotalBase.AssertEquals(TotalBase);
        LibraryVariableStorage.Dequeue(RowNo);
        VATStatementPreview.VATStatementLineSubForm.Filter.SetFilter("Row No.", RowNo);
        VATStatementPreview.VATStatementLineSubForm.TotalAmount.AssertEquals(TotalAmount);
    end;

    [PageHandler]
    procedure VatStatementPreviewVerifyFiltersPageHandler(var VATStatementPreview: TestPage "VAT Statement Preview")
    var
        StartingDate: Date;
    begin
        StartingDate := LibraryVariableStorage.DequeueDate();
        VATStatementPreview.DateFilter.AssertEquals(StrSubstNo('%1..%2', StartingDate, CalcDate('<CM>', StartingDate)));
        VATStatementPreview.PeriodSelection.AssertEquals(LibraryVariableStorage.DequeueInteger());
        VATStatementPreview.Selection.AssertEquals(LibraryVariableStorage.DequeueInteger());
    end;

    [ModalPageHandler]
    procedure VatStatementTemplateListPageHandler(var VATStatementTemplateList: TestPage "VAT Statement Template List")
    var
        DequeueVariable: Variant;
    begin
        LibraryVariableStorage.Dequeue(DequeueVariable);
        VATStatementTemplateList.Filter.SetFilter(Name, DequeueVariable);
        VATStatementTemplateList.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure CreateXMLFileVATAdvNotifHandler(var CreateXMLFileVATAdvNotif: TestRequestPage "Create XML-File VAT Adv.Notif.");
    begin
        CreateXMLFileVATAdvNotif.OK().Invoke();
    end;


}