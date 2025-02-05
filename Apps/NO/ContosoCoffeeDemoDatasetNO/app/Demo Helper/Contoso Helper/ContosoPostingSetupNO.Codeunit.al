codeunit 10722 "Contoso Posting Setup NO"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "VAT Posting Setup" = rim,
        tabledata "VAT Reporting Code" = rim;

    var
        VATSetupDescTok: Label 'Setup for %1 / %2', MaxLength = 100, Comment = '%1 is the VAT Bus. Posting Group Code, %2 is the VAT Prod. Posting Group Code';
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertVatReportingCode(Code: Code[20]; Description: Text[250]; GenPostingType: Option; TradeSettlement2017BoxNo: Option; ReverseChargeReportBoxNo: Option)
    var
        VATReportingCode: Record "VAT Reporting Code";
        Exists: Boolean;
    begin
        if VATReportingCode.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VATReportingCode.Validate(Code, Code);
        VATReportingCode.Validate(Description, Description);
        VATReportingCode.Validate("Gen. Posting Type", GenPostingType);
        VATReportingCode.Validate("Trade Settlement 2017 Box No.", TradeSettlement2017BoxNo);
        VATReportingCode.Validate("Reverse Charge Report Box No.", ReverseChargeReportBoxNo);

        if Exists then
            VATReportingCode.Modify(true)
        else
            VATReportingCode.Insert(true);
    end;

    procedure InsertVATPostingSetup(VATBusinessGroupCode: Code[20]; VATProductGroupCode: Code[20]; SalesVATAccountNo: Code[20]; PurchaseVATAccountNo: Code[20]; VATIdentifier: Code[20]; VATPercentage: Decimal; VATCalculationType: Enum "Tax Calculation Type"; TaxCategory: Code[10]; ReverseChargeVATUnrealAcc: Code[20]; VATClauseCode: Code[20]; SalesVATReportingCode: Code[20]; PurchaseVATReportingCode: Code[20]; VATNumber: Code[20])
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Exists: Boolean;
    begin
        if VATPostingSetup.Get(VATBusinessGroupCode, VATProductGroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VATPostingSetup.Validate("VAT Bus. Posting Group", VATBusinessGroupCode);
        VATPostingSetup.Validate("VAT Prod. Posting Group", VATProductGroupCode);
        VATPostingSetup.Validate(Description, StrSubstNo(VATSetupDescTok, VATBusinessGroupCode, VATProductGroupCode));
        if SalesVATReportingCode <> '' then
            VATPostingSetup.Validate("Sale VAT Reporting Code", SalesVATReportingCode);
        if PurchaseVATReportingCode <> '' then
            VATPostingSetup.Validate("Purch. VAT Reporting Code", PurchaseVATReportingCode);
        if VATNumber <> '' then
            VATPostingSetup.Validate("VAT Number", VATNumber);

        if Exists then begin
            if VATPostingSetup."VAT Calculation Type" <> VATCalculationType then
                VATPostingSetup.Validate("VAT Calculation Type", VATCalculationType);
        end else
            VATPostingSetup.Validate("VAT Calculation Type", VATCalculationType);

        if not (VATPostingSetup."VAT Calculation Type" = Enum::"Tax Calculation Type"::"Sales Tax") then begin
            VATPostingSetup.Validate("Sales VAT Account", SalesVATAccountNo);
            VATPostingSetup.Validate("Purchase VAT Account", PurchaseVATAccountNo);
            VATPostingSetup.Validate("VAT Identifier", VATIdentifier);
            VATPostingSetup.Validate("VAT %", VATPercentage);
        end;
        if VATPostingSetup."VAT Calculation Type" = VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT" then
            VATPostingSetup.Validate("Reverse Chrg. VAT Acc.", ReverseChargeVATUnrealAcc);

        VATPostingSetup.Validate("Tax Category", TaxCategory);
        VATPostingSetup.Validate("VAT Clause Code", VATClauseCode);

        if Exists then
            VATPostingSetup.Modify(true)
        else
            VATPostingSetup.Insert(true);
    end;
}