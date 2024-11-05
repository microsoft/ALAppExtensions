codeunit 149126 "BCPT Create Customer" implements "BCPT Test Param. Provider"
{
    trigger OnRun()
    begin
        InitTest();
        CreateCustomer();
    end;

    var
        BCPTTestContext: Codeunit "BCPT Test Context";
        CustomerTemplateToUse: Code[20];
        CustomerTemplateParamLbl: Label 'Customer Template';
        ParamValidationErr: Label 'Parameter is not defined in the correct format. The expected format is "%1"', Comment = '%1 = Default Parameter';

    local procedure InitTest()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        NoSeriesLine: Record "No. Series Line";
    begin
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.TestField("Customer Nos.");
        NoSeriesLine.SetRange("Series Code", SalesReceivablesSetup."Customer Nos.");
        NoSeriesLine.FindSet(true);
        repeat
            if NoSeriesLine."Ending No." <> '' then begin
                NoSeriesLine."Ending No." := '';
                NoSeriesLine.Validate("Allow Gaps in Nos.", true);
                NoSeriesLine.Modify(true);
            end;
        until NoSeriesLine.Next() = 0;
        Commit(); //Commit to avoid deadlocks

        if Evaluate(CustomerTemplateToUse, BCPTTestContext.GetParameter(CustomerTemplateParamLbl)) then;
    end;

    local procedure CreateCustomer()
    var
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        CustContUpdate: Codeunit "CustCont-Update";
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
    begin
        Clear(Customer);
        Customer.Insert(true);
        Customer.Validate(Name, Customer."No.");

        if CustomerTemplateToUse <> '' then begin
            CustomerTempl.Get(CustomerTemplateToUse);
            CustomerTemplMgt.ApplyCustomerTemplate(Customer, CustomerTempl)
        end else begin
            Customer.Validate("Gen. Bus. Posting Group", LookUpGenBusPostingGroup());
            Customer.Validate("VAT Bus. Posting Group", FindVATPostingSetup());
            Customer.Validate("Customer Posting Group", FindCustomerPostingGroup());
            Customer.Validate("Payment Terms Code", FindPaymentTermsCode());
            Customer.Validate("Payment Method Code", FindPaymentMethod());
            Customer.Modify(true);
        end;
        Commit(); //Commit to avoid deadlocks
        CustContUpdate.OnModify(Customer);

        OnAfterCreateCustomer(Customer);
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

    local procedure FindCustomerPostingGroup(): Code[20]
    var
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        CustomerPostingGroup.SetFilter("Receivables Account", '<>%1', '');
        if CustomerPostingGroup.FindFirst() then
            exit(CustomerPostingGroup.Code);
    end;

    local procedure FindVATPostingSetup(): Code[20]
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.SetFilter("VAT Prod. Posting Group", '<>%1', '');
        VATPostingSetup.SetFilter("VAT %", '<>%1', 0);
        VATPostingSetup.SetRange("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        VATPostingSetup.SetFilter("Sales VAT Account", '<>%1', '');
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
        exit(CopyStr(CustomerTemplateParamLbl + '=', 1, 1000));
    end;

    procedure ValidateParameters(Parameters: Text[1000])
    begin
        if StrPos(Parameters, CustomerTemplateParamLbl) > 0 then begin
            Parameters := DelStr(Parameters, 1, StrLen(CustomerTemplateParamLbl + '='));
            if Evaluate(CustomerTemplateToUse, Parameters) then
                exit;
        end;
        Error(ParamValidationErr, GetDefaultParameters());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateCustomer(var Customer: Record Customer)
    begin
    end;
}