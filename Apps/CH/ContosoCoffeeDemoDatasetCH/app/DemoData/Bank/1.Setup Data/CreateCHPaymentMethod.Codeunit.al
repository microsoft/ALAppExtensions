codeunit 11609 "Create CH Payment Method"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPayments: Codeunit "Contoso Payments";
    begin
        ContosoPayments.InsertBankPaymentMethod(ESR(), ESRWithCSLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
        ContosoPayments.InsertBankPaymentMethod(ESRPost(), ESRWithPostLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
        ContosoPayments.InsertBankPaymentMethod(LSV(), CustomerLSVCollectionLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
    end;

    procedure ESR(): Code[10]
    begin
        exit(ESRTok);
    end;

    procedure ESRPost(): Code[10]
    begin
        exit(ESRPostTok);
    end;

    procedure LSV(): Code[10]
    begin
        exit(LSVTok);
    end;

    var
        ESRTok: Label 'ESR', MaxLength = 10;
        ESRWithCSLbl: Label 'ESR with CS', MaxLength = 100;
        ESRPostTok: Label 'ESR POST', MaxLength = 10;
        ESRWithPostLbl: Label 'ESR with POST', MaxLength = 100;
        LSVTok: Label 'LSV', MaxLength = 10;
        CustomerLSVCollectionLbl: Label 'Customer with LSV Collection', MaxLength = 100;
}