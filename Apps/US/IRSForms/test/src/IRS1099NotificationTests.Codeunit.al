// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Vendor;
using System.TestLibraries.Utilities;

codeunit 148013 "IRS 1099 Notification Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryIRSReportingPeriod: Codeunit "Library IRS Reporting Period";
        LibraryIRS1099FormBox: Codeunit "Library IRS 1099 Form Box";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;

    [Test]
    [HandlerFunctions('SendNotificationHandler')]
    procedure NotificationSentWhenVendorHas1099CodeInPrevPeriodButNotCurrent()
    var
        VendorNo, FormNo, FormBoxNo : Code[20];
        PostingDate2023, PostingDate2024 : Date;
        ExpectedMessage: Text;
    begin
        // [SCENARIO 562547] Notification is sent when vendor "V" has 1099 code in previous period but not in current period
        Initialize();

        // [GIVEN] Reporting period "P1" for year 2023
        // [GIVEN] Reporting period "P2" for year 2024
        // [GIVEN] Vendor "V" with 1099 form box setup for period "P1"
        // [GIVEN] No 1099 form box setup for vendor "V" in period "P2"
        PostingDate2023 := DMY2Date(15, 6, 2023);
        PostingDate2024 := DMY2Date(15, 6, 2024);
        LibraryIRSReportingPeriod.CreateReportingPeriod(DMY2Date(1, 1, 2023), DMY2Date(31, 12, 2023));
        LibraryIRSReportingPeriod.CreateReportingPeriod(DMY2Date(1, 1, 2024), DMY2Date(31, 12, 2024));
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(PostingDate2023);
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(PostingDate2023, FormNo);
        VendorNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(PostingDate2023, FormNo, FormBoxNo);

        // [WHEN] ShowNotificationIfVendorHas1099CodePrevPeriodButNotCurr is called with vendor "V" and posting date in year 2024
        ExpectedMessage := 'You have a 1099 code for this vendor in the previous reporting period but not in the current one. Do you want to open the vendor setup to handle current one?';
        LibraryIRS1099FormBox.ShowNotificationIfVendorHas1099CodePrevPeriodButNotCurr(VendorNo, PostingDate2024);

        // [THEN] Notification is sent with message about missing 1099 code in current period
        VerifyNotificationMessage(ExpectedMessage);
    end;

    [Test]
    procedure NotificationNotSentWhenVendorHas1099CodeInCurrentPeriod()
    var
        VendorNo, FormNo, FormBoxNo : Code[20];
        PostingDate: Date;
    begin
        // [SCENARIO 562547] Notification is not sent when vendor "V" has 1099 code in current period
        Initialize();

        // [GIVEN] Reporting period "P" for year 2024
        // [GIVEN] Vendor "V" with 1099 form box setup for period "P"
        PostingDate := DMY2Date(15, 6, 2024);
        LibraryIRSReportingPeriod.CreateReportingPeriod(DMY2Date(1, 1, 2024), DMY2Date(31, 12, 2024));
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(PostingDate);
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(PostingDate, FormNo);
        VendorNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(PostingDate, FormNo, FormBoxNo);

        // [WHEN] ShowNotificationIfVendorHas1099CodePrevPeriodButNotCurr is called with vendor "V" and posting date in year 2024
        LibraryIRS1099FormBox.ShowNotificationIfVendorHas1099CodePrevPeriodButNotCurr(VendorNo, PostingDate);

        // [THEN] No notification is sent
    end;

    [Test]
    procedure NotificationNotSentWhenVendorHasNo1099CodeInPreviousPeriod()
    var
        Vendor: Record Vendor;
        PostingDate: Date;
    begin
        // [SCENARIO 562547] Notification is not sent when vendor "V" has no 1099 code in previous or current period
        Initialize();

        // [GIVEN] Reporting period "P1" for year 2023
        // [GIVEN] Reporting period "P2" for year 2024
        // [GIVEN] Vendor "V" without 1099 form box setup for any period
        LibraryIRSReportingPeriod.CreateReportingPeriod(DMY2Date(1, 1, 2023), DMY2Date(31, 12, 2023));
        LibraryIRSReportingPeriod.CreateReportingPeriod(DMY2Date(1, 1, 2024), DMY2Date(31, 12, 2024));
        LibraryPurchase.CreateVendor(Vendor);
        PostingDate := DMY2Date(15, 6, 2024);

        // [WHEN] ShowNotificationIfVendorHas1099CodePrevPeriodButNotCurr is called with vendor "V" and posting date in year 2024
        LibraryIRS1099FormBox.ShowNotificationIfVendorHas1099CodePrevPeriodButNotCurr(Vendor."No.", PostingDate);

        // [THEN] No notification is sent
    end;

    [Test]
    procedure NotificationNotSentWhenVendorNoIsEmpty()
    var
        PostingDate: Date;
    begin
        // [SCENARIO 562547] Notification is not sent when vendor number is empty
        Initialize();

        // [GIVEN] Reporting period "P" for year 2024
        LibraryIRSReportingPeriod.CreateReportingPeriod(DMY2Date(1, 1, 2024), DMY2Date(31, 12, 2024));
        PostingDate := DMY2Date(15, 6, 2024);

        // [WHEN] ShowNotificationIfVendorHas1099CodePrevPeriodButNotCurr is called with empty vendor number and posting date in year 2024
        LibraryIRS1099FormBox.ShowNotificationIfVendorHas1099CodePrevPeriodButNotCurr('', PostingDate);

        // [THEN] No notification is sent
    end;

    [Test]
    procedure NotificationNotSentWhenPostingDateIsZero()
    var
        Vendor: Record Vendor;
    begin
        // [SCENARIO 562547] Notification is not sent when posting date is zero
        Initialize();

        // [GIVEN] Vendor "V" with 1099 form box setup
        LibraryPurchase.CreateVendor(Vendor);

        // [WHEN] ShowNotificationIfVendorHas1099CodePrevPeriodButNotCurr is called with vendor "V" and zero posting date
        LibraryIRS1099FormBox.ShowNotificationIfVendorHas1099CodePrevPeriodButNotCurr(Vendor."No.", 0D);

        // [THEN] No notification is sent
    end;

    procedure Initialize()
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
    begin
        IRSReportingPeriod.DeleteAll();
        if IsInitialized then
            exit;
        IsInitialized := true;
    end;

    local procedure VerifyNotificationMessage(ExpectedMessage: Text)
    var
        ActualMessage: Text;
    begin
        ActualMessage := LibraryVariableStorage.DequeueText();
        Assert.AreEqual(ExpectedMessage, ActualMessage, 'Notification message does not match');
        LibraryVariableStorage.AssertEmpty();
    end;

    [SendNotificationHandler]
    procedure SendNotificationHandler(var TheNotification: Notification): Boolean
    begin
        LibraryVariableStorage.Enqueue(TheNotification.Message);
    end;
}
