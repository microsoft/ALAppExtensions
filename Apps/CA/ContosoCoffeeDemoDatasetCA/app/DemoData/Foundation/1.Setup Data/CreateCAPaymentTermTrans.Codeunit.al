codeunit 27080 "Create CA Payment Term Trans."
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCATranslation: Codeunit "Contoso CA Translation";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
        CreateLanguage: Codeunit "Create Language";
    begin
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS10(), CreateLanguage.ENC(), ENCPaymentTermsDAYS10DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS10(), CreateLanguage.ENU(), ENUPaymentTermsDAYS10DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS10(), CreateLanguage.FRC(), FRCPaymentTermsDAYS10DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS14(), CreateLanguage.ENC(), ENCPaymentTermsDAYS14DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS14(), CreateLanguage.ENU(), ENUPaymentTermsDAYS14DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS14(), CreateLanguage.FRC(), FRCPaymentTermsDAYS14DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS15(), CreateLanguage.ENC(), ENCPaymentTermsDAYS15DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS15(), CreateLanguage.ENU(), ENUPaymentTermsDAYS15DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS15(), CreateLanguage.FRC(), FRCPaymentTermsDAYS15DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsM8D(), CreateLanguage.ENC(), ENCPaymentTermsM8DDescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsM8D(), CreateLanguage.ENU(), ENUPaymentTermsM8DDescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsM8D(), CreateLanguage.FRC(), FRCPaymentTermsM8DDescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS2(), CreateLanguage.ENC(), ENCPaymentTermsDAYS2DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS2(), CreateLanguage.ENU(), ENUPaymentTermsDAYS2DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS2(), CreateLanguage.FRC(), FRCPaymentTermsDAYS2DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS21(), CreateLanguage.ENC(), ENCPaymentTermsDAYS21DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS21(), CreateLanguage.ENU(), ENUPaymentTermsDAYS21DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS21(), CreateLanguage.FRC(), FRCPaymentTermsDAYS21DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS30(), CreateLanguage.ENC(), ENCPaymentTermsDAYS30DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS30(), CreateLanguage.ENU(), ENUPaymentTermsDAYS30DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS30(), CreateLanguage.FRC(), FRCPaymentTermsDAYS30DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS60(), CreateLanguage.ENC(), ENCPaymentTermsDAYS60DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS60(), CreateLanguage.ENU(), ENUPaymentTermsDAYS60DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS60(), CreateLanguage.FRC(), FRCPaymentTermsDAYS60DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS7(), CreateLanguage.ENC(), ENCPaymentTermsDAYS7DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS7(), CreateLanguage.ENU(), ENUPaymentTermsDAYS7DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsDAYS7(), CreateLanguage.FRC(), FRCPaymentTermsDAYS7DescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsCM(), CreateLanguage.ENC(), ENCPaymentTermsCMDescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsCM(), CreateLanguage.ENU(), ENUPaymentTermsCMDescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsCM(), CreateLanguage.FRC(), FRCPaymentTermsCMDescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsCOD(), CreateLanguage.ENC(), ENCPaymentTermsCODDescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsCOD(), CreateLanguage.ENU(), ENUPaymentTermsCODDescLbl);
        ContosoCATranslation.InsertPaymentTermTranslation(CreatePaymentTerms.PaymentTermsCOD(), CreateLanguage.FRC(), FRCPaymentTermsCODDescLbl);
    end;

    var
        ENCPaymentTermsDAYS10DescLbl: Label 'Net 10 days', MaxLength = 100;
        ENUPaymentTermsDAYS10DescLbl: Label 'Net 10 days', MaxLength = 100;
        FRCPaymentTermsDAYS10DescLbl: Label 'Net 10 jours', MaxLength = 100;
        ENCPaymentTermsDAYS14DescLbl: Label 'Net 14 days', MaxLength = 100;
        ENUPaymentTermsDAYS14DescLbl: Label 'Net 14 days', MaxLength = 100;
        FRCPaymentTermsDAYS14DescLbl: Label 'Net 14 jours', MaxLength = 100;
        ENCPaymentTermsDAYS15DescLbl: Label 'Net 15 days', MaxLength = 100;
        ENUPaymentTermsDAYS15DescLbl: Label 'Net 15 days', MaxLength = 100;
        FRCPaymentTermsDAYS15DescLbl: Label 'Net 15 jours', MaxLength = 100;
        ENCPaymentTermsM8DDescLbl: Label '1 Month/2% 8 days', MaxLength = 100;
        ENUPaymentTermsM8DDescLbl: Label '1 Month/2% 8 days', MaxLength = 100;
        FRCPaymentTermsM8DDescLbl: Label '1 Mois/2% 8 jours', MaxLength = 100;
        ENCPaymentTermsDAYS2DescLbl: Label 'Net 2 days', MaxLength = 100;
        ENUPaymentTermsDAYS2DescLbl: Label 'Net 2 days', MaxLength = 100;
        FRCPaymentTermsDAYS2DescLbl: Label 'Net 2 jours', MaxLength = 100;
        ENCPaymentTermsDAYS21DescLbl: Label 'Net 21 days', MaxLength = 100;
        ENUPaymentTermsDAYS21DescLbl: Label 'Net 21 days', MaxLength = 100;
        FRCPaymentTermsDAYS21DescLbl: Label 'Net 21 jours', MaxLength = 100;
        ENCPaymentTermsDAYS30DescLbl: Label 'Net 30 days', MaxLength = 100;
        ENUPaymentTermsDAYS30DescLbl: Label 'Net 30 days', MaxLength = 100;
        FRCPaymentTermsDAYS30DescLbl: Label 'Net 30 jours', MaxLength = 100;
        ENCPaymentTermsDAYS60DescLbl: Label 'Net 60 days', MaxLength = 100;
        ENUPaymentTermsDAYS60DescLbl: Label 'Net 60 days', MaxLength = 100;
        FRCPaymentTermsDAYS60DescLbl: Label 'Net 60 jours', MaxLength = 100;
        ENCPaymentTermsDAYS7DescLbl: Label 'Net 7 days', MaxLength = 100;
        ENUPaymentTermsDAYS7DescLbl: Label 'Net 7 days', MaxLength = 100;
        FRCPaymentTermsDAYS7DescLbl: Label 'Net 7 jours', MaxLength = 100;
        ENCPaymentTermsCMDescLbl: Label 'Current Month', MaxLength = 100;
        ENUPaymentTermsCMDescLbl: Label 'Current Month', MaxLength = 100;
        FRCPaymentTermsCMDescLbl: Label 'Mois en cours', MaxLength = 100;
        ENCPaymentTermsCODDescLbl: Label 'Cash on delivery', MaxLength = 100;
        ENUPaymentTermsCODDescLbl: Label 'Cash on delivery', MaxLength = 100;
        FRCPaymentTermsCODDescLbl: Label 'Paiement … la livraison', MaxLength = 100;
}