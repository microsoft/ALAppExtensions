codeunit 149125 "BCPT Create Vendor" implements "BCPT Test Param. Provider"
{
    trigger OnRun()
    begin
        InitTest();
        CreateVendor();
    end;

    var
        BCPTTestContext: Codeunit "BCPT Test Context";
        VendorTemplateToUse: Code[20];
        VendorTemplateParamLbl: Label 'Vendor Template';
        ParamValidationErr: Label 'Parameter is not defined in the correct format. The expected format is "%1"', Comment = '%1 = Default Parameter';

    local procedure InitTest();
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        NoSeriesLine: Record "No. Series Line";
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.TestField("Vendor Nos.");
        NoSeriesLine.SetRange("Series Code", PurchasesPayablesSetup."Vendor Nos.");
        NoSeriesLine.FindSet(true);
        repeat
            if NoSeriesLine."Ending No." <> '' then begin
                NoSeriesLine."Ending No." := '';
                NoSeriesLine.Validate("Allow Gaps in Nos.", true);
                NoSeriesLine.Modify(true);
            end;
        until NoSeriesLine.Next() = 0;
        Commit(); //Commit to avoid deadlocks

        if Evaluate(VendorTemplateToUse, BCPTTestContext.GetParameter(VendorTemplateParamLbl)) then;
    end;

    local procedure CreateVendor()
    var
        Vendor: Record Vendor;
        VendorTempl: Record "Vendor Templ.";
        VendContUpdate: Codeunit "VendCont-Update";
        VendorTemplMgt: Codeunit "Vendor Templ. Mgt.";
    begin
        Clear(Vendor);
        Vendor.Insert(true);
        Vendor.Validate(Name, Vendor."No.");
        if VendorTemplateToUse <> '' then begin
            VendorTempl.Get(VendorTemplateToUse);
            VendorTemplMgt.ApplyVendorTemplate(Vendor, VendorTempl)
        end else begin
            Vendor.Validate("Gen. Bus. Posting Group", LookUpGenBusPostingGroup());
            Vendor.Validate("VAT Bus. Posting Group", FindVATPostingSetup());
            Vendor.Validate("Vendor Posting Group", FindVendorPostingGroup());
            Vendor.Validate("Payment Terms Code", FindPaymentTermsCode());
            Vendor.Validate("Payment Method Code", FindPaymentMethod());
            Vendor.Modify(true);
        end;
        Commit(); //Commit to avoid deadlocks
        VendContUpdate.OnModify(Vendor);

        OnAfterCreateVendor(Vendor);
        Commit(); //Commit to avoid deadlocks
    end;

    local procedure LookUpGenBusPostingGroup(): Code[20]
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        GeneralPostingSetup.Reset();
        GeneralPostingSetup.SetFilter("Gen. Prod. Posting Group", '<>%1', '');
        GeneralPostingSetup.SetFilter("Purch. Account", '<>%1', '');
        if GeneralPostingSetup.FindFirst() then
            exit(GeneralPostingSetup."Gen. Bus. Posting Group");
    end;

    local procedure FindVendorPostingGroup(): Code[20]
    var
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        VendorPostingGroup.SetFilter("Payables Account", '<>%1', '');
        if VendorPostingGroup.FindFirst() then
            exit(VendorPostingGroup.Code);
    end;

    local procedure FindVATPostingSetup(): Code[20]
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.SetFilter("VAT Prod. Posting Group", '<>%1', '');
        VATPostingSetup.SetFilter("VAT %", '<>%1', 0);
        VATPostingSetup.SetRange("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        VATPostingSetup.SetFilter("Purchase VAT Account", '<>%1', '');
        if VATPostingSetup.FindFirst() then
            exit(VATPostingSetup."VAT Bus. Posting Group");
    end;

    local procedure FindPaymentTermsCode(): Code[10]
    var
        PaymentTerms: Record "Payment Terms";
        DateFormular_0D: DateFormula;
    begin
        Evaluate(DateFormular_0D, '<0D>');

        if PaymentTerms.FieldActive("Due Date Calculation") then
            PaymentTerms.SetRange("Due Date Calculation", DateFormular_0D);
        if PaymentTerms.FindFirst() then
            exit(PaymentTerms.Code);
    end;

    local procedure FindPaymentMethod(): Code[10]
    var
        PaymentMethod: Record "Payment Method";
    begin
        PaymentMethod.SetRange("Bal. Account No.", '');
        if PaymentMethod.FindFirst() then
            exit(PaymentMethod.Code)
    end;

    procedure GetDefaultParameters(): Text[1000]
    begin
        exit(CopyStr(VendorTemplateParamLbl + '=', 1, 1000));
    end;

    procedure ValidateParameters(Parameters: Text[1000])
    begin
        if StrPos(Parameters, VendorTemplateParamLbl) > 0 then begin
            Parameters := DelStr(Parameters, 1, StrLen(VendorTemplateParamLbl + '='));
            if Evaluate(VendorTemplateToUse, Parameters) then
                exit;
        end;
        Error(ParamValidationErr, GetDefaultParameters());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateVendor(var Vendor: Record Vendor)
    begin
    end;
}