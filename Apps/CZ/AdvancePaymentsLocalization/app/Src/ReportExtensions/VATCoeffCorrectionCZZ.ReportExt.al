#pragma warning disable AA0247
reportextension 31007 "VAT Coeff. Correction CZZ" extends "VAT Coeff. Correction CZL"
{
    dataset
    {
        modify("VAT Entry")
        {
            trigger OnAfterPreDataItem()
            begin
                if RecalculateAdvances then
                    exit;

                "VAT Entry".SetRange("Advance Letter No. CZZ", '');
            end;
        }
        modify(Loop)
        {
            trigger OnAfterPostDataItem()
            begin
                if not RecalculateAdvances or not Post then
                    exit;

                UpdatePurchAdvLetterEntries();
            end;
        }
    }

    requestpage
    {
        layout
        {
            addlast(Entries)
            {
                field(RecalculateAdvancesField; RecalculateAdvances)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Recalculate Advances';
                    ToolTip = 'Specifies whether the advances should be recalculated.';
                }
            }
        }
    }

    var
        RecalculateAdvances: Boolean;

    [InherentPermissions(PermissionObjectType::TableData, Database::"Purch. Adv. Letter Entry CZZ", 'rm')]
    local procedure UpdatePurchAdvLetterEntries()
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        NonDeductibleVATSetupCZL: Record "Non-Deductible VAT Setup CZL";
    begin
        PurchAdvLetterEntryCZZ.SetRange("VAT Date", FromVATDate, ToVATDate);
        PurchAdvLetterEntryCZZ.SetFilter("Non-Deductible VAT %", '<>0');
        if PurchAdvLetterEntryCZZ.FindSet() then
            repeat
                if NonDeductibleVATSetupCZL.FindToDate(PurchAdvLetterEntryCZZ."VAT Date") then
                    if PurchAdvLetterEntryCZZ."Non-Deductible VAT %" <> NonDeductibleVATSetupCZL."Settlement Coefficient" then begin
                        PurchAdvLetterEntryCZZ."Non-Deductible VAT %" := NonDeductibleVATSetupCZL."Settlement Coefficient";
                        PurchAdvLetterEntryCZZ.Modify(false);
                    end;
            until PurchAdvLetterEntryCZZ.Next() = 0;
    end;
}
