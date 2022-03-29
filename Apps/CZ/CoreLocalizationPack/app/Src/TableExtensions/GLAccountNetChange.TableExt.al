#if not CLEAN18
#pragma warning disable AL0432
#endif
tableextension 31047 "G/L Account Net Change CZL" extends "G/L Account Net Change"
{
    fields
    {
        field(31001; "Account Type CZL"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Account Type';
            DataClassification = SystemMetadata;
        }
        field(31002; "Account No. CZL"; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(AccountTypeNoCZL; "Account Type CZL", "Account No. CZL")
        {
        }
    }
}
