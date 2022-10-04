codeunit 139554 "Library - Intrastat"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    // [FEATURE] [Intrastat] [Library]
    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryMarketing: Codeunit "Library - Marketing";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryUtility: Codeunit "Library - Utility";

    procedure CreateIntrastatReportSetup()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        NoSeriesCode: Code[20];
    begin
        If IntrastatReportSetup.Get() then
            exit;
        NoSeriesCode := LibraryERM.CreateNoSeriesCode();
        IntrastatReportSetup.Init();
        IntrastatReportSetup.Validate("Intrastat Nos.", NoSeriesCode);
        IntrastatReportSetup.Insert();
    end;

    procedure CreateIntrastatReport(ReportDate: Date; var IntrastatReportNo: Code[20])
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
    begin
        IntrastatReportHeader.Init();
        IntrastatReportHeader.Validate("No.", GetIntrastatNo());
        IntrastatReportHeader.Insert();

        IntrastatReportHeader.Validate("Statistics Period", GetStatisticalPeriod(ReportDate));
        IntrastatReportHeader.Modify();

        IntrastatReportNo := IntrastatReportHeader."No.";
    end;

    procedure CreateIntrastatReportLine(var IntrastatReportLine: Record "Intrastat Report Line")
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
        IntrastatReportNo: Code[20];
    begin
        CreateIntrastatReport(WorkDate(), IntrastatReportNo);
        IntrastatReportHeader.Get(IntrastatReportNo);

        IntrastatReportLine.Init();
        IntrastatReportLine.Validate("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.Validate("Line No.", 1000);
        IntrastatReportLine.Insert();
    end;

    procedure CreateIntrastatReportLineinIntrastatReport(var IntrastatReportLine: Record "Intrastat Report Line"; IntrastatReportNo: Code[20])
    var
        IntrastatReportLineRecordRef: RecordRef;
    begin
        IntrastatReportLine.Init();
        IntrastatReportLine.Validate("Intrastat No.", IntrastatReportNo);
        IntrastatReportLineRecordRef.GetTable(IntrastatReportLine);
        IntrastatReportLine.Validate("Line No.", LibraryUtility.GetNewLineNo(IntrastatReportLineRecordRef, IntrastatReportLine.FieldNo("Line No.")));
        IntrastatReportLine.Insert(true);
    end;

    procedure GetStatisticalPeriod(ReportDate: Date): code[20]
    var
        Month: Code[2];
        Year: Code[4];
    begin
        Month := format(Date2DMY(ReportDate, 2));
        If StrLen(Month) < 2 then
            Month := '0' + Month;
        Year := CopyStr(format(Date2DMY(ReportDate, 3)), 3, 2);
        exit(Year + Month);
    end;

    procedure ClearIntrastatReportLines(IntrastatReportNo: Code[20])
    var
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.DeleteAll(true);
    end;

    procedure DeleteIntrastatReport(IntrastatReportNo: Code[20])
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.DeleteAll(true);
        IntrastatReportHeader.SetRange("No.", IntrastatReportNo);
        IntrastatReportHeader.DeleteAll(true);
    end;

    procedure GetIntrastatNo() NoSeriesCode: Code[20]
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        NoSeries: Record "No. Series";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        NoSeries.SetFilter(NoSeries.Code, IntrastatReportSetup."Intrastat Nos.");
        NoSeries.FindFirst();
        NoSeriesCode := NoSeriesManagement.GetNextNo(NoSeries.Code, WorkDate(), true);
    end;

    procedure CreateIntrastatContact(ContactType: Enum "Intrastat Report Contact Type"): Code[20]
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        case ContactType of
            IntrastatReportSetup."Intrastat Contact Type"::Contact:
                exit(LibraryMarketing.CreateIntrastatContact(LibraryERM.CreateCountryRegionWithIntrastatCode()));
            IntrastatReportSetup."Intrastat Contact Type"::Vendor:
                exit(LibraryPurchase.CreateIntrastatContact(LibraryERM.CreateCountryRegionWithIntrastatCode()));
        end;
    end;

    procedure CreateCountryRegionWithIntrastatCode(): Code[10]
    var
        CountryRegion: Record "Country/Region";
    begin
        CreateCountryRegion(CountryRegion);
        CountryRegion.Validate(Name, LibraryUtility.GenerateGUID());
        CountryRegion.Validate("Intrastat Code", LibraryUtility.GenerateGUID());
        CountryRegion.Modify(true);
        exit(CountryRegion.Code);
    end;

    procedure CreateCountryRegion(var CountryRegion: Record "Country/Region")
    begin
        CountryRegion.Init();
        CountryRegion.Validate(
          Code,
          CopyStr(LibraryUtility.GenerateRandomCode(CountryRegion.FieldNo(Code), DATABASE::"Country/Region"),
            1, LibraryUtility.GetFieldLength(DATABASE::"Country/Region", CountryRegion.FieldNo(Code))));
        CountryRegion.Insert(true);
    end;

    procedure CreateIntrastatReportChecklist()
    var
        IntrastatReportChecklist: Record "Intrastat Report Checklist";
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        IntrastatReportChecklist.DeleteAll();

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", IntrastatReportLine.FieldNo("Document No."));
        IntrastatReportChecklist.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnAfterCheckFeatureEnabled', '', true, true)]
    local procedure OnAfterCheckFeatureEnabled(var IsEnabled: Boolean)
    begin
        IsEnabled := true;
    end;
}