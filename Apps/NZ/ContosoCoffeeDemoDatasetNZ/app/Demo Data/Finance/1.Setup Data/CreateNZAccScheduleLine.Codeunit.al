codeunit 17122 "Create NZ Acc. Schedule Line"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    //ToDo: Need to Check with MS Team why standard Schedule Name are commented in W1

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertAccScheduleLine(var Rec: Record "Acc. Schedule Line")
    var
        CreateAccountScheduleName: Codeunit "Create Acc. Schedule Name";
    begin
        if Rec."Schedule Name" = CreateAccountScheduleName.CashCycle() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '6995', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                20000:
                    ValidateRecordFields(Rec, '2390', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                30000:
                    ValidateRecordFields(Rec, '5490', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                40000:
                    ValidateRecordFields(Rec, '2190', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                50000:
                    Rec.Validate("Hide Currency Symbol", true);
                60000:
                    Rec.Validate("Hide Currency Symbol", true);
                70000:
                    Rec.Validate("Hide Currency Symbol", true);
                80000:
                    Rec.Validate("Hide Currency Symbol", true);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CashFlow() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '2390', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                20000:
                    ValidateRecordFields(Rec, '5490', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                30000:
                    ValidateRecordFields(Rec, '2990|5310', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                40000:
                    ValidateRecordFields(Rec, '10..30', Enum::"Acc. Schedule Line Totaling Type"::Formula);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.IncomeExpense() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '6995', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                30000:
                    ValidateRecordFields(Rec, '7995', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                40000:
                    ValidateRecordFields(Rec, '8695', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                50000:
                    ValidateRecordFields(Rec, '8790', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                60000:
                    ValidateRecordFields(Rec, '8890', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                70000:
                    ValidateRecordFields(Rec, '8910', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.ReducedTrialBalance() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFieldsReducedTrial(Rec, TotalRevenueLbl, '6995', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", true);
                20000:
                    Rec.Validate(Totaling, '7995');
                40000:
                    Rec.Validate("Hide Currency Symbol", true);
                50000:
                    ValidateRecordFields(Rec, '8695|8790|8890', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                70000:
                    Rec.Validate("Hide Currency Symbol", true);
                80000:
                    Rec.Validate(Totaling, '8910');
                90000:
                    Rec.Validate(Totaling, '9495');
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.Revenues() then
            case Rec."Line No." of
                50000:
                    ValidateRecordFieldsReducedTrial(Rec, SalesRetailLbl, '6130', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                120000:
                    Rec.Validate("Dimension 1 Totaling", '');
            end;
    end;

    local procedure ValidateRecordFields(var AccScheduleLine: Record "Acc. Schedule Line"; Totaling: Text; TotalingType: Enum "Acc. Schedule Line Totaling Type")
    begin
        AccScheduleLine.Validate(Totaling, Totaling);
        AccScheduleLine.Validate("Totaling Type", TotalingType);
    end;

    local procedure ValidateRecordFieldsReducedTrial(var AccScheduleLine: Record "Acc. Schedule Line"; Description: Text[250]; Totaling: Text; TotalingType: Enum "Acc. Schedule Line Totaling Type"; ShowOppositeSign: Boolean)
    begin
        AccScheduleLine.Validate(Description, Description);
        AccScheduleLine.Validate(Totaling, Totaling);
        AccScheduleLine.Validate("Totaling Type", TotalingType);
        AccScheduleLine.Validate("Show Opposite Sign", ShowOppositeSign);
    end;

    var
        TotalRevenueLbl: Label 'Total Revenue', MaxLength = 250;
        SalesRetailLbl: Label 'Sales, Retail - MISC', MaxLength = 250;
}