#if not CLEAN21
enumextension 11742 "EET Applied Document Type CZP" extends "EET Applied Document Type CZL"
{
#pragma warning disable AS0098
    value(3; Prepayment)
#pragma warning restore AS0098
    {
        Caption = 'Prepayment';
        ObsoleteState = Pending;
        ObsoleteReason = 'Remove after Advance Payment Localization for Czech will be implemented.';
        ObsoleteTag = '21.0';
    }
}
#endif
