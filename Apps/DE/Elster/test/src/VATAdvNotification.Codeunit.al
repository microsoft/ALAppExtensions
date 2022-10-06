// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148169 "Elster VAT Adv. Notification"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURES] [Elster] [VAT Advance Notification]
    end;

    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        IsInitialized: Boolean;
        RollBackChangesErr: Label 'Roll-back the changes done by this test case.';

    [Test]
    procedure CheckFieldValuesOnSalesVATAdvanceNotification()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        ContactForTaxOffice: Text[30];
    begin
        // [SCENARIO 283574] Verify Default field Values on New Sales VAT Advance Notification Record after creating First record.
        Initialize();
        SalesVATAdvanceNotif.DeleteAll(true);

        // [GIVEN] Sales VAT Advance Notification record with Period = Quarter and Contact for Tax Office = "Stan".
        ContactForTaxOffice := LibraryUtility.GenerateGUID();
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif);
        UpdateSalesVATAdvanceNotif(SalesVATAdvanceNotif, SalesVATAdvanceNotif.Period::Quarter, ContactForTaxOffice);

        // [WHEN] Create new Sales VAT Advance Notification record.
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif);

        // [THEN] Verify that New record will take values from previous record.
        SalesVATAdvanceNotif.TestField(Period, SalesVATAdvanceNotif.Period::Quarter);
        SalesVATAdvanceNotif.TestField("Contact for Tax Office", ContactForTaxOffice);

        // Tear-Down
        asserterror Error(RollBackChangesErr);
    end;

    [Test]
    procedure ContactForTaxOfficeWhenFirstSalesVATAdvNotifAndVATRepresentativeBlank()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 436931] Contact for Tax Office value when first Sales VAT Advance Notification is created and VAT Representative is blank.
        Initialize();
        SalesVATAdvanceNotif.DeleteAll(true);

        // [GIVEN] Company Information has blank VAT Representative.
        UpdateVATRepresentativeOnCompanyInfo('');

        // [WHEN] Create the first Sales VAT Advance Notification record.
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif);

        // [THEN] Contact for Tax Office is blank for this record.
        SalesVATAdvanceNotif.TestField("Contact for Tax Office", '');
    end;

    [Test]
    procedure ContactForTaxOfficeWhenFirstSalesVATAdvNotifAndVATRepresentativeNonBlank()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        VATRepresentative: Text[45];
    begin
        // [SCENARIO 436931] Contact for Tax Office value when first Sales VAT Advance Notification is created and VAT Representative is not blank.
        Initialize();
        SalesVATAdvanceNotif.DeleteAll(true);

        // [GIVEN] Company Information has VAT Representative = 'Anna'.
        VATRepresentative := LibraryUtility.GenerateGUID();
        UpdateVATRepresentativeOnCompanyInfo(VATRepresentative);

        // [WHEN] Create the first Sales VAT Advance Notification record.
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif);

        // [THEN] Contact for Tax Office is 'Anna' for this record.
        SalesVATAdvanceNotif.TestField(
            "Contact for Tax Office", CopyStr(VATRepresentative, 1, MaxStrLen(SalesVATAdvanceNotif."Contact for Tax Office")));
    end;

    [Test]
    procedure ContactForTaxOfficeWhenNonFirstSalesVATAdvNotifAndVATRepresentativeBlank()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        ContactForTaxOffice: Text[30];
    begin
        // [SCENARIO 436931] Contact for Tax Office value when non-initial Sales VAT Advance Notification is created and VAT Representative is blank.
        Initialize();
        SalesVATAdvanceNotif.DeleteAll(true);

        // [GIVEN] Company Information has blank VAT Representative.
        UpdateVATRepresentativeOnCompanyInfo('');

        // [GIVEN] Sales VAT Advance Notification record with Contact for Tax Office = 'Stan'.
        ContactForTaxOffice := LibraryUtility.GenerateGUID();
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif);
        UpdateSalesVATAdvanceNotif(SalesVATAdvanceNotif, SalesVATAdvanceNotif.Period, ContactForTaxOffice);

        // [WHEN] Create another Sales VAT Advance Notification record.
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif);

        // [THEN] Contact for Tax Office is 'Stan' for this record.
        SalesVATAdvanceNotif.TestField("Contact for Tax Office", ContactForTaxOffice);
    end;

    [Test]
    procedure ContactForTaxOfficeWhenNonFirstSalesVATAdvNotifAndVATRepresentativeNonBlank()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        ContactForTaxOffice: Text[30];
    begin
        // [SCENARIO 436931] Contact for Tax Office value when non-initial Sales VAT Advance Notification is created and VAT Representative is not blank.
        Initialize();
        SalesVATAdvanceNotif.DeleteAll(true);

        // [GIVEN] Company Information has VAT Representative = 'Anna'.
        UpdateVATRepresentativeOnCompanyInfo(LibraryUtility.GenerateGUID());

        // [GIVEN] Sales VAT Advance Notification record with Contact for Tax Office = 'Stan'.
        ContactForTaxOffice := LibraryUtility.GenerateGUID();
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif);
        UpdateSalesVATAdvanceNotif(SalesVATAdvanceNotif, SalesVATAdvanceNotif.Period, ContactForTaxOffice);

        // [WHEN] Create another Sales VAT Advance Notification record.
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif);

        // [THEN] Contact for Tax Office is 'Stan' for this record.
        SalesVATAdvanceNotif.TestField("Contact for Tax Office", ContactForTaxOffice);
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Elster VAT Adv. Notification");
        LibrarySetupStorage.Restore();

        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Elster VAT Adv. Notification");

        LibraryERMCountryData.CreateVATData();
        LibrarySetupStorage.SaveCompanyInformation();
        Commit();

        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Elster VAT Adv. Notification");
    end;

    local procedure UpdateSalesVATAdvanceNotif(var SalesVATAdvanceNotif: Record "Sales VAT Advance Notif."; PeriodValue: Option; ContactForTaxOffice: Text[30]);
    begin
        SalesVATAdvanceNotif.Validate(Period, PeriodValue);
        SalesVATAdvanceNotif.Validate("Contact for Tax Office", ContactForTaxOffice);
        SalesVATAdvanceNotif.Modify(true);
    end;

    local procedure UpdateVATRepresentativeOnCompanyInfo(VATRepresentative: Text[45])
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation.Validate("VAT Representative", VATRepresentative);
        CompanyInformation.Modify(true);
    end;

    local procedure CreateSalesVATAdvanceNotif(var SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.");
    begin
        SalesVATAdvanceNotif.Init();
        SalesVATAdvanceNotif.Validate("No.",
          CopyStr(LibraryUtility.GenerateRandomCode(SalesVATAdvanceNotif.FieldNo("No."), Database::"Sales VAT Advance Notif."),
            1, LibraryUtility.GetFieldLength(Database::"Sales VAT Advance Notif.", SalesVATAdvanceNotif.FieldNo("No."))));
        SalesVATAdvanceNotif.Insert(true);
    end;
}
