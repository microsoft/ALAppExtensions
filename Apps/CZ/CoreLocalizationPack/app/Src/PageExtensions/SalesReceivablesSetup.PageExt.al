#if not CLEAN22
pageextension 11718 "Sales & Receivables Setup CZL" extends "Sales & Receivables Setup"
{
    ObsoleteState = Pending;
#pragma warning disable AS0072
    ObsoleteTag = '22.0';
#pragma warning restore AS0072
    ObsoleteReason = 'All fields from this pageextension are obsolete.';

    layout
    {
        addlast(content)
        {
            group(VatCZL)
            {
                Caption = 'VAT';
                Visible = not ReplaceVATDateEnabled;
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'All fields from this group are obsolete.';

                field("Default VAT Date CZL"; Rec."Default VAT Date CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default VAT date type for sales document (posting date, document date, blank).';
                    Visible = not ReplaceVATDateEnabled;
                    ObsoleteState = Pending;
                    ObsoleteTag = '22.0';
                    ObsoleteReason = 'Replaced by VAT Reporting Date in General Ledger Setup.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        ReplaceVATDateEnabled := ReplaceVATDateMgtCZL.IsEnabled();
    end;

    var
#pragma warning disable AL0432
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
#pragma warning restore AL0432
        ReplaceVATDateEnabled: Boolean;
}

#endif