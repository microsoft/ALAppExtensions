page 10691 "SAF-T Export Files"
{
    PageType = List;
    SourceTable = "SAF-T Export File";
    Caption = 'SAF-T Export Files';

    layout
    {
        area(Content)
        {
            repeater(Groupings)
            {
                field("No."; "File No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the file.';
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
                PromotedIsBig = True;
                Image = ExportFile;
                Caption = 'Download File';
                ToolTip = 'Download the generated SAF-T file.';

                trigger OnAction()
                var
                    SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
                begin
                    SAFTExportMgt.DownloadExportFile(Rec);
                end;
            }
        }
    }
}
