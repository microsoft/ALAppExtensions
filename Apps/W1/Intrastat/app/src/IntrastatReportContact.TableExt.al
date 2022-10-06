tableextension 4812 "Intrastat Report Contact" extends Contact
{
    trigger OnAfterDelete()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        IntrastatReportSetup.CheckDeleteIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Contact, "No.");
    end;
}