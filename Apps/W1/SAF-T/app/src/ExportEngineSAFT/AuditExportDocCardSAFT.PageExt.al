pageextension 5283 "Audit Export Doc. Card SAF-T" extends "Audit File Export Doc. Card"
{
    layout
    {
        addafter(Contact)
        {
            field(ExportCurrencyInformation; Rec."Export Currency Information")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies that currency information must be included in the export to the audit file.';
                Enabled = SAFTFormat;
                Visible = SAFTFormat;
            }
        }

        modify(Contact)
        {
            Enabled = not SAFTFormat;
            Visible = not SAFTFormat;
        }
    }

    trigger OnOpenPage()
    begin
        SAFTFormat := IsSAFTFormat();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SAFTFormat := IsSAFTFormat();
    end;

    var
        SAFTFormat: Boolean;

    local procedure IsSAFTFormat(): Boolean
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
        AuditFileExportFormat: enum "Audit File Export Format";
        IsSAFTFormatSelected: Boolean;
    begin
        AuditFileExportFormat := Rec."Audit File Export Format";
        if AuditFileExportFormat = 0 then begin     // if not initialized yet
            AuditFileExportSetup.Get();
            AuditFileExportFormat := AuditFileExportSetup."Audit File Export Format";
        end;
        IsSAFTFormatSelected := AuditFileExportFormat = Enum::"Audit File Export Format"::SAFT;
        exit(IsSAFTFormatSelected);
    end;
}