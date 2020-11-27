pageextension 11785 "Tariff Numbers CZL" extends "Tariff Numbers"
{
    layout
    {
        addafter("Supplementary Units")
        {
            field("Statement Code CZL"; Rec."Statement Code CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the statement code for VAT control report and reverse charge.';
            }
            field("Statement Limit Code CZL"; Rec."Statement Limit Code CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the statement limit code for VAT control report and reverse charge.';
            }
            field("VAT Stat. UoM Code CZL"; Rec."VAT Stat. UoM Code CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the unit of measure code for reverse charge reporting.';
            }
            field("Allow Empty UoM Code CZL"; Rec."Allow Empty UoM Code CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the possibillity to allow or not allow empty unit of meas. code for VAT reverse charge.';
            }
        }
    }
}
