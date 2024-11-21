enumextension 139616 "E-Doc Integration Mock" extends "E-Document Integration"
{
#pragma warning disable PTE0023 // The IDs should have been in the range [139500..139899]
#if not CLEAN26
    value(133501; "Mock")
    {
        Implementation = "E-Document Integration" = "E-Doc. Integration Mock";
        ObsoleteTag = '26.0';
        ObsoleteState = Pending;
        ObsoleteReason = 'Obsolete in 26.0';
    }
#endif
#pragma warning restore PTE0023 // The IDs should have been in the range [139500..139899]

}