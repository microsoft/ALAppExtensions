codeunit 5111 "Create Svc Loaner"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        SvcDemoDataSetup: Record "Service Module Setup";
        LOANERTok: Label 'LOANER', MaxLength = 10;

    trigger OnRun()
    var
        ContosoService: Codeunit "Contoso Service";
    begin
        SvcDemoDataSetup.Get();

        ContosoService.InsertLoaner(Loaner(), SvcDemoDataSetup."Item 1 No.");
    end;

    procedure Loaner(): Code[10]
    begin
        exit(LOANERTok);
    end;
}