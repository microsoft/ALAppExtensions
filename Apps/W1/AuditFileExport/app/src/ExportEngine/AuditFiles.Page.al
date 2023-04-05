page 5268 "Audit Files"
{
    PageType = List;
    SourceTable = "Audit File";
    Caption = 'Audit Files';

    layout
    {
        area(Content)
        {
            repeater(Groupings)
            {
                field("No."; Rec."File No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the file.';
                }
                field(AuditFileName; Rec."File Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name with which the file will be downloaded.';

                    trigger OnDrillDown()
                    var
                        AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
                    begin
                        AuditFileExportMgt.DownloadAuditFile(Rec);
                    end;
                }
                field(AuditFileSize; Rec."File Size")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the size of the file.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DownloadFile)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = ExportFile;
                Caption = 'Download File';
                ToolTip = 'Download the generated audit file.';

                trigger OnAction()
                var
                    AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
                begin
                    AuditFileExportMgt.DownloadAuditFile(Rec);
                end;
            }
        }
    }
}
