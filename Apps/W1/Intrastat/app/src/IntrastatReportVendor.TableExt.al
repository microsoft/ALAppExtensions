tableextension 4813 "Intrastat Report Vendor" extends Vendor
{
    fields
    {
        field(4810; "Default Trans. Type"; Code[10])
        {
            Caption = 'Default Trans. Type';
            TableRelation = "Transaction Type";
        }
        field(4811; "Default Trans. Type - Return"; Code[10])
        {
            Caption = 'Default Trans. Type - Returns';
            TableRelation = "Transaction Type";
        }
        field(4812; "Def. Transport Method"; Code[10])
        {
            Caption = 'Default Transport Method';
            TableRelation = "Transport Method";
        }
    }

    trigger OnAfterDelete()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        IntrastatReportSetup.CheckDeleteIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Vendor, "No.");
    end;
}