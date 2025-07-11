// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148165 "Elster Tables UT"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Elster] [UT]
    end;

    var
        LibraryUTUtility: Codeunit "Library UT Utility";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit "Assert";
        LibraryRandom: Codeunit "Library - Random";
        SameValueMsg: Label 'Value must be same.';
        WrongPlaceErr: Label 'Places of %1 in area %2 must be %3.', Comment = '%1 = Registration No. Field Caption; %2 = Tax Office Area; %3 = Registration No. Length';
        CannotChangeXMLFileErr: Label 'You cannot change the value of this field anymore after the XML-File for the %1 has been created.', Comment = '%1 = Sales VAT Advance Notif. Table Caption';

    [Test]
    procedure OnInsertVATStatNameError()
    var
        VATStatementName: Record "VAT Statement Name";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Trigger OnInsert for Table 257 - VAT Statement Name.
        // Setup.
        // Exercise: Create VAT Statement Name with Sales VAT Adv. Notification as True.
        VATStatementName."Sales VAT Adv. Notif." := true;
        asserterror VATStatementName.Insert(true);

        // Verify: Verify Error Code, Actual error message - There is already a VAT Statement Name set up for Sales VAT Adv. Notification.
        Assert.ExpectedErrorCode('Dialog');
    end;



    [Test]
    procedure SalesVATAdvNotificationOnValidateVATStatNameError()
    var
        VATStatementName: Record "VAT Statement Name";
        VATStatementName2: Record "VAT Statement Name";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Trigger OnValidate of Sales VAT Adv. Notification for Table 257 - VAT Statement Name.

        // Setup: Delete VAT Statement Name to clear all existing Statement Names and Required to create VAT Statement Name twice to get to correct error in the OnValidate function.
        VATStatementName.DeleteAll();
        CreateVATStatementName(VATStatementName, LibraryUTUtility.GetNewCode10());
        CreateVATStatementName(VATStatementName2, VATStatementName."Statement Template Name");

        // Exercise.
        asserterror VATStatementName2.Validate("Sales VAT Adv. Notif.");

        // Verify: Verify Error Code, Actual error message - There is already a VAT Statement Name set up for Sales VAT Adv. Notification.
        Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    procedure OnInsertSalesVATAdvNotif()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    BEGIN
        // [SCENARIO 283574] Purpose of the test is to validate Trigger OnInsert for Table 11011 - Sales VAT Advance Notification.
        // Setup.
        // Exercise.
        SalesVATAdvanceNotif.Insert(true);

        // Verify: Verify New created Sales VAT Advance Notification and No. Series.
        SalesVATAdvanceNotif.TestField("No.");
        SalesVATAdvanceNotif.TestField("No. Series");
    end;

    [Test]
    procedure OnDeleteSalesVATAdvNotif()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Trigger OnDelete for Table 11011 - Sales VAT Advance Notification.

        // Setup: Create Sales VAT Advance Notification
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif, 0D);  // XML-File Creation Date as 0D.

        // Exercise.
        SalesVATAdvanceNotif.Delete(true);

        // Verify: Verify Sales VAT Advance Notification and Transmission Log Entry deleted.
        Assert.IsFalse(SalesVATAdvanceNotif.GET(SalesVATAdvanceNotif."No."), 'Sales VAT Advance Notification must not exist.');
    end;

    [Test]
    procedure OnRenameSalesVATAdvNotifError()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Trigger OnRename for Table 11011 - Sales VAT Advance Notification.
        // Setup.
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif, WorkDate());

        // Exercise.
        asserterror SalesVATAdvanceNotif.Rename(LibraryUTUtility.GetNewCode());

        // Verify: Verify Error code. Actual error message - You cannot change the value of this field anymore after the XML-File for the Sales VAT Advance Notification has been created.
        Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    procedure NoOnValidateSalesVATAdvNotif()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        ElecVATDeclSetup: Record "Elec. VAT Decl. Setup";
        NoSeries: Record "No. Series";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Trigger OnValidate of No for Table 11011 - Sales VAT Advance Notification.

        // Setup: Update No. Series for Manual Nos.
        ElecVATDeclSetup.Get();
        NoSeries.Get(ElecVATDeclSetup."Sales VAT Adv. Notif. Nos.");
        NoSeries."Manual Nos." := true;
        NoSeries.Modify();

        // Exercise.
        SalesVATAdvanceNotif.Validate("No.", LibraryUTUtility.GetNewCode());
        SalesVATAdvanceNotif.Insert();

        // Verify: Verify newly created Sales VAT Advance Notification, with No. Series which should be blank.
        SalesVATAdvanceNotif.Get(SalesVATAdvanceNotif."No.");
        SalesVATAdvanceNotif.TestField("No. Series", '');
    end;

    [Test]
    procedure StartingDateOnValidateSalesVATAdvNotifError()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Trigger OnValidate of Starting Date for Table 11011 - Sales VAT Advance Notification.
        // Setup.
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif, 0D);  // XML-File Creation Date as 0D.

        // Exercise.
        asserterror SalesVATAdvanceNotif.Validate(
            "Starting Date", DMY2Date(1 + LibraryRandom.RandInt(10), Date2DMY(WorkDate(), 2), Date2DMY(WorkDate(), 3)));  // Date where calendar day not equal to 1.

        // Verify: Verify Error Code, Actual error message - You must specify a beginning of a month as starting date of the statement period.
        Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    procedure PeriodOnValidateSalesVATAdvNotifError()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Trigger OnValidate of Period for Table 11011 - Sales VAT Advance Notification.

        // Setup: Create Sales VAT Advance Notification and update Starting Date.
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif, 0D);  // XML-File Creation Date as 0D.
        SalesVATAdvanceNotif."Starting Date" := DMY2Date(1, 2, Date2DMY(WorkDate(), 3));  // Date where calendar day = 1, and calendar month not equal to quarterly month (1,4,7,10) required, hence month taken as 2.
        SalesVATAdvanceNotif.Modify();

        // Exercise.
        asserterror SalesVATAdvanceNotif.Validate(Period, SalesVATAdvanceNotif.Period::Quarter);

        // Verify: Verify Error Code, Actual error message - The starting date is not the first date of a quarter.
        Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    procedure StatTemplateNameOnValidateSalesVATAdvNotifError()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Trigger OnValidate of Statement Template Name for Table 11011 - Sales VAT Advance Notification.
        OnValidateSalesVATAdvNotif(SalesVATAdvanceNotif.FieldNo("Statement Template Name"));
    end;

    [Test]
    procedure StatNameOnValidateSalesVATAdvNotifError()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Trigger OnValidate of Statement Name for Table 11011 - Sales VAT Advance Notification.
        OnValidateSalesVATAdvNotif(SalesVATAdvanceNotif.FieldNo("Statement Name"));
    end;

    [Test]
    procedure InclVATEntriesClosingOnValidateSalesVATAdvNotifError()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Trigger OnValidate of Incl. VAT Entries (Closing) for Table 11011 - Sales VAT Advance Notification.
        OnValidateSalesVATAdvNotif(SalesVATAdvanceNotif.FieldNo("Incl. VAT Entries (Closing)"));
    end;

    [Test]
    procedure InclVATEntriesPeriodOnValidateSalesVATAdvNotifError()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Trigger OnValidate of Incl. VAT Entries (Period) for Table 11011 - Sales VAT Advance Notification.
        OnValidateSalesVATAdvNotif(SalesVATAdvanceNotif.FieldNo("Incl. VAT Entries (Period)"));
    end;

    [Test]
    procedure CorrectedNotificationOnValidateSalesVATAdvNotifError()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Trigger OnValidate of Corrected Notification for Table 11011 - Sales VAT Advance Notification.
        OnValidateSalesVATAdvNotif(SalesVATAdvanceNotif.FieldNo("Corrected Notification"));
    end;

    [Test]
    procedure OffsetAmountOfRefundOnValidateSalesVATAdvNotifError()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Trigger OnValidate of Offset Amount of Refund for Table 11011 - Sales VAT Advance Notification.
        OnValidateSalesVATAdvNotif(SalesVATAdvanceNotif.FieldNo("Offset Amount of Refund"));
    end;

    [Test]
    procedure CancelOrderForDirectDebitOnValidateSalesVATAdvNotifError()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Trigger OnValidate of Cancel Order for Direct Debit for Table 11011 - Sales VAT Advance Notification.
        OnValidateSalesVATAdvNotif(SalesVATAdvanceNotif.FieldNo("Cancel Order for Direct Debit"));
    end;

    [Test]
    procedure TestVersionOnValidateSalesVATAdvNotifError()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Trigger OnValidate of Testversion for Table 11011 - Sales VAT Advance Notification.
        OnValidateSalesVATAdvNotif(SalesVATAdvanceNotif.FieldNo(Testversion));
    end;

    [Test]
    procedure AdditionalInformationOnValidateSalesVATAdvNotifError()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Trigger OnValidate of Additional Information for Table 11011 - Sales VAT Advance Notification.
        OnValidateSalesVATAdvNotif(SalesVATAdvanceNotif.FieldNo("Additional Information"));
    end;

    [Test]
    procedure ContactForTaxOfficeOnValidateSalesVATAdvNotifError()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Trigger OnValidate of Contact for Tax Office for Table 11011 - Sales VAT Advance Notification.
        OnValidateSalesVATAdvNotif(SalesVATAdvanceNotif.FieldNo("Contact for Tax Office"));
    end;

    [Test]
    procedure ContactPhoneNoOnValidateSalesVATAdvNotifError()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Trigger OnValidate of Contact Phone No. for Table 11011 - Sales VAT Advance Notification.
        OnValidateSalesVATAdvNotif(SalesVATAdvanceNotif.FieldNo("Contact Phone No."));
    end;

    [Test]
    procedure ContactEMailOnValidateSalesVATAdvNotifError()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Trigger OnValidate of Contact E-Mail for Table 11011 - Sales VAT Advance Notification.
        OnValidateSalesVATAdvNotif(SalesVATAdvanceNotif.FieldNo("Contact E-Mail"));
    end;

    [Test]
    procedure DocSubmittedSeparatelyOnValidateSalesVATAdvNotifError()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Trigger OnValidate of Documents Submitted Separately for Table 11011 - Sales VAT Advance Notification.
        OnValidateSalesVATAdvNotif(SalesVATAdvanceNotif.FieldNo("Documents Submitted Separately"));
    end;

    [Test]
    [HandlerFunctions('NoSeriesListModalPageHandler')]
    procedure AssistEditSalesVATAdvNotif()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate AssistEdit function for Table 11011 - Sales VAT Advance Notification.
        // Exercise and Verify: Verify Function AssistEdit return True value.
        Assert.IsTrue(SalesVATAdvanceNotif.AssistEdit(SalesVATAdvanceNotif), 'Value must be True');
    end;

    [Test]
    procedure ShowSalesVATAdvNotifError()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate Show function for Table 11011 - Sales VAT Advance Notification.
        // Setup.
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif, 0D);  // XML-File Creation Date as 0D.

        // Exercise.
        asserterror SalesVATAdvanceNotif.Export();

        // Verify: Verify Error code. Actual error message - You must create the XML-File before it can be shown.
        Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    procedure CalcEndDateForPeriodMonthSalesVATAdvNotif()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        MonthStartingDate: Date;
        ActualMonthEndingDate: Date;
        ExpectedMonthEndingDate: Date;
    begin
        // [SCENARIO 283574] Purpose of the test is to validate CalcEndDate function for Table 11011 - Sales VAT Advance Notification.
        // Setup.
        MonthStartingDate := DMY2Date(1, 1, Date2DMY(WorkDate(), 3));  // Date where calendar day = 1, and calendar month = 1.
        ExpectedMonthEndingDate := DMY2Date(31, 1, Date2DMY(WorkDate(), 3));  // Date where calendar day = 31, and calendar month = 1 for month end date.

        // Exercise.
        ActualMonthEndingDate := SalesVATAdvanceNotif.CalcEndDate(MonthStartingDate);

        // Verify: Verify Expected Month Ending Date and Actual Month Ending Date must be same.
        Assert.AreEqual(ExpectedMonthEndingDate, ActualMonthEndingDate, SameValueMsg);
    END;

    [Test]
    procedure CalcEndDateForPeriodQuarterSalesVATAdvNotif()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        QuarterStartingDate: Date;
        ActualQuarterEndingDate: Date;
        ExpectedQuarterEndingDate: Date;
    begin
        // [SCENARIO 283574] Purpose of the test is to validate CalcEndDate function for Table 11011 - Sales VAT Advance Notification.
        // Setup.
        QuarterStartingDate := DMY2Date(1, 1, Date2DMY(WorkDate(), 3));  // Date where calendar day = 1, and calendar month = 1.
        ExpectedQuarterEndingDate := DMY2Date(31, 3, Date2DMY(WorkDate(), 3));  // Date where calendar day = 31, and calendar month = 3 for Quarter end date.
        SalesVATAdvanceNotif.Period := SalesVATAdvanceNotif.Period::Quarter;

        // Exercise.
        ActualQuarterEndingDate := SalesVATAdvanceNotif.CalcEndDate(QuarterStartingDate);

        // Verify: Verify Expected Quarter Ending Date and Actual Quarter Ending Date must be same.
        Assert.AreEqual(ExpectedQuarterEndingDate, ActualQuarterEndingDate, SameValueMsg);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTRUE')]
    procedure DeleteXMLSubDocSalesVATAdvNotif()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate DeleteXMLSubDoc function for Table 11011 - Sales VAT Advance Notification.

        // Setup: Create Sales VAT Advance Notification and Transmission Log entry.
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif, WorkDate());
        SalesVATAdvanceNotif."Statement Template Name" := LibraryUTUtility.GetNewCode10();
        SalesVATAdvanceNotif.Modify();

        // Exercise.
        SalesVATAdvanceNotif.DeleteXMLSubDoc();

        // Verify: Verify Sales VAT Advance Notification for Statement Template Name, XML-File Creation Date which should be blank
        SalesVATAdvanceNotif.TestField("Statement Template Name", '');
        SalesVATAdvanceNotif.TestField("XML-File Creation Date", 0D);
    end;

    [Test]
    procedure CheckVATNoSalesVATAdvNotif()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        CompanyInformation: Record "Company Information";
        PosTaxOffice: Integer;
        NumberTaxOffice: Integer;
        PosArea: Integer;
        NumberArea: Integer;
        PosDistinction: Integer;
        NumberDistinction: Integer;
        VATNo: Text[30];
        ExpectedVATNo: Text[30];
    begin
        // [SCENARIO 283574] Purpose of the test is to validate CheckVATNo function for Table 11011 - Sales VAT Advance Notification.
        // Setup.
        UpdateCompanyInformation(CompanyInformation, CompanyInformation."Tax Office Area"::Hamburg, 10);  // Tax Office Area option 2 picked,can be any of these 8,4,2,6,3,7,1,16.
        ExpectedVATNo := DelChr(CompanyInformation."Registration No.");  // Delete space character.
        ExpectedVATNo := DelChr(ExpectedVATNo, '=', '/');

        // Exercise.
        VATNo := SalesVATAdvanceNotif.CheckVATNo(PosTaxOffice, NumberTaxOffice, PosArea, NumberArea, PosDistinction, NumberDistinction);

        // Verify: Verify VAT No and Post Tax Office value.
        Assert.AreEqual(ExpectedVATNo, VATNo, SameValueMsg);
        Assert.AreEqual(9, PosTaxOffice, SameValueMsg);  // Post Tax Office value - 9 for Tax Office Area option value in 8,4,2,6,3,7,1,16.
    end;

    [Test]
    procedure CheckVATNoSalesVATAdvNotifError()
    var
        CompanyInformation: Record "Company Information";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate CheckVATNo function for Table 11011 - Sales VAT Advance Notification.
        CheckVATNoTaxOfficeAreaSalesVATAdvNotif(CompanyInformation."Tax Office Area"::"Nordrhein-Westfalen");  // Tax Office Area option value 5.
    end;

    [Test]
    procedure CheckVATNoWithTaxOfficeAreaSalesVATAdvNotifError();
    var
        CompanyInformation: Record "Company Information";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate CheckVATNo function for Table 11011 - Sales VAT Advance Notification.
        CheckVATNoTaxOfficeAreaSalesVATAdvNotif(CompanyInformation."Tax Office Area"::Bayern);  // Tax Office Area option 9 picked, can be any of these 9,10,11,12,13,14,15.
    end;

    [Test]
    procedure CalcTaxFiguresRowNoContinuedSalesVATAdvNotif()
    begin
        // [SCENARIO 283574] Purpose of the test is to validate CalcTaxFigures function for Table 11011 - Sales VAT Advance Notification.
        CalcTaxFiguresRowNoSalesVATAdvNotif('51');  // Row No value 51 picked from CalcTaxFigures Function, can be any of these 51,86,36,80,97,93,98,96.
    end;

    [Test]
    procedure CalcTaxFiguresRowNoTotalLineSalesVATAdvNotif()
    begin
        // [SCENARIO 283574] Purpose of the test is to validate CalcTaxFigures function for Table 11011 - Sales VAT Advance Notification.
        CalcTaxFiguresRowNoSalesVATAdvNotif('47');  // Row No value 47 picked from CalcTaxFigures Function, can be any of these 47,53,74,85,65.
    end;

    [Test]
    procedure CalcTaxFiguresRowNoTotalLineTwoSalesVATAdvNotif()
    begin
        // [SCENARIO 283574] Purpose of the test is to validate CalcTaxFigures function for Table 11011 - Sales VAT Advance Notification.
        CalcTaxFiguresRowNoSalesVATAdvNotif('66');  // Row No value 66 picked from CalcTaxFigures Function, can be any of these 66,61,62,67,63,64,59.
    end;

    [Test]
    procedure CalcTaxFiguresRowNoTotalLineThreeSalesVATAdvNotif()
    begin
        // [SCENARIO 283574] Purpose of the test is to validate CalcTaxFigures function for Table 11011 - Sales VAT Advance Notification.
        CalcTaxFiguresRowNoSalesVATAdvNotif('69');  // Row No value 69 picked from CalcTaxFigures Function, can be any of these 69,39.
    end;

    [Test]
    procedure CalcTaxFigures_Kz37()
    var
        ActualTaxAmount: Decimal;
    begin
        // [SCENARIO 386738] TAB 11021 "Sales VAT Advance Notif.".CalcTaxFigures() process Kz37
        ActualTaxAmount := CalcTaxFiguresRowNoSalesVATAdvNotif('37');
        Assert.AreNotEqual(0, ActualTaxAmount, 'CalcTaxFigures() for Kz37');
    end;

    [Test]
    procedure CalcTaxFigures_Kz50()
    var
        ActualTaxAmount: Decimal;
    begin
        // [SCENARIO 386738] TAB 11021 "Sales VAT Advance Notif.".CalcTaxFigures() process Kz50
        ActualTaxAmount := CalcTaxFiguresRowNoSalesVATAdvNotif('50');
        Assert.AreNotEqual(0, ActualTaxAmount, 'CalcTaxFigures() for Kz50');
    end;

    [Test]
    procedure CalcTaxFiguresAmtTypeAmountSalesVATAdvNotif()
    var
        VATStatementLine: Record "VAT Statement Line";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate CalcTaxFigures function for Table 11011 - Sales VAT Advance Notification.
        CalcTaxFiguresAmtTypeSalesVATAdvNotif(VATStatementLine."Amount Type"::Amount);
    end;

    [Test]
    procedure CalcTaxFiguresAmtTypeBaseSalesVATAdvNotif()
    var
        VATStatementLine: Record "VAT Statement Line";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate CalcTaxFigures function for Table 11011 - Sales VAT Advance Notification.
        CalcTaxFiguresAmtTypeSalesVATAdvNotif(VATStatementLine."Amount Type"::Base);
    end;

    [Test]
    procedure CalcTaxFiguresAmtTypeUnrealizedAmtSalesVATAdvNotif()
    var
        VATStatementLine: Record "VAT Statement Line";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate CalcTaxFigures function for Table 11011 - Sales VAT Advance Notification.
        CalcTaxFiguresAmtTypeSalesVATAdvNotif(VATStatementLine."Amount Type"::"Unrealized Amount");
    end;

    [Test]
    procedure CalcTaxFiguresAmtTypeUnrealizedBaseSalesVATAdvNotif()
    var
        VATStatementLine: Record "VAT Statement Line";
    begin
        // [SCENARIO 283574] Purpose of the test is to validate CalcTaxFigures function for Table 11011 - Sales VAT Advance Notification.
        CalcTaxFiguresAmtTypeSalesVATAdvNotif(VATStatementLine."Amount Type"::"Unrealized Base");
    end;

    [Test]
    procedure CalcTaxFiguresTypeAccountTotalingSalesVATAdvNotif()
    var
        VATStatementName: Record "VAT Statement Name";
        VATStatementLine: Record "VAT Statement Line";
        GLAccount: Record "G/L Account";
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        TaxAmount: ARRAY[100] OF Decimal;
        TaxBase: ARRAY[100] OF Decimal;
        TaxUnrealizedAmount: ARRAY[100] OF Decimal;
        TaxUnrealizedBase: ARRAY[100] OF Decimal;
        Continued: Decimal;
        TotalLine: Decimal;
        TotalLine2: Decimal;
        TotalLine3: Decimal;
        RowNo: Integer;
    begin
        // [SCENARIO 283574] Purpose of the test is to validate CalcTaxFigures function for Table 11011 - Sales VAT Advance Notification.

        // Setup: Create G/L Account and VAT Statement Line.
        RowNo := LibraryRandom.RandInt(10);
        CreateGLAccount(GLAccount);
        CreateVATStatementLine(VATStatementName, VATStatementLine, FORMAT(RowNo), VATStatementLine."Print with"::"Opposite Sign", VATStatementLine."Amount Type"::Amount, VATStatementLine.Type::"Account Totaling");
        VATStatementLine."Account Totaling" := GLAccount."No.";
        VATStatementLine.Modify();

        // Exercise.
        SalesVATAdvanceNotif.CalcTaxFigures(VATStatementName, TaxAmount, TaxBase, TaxUnrealizedAmount, TaxUnrealizedBase, Continued, TotalLine, TotalLine2, TotalLine3);

        // Verify: Verify Net Change of G/L Account.
        GLAccount.CalcFields("Net Change");
        GLAccount.TestField("Net Change", -TaxAmount[RowNo]);
    end;

    [Test]
    procedure CalcTaxFiguresTypeRowTotalingSalesVATAdvNotifError()
    var
        VATStatementName: Record "VAT Statement Name";
        VATStatementLine: Record "VAT Statement Line";
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        TaxAmount: ARRAY[100] OF Decimal;
        TaxBase: ARRAY[100] OF Decimal;
        TaxUnrealizedAmount: ARRAY[100] OF Decimal;
        TaxUnrealizedBase: ARRAY[100] OF Decimal;
        Continued: Decimal;
        TotalLine: Decimal;
        TotalLine2: Decimal;
        TotalLine3: Decimal;
    begin
        // [SCENARIO 283574] Purpose of the test is to validate CalcTaxFigures function for Table 11011 - Sales VAT Advance Notification.

        // Setup: Create VAT Statement Line and update Row Totaling.
        CreateVATStatementLine(
          VATStatementName, VATStatementLine, FORMAT(LibraryRandom.RandInt(10)),
          VATStatementLine."Print with"::"Opposite Sign", VATStatementLine."Amount Type"::Amount,
          VATStatementLine.Type::"Row Totaling");
        VATStatementLine."Row Totaling" := VATStatementLine."Row No.";
        VATStatementLine.Modify();

        // Exercise.
        asserterror SalesVATAdvanceNotif.CalcTaxFigures(
            VATStatementName, TaxAmount, TaxBase, TaxUnrealizedAmount, TaxUnrealizedBase, Continued, TotalLine, TotalLine2, TotalLine3);

        // Verify: Verify Error Code for Error message - Row No error in VAT Statement Line for selected Statement Template Name and Statement Name.
        Assert.ExpectedErrorCode('NCLCSRTS:TableErrorStr');
    end;

    local procedure CalcTaxFiguresRowNoSalesVATAdvNotif(RowNo: Code[10]): Decimal
    var
        VATStatementName: Record "VAT Statement Name";
        VATStatementLine: Record "VAT Statement Line";
        VATEntry: Record "VAT Entry";
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        TaxAmount: ARRAY[100] OF Decimal;
        TaxBase: ARRAY[100] OF Decimal;
        TaxUnrealizedAmount: ARRAY[100] OF Decimal;
        TaxUnrealizedBase: ARRAY[100] OF Decimal;
        Continued: Decimal;
        TotalLine: Decimal;
        TotalLine2: Decimal;
        TotalLine3: Decimal;
        RowNoInt: Integer;
    begin
        // Create VAT Statement Line and VAT Entry.
        CreateVATStatementLine(VATStatementName, VATStatementLine, RowNo, VATStatementLine."Print with"::Sign, VATStatementLine."Amount Type"::Amount, VATStatementLine.Type::"VAT Entry Totaling");
        CreateVATEntry(VATEntry, VATStatementLine."Amount Type"::Amount, VATStatementLine."VAT Prod. Posting Group");

        // Exercise.
        SalesVATAdvanceNotif.CalcTaxFigures(VATStatementName, TaxAmount, TaxBase, TaxUnrealizedAmount, TaxUnrealizedBase, Continued, TotalLine, TotalLine2, TotalLine3);

        // Verify: Verify Amount in VAT Entry.
        VerifyVATEntryAmount(VATEntry, RowNo, Continued, TotalLine, TotalLine2, TotalLine3);

        Evaluate(RowNoInt, RowNo);
        exit(TaxAmount[RowNoInt]);
    end;

    local procedure CheckVATNoTaxOfficeAreaSalesVATAdvNotif(TaxOfficeArea: Option);
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        CompanyInformation: Record "Company Information";
        PosTaxOffice: Integer;
        NumberTaxOffice: Integer;
        PosArea: Integer;
        NumberArea: Integer;
        PosDistinction: Integer;
        NumberDistinction: Integer;
    begin
        // Update Tax Office Area on Company Information.
        UpdateCompanyInformation(CompanyInformation, TaxOfficeArea, 10);

        // Exercise.
        asserterror SalesVATAdvanceNotif.CheckVATNo(PosTaxOffice, NumberTaxOffice, PosArea, NumberArea, PosDistinction, NumberDistinction);

        // Verify: Verify Error code. Actual error message - Places of Registration No. in area must be 11.
        Assert.ExpectedErrorCode('Dialog');
    end;

    local procedure CalcTaxFiguresAmtTypeSalesVATAdvNotif(AmountType: Option);
    var
        VATStatementName: Record "VAT Statement Name";
        VATStatementLine: Record "VAT Statement Line";
        VATEntry: Record "VAT Entry";
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        TaxAmount: ARRAY[100] OF Decimal;
        TaxBase: ARRAY[100] OF Decimal;
        TaxUnrealizedAmount: ARRAY[100] OF Decimal;
        TaxUnrealizedBase: ARRAY[100] OF Decimal;
        Continued: Decimal;
        TotalLine: Decimal;
        TotalLine2: Decimal;
        TotalLine3: Decimal;
        RowNo: Integer;
    begin
        // Create VAT Statement Line and VAT Entry.
        RowNo := LibraryRandom.RandInt(10);
        CreateVATStatementLine(VATStatementName, VATStatementLine, FORMAT(RowNo), VATStatementLine."Print with"::"Opposite Sign", AmountType, VATStatementLine.Type::"VAT Entry Totaling");
        CreateVATEntry(VATEntry, AmountType, VATStatementLine."VAT Prod. Posting Group");

        // Exercise.
        SalesVATAdvanceNotif.CalcTaxFigures(VATStatementName, TaxAmount, TaxBase, TaxUnrealizedAmount, TaxUnrealizedBase, Continued, TotalLine, TotalLine2, TotalLine3);

        // Verify: Verify Amount in VAT Entry for Tax Amount,Tax Base,Tax Unrealized Amount,Tax Unrealized Base.
        VerifyVATEntryTax(VATEntry, AmountType, TaxAmount[RowNo], TaxBase[RowNo], TaxUnrealizedAmount[RowNo], TaxUnrealizedBase[RowNo]);
    end;

    [Test]
    procedure CheckVATNoSalesVATAdvNotifForHessen()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        CompanyInformation: Record "Company Information";
        PosTaxOffice: Integer;
        NumberTaxOffice: Integer;
        PosArea: Integer;
        NumberArea: Integer;
        PosDistinction: Integer;
        NumberDistinction: Integer;
        VATNo: Text[30];
        ExpectedVATNo: Text[30];
    begin
        // [SCENARIO 359432] Validate CheckVATNo function for Table 11011 - Sales VAT Advance Notification when "Tax Office Area" is "Hessen" and "Registration No." has length of 11 chars 

        UpdateCompanyInformation(CompanyInformation, CompanyInformation."Tax Office Area"::Hessen, 11);
        ExpectedVATNo := DelChr(CompanyInformation."Registration No.");
        ExpectedVATNo := DelChr(ExpectedVATNo, '=', '/');
        VATNo := SalesVATAdvanceNotif.CheckVATNo(PosTaxOffice, NumberTaxOffice, PosArea, NumberArea, PosDistinction, NumberDistinction);
        Assert.AreEqual(ExpectedVATNo, VATNo, SameValueMsg);
        Assert.AreEqual(8, PosTaxOffice, SameValueMsg);
    end;

    [Test]
    procedure CheckVATNoWithTaxOfficeAreaSalesVATAdvNotifErrorForHessen();
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        CompanyInformation: Record "Company Information";
        PosTaxOffice: Integer;
        NumberTaxOffice: Integer;
        PosArea: Integer;
        NumberArea: Integer;
        PosDistinction: Integer;
        NumberDistinction: Integer;
    begin
        // [SCENARIO 359432] Validate CheckVATNo function for Table 11011 - Sales VAT Advance Notification when "Tax Office Area" is "Hessen" and "Registration No." has length of 9 chars

        UpdateCompanyInformation(CompanyInformation, CompanyInformation."Tax Office Area"::Hessen, 9);
        asserterror SalesVATAdvanceNotif.CheckVATNo(PosTaxOffice, NumberTaxOffice, PosArea, NumberArea, PosDistinction, NumberDistinction);
        Assert.ExpectedError(
            StrSubstNo(WrongPlaceErr, CompanyInformation.FieldCaption("Registration No."), CompanyInformation."Tax Office Area", 11));
        Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    procedure NotPossibleToDeleteSalesVATAdvNotificationWithXMLGenerated();
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 359432] Stan cannot delete a sales VAT advance notification with the XML file generated

        // [GIVEN] Sales VAT advance notification with "XML File Create Date" = 01.01.20
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif, WorkDate());

        // [WHEN] Stan delete Sales VAT advance notification
        asserterror SalesVATAdvanceNotif.Delete(true);

        // [THEN] An error message "You cannot change the value of this field anymore after the XML-File has been created" thrown
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo(CannotChangeXMLFileErr, SalesVATAdvanceNotif.TableCaption()));
    end;

    local procedure CreateVATStatementName(var VATStatementName: Record "VAT Statement Name"; StatementTemplateName: Code[10])
    begin
        VATStatementName."Statement Template Name" := StatementTemplateName;
        VATStatementName.Name := LibraryUTUtility.GetNewCode10();
        VATStatementName."Sales VAT Adv. Notif." := true;
        VATStatementName.Insert();
    end;

    local procedure CreateVATStatementLine(var VATStatementName: Record "VAT Statement Name"; var VATStatementLine: Record "VAT Statement Line"; RowNo: Code[10]; PrintWith: Option; AmountType: Enum "VAT Statement Line Amount Type"; Type: Enum "VAT Statement Line Type");
    begin
        CreateVATStatementName(VATStatementName, LibraryUTUtility.GetNewCode10());
        VATStatementLine."Statement Template Name" := VATStatementName."Statement Template Name";
        VATStatementLine."Statement Name" := VATStatementName.Name;
        VATStatementLine."Row No." := RowNo;
        VATStatementLine."Print with" := PrintWith;
        VATStatementLine.Type := Type;
        VATStatementLine."Amount Type" := AmountType;
        VATStatementLine."VAT Prod. Posting Group" := LibraryUTUtility.GetNewCode10();
        VATStatementLine.Insert();
    end;

    local procedure CreateSalesVATAdvanceNotif(var SalesVATAdvanceNotif: Record "Sales VAT Advance Notif."; XMLFileCreationDate: Date);
    begin
        SalesVATAdvanceNotif."No." := LibraryUTUtility.GetNewCode();
        SalesVATAdvanceNotif."XML-File Creation Date" := XMLFileCreationDate;
        SalesVATAdvanceNotif.Insert();
    end;

    local procedure OnValidateSalesVATAdvNotif(FieldNo: Integer);
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        FieldRef: FieldRef;
        RecRef: RecordRef;
    begin
        // Create Sales VAT Advance Notification.
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif, WorkDate());
        RecRef.GetTable(SalesVATAdvanceNotif);
        FieldRef := RecRef.Field(FieldNo);

        // Exercise: Validate statement to call OnValidate Trigger of the respective fields.
        asserterror FieldRef.Validate();

        // Verify: Verify Error code. Actual error message - You cannot change the value of this field anymore after the XML-File for the Sales VAT Advance Notification has been created.
        Assert.ExpectedErrorCode('Dialog');
    end;

    local procedure UpdateCompanyInformation(var CompanyInformation: Record "Company Information"; TaxOfficeArea: Option; RegistrationNoLength: Integer)
    begin
        CompanyInformation.Get();
        CompanyInformation."Tax Office Area" := TaxOfficeArea;
        CompanyInformation."Registration No." :=
            copystr(LibraryUtility.GenerateRandomXMLText(RegistrationNoLength), 1, MaxStrLen(CompanyInformation."Registration No."));
        CompanyInformation.Modify();
    end;

    local procedure CreateVATEntry(var VATEntry: Record "VAT Entry"; AmountType: Option; VATProdPostingGroup: Code[20]);
    var
        VATEntry2: Record "VAT Entry";
        VATStatementLine: Record "VAT Statement Line";
    begin
        VATEntry2.FindLast();
        VATEntry."Entry No." := VATEntry2."Entry No." + 1;
        VATEntry."VAT Prod. Posting Group" := VATProdPostingGroup;
        case AmountType of
            VATStatementLine."Amount Type"::Amount:
                VATEntry.Amount := LibraryRandom.RandDec(10, 2);
            VATStatementLine."Amount Type"::Base:
                VATEntry.Base := LibraryRandom.RandDec(10, 2);
            VATStatementLine."Amount Type"::"Unrealized Amount":
                VATEntry."Unrealized Amount" := LibraryRandom.RandDec(10, 2);
            VATStatementLine."Amount Type"::"Unrealized Base":
                VATEntry."Unrealized Base" := LibraryRandom.RandDec(10, 2);
        end;
        VATEntry.Insert();
    end;

    local procedure CreateGLAccount(var GLAccount: Record "G/L Account");
    var
        GLEntry: Record "G/L Entry";
        GLEntry2: Record "G/L Entry";
    begin
        GLAccount."No." := LibraryUTUtility.GetNewCode();
        GLAccount.Insert();

        // G/L Entry record required for Net Change of G/L Account.
        GLEntry2.FindLast();
        GLEntry."Entry No." := GLEntry2."Entry No." + 1;
        GLEntry.Amount := LibraryRandom.RandDec(10, 2);
        GLEntry."G/L Account No." := GLAccount."No.";
        GLEntry.Insert();
    end;

    local procedure VerifyVATEntryAmount(VATEntry: Record "VAT Entry"; RowNo: Code[10]; Continued: Decimal; TotalLine: Decimal; TotalLine2: Decimal; TotalLine3: Decimal);
    var
        RowNoValue: Integer;
    begin
        Evaluate(RowNoValue, RowNo);
        case RowNoValue of // Row No value picked from CalcTaxFigures Function, Table 11011.
            51, 86, 36, 80, 97, 93, 98, 96:
                VATEntry.TestField(Amount, -Continued);
            47, 53, 74, 85, 65:
                VATEntry.TestField(Amount, -TotalLine);
            66, 61, 62, 67, 63, 64, 59:
                VATEntry.TestField(Amount, TotalLine2);
            69, 39:
                VATEntry.TestField(Amount, -TotalLine3);
        end;
    end;

    local procedure VerifyVATEntryTax(VATEntry: Record "VAT Entry"; AmountType: Option; TaxAmount: Decimal; TaxBase: Decimal; TaxUnrealizedAmount: Decimal; TaxUnrealizedBase: Decimal);
    var
        VATStatementLine: Record "VAT Statement Line";
    begin
        case AmountType of
            VATStatementLine."Amount Type"::Amount:
                VATEntry.TestField(Amount, -TaxAmount);
            VATStatementLine."Amount Type"::Base:
                VATEntry.TestField(Base, -TaxBase);
            VATStatementLine."Amount Type"::"Unrealized Amount":
                VATEntry.TestField("Unrealized Amount", -TaxUnrealizedAmount);
            VATStatementLine."Amount Type"::"Unrealized Base":
                VATEntry.TestField("Unrealized Base", -TaxUnrealizedBase);
        end;
    end;

    [ModalPageHandler]
    procedure NoSeriesListModalPageHandler(var NoSeriesList: TestPage "No. Series")
    begin
        NoSeriesList.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerTRUE(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;
}