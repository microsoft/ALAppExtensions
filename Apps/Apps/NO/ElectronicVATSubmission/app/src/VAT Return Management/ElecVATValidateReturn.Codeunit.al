// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Company;
using System.Utilities;

codeunit 10686 "Elec. VAT Validate Return"
{
    TableNo = "VAT Report Header";

    var
        VATAmountCalcErr: Label 'The VAT amount in the box %1 is not equal to the base VAT * VAT Rate.', Comment = '%1 - number';

    trigger OnRun()
    begin
        codeunit.Run(Codeunit::"VAT Report Validate", Rec);
        ValidateVATReport(Rec);
    end;

    local procedure ValidateVATReport(VATReportHeader: Record "VAT Report Header")
    var
        ElecVATSetup: Record "Elec. VAT Setup";
        VATStatementReportLine: Record "VAT Statement Report Line";
        ErrorMessage: Record "Error Message";
        CompanyInformation: Record "Company Information";
        VATReportingCode: Record "VAT Reporting Code";
        VATCodeValue: Code[20];
        ExpectedVATAmount: Decimal;
    begin
        ElecVATSetup.Get();
        if ElecVATSetup."Disable Checks On Release" then
            exit;
        ErrorMessage.SetContext(VATReportHeader);
        CompanyInformation.Get();
        ErrorMessage.ClearLogRec(CompanyInformation);
        ErrorMessage.LogIfEmpty(CompanyInformation, CompanyInformation.FieldNo("VAT Registration No."), ErrorMessage."Message Type"::Error);

        VATStatementReportLine.SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
        VATStatementReportLine.SetRange("VAT Report No.", VATReportHeader."No.");
        VATStatementReportLine.FindSet();
        repeat
            VATCodeValue := CopyStr(VATStatementReportLine."Box No.", 1, MaxStrLen(VATCodeValue));
            VATReportingCode.Get(VATCodeValue);
            if VATReportingCode."Report VAT Rate" and (VATStatementReportLine.Base <> 0) then begin
                ExpectedVATAmount := Round(VATStatementReportLine.Base * VATReportingCode."VAT Rate For Reporting" / 100);
                if Abs(ExpectedVATAmount - VATStatementReportLine.Amount) > 1 then
                    Error(VATAmountCalcErr, VATStatementReportLine."Box No.");
            end;
        until VATStatementReportLine.Next() = 0;
    end;
}
