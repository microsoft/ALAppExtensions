/// <summary>
/// Page Shpfy Data Capture List (ID 30118).
/// </summary>
page 30118 "Shpfy Data Capture List"
{

    Caption = 'Shopify Data Capture List';
    PageType = List;
    SourceTable = "Shpfy Data Capture";
    SourceTableView = sorting("Entry No.") order(descending);
    Editable = false;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(EntryNo; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the entry, as assigned from a specific number series when the entry was created.';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the entry was created.';
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the users who has created this entry.';
                }
            }
            field(JsonViewer; Rec.GetData())
            {
                ApplicationArea = All;
                Caption = 'Json Data';
                MultiLine = true;
                ToolTip = 'The JSON data of that is received from Shopify.';
            }
        }
    }


    actions
    {
        area(Processing)
        {
            action(DownloadDataAction)
            {
                Caption = 'Download Data';
                ApplicationArea = All;
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Download the data retrieved from Shopify as a json file.';

                trigger OnAction()
                begin
                    DownloadData();
                end;
            }
        }
    }

    local procedure DownloadData()
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        TitleLbl: Label 'Download Data to file';
        OutStream: OutSTream;
        ToFile: Text;
    begin
        TempBlob.CreateInStream(InStream);
        TempBlob.CreateOutStream(OutStream);
        OutStream.Write(Rec.GetData());
        ToFile := 'Data_' + format(Rec."Entry No.") + '.json';
        File.DownloadFromStream(InStream, TitleLbl, '', '(*.*)|*.*', ToFile);
    end;

}
