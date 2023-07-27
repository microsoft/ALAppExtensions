codeunit 148134 "Elec. VAT Submission UT"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryElecVATSubmission: Codeunit "Library - Elec. VAT Submission";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        IsInitialized: Boolean;

    trigger OnRun()
    begin
        // [FEATURE] [Electronic VAT Submission] [UT]
    end;

#if CLEAN23
    [Test]
    procedure ValidateVATStatementSignWithVATCodeDependentOnOtherCode()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: Record "VAT Statement Report Line";
        VATReportingCode: Record "VAT Reporting Code";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 422655] Stan can validate VAT statement with the VAT Code that has "SAF-T Code" specified

        Initialize();
        LibraryElecVATSubmission.InsertElecVATReportHeader(VATReportHeader);
        VATReportingCode.Get(LibraryElecVATSubmission.CreateSimpleVATCode());
        VATReportingCode.Validate("SAF-T VAT Code", '1');
        VATReportingCode.Modify(true);
        LibraryElecVATSubmission.InsertVATStatementReportLineWithBoxNo(VATStatementReportLine, VATReportHeader, VATReportingCode.Code);
        VATStatementReportLine.Validate(Amount, -1);
        VATStatementReportLine.Modify(true);
        Codeunit.Run(Codeunit::"Elec. VAT Validate Return", VATReportHeader);
    end;
#else
    [Test]
    [Scope('OnPrem')]
    procedure ValidateVATStatementSignWithVATCodeDependentOnOtherCode()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: Record "VAT Statement Report Line";
        VATCode: Record "VAT Code";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 422655] Stan can validate VAT statement with the VAT Code that has "SAF-T Code" specified

        Initialize();
        LibraryElecVATSubmission.InsertElecVATReportHeader(VATReportHeader);
        VATCode.Get(LibraryElecVATSubmission.CreateSimpleVATCode());
        VATCode.Validate("SAF-T VAT Code", '1');
        VATCode.Modify(true);
        LibraryElecVATSubmission.InsertVATStatementReportLineWithBoxNo(VATStatementReportLine, VATReportHeader, VATCode.Code);
        VATStatementReportLine.Validate(Amount, -1);
        VATStatementReportLine.Modify(true);
        Codeunit.Run(Codeunit::"Elec. VAT Validate Return", VATReportHeader);
    end;
#endif

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"Elec. VAT Submission UT");
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"Elec. VAT Submission UT");
        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Elec. VAT Submission UT");
    end;


}