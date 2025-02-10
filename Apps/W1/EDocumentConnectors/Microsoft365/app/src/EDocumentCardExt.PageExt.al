namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using Microsoft.eServices.EDocument;

pageextension 6384 EDocumentCardExt extends "E-Document"
{
    layout
    {
        addafter(General)
        {
            group(Service)
            {
                Caption = 'Service';
                Visible = ServiceFieldGroupVisible;

                field("File Id"; Rec."File Id")
                {
                    ApplicationArea = All;
                    Caption = 'File Name';
                    ToolTip = 'Specifies the name of the attached file';
                    Visible = ServiceFieldGroupVisible;
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        DriveIntegrationImpl: Codeunit "Drive Integration Impl.";
                    begin
                        DriveIntegrationImpl.PreviewContent(Rec);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        DriveIntegrationImpl: Codeunit "Drive Integration Impl.";
    begin
        DriveIntegrationImpl.SetConditionalVisibilityFlag(ServiceFieldGroupVisible);
    end;

    var
        ServiceFieldGroupVisible: Boolean;
}