codeunit 13738 "Create Acc. Schedule Line DK"
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
        CreateGLAccountDK: Codeunit "Create GL Acc. DK";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        if Rec."Schedule Name" = CreateAccountScheduleName.AccountCategoriesOverview() then
            case Rec."Line No." of
                60000:
                    ValidateRecordFields(Rec, '9999', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
            end;
        if Rec."Schedule Name" = CreateAccountScheduleName.CapitalStructure() then
            case Rec."Line No." of
                40000:
                    ValidateRecordFields(Rec, CreateGLAccountDK.Totalinventory(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                50000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsReceivable() + '..' + CreateGLAccountDK.PrepaymentsReceivables() + '|' + CreateGLAccountDK.Depositstenancy(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                60000:
                    ValidateRecordFields(Rec, '10998', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                70000:
                    ValidateRecordFields(Rec, CreateGLAccountDK.Totalcashflowfunds(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                110000:
                    ValidateRecordFields(Rec, CreateGLAccount.RevolvingCredit(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                120000:
                    ValidateRecordFields(Rec, CreateGLAccountDK.AccountsPayablePosting() + '..' + CreateGLAccountDK.PrepaymentsAccountsPayable(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                130000:
                    ValidateRecordFields(Rec, CreateGLAccountDK.Totalsalestax(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                140000:
                    ValidateRecordFields(Rec, CreateGLAccountDK.Totalpayrollliabilities(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                150000:
                    ValidateRecordFields(Rec, CreateGLAccountDK.Totalaccruedcosts(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CashCycle() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalRevenue(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                20000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsReceivable() + '|' + CreateGLAccount.OtherReceivables() + '|' + CreateGLAccountDK.SalestaxreceivableInputTax() + '..' + CreateGLAccountDK.Euacquisitiontax(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                30000:
                    ValidateRecordFields(Rec, CreateGLAccountDK.AccountsPayablePosting() + '|' + CreateGLAccountDK.PrepaymentsAccountsPayable() + '|' + CreateGLAccountDK.SalestaxpayableSalesTax(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                40000:
                    ValidateRecordFields(Rec, CreateGLAccountDK.Totalinventory(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CashFlow() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsReceivable() + '|' + CreateGLAccount.OtherReceivables() + '|' + CreateGLAccountDK.SalestaxreceivableInputTax() + '..' + CreateGLAccountDK.Euacquisitiontax(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                20000:
                    ValidateRecordFields(Rec, CreateGLAccountDK.AccountsPayablePosting() + '|' + CreateGLAccountDK.PrepaymentsAccountsPayable() + '|' + CreateGLAccountDK.SalestaxpayableSalesTax(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                30000:
                    ValidateRecordFields(Rec, CreateGLAccountDK.Checkout() + '..' + '18300', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.IncomeExpense() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalRevenue(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                30000:
                    ValidateRecordFields(Rec, CreateGLAccountDK.Totalcostofgoodssold() + '|' + CreateGLAccountDK.Totalprojectcosts(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                40000:
                    ValidateRecordFields(Rec, CreateGLAccountDK.Marketingcosts() + '|' + CreateGLAccountDK.Totalvehicleoperations() + '|' + '03597' + '|' + CreateGLAccountDK.Machinestotal() + '|' + CreateGLAccountDK.Totalcostofofficeworkshopspace() + '|' + CreateGLAccountDK.Totaladministrativecosts(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                50000:
                    ValidateRecordFields(Rec, CreateGLAccountDK.Totalpersonnelcosts(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                60000:
                    ValidateRecordFields(Rec, CreateGLAccountDK.Totaldepreciation(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                70000:
                    ValidateRecordFields(Rec, CreateGLAccountDK.Totalfinancialexpenses(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.ReducedTrialBalance() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalRevenue(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                20000:
                    ValidateRecordFields(Rec, CreateGLAccountDK.Totalcostofgoodssold() + '|' + CreateGLAccountDK.Totalprojectcosts(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
                50000:
                    ValidateRecordFields(Rec, CreateGLAccountDK.Totalpersonnelcosts() + '|' + CreateGLAccountDK.Totaldepreciation() + '|' + CreateGLAccountDK.Marketingcosts() + '|' + CreateGLAccountDK.Totalvehicleoperations() + '|' + '03597' + '|' + CreateGLAccountDK.Machinestotal() + '|' + CreateGLAccountDK.Totalcostofofficeworkshopspace() + '|' + CreateGLAccountDK.Totaladministrativecosts(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                80000:
                    ValidateRecordFields(Rec, CreateGLAccountDK.Totalfinancialexpenses(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                90000:
                    ValidateRecordFields(Rec, '07799', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts");
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.Revenues() then
            case Rec."Line No." of
                40000:
                    ValidateRecordFieldsRevenue(Rec, '11', CreateGLAccountDK.Domesticsalesofgoodsandservices(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                50000:
                    ValidateRecordFieldsRevenue(Rec, '12', CreateGLAccountDK.Eusalesofgoodsandservices(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                60000:
                    ValidateRecordFieldsRevenue(Rec, '13', CreateGLAccountDK.Salesofgoodsandservicestoothercountries(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                70000:
                    begin
                        Rec.Validate(Description, SalesAdjmtRetailLbl);
                        ValidateRecordFieldsRevenue(Rec, '14', CreateGLAccountDK.Chargeexsalestax() + '|' + CreateGLAccountDK.Chargeinclsalestax() + '|' + CreateGLAccountDK.Discountsgranted(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                    end;
                80000:
                    ValidateRecordFieldsRevenue(Rec, '16', '11..14', Enum::"Acc. Schedule Line Totaling Type"::Formula);
                100000:
                    begin
                        Rec.Validate(Description, RevenueAreaTotalLbl);
                        Rec.Validate("Dimension 1 Filter", '10..55');
                        ValidateRecordFieldsRevenue(Rec, '21', CreateGLAccountDK.Domesticsalesofgoodsandservices() + '|' + CreateGLAccountDK.Eusalesofgoodsandservices() + '|' + CreateGLAccountDK.Salesofgoodsandservicestoothercountries() + '|' + CreateGLAccountDK.Chargeexsalestax() + '|' + CreateGLAccountDK.Chargeinclsalestax() + '|' + CreateGLAccountDK.Discountsgranted(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                    end;
                110000:
                    ValidateRecordFieldsRevenue(Rec, '22', CreateGLAccountDK.Domesticsalesofgoodsandservices() + '|' + CreateGLAccountDK.Eusalesofgoodsandservices() + '|' + CreateGLAccountDK.Salesofgoodsandservicestoothercountries() + '|' + CreateGLAccountDK.Chargeexsalestax() + '|' + CreateGLAccountDK.Chargeinclsalestax() + '|' + CreateGLAccountDK.Discountsgranted(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                120000:
                    ValidateRecordFieldsRevenue(Rec, '23', CreateGLAccountDK.Domesticsalesofgoodsandservices() + '|' + CreateGLAccountDK.Eusalesofgoodsandservices() + '|' + CreateGLAccountDK.Salesofgoodsandservicestoothercountries() + '|' + CreateGLAccountDK.Chargeexsalestax() + '|' + CreateGLAccountDK.Chargeinclsalestax() + '|' + CreateGLAccountDK.Discountsgranted(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
                130000:
                    ValidateRecordFieldsRevenue(Rec, '34', '21..23', Enum::"Acc. Schedule Line Totaling Type"::Formula);
            end;
    end;

    local procedure ValidateRecordFields(var AccScheduleLine: Record "Acc. Schedule Line"; Totaling: Text; TotalingType: Enum "Acc. Schedule Line Totaling Type")
    begin
        AccScheduleLine.Validate(Totaling, Totaling);
        AccScheduleLine.Validate("Totaling Type", TotalingType);
    end;

    local procedure ValidateRecordFieldsRevenue(var AccScheduleLine: Record "Acc. Schedule Line"; RowNo: Code[10]; Totaling: Text; TotalingType: Enum "Acc. Schedule Line Totaling Type")
    begin
        AccScheduleLine.Validate("Row No.", RowNo);
        AccScheduleLine.Validate(Totaling, Totaling);
        AccScheduleLine.Validate("Totaling Type", TotalingType);
    end;

    var
        SalesAdjmtRetailLbl: Label 'Sales Adjmt, Retail', MaxLength = 100;
        RevenueAreaTotalLbl: Label 'Revenue Area 10..55, Total', MaxLength = 100;
}