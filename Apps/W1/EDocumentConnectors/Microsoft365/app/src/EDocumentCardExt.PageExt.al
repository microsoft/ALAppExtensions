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
                        IntegrationImpl: Codeunit "Integration Impl.";
                    begin
                        IntegrationImpl.PreviewContent(Rec);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        IntegrationImpl: Codeunit "Integration Impl.";
    begin
        IntegrationImpl.SetConditionalVisibilityFlag(ServiceFieldGroupVisible);
    end;

    var
        ServiceFieldGroupVisible: Boolean;
}