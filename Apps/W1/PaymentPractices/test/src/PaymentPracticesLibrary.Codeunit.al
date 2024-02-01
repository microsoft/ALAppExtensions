codeunit 134196 "Payment Practices Library"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        LibraryUtility: Codeunit "Library - Utility";
        LibraryPurchase: Codeunit "Library - Purchase";

    procedure CreatePaymentPracticeHeader(var PaymentPracticeHeader: Record "Payment Practice Header"; HeaderType: Enum "Paym. Prac. Header Type"; AggregationType: Enum "Paym. Prac. Aggregation Type"; StartingDate: Date; EndingDate: Date)
    begin
        PaymentPracticeHeader.Init();
        PaymentPracticeHeader."Header Type" := HeaderType;
        PaymentPracticeHeader."Aggregation Type" := AggregationType;
        PaymentPracticeHeader."Starting Date" := StartingDate;
        PaymentPracticeHeader."Ending Date" := EndingDate;
        PaymentPracticeHeader.Insert();
    end;

    procedure CreatePaymentPracticeHeaderSimple(var PaymentPracticeHeader: Record "Payment Practice Header")
    begin
        CreatePaymentPracticeHeader(PaymentPracticeHeader, "Paym. Prac. Header Type"::Vendor, "Paym. Prac. Aggregation Type"::"Company Size", WorkDate() - 180, WorkDate() + 180);
    end;

    procedure CreatePaymentPracticeHeaderSimple(var PaymentPracticeHeader: Record "Payment Practice Header"; HeaderType: Enum "Paym. Prac. Header Type"; AggregationType: Enum "Paym. Prac. Aggregation Type")
    begin
        CreatePaymentPracticeHeader(PaymentPracticeHeader, HeaderType, AggregationType, WorkDate() - 180, WorkDate() + 180);
    end;

    procedure CreateCompanySizeCode(): Code[20]
    var
        CompanySize: Record "Company Size";
    begin
        CompanySize.Init();
        CompanySize.Code := LibraryUtility.GenerateGUID();
        CompanySize.Description := CompanySize.Code;
        CompanySize.Insert();
        exit(CompanySize.Code);
    end;

    procedure CreatePaymentPeriod(DaysFrom: Integer; DaysTo: Integer)
    var
        PaymentPeriod: Record "Payment Period";
    begin
        PaymentPeriod.Init();
        PaymentPeriod."Days From" := DaysFrom;
        PaymentPeriod."Days To" := DaysTo;
        PaymentPeriod.Insert();
    end;

    procedure CreateVendorNoWithSizeAndExcl(CompanySizeCode: Code[20]; ExclFromPaymentPractice: Boolean) VendorNo: Code[20]
    var
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        SetCompanySize(Vendor, CompanySizeCode);
        SetExcludeFromPaymentPractices(Vendor, ExclFromPaymentPractice);
        exit(Vendor."No.");
    end;

    procedure InitializeCompanySizes(var CompanySizeCodes: array[3] of Code[20])
    var
        i: Integer;
    begin
        for i := 1 to ArrayLen(CompanySizeCodes) do
            CompanySizeCodes[i] := CreateCompanySizeCode();
    end;

    procedure InitializePaymentPeriods(var PaymentPeriods: array[3] of Record "Payment Period")
    var
        PaymentPeriod: Record "Payment Period";
        i: Integer;
    begin
        PaymentPeriod.SetupDefaults();
        PaymentPeriod.SetCurrentKey("Days From");
        PaymentPeriod.FindSet();
        for i := 1 to ArrayLen(PaymentPeriods) do begin
            PaymentPeriods[i] := PaymentPeriod;
            PaymentPeriod.Next();
        end;
    end;

    procedure InitAndGetLastPaymentPeriod(var PaymentPeriod: Record "Payment Period")
    begin
        PaymentPeriod.SetupDefaults();
        PaymentPeriod.SetRange("Days To", 0);
        PaymentPeriod.FindLast();
    end;

    procedure SetCompanySize(var Vendor: Record Vendor; CompanySizeCode: Code[20])
    begin
        Vendor."Company Size Code" := CompanySizeCode;
        Vendor.Modify();
    end;

    procedure SetExcludeFromPaymentPractices(var Vendor: Record Vendor; NewExcludeFromPaymentPractice: Boolean)
    begin
        Vendor."Exclude from Pmt. Practices" := NewExcludeFromPaymentPractice;
        Vendor.Modify();
    end;

    procedure SetExcludeFromPaymentPractices(var Customer: Record Customer; NewExcludeFromPaymentPractice: Boolean)
    begin
        Customer."Exclude from Pmt. Practices" := NewExcludeFromPaymentPractice;
        Customer.Modify();
    end;

    procedure SetExcludeFromPaymentPracticesOnAllVendorsAndCustomers()
    var
        Vendor: Record Vendor;
        Customer: Record Customer;
    begin
        if Vendor.FindSet(true) then
            repeat
                SetExcludeFromPaymentPractices(Vendor, true);
            until Vendor.Next() = 0;
        if Customer.FindSet(true) then
            repeat
                SetExcludeFromPaymentPractices(Customer, true);
            until Customer.Next() = 0;
    end;

    procedure VerifyLinesCount(PaymentPracticeHeader: Record "Payment Practice Header"; NumberOfLines: Integer)
    var
        PaymentPracticeLine: Record "Payment Practice Line";
    begin
        PaymentPracticeLine.SetRange("Header No.", PaymentPracticeHeader."No.");
        Assert.RecordCount(PaymentPracticeLine, NumberOfLines);
    end;

    procedure VerifyPeriodLine(PaymentPracticeHeaderNo: Integer; SourceType: Enum "Paym. Prac. Header Type"; PaymentPeriodCode: Code[20]; PctInPeriodExpected: Decimal; PctInPeriodAmountExpected: Decimal)
    var
        PaymentPracticeLine: Record "Payment Practice Line";
    begin
        PaymentPracticeLine.SetRange("Header No.", PaymentPracticeHeaderNo);
        PaymentPracticeLine.SetRange("Payment Period Code", PaymentPeriodCode);
        PaymentPracticeLine.SetRange("Source Type", SourceType);
        PaymentPracticeLine.FindFirst();
        Assert.AreNearlyEqual(PctInPeriodExpected, PaymentPracticeLine."Pct Paid in Period", 0.1, '"Pct Paid in Period" is not as expected');
        Assert.AreNearlyEqual(PctInPeriodAmountExpected, PaymentPracticeLine."Pct Paid in Period (Amount)", 0.1, '"Pct Paid in Period (Amount)" is not as expected');
    end;

#if not CLEAN24
    [Obsolete('Not used', '24.0')]
    procedure VerifyPeriodLine()
    begin
    end;
#endif

    procedure VerifyBufferCount(PaymentPracticeHeader: Record "Payment Practice Header"; NumberOfLines: Integer; SourceType: Enum "Paym. Prac. Header Type")
    var
        PaymentPracticeData: Record "Payment Practice Data";
    begin
        PaymentPracticeData.SetRange("Header No.", PaymentPracticeHeader."No.");
        PaymentPracticeData.SetRange("Source Type", SourceType);
        Assert.RecordCount(PaymentPracticeData, NumberOfLines);
    end;

}