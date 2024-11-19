codeunit 11625 "Create CH VAT Cipher"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateVATCipherCode();
        CreateVATCipherSetup();
    end;

    local procedure CreateVATCipherCode()
    var
        ContosoCHVATCipher: Codeunit "Contoso CH VAT Cipher";
    begin
        ContosoCHVATCipher.InsertVATCipherCode('200', TotalAmountOfAgreedOrCollectedConsiderationLbl);
        ContosoCHVATCipher.InsertVATCipherCode('205', RevenueOfNonTaxableServicesLbl);
        ContosoCHVATCipher.InsertVATCipherCode('220', DeductionOfTaxExemptServicesLbl);
        ContosoCHVATCipher.InsertVATCipherCode('221', DeductionOfServicesAbroadLbl);
        ContosoCHVATCipher.InsertVATCipherCode('225', DeductionOfTransferLbl);
        ContosoCHVATCipher.InsertVATCipherCode('230', DeductionOfNonTaxableServicesLbl);
        ContosoCHVATCipher.InsertVATCipherCode('235', ReductionInPaymentsLbl);
        ContosoCHVATCipher.InsertVATCipherCode('280', MiscellaneousTaxationLbl);
        ContosoCHVATCipher.InsertVATCipherCode('289', TotalDeductionsLbl);
        ContosoCHVATCipher.InsertVATCipherCode('299', TotalTaxableTurnoverLbl);
        ContosoCHVATCipher.InsertVATCipherCode('302', TaxServicesAtNormalRateBeforePeriodLbl);
        ContosoCHVATCipher.InsertVATCipherCode('303', TaxServicesAtNormalRateFromPeriodLbl);
        ContosoCHVATCipher.InsertVATCipherCode('312', TaxServicesAtReducedRateBeforePeriodLbl);
        ContosoCHVATCipher.InsertVATCipherCode('313', TaxServicesAtReducedRateFromPeriodLbl);
        ContosoCHVATCipher.InsertVATCipherCode('342', TaxServicesAtHotelRateBeforePeriodLbl);
        ContosoCHVATCipher.InsertVATCipherCode('343', TaxServicesAtHotelRateFromPeriodLbl);
        ContosoCHVATCipher.InsertVATCipherCode('382', AcquisitionTaxBeforePeriodLbl);
        ContosoCHVATCipher.InsertVATCipherCode('383', AcquisitionTaxFromPeriodLbl);
        ContosoCHVATCipher.InsertVATCipherCode('399', TotalOwnedTaxLbl);
        ContosoCHVATCipher.InsertVATCipherCode('400', InputTaxOnCostOfMaterialsAndServicesLbl);
        ContosoCHVATCipher.InsertVATCipherCode('405', InputTaxOnInvestmentsLbl);
        ContosoCHVATCipher.InsertVATCipherCode('410', DeTaxationLbl);
        ContosoCHVATCipher.InsertVATCipherCode('415', CorrectionOfTheInputTaxDeductionLbl);
        ContosoCHVATCipher.InsertVATCipherCode('420', ReductionOfTheInputTaxDeductionLbl);
        ContosoCHVATCipher.InsertVATCipherCode('479', TotalAmountOfTaxDueLbl);
        ContosoCHVATCipher.InsertVATCipherCode('500', AmountToBePaidLbl);
        ContosoCHVATCipher.InsertVATCipherCode('510', CreditInFavourOfTheTaxablePersonLbl);
        ContosoCHVATCipher.InsertVATCipherCode('900', CashFlowTaxesSubsidiesFundsLbl);
        ContosoCHVATCipher.InsertVATCipherCode('910', CashFlowCompensationsDonationsDividendsLbl);
    end;

    local procedure CreateVATCipherSetup()
    var
        ContosoCHVATCipher: Codeunit "Contoso CH VAT Cipher";
    begin
        ContosoCHVATCipher.InsertVATCipherSetup('200', '205', '220', '221', '225', '230', '235', '280', '289', '299', '302', '303', '312', '313', '342', '343', '382', '383', '399', '400', '405', '410', '415', '420', '479', '500', '510', '900', '910');
    end;

    var
        TotalAmountOfAgreedOrCollectedConsiderationLbl: Label 'Total amount of agreed or collected consideration', MaxLength = 50;
        RevenueOfNonTaxableServicesLbl: Label 'Revenue of non-taxable services', MaxLength = 50;
        DeductionOfTaxExemptServicesLbl: Label 'Deduction of tax-exempt services', MaxLength = 50;
        DeductionOfServicesAbroadLbl: Label 'Deduction of services abroad', MaxLength = 50;
        DeductionOfTransferLbl: Label 'Deduction of transfer', MaxLength = 50;
        DeductionOfNonTaxableServicesLbl: Label 'Deduction of non-taxable services', MaxLength = 50;
        ReductionInPaymentsLbl: Label 'Reduction in payments', MaxLength = 50;
        MiscellaneousTaxationLbl: Label 'Miscellaneous taxation', MaxLength = 50;
        TotalDeductionsLbl: Label 'Total deductions', MaxLength = 50;
        TotalTaxableTurnoverLbl: Label 'Total taxable turnover', MaxLength = 50;
        TaxServicesAtNormalRateBeforePeriodLbl: Label 'Tax services at normal rate before period', MaxLength = 50;
        TaxServicesAtNormalRateFromPeriodLbl: Label 'Tax services at normal rate from period', MaxLength = 50;
        TaxServicesAtReducedRateBeforePeriodLbl: Label 'Tax services at reduced rate before period', MaxLength = 50;
        TaxServicesAtReducedRateFromPeriodLbl: Label 'Tax services at reduced rate from period', MaxLength = 50;
        TaxServicesAtHotelRateBeforePeriodLbl: Label 'Tax services at hotel rate before period', MaxLength = 50;
        TaxServicesAtHotelRateFromPeriodLbl: Label 'Tax services at hotel rate from period', MaxLength = 50;
        AcquisitionTaxBeforePeriodLbl: Label 'Acquisition tax before period', MaxLength = 50;
        AcquisitionTaxFromPeriodLbl: Label 'Acquisition tax from period', MaxLength = 50;
        TotalOwnedTaxLbl: Label 'Total owned tax', MaxLength = 50;
        InputTaxOnCostOfMaterialsAndServicesLbl: Label 'Input tax on cost of materials and services', MaxLength = 50;
        InputTaxOnInvestmentsLbl: Label 'Input tax on investments', MaxLength = 50;
        DeTaxationLbl: Label 'De-taxation', MaxLength = 50;
        CorrectionOfTheInputTaxDeductionLbl: Label 'Correction of the input tax deduction', MaxLength = 50;
        ReductionOfTheInputTaxDeductionLbl: Label 'Reduction of the input tax deduction', MaxLength = 50;
        TotalAmountOfTaxDueLbl: Label 'Total amount of tax due', MaxLength = 50;
        AmountToBePaidLbl: Label 'Amount to be paid', MaxLength = 50;
        CreditInFavourOfTheTaxablePersonLbl: Label 'Credit in favour of the taxable person', MaxLength = 50;
        CashFlowTaxesSubsidiesFundsLbl: Label 'Cash flow taxes: subsidies, funds', MaxLength = 50;
        CashFlowCompensationsDonationsDividendsLbl: Label 'Cash flow compensations: donations, dividends', MaxLength = 50;

}