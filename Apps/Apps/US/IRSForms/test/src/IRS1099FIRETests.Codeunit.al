// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.TestLibraries.Utilities;
using Microsoft.Purchases.Vendor;
using System.Utilities;

codeunit 148020 "IRS 1099 FIRE Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryIRSReportingPeriod: Codeunit "Library IRS Reporting Period";
        LibraryIRS1099FormBox: Codeunit "Library IRS 1099 Form Box";
        LibraryFileMgtHandler: Codeunit "Library - File Mgt Handler";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUTUtility: Codeunit "Library UT Utility";
        LibraryTextFileValidation: Codeunit "Library - Text File Validation";
        Assert: Codeunit Assert;
        TempBlob: Codeunit "Temp Blob";
        IsInitialized: Boolean;
        AmountErr: Label 'Wrong value of Amount.';

    [Test]
    [HandlerFunctions('IRS1099FIRERequestPageHandler')]
    procedure IRS1090FIREShowsAmountWithOnlyAdjustment()
    var
        PeriodNo, FormNo, FormBoxNo, VendNo : Code[20];
        StartingDate, EndingDate : Date;
        AdjustmentAmount: Decimal;
    begin
        // [SCENARIO 565315] A "IRS 1099 FIRE" report shows the amount with only the adjustment
        Initialize();

        // [GIVEN] Adjustment amount equals 100 for vendor "A", code "MISC-01", Year = 2025
        StartingDate := CalcDate('<-CY>', LibraryIRSReportingPeriod.GetPostingDate());
        EndingDate := CalcDate('<CY>', StartingDate);
        PeriodNo := Format(Date2DMY(StartingDate, 3));
        LibraryIRSReportingPeriod.CreateSpecificReportingPeriod(PeriodNo, StartingDate, EndingDate);
        FormNo := 'MISC';
        LibraryIRS1099FormBox.CreateSpecificFormInReportingPeriod(StartingDate, EndingDate, FormNo);
        FormBoxNo := 'MISC-02';
        LibraryIRS1099FormBox.CreateSpecificFormBoxInReportingPeriod(StartingDate, EndingDate, FormNo, FormBoxNo);
        // [GIVEN] Vendor with adjustment amount 100 for period "X"
        VendNo := LibraryPurchase.CreateVendorNo();
        AdjustmentAmount := LibraryRandom.RandDecInRange(10, 100, 2);
        LibraryIRS1099FormBox.AddAdjustmentAmountForVendor(StartingDate, EndingDate, VendNo, FormNo, FormBoxNo, AdjustmentAmount);

        Commit();
        LibraryVariableStorage.Enqueue(StartingDate);
        LibraryVariableStorage.Enqueue(VendNo);

        // [WHEN] Run "IRS 1099 FIRE" report for 2025 and vendor "A"
        RunIRS1099FIREReportSingleVendor(VendNo);

        // [THEN] Line has amount element with value "00000100 00"
        LibraryFileMgtHandler.GetTempBlob(TempBlob);
        VerifyAmountInFile(AdjustmentAmount);

        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure Initialize()
    begin
        clear(TempBlob);
        LibraryTestInitialize.OnTestInitialize(Codeunit::"IRS 1099 FIRE Tests");
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"IRS 1099 FIRE Tests");
        LibraryFileMgtHandler.SetBeforeDownloadFromStreamHandlerActivated(true);
        BindSubscription(LibraryFileMgtHandler);
        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"IRS 1099 FIRE Tests");
    end;

    local procedure RunIRS1099FIREReportSingleVendor(VendorNo: Code[20])
    var
        Vendor: Record Vendor;
        IRS1099FIRE: Report "IRS 1099 FIRE";
    begin
        Vendor.SetRange("No.", VendorNo);
        IRS1099FIRE.SetTableView(Vendor);
        IRS1099FIRE.Run();
    end;

    local procedure FormatMoneyAmount(Amount: Decimal; Length: Integer): Text[250]
    var
        AmtStr: Text[32];
    begin
#pragma warning disable AA0139
        AmtStr := StripNonNumerics(Format(Round(Abs(Amount) * 100, 1)));

        // left zero-padding
        if Length - StrLen(AmtStr) > 0 then
            AmtStr := '0000000000000000000' + AmtStr;
#pragma warning restore AA0139
        AmtStr := DelStr(AmtStr, 1, StrLen(AmtStr) - Length);
        exit(AmtStr);
    end;

    local procedure StripNonNumerics(Text: Text[80]): Text[250]
    begin
        exit(DelChr(Text, '=', '-,. '));
    end;

    local procedure VerifyAmountInFile(Amount: Decimal)
    var
        LineInStream: InStream;
        Line, FieldValue : Text;
    begin
        TempBlob.CreateInStream(LineInStream);
        Line := LibraryTextFileValidation.ReadLineFromStream(LineInStream, 3);
        FieldValue := LibraryTextFileValidation.ReadValue(Line, 67, 12);
        Assert.AreEqual(FormatMoneyAmount(Amount, 12), FieldValue, AmountErr);
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure IRS1099FIRERequestPageHandler(var IRS1099FIRE: TestRequestPage "IRS 1099 FIRE")
    begin
        IRS1099FIRE.YearField.SetValue(Date2DMY(LibraryVariableStorage.DequeueDate(), 3));
        IRS1099FIRE.TCCField.SetValue(CopyStr(LibraryUTUtility.GetNewCode(), 1, 5));
        IRS1099FIRE.ContactNameField.SetValue(LibraryUTUtility.GetNewCode());
        IRS1099FIRE.ContactPhoneNoField.SetValue(LibraryUTUtility.GetNewCode());
        IRS1099FIRE.VendContactNameField.SetValue(LibraryUTUtility.GetNewCode());
        IRS1099FIRE.VendContactPhoneNoField.SetValue(LibraryUTUtility.GetNewCode());
        IRS1099FIRE.VendorInfoName.SetValue(LibraryUTUtility.GetNewCode());
        IRS1099FIRE.VendorInfoAddress.SetValue(LibraryUTUtility.GetNewCode());
        IRS1099FIRE.VendorInfoCity.SetValue(LibraryUTUtility.GetNewCode());
        IRS1099FIRE.VendorInfoCounty.SetValue(LibraryUTUtility.GetNewCode());
        IRS1099FIRE.VendorInfoPostCode.SetValue(LibraryUTUtility.GetNewCode());
        IRS1099FIRE.VendorInfoEMail.SetValue(LibraryUTUtility.GetNewCode());

        IRS1099FIRE.VendorData.SetFilter("No.", LibraryVariableStorage.DequeueText());
        IRS1099FIRE.OK().Invoke();
    end;
}