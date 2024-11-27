codeunit 5696 "Contoso Finance Charge"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Finance Charge Terms" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertFinanceChargeTerms(Code: Code[10]; InterestRate: Decimal; Description: Text[100]; InterestCalculationMethod: Enum "Interest Calculation Method"; InterestPeriodDays: Integer; GracePeriod: Text; DueDateCalculation: Text; PostInterest: Boolean; PostAdditionalFee: Boolean; LineDescription: Text[100]; DetailedLinesDescription: Text[100])
    var
        FinanceChargeTerms: Record "Finance Charge Terms";
        Exists: Boolean;
    begin
        if FinanceChargeTerms.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        FinanceChargeTerms.Validate(Code, Code);
        FinanceChargeTerms.Validate("Interest Rate", InterestRate);
        FinanceChargeTerms.Description := Description;
        FinanceChargeTerms.Validate("Interest Calculation Method", InterestCalculationMethod);
        FinanceChargeTerms.Validate("Interest Period (Days)", InterestPeriodDays);
        Evaluate(FinanceChargeTerms."Grace Period", GracePeriod);
        Evaluate(FinanceChargeTerms."Due Date Calculation", DueDateCalculation);
        FinanceChargeTerms.Validate("Grace Period");
        FinanceChargeTerms.Validate("Due Date Calculation");
        FinanceChargeTerms.Validate("Post Interest", PostInterest);
        FinanceChargeTerms.Validate("Post Additional Fee", PostAdditionalFee);
        FinanceChargeTerms.Validate("Line Description", LineDescription);
        FinanceChargeTerms.Validate("Detailed Lines Description", DetailedLinesDescription);

        if Exists then
            FinanceChargeTerms.Modify(true)
        else
            FinanceChargeTerms.Insert(true);
    end;
}