#if not CLEAN21
#pragma warning disable AS0098
enumextension 31001 "Feature To Update - CZZ" extends "Feature To Update"
{
    value(31000; AdvancePaymentsLocalizationForCzech)
    {
        Caption = 'Advance Payments Localization for Czech';
        Implementation = "Feature Data Update" = "Feature Advance Payments CZZ";
        ObsoleteState = Pending;
        ObsoleteReason = 'AdvancePaymentsLocalizationForCzech removed from Feature Management.';
        ObsoleteTag = '21.0';
    }
}
#endif
