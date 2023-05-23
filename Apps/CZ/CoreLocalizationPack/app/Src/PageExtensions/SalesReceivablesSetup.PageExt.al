#if not CLEAN22
pageextension 11718 "Sales & Receivables Setup CZL" extends "Sales & Receivables Setup"
{
    layout
    {
#if not CLEAN20
        addlast(General)
        {
            field("Allow Alter Posting Groups CZL"; Rec."Allow Alter Posting Groups CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Allow Alter Posting Groups (Obsolete)';
                ToolTip = 'Allows you to use a different posting group on the document than the one set on the customer.';
                Visible = not AllowMultiplePostingGroupsEnabled;
                ObsoleteState = Pending;
                ObsoleteTag = '20.1';
                ObsoleteReason = 'It will be replaced by "Allow Multiple Posting Groups" field.';
            }
        }
#endif
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
#if not CLEAN20
        AllowMultiplePostingGroupsEnabled := PostingGroupManagement.IsAllowMultipleCustVendPostingGroupsEnabled();
#endif
    end;

    var
#pragma warning disable AL0432
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
#if not CLEAN20
        PostingGroupManagement: Codeunit "Posting Group Management CZL";
        AllowMultiplePostingGroupsEnabled: Boolean;
#endif
#pragma warning restore AL0432
        ReplaceVATDateEnabled: Boolean;
}

#endif