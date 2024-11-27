codeunit 11624 "Contoso CH VAT Cipher"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "VAT Cipher Code" = rim,
        tabledata "VAT Cipher Setup" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertVATCipherSetup(TotalRevenue: Code[20]; RevenueofNonTaxServices: Code[20]; DeductionofTaxExempt: Code[20]; DeductionofServicesAbroad: Code[20]; DeductionofTransfer: Code[20]; DeductionofNonTaxServices: Code[20]; ReductioninPayments: Code[20]; Miscellaneous: Code[20]; TotalDeductions: Code[20]; TotalTaxableRevenue: Code[20]; TaxNormalRateServBefore: Code[20]; TaxNormalRateServAfter: Code[20]; TaxReducedRateServBefore: Code[20]; TaxReducedRateServAfter: Code[20]; TaxHotelRateServBefore: Code[20]; TaxHotelRateServAfter: Code[20]; AcquisitionTaxBefore: Code[20]; AcquisitionTaxAfter: Code[20]; TotalOwnedTax: Code[20]; InputTaxonMaterialandServ: Code[20]; InputTaxonInvestsments: Code[20]; DepositTax: Code[20]; InputTaxCorrections: Code[20]; InputTaxCutbacks: Code[20]; TotalInputTax: Code[20]; TaxAmounttoPay: Code[20]; CreditofTaxablePerson: Code[20]; CashFlowTaxes: Code[20]; CashFlowCompensations: Code[20])
    var
        VATCipherSetup: Record "VAT Cipher Setup";
    begin
        if not VATCipherSetup.Get() then
            VATCipherSetup.Insert();

        VATCipherSetup.Validate("Total Revenue", TotalRevenue);
        VATCipherSetup.Validate("Revenue of Non-Tax. Services", RevenueofNonTaxServices);
        VATCipherSetup.Validate("Deduction of Tax-Exempt", DeductionofTaxExempt);
        VATCipherSetup.Validate("Deduction of Services Abroad", DeductionofServicesAbroad);
        VATCipherSetup.Validate("Deduction of Transfer", DeductionofTransfer);
        VATCipherSetup.Validate("Deduction of Non-Tax. Services", DeductionofNonTaxServices);
        VATCipherSetup.Validate("Reduction in Payments", ReductioninPayments);
        VATCipherSetup.Validate("Miscellaneous", Miscellaneous);
        VATCipherSetup.Validate("Total Deductions", TotalDeductions);
        VATCipherSetup.Validate("Total Taxable Revenue", TotalTaxableRevenue);
        VATCipherSetup.Validate("Tax Normal Rate Serv. Before", TaxNormalRateServBefore);
        VATCipherSetup.Validate("Tax Normal Rate Serv. After", TaxNormalRateServAfter);
        VATCipherSetup.Validate("Tax Reduced Rate Serv. Before", TaxReducedRateServBefore);
        VATCipherSetup.Validate("Tax Reduced Rate Serv. After", TaxReducedRateServAfter);
        VATCipherSetup.Validate("Tax Hotel Rate Serv. Before", TaxHotelRateServBefore);
        VATCipherSetup.Validate("Tax Hotel Rate Serv. After", TaxHotelRateServAfter);
        VATCipherSetup.Validate("Acquisition Tax Before", AcquisitionTaxBefore);
        VATCipherSetup.Validate("Acquisition Tax After", AcquisitionTaxAfter);
        VATCipherSetup.Validate("Total Owned Tax", TotalOwnedTax);
        VATCipherSetup.Validate("Input Tax on Material and Serv", InputTaxonMaterialandServ);
        VATCipherSetup.Validate("Input Tax on Investsments", InputTaxonInvestsments);
        VATCipherSetup.Validate("Deposit Tax", DepositTax);
        VATCipherSetup.Validate("Input Tax Corrections", InputTaxCorrections);
        VATCipherSetup.Validate("Input Tax Cutbacks", InputTaxCutbacks);
        VATCipherSetup.Validate("Total Input Tax", TotalInputTax);
        VATCipherSetup.Validate("Tax Amount to Pay", TaxAmounttoPay);
        VATCipherSetup.Validate("Credit of Taxable Person", CreditofTaxablePerson);
        VATCipherSetup.Validate("Cash Flow Taxes", CashFlowTaxes);
        VATCipherSetup.Validate("Cash Flow Compensations", CashFlowCompensations);
        VATCipherSetup.Modify(true);
    end;

    procedure InsertVATCipherCode(Code: Code[20]; Description: Text[50])
    var
        VATCipherCode: Record "VAT Cipher Code";
        Exists: Boolean;
    begin
        if VATCipherCode.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VATCipherCode.Validate(Code, Code);
        VATCipherCode.Validate(Description, Description);

        if Exists then
            VATCipherCode.Modify(true)
        else
            VATCipherCode.Insert(true);
    end;
}