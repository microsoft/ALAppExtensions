codeunit 11420 "Validate Elec. Tax Declaration"
{
    TableNo = "VAT Report Header";

    var
        OnlySpecificSymbolErr: Label 'Additional Information can only contain letters, digits and dashes';
        StartsWithOBErr: Label 'Additional Information must start with ''OB-''';

    trigger OnRun()
    begin
        CODEUNIT.Run(CODEUNIT::"VAT Report Validate", Rec);
        ValidateElecTaxDeclaration(Rec);
    end;

    var
        OneCompanyTxt: Label 'It is only possible to create an Electronic VAT Declaration for one company. If more companies belong to this Fiscal Entity, please submit the VAT details via the Tax Authority website.';

    local procedure ValidateElecTaxDeclaration(VATReportHeader: Record "VAT Report Header")
    var
        ErrorMessage: Record "Error Message";
        ElecTaxDeclarationSetup: Record "Elec. Tax Declaration Setup";
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        ErrorMessage.SetContext(VATReportHeader);
        ErrorMessage.LogIfEmpty(VATReportHeader, VATReportHeader.FieldNo("Additional Information"), ErrorMessage."Message Type"::Error);
        if VATReportHeader."Additional Information" <> DelChr(VATReportHeader."Additional Information", '=', DelChr(VATReportHeader."Additional Information", '=', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-')) then
            ErrorMessage.LogSimpleMessage(ErrorMessage."Message Type"::Error, OnlySpecificSymbolErr);
        if CopyStr(VATReportHeader."Additional Information", 1, 3) <> 'OB-' then
            ErrorMessage.LogContextFieldError(0, StartsWithOBErr, VATReportHeader, VATReportHeader.FieldNo("Additional Information"), '');

        ErrorMessage.ClearLogRec(ElecTaxDeclarationSetup);
        ElecTaxDeclarationSetup.Get();
        if ElecTaxDeclarationSetup."VAT Contact Type" = ElecTaxDeclarationSetup."VAT Contact Type"::Agent then begin
            ErrorMessage.LogIfEmpty(
              ElecTaxDeclarationSetup, ElecTaxDeclarationSetup.FieldNo("Agent Contact ID"), ErrorMessage."Message Type"::Error);
            ErrorMessage.LogIfEmpty(
              ElecTaxDeclarationSetup, ElecTaxDeclarationSetup.FieldNo("Agent Contact Name"), ErrorMessage."Message Type"::Error);
            ErrorMessage.LogIfEmpty(
              ElecTaxDeclarationSetup, ElecTaxDeclarationSetup.FieldNo("Agent Contact Address"), ErrorMessage."Message Type"::Error);
            ErrorMessage.LogIfEmpty(
              ElecTaxDeclarationSetup, ElecTaxDeclarationSetup.FieldNo("Agent Contact Post Code"), ErrorMessage."Message Type"::Error);
            ErrorMessage.LogIfEmpty(
              ElecTaxDeclarationSetup, ElecTaxDeclarationSetup.FieldNo("Agent Contact City"), ErrorMessage."Message Type"::Error);
            ErrorMessage.LogIfEmpty(
              ElecTaxDeclarationSetup, ElecTaxDeclarationSetup.FieldNo("Agent Contact Phone No."), ErrorMessage."Message Type"::Error);
        end else begin
            ErrorMessage.LogIfEmpty(
              ElecTaxDeclarationSetup, ElecTaxDeclarationSetup.FieldNo("Tax Payer Contact Name"), ErrorMessage."Message Type"::Error);
            ErrorMessage.LogIfEmpty(
              ElecTaxDeclarationSetup, ElecTaxDeclarationSetup.FieldNo("Tax Payer Contact Phone No."), ErrorMessage."Message Type"::Error);
        end;

        ErrorMessage.ClearLogRec(CompanyInformation);
        CompanyInformation.Get();
        ErrorMessage.LogIfEmpty(
          CompanyInformation, CompanyInformation.FieldNo("VAT Registration No."), ErrorMessage."Message Type"::Error);
        if ElecTaxDeclarationSetup."Part of Fiscal Entity" then begin
            ErrorMessage.LogIfEmpty(
              CompanyInformation, CompanyInformation.FieldNo("Fiscal Entity No."), ErrorMessage."Message Type"::Error);
            ErrorMessage.LogSimpleMessage(ErrorMessage."Message Type"::Information, OneCompanyTxt);
        end;

        ErrorMessage.ClearLogRec(GeneralLedgerSetup);
        GeneralLedgerSetup.Get();
        ErrorMessage.LogIfNotEqualTo(
          GeneralLedgerSetup, GeneralLedgerSetup.FieldNo("Local Currency"),
          ErrorMessage."Message Type"::Error, GeneralLedgerSetup."Local Currency"::Euro);
    end;
}

