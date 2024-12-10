codeunit 27012 "Contoso CA Tax"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
            tabledata "Tax Area" = rim,
            tabledata "Tax Area Translation" = rim,
            tabledata "Tax Detail" = rim,
            tabledata "Tax Group" = rim,
            tabledata "Tax Setup" = rim,
            tabledata "Tax Jurisdiction" = rim,
            tabledata "Tax Jurisdiction Translation" = rim,
            tabledata "Tax Area Line" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertTaxArea(Code: Code[20]; Description: Text[100]; CountryRegion: Option; RoundTax: Option)
    var
        TaxArea: Record "Tax Area";
        Exists: Boolean;
    begin
        if TaxArea.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        TaxArea.Validate(Code, Code);
        TaxArea.Validate(Description, Description);
        TaxArea.Validate("Country/Region", CountryRegion);
        TaxArea.Validate("Round Tax", RoundTax);

        if Exists then
            TaxArea.Modify(true)
        else
            TaxArea.Insert(true);
    end;

    procedure InsertTaxAreaTranslation(TaxAreaCode: Code[20]; LanguageCode: Code[10]; Description: Text[100])
    var
        TaxAreaTranslation: Record "Tax Area Translation";
        Exists: Boolean;
    begin
        if TaxAreaTranslation.Get(TaxAreaCode, LanguageCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        TaxAreaTranslation.Validate("Tax Area Code", TaxAreaCode);
        TaxAreaTranslation.Validate("Language Code", LanguageCode);
        TaxAreaTranslation.Validate(Description, Description);

        if Exists then
            TaxAreaTranslation.Modify(true)
        else
            TaxAreaTranslation.Insert(true);
    end;

    procedure InsertTaxGroup(Code: Code[20]; Description: Text[100])
    var
        TaxGroup: Record "Tax Group";
        Exists: Boolean;
    begin
        if TaxGroup.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        TaxGroup.Validate(Code, Code);
        TaxGroup.Validate(Description, Description);

        if Exists then
            TaxGroup.Modify(true)
        else
            TaxGroup.Insert(true);
    end;

    procedure InsertTaxSetup(AutoCreateTaxDetails: Boolean; NonTaxableTaxGroupCode: Code[20]; TaxAccountSales: Code[20]; TaxAccountPurchases: Code[20]; ReverseChargePurchases: Code[20])
    var
        TaxSetup: Record "Tax Setup";
    begin
        if not TaxSetup.Get() then
            TaxSetup.Insert(true);

        TaxSetup.Validate("Auto. Create Tax Details", AutoCreateTaxDetails);
        TaxSetup.Validate("Non-Taxable Tax Group Code", NonTaxableTaxGroupCode);
        TaxSetup.Validate("Tax Account (Sales)", TaxAccountSales);
        TaxSetup.Validate("Tax Account (Purchases)", TaxAccountPurchases);
        TaxSetup.Validate("Reverse Charge (Purchases)", ReverseChargePurchases);
        TaxSetup.Modify(true);
    end;

    procedure InsertTaxDetail(TaxJurisdictionCode: Code[10]; TaxGroupCode: Code[20]; TaxType: Option; EffectiveDate: Date; TaxBelowMaximum: Decimal)
    var
        TaxDetail: Record "Tax Detail";
        Exists: Boolean;
    begin
        if TaxDetail.Get(TaxJurisdictionCode, TaxGroupCode, TaxType, EffectiveDate) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        TaxDetail.Validate("Tax Jurisdiction Code", TaxJurisdictionCode);
        TaxDetail.Validate("Tax Group Code", TaxGroupCode);
        TaxDetail.Validate("Tax Type", TaxType);
        TaxDetail.Validate("Effective Date", EffectiveDate);
        TaxDetail.Validate("Tax Below Maximum", TaxBelowMaximum);

        if Exists then
            TaxDetail.Modify(true)
        else
            TaxDetail.Insert(true);
    end;

    procedure InsertTaxJurisdiction(Code: Code[10]; Description: Text[100]; TaxAccountSales: Code[20]; TaxAccountPurchases: Code[20]; ReporttoJurisdiction: Code[10]; ReverseChargePurchases: Code[20]; CountryRegion: Option; PrintOrder: Integer; PrintDescription: Text[30])
    var
        TaxJurisdiction: Record "Tax Jurisdiction";
    begin
        TaxJurisdiction.Validate(Code, Code);
        TaxJurisdiction.Insert(true);

        TaxJurisdiction.Validate(Description, Description);
        TaxJurisdiction.Validate("Tax Account (Sales)", TaxAccountSales);
        TaxJurisdiction.Validate("Tax Account (Purchases)", TaxAccountPurchases);
        TaxJurisdiction.Validate("Report-to Jurisdiction", ReporttoJurisdiction);
        TaxJurisdiction.Validate("Reverse Charge (Purchases)", ReverseChargePurchases);
        TaxJurisdiction.Validate("Country/Region", CountryRegion);
        TaxJurisdiction.Validate("Print Order", PrintOrder);
        TaxJurisdiction.Validate("Print Description", PrintDescription);
        TaxJurisdiction.Modify(true);
    end;

    procedure InsertTaxJurisdictionTranslation(TaxJurisdictionCode: Code[10]; LanguageCode: Code[10]; Description: Text[100]; PrintDescription: Text[30])
    var
        TaxJurisdictionTranslation: Record "Tax Jurisdiction Translation";
    begin
        TaxJurisdictionTranslation.Validate("Tax Jurisdiction Code", TaxJurisdictionCode);
        TaxJurisdictionTranslation.Validate("Language Code", LanguageCode);
        TaxJurisdictionTranslation.Insert(true);

        TaxJurisdictionTranslation.Validate(Description, Description);
        TaxJurisdictionTranslation.Validate("Print Description", PrintDescription);
        TaxJurisdictionTranslation.Modify(true);
    end;

    procedure InsertTaxAreaLine(TaxArea: Code[20]; TaxJurisdictionCode: Code[10])
    var
        TaxAreaLine: Record "Tax Area Line";
        Exists: Boolean;
    begin
        if TaxAreaLine.Get(TaxArea, TaxJurisdictionCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        TaxAreaLine.Validate("Tax Area", TaxArea);
        TaxAreaLine.Validate("Tax Jurisdiction Code", TaxJurisdictionCode);

        if Exists then
            TaxAreaLine.Modify(true)
        else
            TaxAreaLine.Insert(true);
    end;
}