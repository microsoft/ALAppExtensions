pageextension 10828 "Audit File Export Setup FEC" extends "Audit File Export Setup"
{
    layout
    {
        modify("Data Quality")
        {
            Enabled = not FECFormat;
            Visible = not FECFormat;
        }
    }

    var
        FECFormat: Boolean;

    trigger OnOpenPage()
    begin
        FECFormat := IsFECFormat();
    end;

    local procedure IsFECFormat(): Boolean
    var
        AuditFileExportFormat: Enum "Audit File Export Format";
    begin
        exit(Rec."Audit File Export Format" = AuditFileExportFormat::FEC);
    end;
}