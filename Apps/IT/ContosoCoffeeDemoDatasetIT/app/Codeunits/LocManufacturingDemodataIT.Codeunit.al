codeunit 12164 "Loc. Manufacturing Demodata-IT"
{
    Permissions = tabledata "Routing Line" = rm,
        tabledata "No. Series" = rm;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifyManufacturingDemoAccounts()
    begin
        ManufacturingDemoAccount.ReturnAccountKey(true);

        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.WIPAccountFinishedgoods(), '2140');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.MaterialVariance(), '7890');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.CapacityVariance(), '7891');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.MfgOverheadVariance(), '7894');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.CapOverheadVariance(), '7893');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.SubcontractedVariance(), '7892');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.FinishedGoods(), '2130');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.RawMaterials(), '2120');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedCap(), '7791');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedRawMat(), '7291');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.DirectCostAppliedRetail(), '7191');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.InventoryAdjRawMat(), '7270');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.InventoryAdjRetail(), '7170');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedCap(), '7792');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedRawMat(), '7292');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.OverheadAppliedRetail(), '7192');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchRawMatDom(), '7210');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceCap(), '7793');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceRawMat(), '7293');
        ManufacturingDemoAccounts.AddAccount(ManufacturingDemoAccount.PurchaseVarianceRetail(), '7193');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg Item Jnl Template", 'OnAfterInitSeries', '', false, false)]
    local procedure ChangeNoSeries(var NoSeriesCode: Code[20])
    begin
        ModifyNoSeriesWithDefaultValues(NoSeriesCode);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg Setup", 'OnAfterInitSeries', '', false, false)]
    local procedure ChangeCode(var SeriesCode: Code[20]; var "Code": Code[20])
    begin
        ModifyNoSeriesWithDefaultValues("Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg Prod. Routing", 'OnAfterRoutingLineInsert', '', false, false)]
    local procedure ModifyRoutingLine(var RoutingLine: Record "Routing Line")
    begin
        if RoutingLine."Routing No." = '2000' then begin
            case RoutingLine."Operation No." of
                '10':
                    RoutingLine.Validate("WIP Item", false);
                '20':
                    begin
                        RoutingLine.Validate("Standard Task Code", '1');
                        RoutingLine.Validate("WIP Item", true);
                    end;
                '30':
                    begin
                        RoutingLine.Validate("Standard Task Code", '2');
                        RoutingLine.Validate("WIP Item", false);
                    end;
            end;

            RoutingLine.Modify();
        end;
    end;

    local procedure ModifyNoSeriesWithDefaultValues("Code": Code[20])
    var
        NoSeries: Record "No. Series";
    begin
        NoSeries.Get("Code");

        NoSeries."No. Series Type" := NoSeries."No. Series Type"::Normal;
        NoSeries."VAT Register" := '';
        NoSeries."VAT Reg. Print Priority" := 0;
        NoSeries."Reverse Sales VAT No. Series" := '';
        NoSeries."Date Order" := false;

        NoSeries.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Whse Demo Accounts", 'OnAfterCreateDemoAccounts', '', false, false)]
    local procedure AddAndModifyWhseDemoAccounts()
    begin
        WhseDemoAccount.ReturnAccountKey(true);

        WhseDemoAccounts.AddAccount(WhseDemoAccount.CustDomestic(), '2310');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.Resale(), '2110');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.ResaleInterim(), '2111');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.VendDomestic(), '5410');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.SalesDomestic(), '6410');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.PurchDomestic(), '7110');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.SalesVAT(), '5610');
        WhseDemoAccounts.AddAccount(WhseDemoAccount.PurchaseVAT(), '5630');
    end;

    var
        ManufacturingDemoAccount: Record "Manufacturing Demo Account";
        WhseDemoAccount: Record "Whse. Demo Account";
        ManufacturingDemoAccounts: Codeunit "Manufacturing Demo Accounts";
        WhseDemoAccounts: Codeunit "Whse. Demo Accounts";
}