codeunit 148006 "Library - EET CZL"
{

    trigger OnRun()
    begin
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";

    procedure CreateEETBusinessPremises(var EETBusinessPremisesCZL: Record "EET Business Premises CZL"; Identification2: Code[6])
    begin
        EETBusinessPremisesCZL.Init();
        EETBusinessPremisesCZL.Validate(Code, LibraryUtility.GenerateRandomCode(EETBusinessPremisesCZL.FieldNo(Code), DATABASE::"EET Business Premises CZL"));
        EETBusinessPremisesCZL.Insert(true);

        EETBusinessPremisesCZL.Description := EETBusinessPremisesCZL.Code;
        EETBusinessPremisesCZL.Identification := Identification2;
        EETBusinessPremisesCZL.Modify(true);
    end;

    procedure CreateEETCashRegister(var EETCashRegisterCZL: Record "EET Cash Register CZL"; BusinessPremisesCode: Code[10]; CashRegisterType: Enum "EET Cash Register Type CZL"; CashRegisterNo: Code[20])
    var
        EETBusinessPremises: Record "EET Business Premises CZL";
    begin
        if not EETBusinessPremises.Get(BusinessPremisesCode) then
            CreateEETBusinessPremises(EETBusinessPremises, GetDefaultBusinessPremisesIdentification());

        BusinessPremisesCode := EETBusinessPremises.Code;
        EETCashRegisterCZL.Init();
        EETCashRegisterCZL."Business Premises Code" := BusinessPremisesCode;
        EETCashRegisterCZL.Validate(Code, LibraryUtility.GenerateRandomCode(EETCashRegisterCZL.FieldNo(Code), DATABASE::"EET Cash Register CZL"));
        EETCashRegisterCZL.Insert(true);

        EETCashRegisterCZL.Validate("Cash Register Type", CashRegisterType);
        EETCashRegisterCZL.Validate("Cash Register No.", CashRegisterNo);
        EETCashRegisterCZL.Validate("Receipt Serial Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        EETCashRegisterCZL.Modify(true);
    end;

    local procedure CreateEETServiceSetup(var EETServiceSetupCZL: Record "EET Service Setup CZL")
    begin
        EETServiceSetupCZL.Init();
        EETServiceSetupCZL.Insert(true);
    end;

    procedure GetDefaultBusinessPremisesIdentification(): Code[6]
    begin
        exit('181');
    end;

    procedure SetEnabledEETService(Enabled: Boolean)
    var
        EETServiceSetupCZL: Record "EET Service Setup CZL";
    begin
        if not EETServiceSetupCZL.Get() then
            CreateEETServiceSetup(EETServiceSetupCZL);

        EETServiceSetupCZL.Enabled := Enabled;
        EETServiceSetupCZL.Modify();
    end;

    procedure SetCertificateCode(CertificateCode: Code[10])
    var
        EETServiceSetupCZL: Record "EET Service Setup CZL";
    begin
        if not EETServiceSetupCZL.Get() then
            CreateEETServiceSetup(EETServiceSetupCZL);

        EETServiceSetupCZL.Validate("Certificate Code", CertificateCode);
        EETServiceSetupCZL.Modify();
    end;
}

