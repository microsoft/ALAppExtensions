codeunit 139526 "VAT Group Mock Service Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        VATGroupSubmissionStatus: Codeunit "VAT Group Submission Status";
        LibraryVATGroup: Codeunit "Library - VAT Group";
        IsInitialized: Boolean;
        BCVersion: Enum "VAT Group BC Version";
        URLTxt: Label 'https://localhost:8080/vatgroup-mockservice', Locked = true;
        GuidBCTxt: Label 'A98C93EE-BC95-4C34-A34A-E6D289F768AA', Locked = true;
        Guid2018Txt: Label '4F35940F-FEB9-4370-897E-0A86B8270B95', Locked = true;
        Guid2017Txt: Label '417EB2A7-D8B3-4CA2-A285-57262BD64A65', Locked = true;
        VATReturn1Txt: Label 'VAT-RETURN-1', Locked = true;
        VATReturn2Txt: Label 'VAT-RETURN-2', Locked = true;

    [Test]
    procedure SingleStatus_BC()
    begin
        // [SCENARIO 374187] Update single VAT Return Group Status (Business Central representer mode)
        Initialize();
        LibraryVATGroup.UpdateMemberId(GuidBCTxt);
        LibraryVATGroup.UpdateBCVersion(BCVersion::BC);

        MockVATReportHeader(VATReturn1Txt);

        VATGroupSubmissionStatus.UpdateSingleVATReportStatus(VATReturn1Txt);

        VerifyAllVATReportGroupStatuses('Released');
    end;

    [Test]
    procedure SingleStatus_2018()
    begin
        // [SCENARIO 374187] Update single VAT Return Group Status (NAV2018 representer mode)
        Initialize();
        LibraryVATGroup.UpdateMemberId(Guid2018Txt);
        LibraryVATGroup.UpdateBCVersion(BCVersion::NAV2018);

        MockVATReportHeader(VATReturn1Txt);

        VATGroupSubmissionStatus.UpdateSingleVATReportStatus(VATReturn1Txt);

        VerifyAllVATReportGroupStatuses('Released');
    end;

    [Test]
    procedure SingleStatus_2017()
    begin
        // [SCENARIO 374187] Update single VAT Return Group Status (NAV2017 representer mode)
        Initialize();
        LibraryVATGroup.UpdateMemberId(Guid2017Txt);
        LibraryVATGroup.UpdateBCVersion(BCVersion::NAV2017);

        MockVATReportHeader(VATReturn1Txt);

        VATGroupSubmissionStatus.UpdateSingleVATReportStatus(VATReturn1Txt);

        VerifyAllVATReportGroupStatuses('Released');
    end;

    [Test]
    procedure BatchStatus_BC()
    begin
        // [SCENARIO 374187] Update several VAT Returns Group Status via batch URL request (Business Central representer mode)
        Initialize();
        LibraryVATGroup.UpdateMemberId(GuidBCTxt);
        LibraryVATGroup.UpdateBCVersion(BCVersion::BC);

        MockVATReportHeader(VATReturn1Txt);
        MockVATReportHeader(VATReturn2Txt);

        VATGroupSubmissionStatus.UpdateAllVATReportStatus();

        VerifyAllVATReportGroupStatuses('Released');
    end;

    [Test]
    procedure BatchStatus_2018()
    begin
        // [SCENARIO 374187] Update several VAT Returns Group Status via batch URL request (NAV2018 representer mode)
        Initialize();
        LibraryVATGroup.UpdateMemberId(Guid2018Txt);
        LibraryVATGroup.UpdateBCVersion(BCVersion::NAV2018);

        MockVATReportHeader(VATReturn1Txt);
        MockVATReportHeader(VATReturn2Txt);

        VATGroupSubmissionStatus.UpdateAllVATReportStatus();

        VerifyAllVATReportGroupStatuses('Released');
    end;

    [Test]
    procedure BatchStatus_2017()
    begin
        // [SCENARIO 374187] Update several VAT Returns Group Status via batch URL request (NAV2017 representer mode)
        Initialize();
        LibraryVATGroup.UpdateMemberId(Guid2017Txt);
        LibraryVATGroup.UpdateBCVersion(BCVersion::NAV2017);

        MockVATReportHeader(VATReturn1Txt);
        MockVATReportHeader(VATReturn2Txt);

        VATGroupSubmissionStatus.UpdateAllVATReportStatus();

        VerifyAllVATReportGroupStatuses('Released');
    end;

    [Test]
    procedure Submit_BC()
    var
        VATReportHeader: Record "VAT Report Header";
    begin
        // [SCENARIO 374187] Submit VAT Return to representer (Business Central representer mode)
        Initialize();
        LibraryVATGroup.UpdateMemberId(GuidBCTxt);
        LibraryVATGroup.UpdateBCVersion(BCVersion::BC);

        LibraryVATGroup.MockVATReportHeaderWithDates(VATReportHeader, Today(), Today());

        Submit(VATReportHeader);

        VATReportHeader.TestField(Status, VATReportHeader.Status::Submitted);
    end;

    [Test]
    procedure Submit_2018()
    var
        VATReportHeader: Record "VAT Report Header";
    begin
        // [SCENARIO 374187] Submit VAT Return to representer (NAV2018 representer mode)
        Initialize();
        LibraryVATGroup.UpdateMemberId(Guid2018Txt);
        LibraryVATGroup.UpdateBCVersion(BCVersion::NAV2018);

        LibraryVATGroup.MockVATReportHeaderWithDates(VATReportHeader, Today(), Today());

        Submit(VATReportHeader);

        VATReportHeader.TestField(Status, VATReportHeader.Status::Submitted);
    end;

    [Test]
    procedure Submit_2017()
    var
        VATReportHeader: Record "VAT Report Header";
    begin
        // [SCENARIO 374187] Submit VAT Return to representer (NAV2017 representer mode)
        Initialize();
        LibraryVATGroup.UpdateMemberId(Guid2017Txt);
        LibraryVATGroup.UpdateBCVersion(BCVersion::NAV2017);

        LibraryVATGroup.MockVATReportHeaderWithDates(VATReportHeader, Today(), Today());

        Submit(VATReportHeader);

        VATReportHeader.TestField(Status, VATReportHeader.Status::Submitted);
    end;

    local procedure Initialize()
    var
        VATReportHeader: Record "VAT Report Header";
    begin
        VATReportHeader.DeleteAll();

        if IsInitialized then
            exit;

        LibraryVATGroup.EnableDefaultVATMemberSetup();
        LibraryVATGroup.UpdateRepresentativeURL(URLTxt);
        LibraryVATGroup.UpdateRepresentativeCompanyName('VAT Group Repr Test Company');
        Commit();

        IsInitialized := true;
    end;

    local procedure MockVATReportHeader(No: Code[20])
    var
        VATReportHeader: Record "VAT Report Header";
    begin
        VATReportHeader."No." := No;
        VATReportHeader."VAT Report Config. Code" := VATReportHeader."VAT Report Config. Code"::"VAT Return";
        VATReportHeader."VAT Report Version" := 'VATGROUP';
        VATReportHeader."Start Date" := Today();
        VATReportHeader."end Date" := Today();
        VATReportHeader.Status := VATReportHeader.Status::Submitted;
        VATReportHeader.Insert();
    end;

    local procedure Submit(var VATReportHeader: Record "VAT Report Header")
    begin
        Codeunit.Run(Codeunit::"VAT Group Submit To Represent.", VATReportHeader);
        VATReportHeader.Find();
    end;

    local procedure VerifyAllVATReportGroupStatuses(ExpectedStatus: Text)
    var
        VATReportHeader: Record "VAT Report Header";
    begin
        VATReportHeader.FindSet();
        REPEAT
            VATReportHeader.TestField("VAT Group Status", ExpectedStatus);
        UNTIL VATReportHeader.Next() = 0;
    end;
}
