codeunit 5155 "Create FA Insurance"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
        FixedAsset: Record "Fixed Asset";
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
        CreateFAInsuranceType: Codeunit "Create FA Insurance Type";
        CreateFixedAssets: Codeunit "Create Fixed Asset";
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        FixedAsset.Get(CreateFixedAssets.FA000010());
        ContosoFixedAsset.InsertInsurance(FAInsurance000010(), FixedAsset.Description, ContosoUtilities.AdjustDate(19030101D), InsurancePolicyNoQW27425ALbl, 4000, 35000, CreateFAInsuranceType.Vehicle(), FixedAsset."FA Class Code", FixedAsset."FA Subclass Code");

        FixedAsset.Get(CreateFixedAssets.FA000020());
        ContosoFixedAsset.InsertInsurance(FAInsurance000020(), FixedAsset.Description, ContosoUtilities.AdjustDate(19030101D), InsurancePolicyNoQW37425ALbl, 3000, 45000, CreateFAInsuranceType.Vehicle(), FixedAsset."FA Class Code", FixedAsset."FA Subclass Code");

        FixedAsset.Get(CreateFixedAssets.FA000030());
        ContosoFixedAsset.InsertInsurance(FAInsurance000030(), FixedAsset.Description, ContosoUtilities.AdjustDate(19030101D), InsurancePolicyNoQW38425AKLbl, 2000, 20000, CreateFAInsuranceType.Vehicle(), FixedAsset."FA Class Code", FixedAsset."FA Subclass Code");

        FixedAsset.Get(CreateFixedAssets.FA000040());
        ContosoFixedAsset.InsertInsurance(FAInsurance000040(), MachineryInsuranceLbl, ContosoUtilities.AdjustDate(19030101D), InsurancePolicyNoQMA18425ALbl, 10000, 30000, CreateFAInsuranceType.Machinery(), FixedAsset."FA Class Code", FixedAsset."FA Subclass Code");
    end;

    var
        Ins000010Lbl: Label 'INS000010', MaxLength = 20;
        Ins000020Lbl: Label 'INS000020', MaxLength = 20;
        Ins000030Lbl: Label 'INS000030', MaxLength = 20;
        Ins000040Lbl: Label 'INS000040', MaxLength = 20;
        InsurancePolicyNoQW27425ALbl: Label 'QW 27425 A', Locked = true;
        InsurancePolicyNoQW37425ALbl: Label 'QW 37425 A', Locked = true;
        InsurancePolicyNoQW38425AKLbl: Label 'QW 38425 A', Locked = true;
        InsurancePolicyNoQMA18425ALbl: Label 'MA 18425 A', Locked = true;
        MachineryInsuranceLbl: Label 'Machinery Insurance', MaxLength = 100;

    procedure FAInsurance000010(): Text[20]
    begin
        exit(Ins000010Lbl);
    end;

    procedure FAInsurance000020(): Text[20]
    begin
        exit(Ins000020Lbl);
    end;

    procedure FAInsurance000030(): Text[20]
    begin
        exit(Ins000030Lbl);
    end;

    procedure FAInsurance000040(): Text[20]
    begin
        exit(Ins000040Lbl);
    end;
}