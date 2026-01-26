// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Tests;

using Microsoft.Foundation.Company;
using Microsoft.Foundation.Reporting;
using Microsoft.Foundation.UOM;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Setup;
using Microsoft.Test.Sustainability;
using System.Reflection;
using System.Utilities;

codeunit 148217 "Sustainability Report Tests"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibrarySustainability: Codeunit "Library - Sustainability";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        IsInitialized: Boolean;
        AccountCodeLbl: Label 'AccountCode%1', Comment = '%1 = Number';
        CategoryCodeLbl: Label 'CategoryCode%1', Comment = '%1 = Number';
        SubcategoryCodeLbl: Label 'SubcategoryCode%1', Comment = '%1 = Number';
        MSXLbl: Label 'MSX%1', Comment = '%1 = random number for unique layout code';
        MSXILbl: Label 'MSXI%1', Comment = '%1 = random number for unique layout code';
        DocxLbl: Label 'docx';
        TotalCO2eLbl: Label 'TotalCO2e';
        CO2ePerUnitLineLbl: Label 'CO2ePerUnit_Line';
        DisclaimerLbl: Label 'Disclaimer_Lbl';
        CO2ePerUnitTagLbl: Label 'CO2ePerUnit_Lbl';
        TotalCO2eTagLbl: Label 'TotalCO2e_Lbl';
        ReportDisclaimerLbl: Label 'Disclaimer %1', Comment = '%1 = Random Value';
        CO2ePerUnitCaptionLbl: Label 'CO2e [%1] per Unit', Comment = '%1 = Unit Of Measure Code';
        TotalCO2eCaptionLbl: Label 'Total CO2e [%1]', Comment = '%1 = Unit Of Measure Code';

    [Test]
    [HandlerFunctions('StandardSalesQuoteRequestPageHandler')]
    procedure VerifyTotalCO2eAndDisclaimerInStandardSalesQuote()
    var
        SustainabilitySetup: Record "Sustainability Setup";
        UnitOfMeasure: Record "Unit of Measure";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CustomReportLayout: Record "Custom Report Layout";
        ExpectedCO2ePerUnit: Decimal;
        ExpectedTotalCO2e: Decimal;
        ExpectedFormatCO2ePerUnit: Text;
        ExpectedFormatTotalCO2e: Text;
        ExpectedDisclaimerTxt: Text[100];
    begin
        // [SCENARIO 580130] Verify "CO2e per Unit", "Total CO2e" and Disclaimer for Standard ESG Sales Quote Report.
        Initialize();

        // [GIVEN] Select "Standard Sales - Quote" report in report selections for Sales Quote.
        LibraryERM.SetupReportSelection("Report Selection Usage"::"S.Quote", Report::"Standard Sales - Quote");

        // [GIVEN] Create Unit of Measure.
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] Update "Emission Unit of Measure Code" in Sustainability Setup.
        UpdateEmissionUnitOfMeasureInSustainabilitySetup(UnitOfMeasure.Code);

        // [GIVEN] Select layout as Custom Body Layout in "Standard Sales-Quote" report.
        GetCustomBodyLayout(CustomReportLayout, GetStandardSalesQuoteReportID());

        // [GIVEN] Generate Random CO2e per Unit.
        ExpectedCO2ePerUnit := LibraryRandom.RandDec(20, 2);

        // [GIVEN] Create a Sales Quote.
        CreateSalesQuote(SalesHeader, SalesLine);
        SalesLine.Validate("CO2e per Unit", ExpectedCO2ePerUnit);
        SalesLine.Modify(true);

        // [GIVEN] Calculate Expected Total CO2e.
        ExpectedTotalCO2e := SalesLine.Quantity * SalesLine."Qty. per Unit of Measure" * ExpectedCO2ePerUnit;

        // [GIVEN] Format the Expected CO2e and Total CO2e values.
        SustainabilitySetup.Get();
        ExpectedFormatCO2ePerUnit := Format(ExpectedCO2ePerUnit, 0, SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places")));
        ExpectedFormatTotalCO2e := Format(ExpectedTotalCO2e, 0, SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places")));

        // [GIVEN] Generate Expected Disclaimer.
        ExpectedDisclaimerTxt := CopyStr(StrSubstNo(ReportDisclaimerLbl, LibraryRandom.RandIntInRange(10000, 99999)), 1, MaxStrLen(ExpectedDisclaimerTxt));

        // [GIVEN] Insert Disclaimer for Sales Quote.
        InsertDisclaimerForSalesQuote(ExpectedDisclaimerTxt);

        // [GIVEN] Save the transaction.
        Commit();

        // [WHEN] Run the Standard Sales - Quote report.
        RunStandardSalesQuoteReport(SalesHeader."No.");

        // [THEN] Verify the dataset contains 'CO2ePerUnit_Line', 'TotalCO2e' and 'Disclaimer' with the expected formatted value.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.AssertElementTagWithValueExists(TotalCO2eLbl, ExpectedFormatTotalCO2e);
        LibraryReportDataset.AssertElementTagWithValueExists(CO2ePerUnitLineLbl, ExpectedFormatCO2ePerUnit);
        LibraryReportDataset.AssertElementTagWithValueExists(DisclaimerLbl, ExpectedDisclaimerTxt);
    end;

    [Test]
    [HandlerFunctions('StandardSalesQuoteWithoutDisclaimerRequestPageHandler')]
    procedure VerifyCO2ePerUnitAndTotalCO2eCaptionInStandardSalesQuote()
    var
        UnitOfMeasure: Record "Unit of Measure";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CustomReportLayout: Record "Custom Report Layout";
        ExpectedCO2ePerUnitCaption: Text;
        ExpectedTotalCO2eCaption: Text;
    begin
        // [SCENARIO 580130] Verify "CO2e per Unit" and "Total CO2e" caption for Standard ESG Sales Quote Report.
        Initialize();

        // [GIVEN] Select "Standard Sales - Quote" report in report selections for Sales Quote.
        LibraryERM.SetupReportSelection("Report Selection Usage"::"S.Quote", Report::"Standard Sales - Quote");

        // [GIVEN] Create Unit of Measure.
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] Update "Emission Unit of Measure Code" in Sustainability Setup.
        UpdateEmissionUnitOfMeasureInSustainabilitySetup(UnitOfMeasure.Code);

        // [GIVEN] Select layout as Custom Body Layout in "Standard Sales-Quote" report.
        GetCustomBodyLayout(CustomReportLayout, GetStandardSalesQuoteReportID());

        // [GIVEN] Create a Sales Quote.
        CreateSalesQuote(SalesHeader, SalesLine);

        // [GIVEN] Save the transaction.
        Commit();

        // [GIVEN] Generate Expected Caption for CO2e per Unit and Total CO2e.
        ExpectedCO2ePerUnitCaption := StrSubstNo(CO2ePerUnitCaptionLbl, UnitOfMeasure.Code);
        ExpectedTotalCO2eCaption := StrSubstNo(TotalCO2eCaptionLbl, UnitOfMeasure.Code);

        // [WHEN] Run the Standard Sales - Quote report.
        RunStandardSalesQuoteReport(SalesHeader."No.");

        // [THEN] Verify the dataset contains 'CO2ePerUnit_Lbl' and 'TotalCO2e_Lbl' with the expected caption values.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.AssertElementTagWithValueExists(CO2ePerUnitTagLbl, ExpectedCO2ePerUnitCaption);
        LibraryReportDataset.AssertElementTagWithValueExists(TotalCO2eTagLbl, ExpectedTotalCO2eCaption);
    end;

    [Test]
    [HandlerFunctions('StandardSalesInvoiceRequestPageHandler')]
    procedure VerifyTotalCO2eAndDisclaimerInStandardSalesInvoice()
    var
        SustainabilitySetup: Record "Sustainability Setup";
        UnitOfMeasure: Record "Unit of Measure";
        CustomReportLayout: Record "Custom Report Layout";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Quantity: Decimal;
        ExpectedCO2ePerUnit: Decimal;
        ExpectedTotalCO2e: Decimal;
        ExpectedFormatCO2ePerUnit: Text;
        ExpectedFormatTotalCO2e: Text;
        ExpectedDisclaimerTxt: Text[100];
    begin
        // [SCENARIO 580131] Verify "CO2e per Unit", "Total CO2e" and Disclaimer for Standard ESG Sales Invoice Report.
        Initialize();

        // [GIVEN] Select "Standard Sales - Invoice" report in report selections for Sales Invoice.
        LibraryERM.SetupReportSelection("Report Selection Usage"::"S.Invoice", Report::"Standard Sales - Invoice");

        // [GIVEN] Create Unit of Measure.
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] Update "Emission Unit of Measure Code" in Sustainability Setup.
        UpdateEmissionUnitOfMeasureInSustainabilitySetup(UnitOfMeasure.Code);

        // [GIVEN] Select layout as Custom Body Layout in "Standard Sales-Invoice" report.
        GetCustomBodyLayout(CustomReportLayout, GetStandardSalesInvoiceReportID());

        // [GIVEN] Generate Random CO2e per Unit and Quantity.
        ExpectedCO2ePerUnit := LibraryRandom.RandDec(20, 2);
        Quantity := LibraryRandom.RandInt(1);

        // [GIVEN] Create and post a Sales Order.
        CreateAndPostSalesOrder(SalesInvoiceHeader, ExpectedCO2ePerUnit, Quantity);

        // [GIVEN] Calculate Expected Total CO2e.
        ExpectedTotalCO2e := Quantity * ExpectedCO2ePerUnit;

        // [GIVEN] Format the Expected CO2e and Total CO2e values.
        SustainabilitySetup.Get();
        ExpectedFormatCO2ePerUnit := Format(ExpectedCO2ePerUnit, 0, SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places")));
        ExpectedFormatTotalCO2e := Format(ExpectedTotalCO2e, 0, SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places")));

        // [GIVEN] Generate Expected Disclaimer.
        ExpectedDisclaimerTxt := CopyStr(StrSubstNo(ReportDisclaimerLbl, LibraryRandom.RandIntInRange(10000, 99999)), 1, MaxStrLen(ExpectedDisclaimerTxt));

        // [GIVEN] Insert Disclaimer for Posted Sales Invoice.
        InsertDisclaimerForPostedSalesInvoice(ExpectedDisclaimerTxt);

        // [GIVEN] Save the transaction.
        Commit();

        // [WHEN] Run the Standard Sales - Invoice report.
        RunStandardSalesInvoiceReport(SalesInvoiceHeader."No.");

        // [THEN] Verify the dataset contains 'CO2ePerUnit_Line', 'TotalCO2e' and 'Disclaimer' with the expected formatted value.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.AssertElementTagWithValueExists(TotalCO2eLbl, ExpectedFormatTotalCO2e);
        LibraryReportDataset.AssertElementTagWithValueExists(CO2ePerUnitLineLbl, ExpectedFormatCO2ePerUnit);
        LibraryReportDataset.AssertElementTagWithValueExists(DisclaimerLbl, ExpectedDisclaimerTxt);
    end;

    [Test]
    [HandlerFunctions('StandardSalesInvoiceWithoutDisclaimerRequestPageHandler')]
    procedure VerifyCO2ePerUnitAndTotalCO2eCaptionInStandardSalesInvoice()
    var
        UnitOfMeasure: Record "Unit of Measure";
        CustomReportLayout: Record "Custom Report Layout";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Quantity: Decimal;
        ExpectedCO2ePerUnit: Decimal;
        ExpectedCO2ePerUnitCaption: Text;
        ExpectedTotalCO2eCaption: Text;
    begin
        // [SCENARIO 580131] Verify "CO2e per Unit" and "Total CO2e" caption for Standard ESG Sales Invoice Report.
        Initialize();

        // [GIVEN] Select "Standard Sales - Invoice" report in report selections for Sales Invoice.
        LibraryERM.SetupReportSelection("Report Selection Usage"::"S.Invoice", Report::"Standard Sales - Invoice");

        // [GIVEN] Create Unit of Measure.
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] Update "Emission Unit of Measure Code" in Sustainability Setup.
        UpdateEmissionUnitOfMeasureInSustainabilitySetup(UnitOfMeasure.Code);

        // [GIVEN] Select layout as Custom Body Layout in "Standard Sales-Invoice" report.
        GetCustomBodyLayout(CustomReportLayout, GetStandardSalesInvoiceReportID());

        // [GIVEN] Generate Random CO2e per Unit and Quantity.
        ExpectedCO2ePerUnit := LibraryRandom.RandDec(20, 2);
        Quantity := LibraryRandom.RandInt(1);

        // [GIVEN] Create and post a Sales Order.
        CreateAndPostSalesOrder(SalesInvoiceHeader, ExpectedCO2ePerUnit, Quantity);

        // [GIVEN] Save the transaction.
        Commit();

        // [GIVEN] Generate Expected Caption for CO2e per Unit and Total CO2e.
        ExpectedCO2ePerUnitCaption := StrSubstNo(CO2ePerUnitCaptionLbl, UnitOfMeasure.Code);
        ExpectedTotalCO2eCaption := StrSubstNo(TotalCO2eCaptionLbl, UnitOfMeasure.Code);

        // [WHEN] Run the Standard Sales - Invoice report.
        RunStandardSalesInvoiceReport(SalesInvoiceHeader."No.");

        // [THEN] Verify the dataset contains 'CO2ePerUnit_Lbl' and 'TotalCO2e_Lbl' with the expected caption values.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.AssertElementTagWithValueExists(CO2ePerUnitTagLbl, ExpectedCO2ePerUnitCaption);
        LibraryReportDataset.AssertElementTagWithValueExists(TotalCO2eTagLbl, ExpectedTotalCO2eCaption);
    end;

    local procedure Initialize()
    var
        CompanyInformation: Record "Company Information";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Sustainability Report Tests");
        LibrarySustainability.CleanUpBeforeTesting();
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Sustainability Report Tests");

        LibrarySales.SetCreditWarningsToNoWarnings();
        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        LibraryERMCountryData.CreateGeneralPostingSetupData();
        LibraryERMCountryData.UpdateVATPostingSetup();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERMCountryData.UpdateLocalData();
        LibrarySales.SetExtDocNo(false);

        CompanyInformation.Get();
        CompanyInformation."Allow Blank Payment Info." := true;
        CompanyInformation.Modify(false);

        LibraryERMCountryData.CompanyInfoSetVATRegistrationNo();
        IsInitialized := true;

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Sustainability Report Tests");
    end;

    local procedure GetCustomBodyLayout(var CustomReportLayout: Record "Custom Report Layout"; ReportID: Integer)
    var
        ReportLayoutList: Record "Report Layout List";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
    begin
        CustomReportLayout.SetRange("Report ID", ReportID);
        CustomReportLayout.SetRange(Type, CustomReportLayout.Type::Word);
        if CustomReportLayout.FindLast() then
            exit;

        ReportLayoutList.SetRange("Report ID", ReportID);
        ReportLayoutList.SetRange("Layout Format", ReportLayoutList."Layout Format"::Word);
        ReportLayoutList.FindFirst();

        TempBlob.CreateOutStream(OutStr);
        ReportLayoutList.Layout.ExportStream(OutStr);
        TempBlob.CreateInStream(InStr);

        CustomReportLayout.Init();
        CustomReportLayout."Report ID" := ReportID;
        if ReportID = Report::"Standard Sales - Quote" then
            CustomReportLayout.Code := CopyStr(StrSubstNo(MSXLbl, LibraryRandom.RandIntInRange(100, 200)), 1, 10)
        else
            CustomReportLayout.Code := CopyStr(StrSubstNo(MSXILbl, LibraryRandom.RandIntInRange(100, 200)), 1, 10);
        CustomReportLayout."File Extension" := DocxLbl;
        CustomReportLayout.Type := CustomReportLayout.Type::Word;
        CustomReportLayout.Layout.CreateOutStream(OutStr);
        CopyStream(OutStr, InStr);
        CustomReportLayout.Insert();
    end;

    local procedure CreateSustainabilityCategory(var CategoryCode: Code[20]; i: Integer)
    begin
        CategoryCode := StrSubstNo(CategoryCodeLbl, i);
        LibrarySustainability.InsertAccountCategory(
            CategoryCode, CategoryCode, Enum::"Emission Scope"::"Scope 1", Enum::"Calculation Foundation"::"Fuel/Electricity",
            true, true, true, '', false);
    end;

    local procedure CreateSustainabilitySubcategory(var CategoryCode: Code[20]; var SubcategoryCode: Code[20]; i: Integer)
    begin
        CategoryCode := StrSubstNo(CategoryCodeLbl, i);
        CreateSustainabilityCategory(CategoryCode, i);

        SubcategoryCode := StrSubstNo(SubcategoryCodeLbl, i);
        LibrarySustainability.InsertAccountSubcategory(CategoryCode, SubcategoryCode, SubcategoryCode, 1, 2, 3, false);
    end;

    local procedure CreateSustainabilityAccount(var AccountCode: Code[20]; var CategoryCode: Code[20]; var SubcategoryCode: Code[20]; i: Integer): Record "Sustainability Account"
    begin
        CreateSustainabilitySubcategory(CategoryCode, SubcategoryCode, i);
        AccountCode := StrSubstNo(AccountCodeLbl, i);
        exit(LibrarySustainability.InsertSustainabilityAccount(
            AccountCode, '', CategoryCode, SubcategoryCode, Enum::"Sustainability Account Type"::Posting, '', true));
    end;

    local procedure UpdateEmissionUnitOfMeasureInSustainabilitySetup(EmissionUoMCode: Code[10])
    var
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        SustainabilitySetup.Get();
        SustainabilitySetup.Validate("Emission Unit of Measure Code", EmissionUoMCode);
        SustainabilitySetup.Modify();
    end;

    local procedure CreateSalesQuote(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        SustainabilityAccount: Record "Sustainability Account";
        AccountNo: Code[20];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
    begin
        SustainabilityAccount := CreateSustainabilityAccount(AccountNo, CategoryCode, SubcategoryCode, 1);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, LibrarySales.CreateCustomerNo());

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(1));
        SalesLine.Validate("Sust. Account No.", SustainabilityAccount."No.");
        SalesLine.Modify(true);
    end;

    local procedure CreateAndPostSalesOrder(var SalesInvoiceHeader: Record "Sales Invoice Header"; CO2ePerUnit: Decimal; Quantity: Decimal)
    var
        SustainabilityAccount: Record "Sustainability Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        AccountNo: Code[20];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
    begin
        SustainabilityAccount := CreateSustainabilityAccount(AccountNo, CategoryCode, SubcategoryCode, 1);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, LibrarySales.CreateCustomerNo());

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItemNo(), Quantity);
        SalesLine.Validate("Sust. Account No.", SustainabilityAccount."No.");
        SalesLine.Validate("CO2e per Unit", CO2ePerUnit);
        SalesLine.Modify(true);

        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure InsertDisclaimerForSalesQuote(Disclaimer: Text)
    var
        SustainabilityDisclaimer: Record "Sustainability Disclaimer";
    begin
        SustainabilityDisclaimer.Init();
        SustainabilityDisclaimer.Validate("Document Type", SustainabilityDisclaimer."Document Type"::"Sales Quote");
        SustainabilityDisclaimer.Validate(Disclaimer, Disclaimer);
        SustainabilityDisclaimer.Insert();
    end;

    local procedure InsertDisclaimerForPostedSalesInvoice(Disclaimer: Text)
    var
        SustainabilityDisclaimer: Record "Sustainability Disclaimer";
    begin
        SustainabilityDisclaimer.Init();
        SustainabilityDisclaimer.Validate("Document Type", SustainabilityDisclaimer."Document Type"::"Posted Sales Invoice");
        SustainabilityDisclaimer.Validate(Disclaimer, Disclaimer);
        SustainabilityDisclaimer.Insert();
    end;

    local procedure GetStandardSalesQuoteReportID(): Integer
    begin
        exit(Report::"Standard Sales - Quote");
    end;

    local procedure GetStandardSalesInvoiceReportID(): Integer
    begin
        exit(Report::"Standard Sales - Invoice");
    end;

    local procedure RunStandardSalesQuoteReport(QuoteNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("No.", QuoteNo);

        Report.Run(Report::"Standard Sales - Quote", true, false, SalesHeader);
    end;

    local procedure RunStandardSalesInvoiceReport(InvoiceNo: Code[20])
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.SetRange("No.", InvoiceNo);

        Report.Run(Report::"Standard Sales - Invoice", true, false, SalesInvoiceHeader);
    end;

    [RequestPageHandler]
    procedure StandardSalesQuoteRequestPageHandler(var StandardSalesQuote: TestRequestPage "Standard Sales - Quote")
    begin
        StandardSalesQuote.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure StandardSalesQuoteWithoutDisclaimerRequestPageHandler(var StandardSalesQuote: TestRequestPage "Standard Sales - Quote")
    begin
        StandardSalesQuote.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure StandardSalesInvoiceRequestPageHandler(var StandardSalesInvoice: TestRequestPage "Standard Sales - Invoice")
    begin
        StandardSalesInvoice.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure StandardSalesInvoiceWithoutDisclaimerRequestPageHandler(var StandardSalesInvoice: TestRequestPage "Standard Sales - Invoice")
    begin
        StandardSalesInvoice.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;
}