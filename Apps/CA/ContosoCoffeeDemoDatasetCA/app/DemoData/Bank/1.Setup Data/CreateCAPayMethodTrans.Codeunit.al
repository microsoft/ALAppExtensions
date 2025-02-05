codeunit 27079 "Create CA Pay. Method Trans."
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCATranslation: Codeunit "Contoso CA Translation";
        CreatePaymentMethod: Codeunit "Create Payment Method";
        CreateLanguage: Codeunit "Create Language";
    begin
        ContosoCATranslation.InsertPaymentMethodTranslation(CreatePaymentMethod.Account(), CreateLanguage.FRC(), AccountDescriptionLbl);
        ContosoCATranslation.InsertPaymentMethodTranslation(CreatePaymentMethod.Bank(), CreateLanguage.FRC(), BankDescriptionLbl);
        ContosoCATranslation.InsertPaymentMethodTranslation(CreatePaymentMethod.Bnkconvdom(), CreateLanguage.FRC(), BnkconvdomDescriptionLbl);
        ContosoCATranslation.InsertPaymentMethodTranslation(CreatePaymentMethod.Bnkconvint(), CreateLanguage.FRC(), BnkconvintDescriptionLbl);
        ContosoCATranslation.InsertPaymentMethodTranslation(CreatePaymentMethod.Card(), CreateLanguage.FRC(), CardDescriptionLbl);
        ContosoCATranslation.InsertPaymentMethodTranslation(CreatePaymentMethod.Cash(), CreateLanguage.FRC(), CashDescriptionLbl);
        ContosoCATranslation.InsertPaymentMethodTranslation(CreatePaymentMethod.Check(), CreateLanguage.FRC(), CheckDescriptionLbl);
        ContosoCATranslation.InsertPaymentMethodTranslation(CreatePaymentMethod.Giro(), CreateLanguage.FRC(), GiroDescriptionLbl);
        ContosoCATranslation.InsertPaymentMethodTranslation(CreatePaymentMethod.Intercom(), CreateLanguage.FRC(), IntercomDescriptionLbl);
        ContosoCATranslation.InsertPaymentMethodTranslation(CreatePaymentMethod.Multiple(), CreateLanguage.FRC(), MultipleDescriptionLbl);
    end;

    var
        AccountDescriptionLbl: Label 'Acompte', MaxLength = 100;
        BankDescriptionLbl: Label 'Virement bancaire', MaxLength = 100;
        BnkconvdomDescriptionLbl: Label 'Conversion des données bancaires pour les banques nationales', MaxLength = 100;
        BnkconvintDescriptionLbl: Label 'Conversion des données bancaires pour les banques internationales', MaxLength = 100;
        CardDescriptionLbl: Label 'Paiement par carte', MaxLength = 100;
        CashDescriptionLbl: Label 'Paiement au comptant', MaxLength = 100;
        CheckDescriptionLbl: Label 'Paiement par chèque', MaxLength = 100;
        GiroDescriptionLbl: Label 'Virement giro', MaxLength = 100;
        IntercomDescriptionLbl: Label 'Paiement inter-compagnie', MaxLength = 100;
        MultipleDescriptionLbl: Label 'Diverses methodées de paiement', MaxLength = 100;
}