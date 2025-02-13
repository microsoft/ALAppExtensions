namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using Microsoft.eServices.EDocument;

pageextension 6383 EDocumentListExt extends "E-Documents"
{
    layout
    {
        addafter("Entry No")
        {
            field("File Id"; Rec."File Id")
            {
                ApplicationArea = All;
                Caption = 'File Name';
                ToolTip = 'Specifies the name of the attached file';
                Visible = FileIdVisible;
                Editable = false;

                trigger OnDrillDown()
                var
                    IntegrationImpl: Codeunit "Integration Impl.";
                begin
                    IntegrationImpl.PreviewContent(Rec);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        IntegrationImpl: Codeunit "Integration Impl.";
    begin
        IntegrationImpl.SetConditionalVisibilityFlag(FileIdVisible);
    end;

    var
        FileIdVisible: Boolean;
}