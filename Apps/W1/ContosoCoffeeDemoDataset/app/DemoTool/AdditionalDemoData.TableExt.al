#if not CLEANSCHEMA25
tableextension 4762 "Additional Demo Data" extends "Assisted Company Setup Status"
{
#pragma warning disable AS0072, AS0115
    fields
    {
#if not CLEANSCHEMA25
        field(4760; InstallAdditionalDemoData; Boolean)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Changing the way demo data is generated, for more infromation see https://go.microsoft.com/fwlink/?linkid=2288084';
            ObsoleteTag = '25.2';
            DataClassification = SystemMetadata;
        }
#endif
    }
#pragma warning restore AS0072, AS0115
}
#endif