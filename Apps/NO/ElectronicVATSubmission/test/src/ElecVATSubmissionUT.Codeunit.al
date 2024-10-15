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