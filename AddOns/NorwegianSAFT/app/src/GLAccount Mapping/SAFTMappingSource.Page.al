page 10680 "SAF-T Mapping Source"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    Caption = 'SAF-T Mapping Source';
    UsageCategory = Administration;
    SourceTable = "SAF-T Mapping Source";
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(MappingSource)
            {
                field(SourceType; "Source Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source type of the mapping.';
                }
                field(SourceNo; "Source No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the source file.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportMappingSource)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Update';
                ToolTip = 'Update the mapping codes from the file.';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = ImportCodes;

                trigger OnAction()
                var
                    SAFTXMLImport: Codeunit "SAF-T XML Import";
                begin
                    ImportMappingSource();
                    SAFTXMLImport.ImportFromMappingSource(Rec);
                    CurrPage.Update();
                end;
            }
        }
    }

}
