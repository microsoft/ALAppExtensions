codeunit 27077 "Contoso CA Translation"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Unit of Measure Translation" = rim,
        tabledata "Payment Term Translation" = rim,
        tabledata "Payment Method Translation" = rim,
        tabledata "Country/Region Translation" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertUnitofMeasureTranslation(Code: Code[10]; LanguageCode: Code[10]; Description: Text[50])
    var
        UnitofMeasureTranslation: Record "Unit of Measure Translation";
        Exists: Boolean;
    begin
        if UnitofMeasureTranslation.Get(Code, LanguageCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        UnitofMeasureTranslation.Validate(Code, Code);
        UnitofMeasureTranslation.Validate("Language Code", LanguageCode);
        UnitofMeasureTranslation.Validate(Description, Description);

        if Exists then
            UnitofMeasureTranslation.Modify(true)
        else
            UnitofMeasureTranslation.Insert(true);
    end;

    procedure InsertPaymentTermTranslation(PaymentTerm: Code[10]; LanguageCode: Code[10]; Description: Text[100])
    var
        PaymentTermTranslation: Record "Payment Term Translation";
        Exists: Boolean;
    begin
        if PaymentTermTranslation.Get(PaymentTerm, LanguageCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        PaymentTermTranslation.Validate("Payment Term", PaymentTerm);
        PaymentTermTranslation.Validate("Language Code", LanguageCode);
        PaymentTermTranslation.Validate(Description, Description);

        if Exists then
            PaymentTermTranslation.Modify(true)
        else
            PaymentTermTranslation.Insert(true);
    end;

    procedure InsertPaymentMethodTranslation(PaymentMethodCode: Code[10]; LanguageCode: Code[10]; Description: Text[100])
    var
        PaymentMethodTranslation: Record "Payment Method Translation";
        Exists: Boolean;
    begin
        if PaymentMethodTranslation.Get(PaymentMethodCode, LanguageCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        PaymentMethodTranslation.Validate("Payment Method Code", PaymentMethodCode);
        PaymentMethodTranslation.Validate("Language Code", LanguageCode);
        PaymentMethodTranslation.Validate(Description, Description);

        if Exists then
            PaymentMethodTranslation.Modify(true)
        else
            PaymentMethodTranslation.Insert(true);
    end;

    procedure InsertCountryRegionTranslation(CountryRegionCode: Code[10]; LanguageCode: Code[10]; Name: Text[50])
    var
        CountryRegionTranslation: Record "Country/Region Translation";
        Exists: Boolean;
    begin
        if CountryRegionTranslation.Get(CountryRegionCode, LanguageCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CountryRegionTranslation.Validate("Country/Region Code", CountryRegionCode);
        CountryRegionTranslation.Validate("Language Code", LanguageCode);
        CountryRegionTranslation.Validate(Name, Name);

        if Exists then
            CountryRegionTranslation.Modify(true)
        else
            CountryRegionTranslation.Insert(true);
    end;
}