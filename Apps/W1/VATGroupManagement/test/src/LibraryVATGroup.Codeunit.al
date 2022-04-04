codeunit 139525 "Library - VAT Group"
{
    var
        LibraryUtility: Codeunit "Library - Utility";
        RepresentativeURL: Text;
        URLAppendixCompanyLbl: Label '/api/microsoft/vatgroup/v1.0/companies(name=''%1'')', Locked = true;
        VATGroupSubmissionStatusEndpointTxt: Label '/vatGroupSubmissionStatus?$filter=no eq ''%1'' and groupMemberId eq %2&$select=no,status', Locked = true;
        NoODataWebServiceErr: Label 'Failed to find any web service with filled OData URL.';

    procedure ClearApprovedMembers()
    var
        VATGroupApprovedMember: Record "VAT Group Approved Member";
    begin
        VATGroupApprovedMember.DeleteAll();
    end;

    procedure DeleteVATReportSetup()
    var
        VATReportSetup: Record "VAT Report Setup";
    begin
        VATReportSetup.DeleteAll();
    end;

    procedure MockVATReturnPeriod(StartDate: Date; EndDate: Date)
    var
        VATReturnPeriod: Record "VAT Return Period";
    begin
        VATReturnPeriod."No." := LibraryUtility.GenerateGUID();
        VATReturnPeriod."Start Date" := StartDate;
        VATReturnPeriod."End Date" := EndDate;
        VATReturnPeriod.Insert();
    end;

    procedure MockDummyVATReportHeader(var VATReportHeader: Record "VAT Report Header")
    begin
        MockVATReportHeaderWithState(VATReportHeader, 0D, 0D, 0);
    end;

    procedure MockVATReportHeaderWithDates(var VATReportHeader: Record "VAT Report Header"; StartDate: Date; EndDate: Date)
    begin
        MockVATReportHeaderWithState(VATReportHeader, StartDate, EndDate, 0);
    end;

    procedure MockVATReportHeaderWithState(var VATReportHeader: Record "VAT Report Header"; StartDate: Date; EndDate: Date; Status: Option)
    begin
        VATReportHeader."VAT Report Config. Code" := VATReportHeader."VAT Report Config. Code"::"VAT Return";
        VATReportHeader."No." := LibraryUtility.GenerateGUID();
        VATReportHeader."Start Date" := StartDate;
        VATReportHeader."End Date" := EndDate;
        VATReportHeader.Status := Status;
        VATReportHeader.Insert();
    end;

    procedure MockVATStatementReportLine(var VATStatementReportLine: Record "VAT Statement Report Line"; VATReportHeader: Record "VAT Report Header"; Amount: Decimal)
    begin
        MockVATStatementReportLineBase(
          VATStatementReportLine,
          VATReportHeader."VAT Report Config. Code"::"VAT Return", VATReportHeader."No.", Amount, '', '');
    end;

    procedure MockVATStatementReportLineWithNo(var VATStatementReportLine: Record "VAT Statement Report Line"; No: Code[20]; Amount: Decimal)
    begin
        MockVATStatementReportLineBase(
          VATStatementReportLine,
          VATStatementReportLine."VAT Report Config. Code"::"VAT Return", No, Amount, '', '');
    end;

    procedure MockVATStatementReportLineWithBoxNo(var VATStatementReportLine: Record "VAT Statement Report Line"; VATReportHeader: Record "VAT Report Header"; Amount: Decimal; RowNo: Code[10]; BoxNo: Text[30])
    begin
        MockVATStatementReportLineBase(
          VATStatementReportLine,
          VATReportHeader."VAT Report Config. Code"::"VAT Return", VATReportHeader."No.", Amount, RowNo, BoxNo);
    end;

    local procedure MockVATStatementReportLineBase(var VATStatementReportLine: Record "VAT Statement Report Line"; VATReportConfigCode: Option; VATReportNo: Code[20]; Amount: Decimal; RowNo: Code[10]; BoxNo: Text[30])
    begin
        VATStatementReportLine."VAT Report Config. Code" := VATReportConfigCode;
        VATStatementReportLine."VAT Report No." := VATReportNo;
        VATStatementReportLine."Line No." :=
          LibraryUtility.GetNewRecNo(VATStatementReportLine, VATStatementReportLine.FIELDNO("Line No."));

        VATStatementReportLine.Amount := Amount;
        VATStatementReportLine."Row No." := RowNo;
        VATStatementReportLine."Box No." := BoxNo;
        VATStatementReportLine.Insert();
    end;

    procedure MockVATGroupSubmissionHeader(StartDate: Date; EndDate: Date; GroupMemberId: Guid): Guid
    begin
        exit(MockVATGroupSubmissionHeaderWithSubmittedDate(StartDate, EndDate, GroupMemberId, '', 0DT));
    end;

    procedure MockVATGroupSubmissionHeaderWithGroupReturnNo(StartDate: Date; EndDate: Date; GroupMemberId: Guid; VATGroupReturnNo: Code[20]): Guid
    begin
        exit(MockVATGroupSubmissionHeaderWithSubmittedDate(StartDate, EndDate, GroupMemberId, VATGroupReturnNo, 0DT));
    end;

    procedure MockVATGroupSubmissionHeaderWithSubmittedDate(StartDate: Date; EndDate: Date; GroupMemberId: Guid; VATGroupReturnNo: Code[20]; SubmittedOn: DateTime): Guid
    var
        VATGroupSubmissionHeader: Record "VAT Group Submission Header";
    begin
        VATGroupSubmissionHeader.ID := CreateGuid();
        VATGroupSubmissionHeader."No." := LibraryUtility.GenerateGUID();
        VATGroupSubmissionHeader."Start Date" := StartDate;
        VATGroupSubmissionHeader."End Date" := EndDate;
        VATGroupSubmissionHeader."Group Member ID" := GroupMemberId;
        VATGroupSubmissionHeader."VAT Group Return No." := VATGroupReturnNo;
        VATGroupSubmissionHeader."Submitted On" := SubmittedOn;
        VATGroupSubmissionHeader.Insert();
        exit(VATGroupSubmissionHeader.ID);
    end;

    procedure MockVATGroupSubmissionLine(VATGroupSubmissionHeader: Record "VAT Group Submission Header"; Amount: Decimal; BoxNo: Text[30]; RowNo: Code[10])
    var
        VATGroupSubmissionLine: Record "VAT Group Submission Line";
    begin
        VATGroupSubmissionLine."VAT Group Submission ID" := VATGroupSubmissionHeader.ID;
        VATGroupSubmissionLine."VAT Group Submission No." := VATGroupSubmissionHeader."No.";
        VATGroupSubmissionLine."Line No." :=
          LibraryUtility.GetNewRecNo(VATGroupSubmissionLine, VATGroupSubmissionLine.FieldNo("Line No."));

        VATGroupSubmissionLine.Amount := Amount;
        VATGroupSubmissionLine."Box No." := BoxNo;
        VATGroupSubmissionLine."Row No." := RowNo;
        VATGroupSubmissionLine.Insert();
    end;

    procedure MockVATGroupApprovedMember(): Guid
    begin
        exit(MockVATGroupApprovedMemberWithName(LibraryUtility.GenerateGUID()));
    end;

    procedure MockVATGroupApprovedMemberWithName(Name: Text): Guid
    var
        VATGroupApprovedMember: Record "VAT Group Approved Member";
    begin
        VATGroupApprovedMember.ID := CreateGuid();
        VATGroupApprovedMember."Group Member Name" := CopyStr(Name, 1, MaxStrLen(VATGroupApprovedMember."Group Member Name"));
        VATGroupApprovedMember.Insert();
        exit(VATGroupApprovedMember.ID);
    end;

    procedure CreateSubmissionStatusURL(No: Code[20]; MemberId: Guid): Text
    var
        MemberIdText: Text;
    begin
        MemberIdText := DelChr(MemberId, '=', '{|}');
        exit(
          GetRepresentativeURL() + StrSubstNo(URLAppendixCompanyLbl, CompanyName()) +
          StrSubstNo(VATGroupSubmissionStatusEndpointTxt, No, MemberIdText));
    end;

    procedure GetRepresentativeURL(): Text
    var
        WebServices: TestPage "Web Services";
        Temp: Text;
        i: Integer;
    begin
        if RepresentativeURL <> '' then
            exit(RepresentativeURL);

        WebServices.OpenView();
        i := 1;
        while (WebServices.ODataV4Url.Value() = '') and (i < 10) do begin
            WebServices.Next();
            i += 1;
        end;
        Temp := WebServices.ODataV4Url.Value();
        if Temp = '' then
            Error(NoODataWebServiceErr);
        WebServices.Close();
        RepresentativeURL := CopyStr(Temp, 1, StrPos(UpperCase(Temp), '/ODATAV4/') - 1);

        exit(RepresentativeURL);
    end;

    procedure GetFromWebService(TargetURL: Text) HttpResponseBodyText: Text
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        HttpRequestHeaders: HttpHeaders;
    begin
        HttpRequestMessage.Method('GET');
        HttpRequestMessage.SetRequestUri(TargetURL);
        HttpRequestMessage.GetHeaders(HttpRequestHeaders);
        HttpRequestHeaders.Add('Accept', 'application/json');
        HttpClient.UseDefaultNetworkWindowsAuthentication();
        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
            HttpResponseMessage.Content().ReadAs(HttpResponseBodyText);
    end;

    procedure EnableDefaultVATMemberSetup()
    var
        VATReportSetup: Record "VAT Report Setup";
    begin
        if not VATReportSetup.Get() then
            VATReportSetup.Insert();

        VATReportSetup."VAT Group Role" := VATReportSetup."VAT Group Role"::Member;
        VATReportSetup."VAT Group BC Version" := VATReportSetup."VAT Group BC Version"::BC;
        VATReportSetup."Group Representative API URL" :=
          CopyStr(GetRepresentativeURL(), 1, MaxStrLen(VATReportSetup."Group Representative API URL"));
        VATReportSetup."Group Representative Company" := CopyStr(CompanyName(), 1, MaxStrLen(VATReportSetup."Group Representative Company"));
        VATReportSetup."Authentication Type" := VATReportSetup."Authentication Type"::WindowsAuthentication;
        VATReportSetup."Group Member ID" := CreateGuid();
        VATReportSetup."Manual Receive Period CU ID" := 0;
        VATReportSetup.Modify();
    end;

    procedure EnableDefaultVATRepresentativeSetup()
    var
        VATReportSetup: Record "VAT Report Setup";
    begin
        if not VATReportSetup.Get() then
            VATReportSetup.Insert();

        VATReportSetup."VAT Group Role" := VATReportSetup."VAT Group Role"::Representative;
        VATReportSetup."Manual Receive Period CU ID" := 0;
        VATReportSetup.Modify();
    end;

    procedure OpenVATReturnCard(var VATReport: TestPage "VAT Report"; VATReportHeader: Record "VAT Report Header")
    begin
        VATReport.Trap();
        Page.Run(Page::"VAT Report", VATReportHeader);
    end;

    procedure UpdateVATReportLineAmounts(var VATStatementReportLine: Record "VAT Statement Report Line"; Amount: Decimal; ReprAmount: Decimal; GroupAmount: Decimal)
    begin
        VATStatementReportLine.Amount := Amount;
        VATStatementReportLine."Representative Amount" := ReprAmount;
        VATStatementReportLine."Group Amount" := GroupAmount;
        VATStatementReportLine.Modify();
    end;

    procedure UpdateRepresentativeCompanyName(CompanyName: Text)
    var
        VATReportSetup: Record "VAT Report Setup";
    begin
        VATReportSetup.Get();
        VATReportSetup."Group Representative Company" := CopyStr(CompanyName, 1, MaxStrLen(VATReportSetup."Group Representative Company"));
        VATReportSetup.Modify();
    end;

    procedure UpdateMemberId(MemberId: Guid)
    var
        VATReportSetup: Record "VAT Report Setup";
    begin
        VATReportSetup.Get();
        VATReportSetup."Group Member ID" := MemberId;
        VATReportSetup.Modify();
    end;

    procedure UpdateRepresentativeURL(TargetURL: Text)
    var
        VATReportSetup: Record "VAT Report Setup";
    begin
        VATReportSetup.Get();
        VATReportSetup."Group Representative API URL" := CopyStr(TargetURL, 1, MaxStrLen(VATReportSetup."Group Representative API URL"));
        VATReportSetup.Modify();
    end;

    procedure UpdateBCVersion(VATGroupBCVersion: Enum "VAT Group BC Version")
    var
        VATReportSetup: Record "VAT Report Setup";
    begin
        VATReportSetup.Get();
        VATReportSetup."VAT Group BC Version" := VATGroupBCVersion;
        VATReportSetup.Modify();
    end;

    procedure UpdateSettlementSetup(VATDueBoxNo: Text; VATSettlementAccount: Code[20]; GroupSettlementAccount: Code[20]; GroupSettlGenJnlTempl: Code[10])
    var
        VATReportSetup: Record "VAT Report Setup";
    begin
        VATReportSetup.Get();
        VATReportSetup."VAT Due Box No." := CopyStr(VATDueBoxNo, 1, MaxStrLen(VATReportSetup."VAT Due Box No."));
        VATReportSetup."VAT Settlement Account" := VATSettlementAccount;
        VATReportSetup."Group Settlement Account" := GroupSettlementAccount;
        VATReportSetup."Group Settle. Gen. Jnl. Templ." := GroupSettlGenJnlTempl;
        VATReportSetup.Modify();
    end;

    procedure IncludeVATGroup(var VATReportHeader: Record "VAT Report Header")
    var
        VATGroupHelperFunctions: Codeunit "VAT Group Helper Functions";
        VATReport: TestPage "VAT Report";
    begin
        VATGroupHelperFunctions.SetOriginalRepresentativeAmount(VATReportHeader);
        OpenVATReturnCard(VATReport, VATReportHeader);
        VATReport."Include VAT Group".Invoke();
        VATReport.Close();
    end;
}
