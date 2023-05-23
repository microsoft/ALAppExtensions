tableextension 11719 "G/L Entry CZL" extends "G/L Entry"
{
    fields
    {
        field(11780; "VAT Date CZL"; Date)
        {
            Caption = 'VAT Date';
            Editable = false;
            DataClassification = CustomerContent;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Replaced by VAT Reporting Date.';
        }
    }
#if not CLEAN22

    internal procedure IsReplaceVATDateEnabled(): Boolean
    var
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
    begin
        exit(ReplaceVATDateMgtCZL.IsEnabled());
    end;
#endif
}
