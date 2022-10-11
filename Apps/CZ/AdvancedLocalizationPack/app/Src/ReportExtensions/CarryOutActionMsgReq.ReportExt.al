reportextension 11701 "Carry Out Action Msg. Req. CZA" extends "Carry Out Action Msg. - Req."
{
    requestpage
    {
        layout
        {
            addlast(Options)
            {
                field(PurchOrderHeaderNoSeries; PurchOrderHeader."No. Series")
                {
                    ApplicationArea = Planning;
                    Caption = 'No. Series';
                    ToolTip = 'Specifies no. series for reporting';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        PurchasesPayablesSetupCZA.Get();
                        PurchasesPayablesSetupCZA.TestField("Order Nos.");
                        if NoSeriesManagementCZA.SelectSeries(PurchasesPayablesSetupCZA."Order Nos.", '', PurchOrderHeader."No. Series") then
                            NoSeriesManagementCZA.TestSeries(PurchasesPayablesSetupCZA."Order Nos.", PurchOrderHeader."No. Series");
                    end;

                    trigger OnValidate()
                    begin
                        PurchasesPayablesSetupCZA.Get();
                        PurchasesPayablesSetupCZA.TestField("Order Nos.");
                        if PurchOrderHeader."No. Series" <> '' then
                            NoSeriesManagementCZA.TestSeries(PurchasesPayablesSetupCZA."Order Nos.", PurchOrderHeader."No. Series");
                    end;
                }
            }
        }
    }

    var
        PurchasesPayablesSetupCZA: Record "Purchases & Payables Setup";
        NoSeriesManagementCZA: Codeunit NoSeriesManagement;
}