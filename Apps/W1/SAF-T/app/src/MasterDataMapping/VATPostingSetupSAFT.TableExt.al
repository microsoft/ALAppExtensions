// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.VAT.Setup;

tableextension 5285 "VAT Posting Setup SAF-T" extends "VAT Posting Setup"
{
    fields
    {
        field(5280; "Sales Tax Code SAF-T"; Code[9])
        {
            trigger OnValidate()
            begin
                VerifyTaxCodeUnique("Sales Tax Code SAF-T");
            end;
        }
        field(5281; "Purchase Tax Code SAF-T"; Code[9])
        {
            trigger OnValidate()
            begin
                VerifyTaxCodeUnique("Purchase Tax Code SAF-T");
            end;
        }
        field(5285; "Starting Date"; Date) { }
    }

    var
        VATCodeAlreadyUsedErr: Label 'The VAT code %1 has already been used in %2 for business posting group %3 and product posting group %4.', Comment = '%1 - VAT code, %2 - "VAT Posting Setup", %3 - VAT Bus. Posting Group, %4 - VAT Prod. Posting Group';

    procedure InitTaxCodeSAFT()
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
        SalesTaxCodeSAFT: Integer;
        PurchaseTaxCodeSAFT: Integer;
    begin
        AuditFileExportSetup.LockTable();
        if not AuditFileExportSetup.Get() then
            exit;
        SalesTaxCodeSAFT := AuditFileExportSetup."Last Tax Code" + 1;
        PurchaseTaxCodeSAFT := AuditFileExportSetup."Last Tax Code" + 2;

        Validate("Sales Tax Code SAF-T", Format(SalesTaxCodeSAFT));
        Validate("Purchase Tax Code SAF-T", Format(PurchaseTaxCodeSAFT));
        Modify();

        AuditFileExportSetup."Last Tax Code" := PurchaseTaxCodeSAFT;
        AuditFileExportSetup.Modify(true);
    end;

    local procedure VerifyTaxCodeUnique(TaxCode: Code[9])
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if TaxCode = '' then
            exit;

        VATPostingSetup.SetRange("Sales Tax Code SAF-T", TaxCode);
        if VATPostingSetup.FindFirst() then
            Error(
                VATCodeAlreadyUsedErr, TaxCode, FieldCaption("Sales Tax Code SAF-T"),
                VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group");

        VATPostingSetup.SetRange("Purchase Tax Code SAF-T", TaxCode);
        if VATPostingSetup.FindFirst() then
            Error(
                VATCodeAlreadyUsedErr, TaxCode, FieldCaption("Purchase Tax Code SAF-T"),
                VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
    end;
}
