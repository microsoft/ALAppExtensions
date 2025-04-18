namespace app.app;

using Microsoft.eServices.EDocument;

page 6104 "E-Document Services API"
{
    PageType = API;

    APIGroup = 'automate';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';

    EntityCaption = 'E-Document Service';
    EntitySetCaption = 'E-Document Services';
    EntityName = 'eDocumentService';
    EntitySetName = 'eDocumentServices';

    ODataKeyFields = SystemId;
    SourceTable = "E-Document Service";

    Extensible = false;
    Editable = false;
    DataAccessIntent = ReadOnly;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(code; Rec.Code)
                {
                    Caption = 'Code';
                    Editable = false;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                    Editable = false;
                }
                field(serviceIntegrationV2; Rec."Service Integration V2")
                {
                    Caption = 'Service Integration V2';
                    Editable = false;
                }
                field(documentFormat; Rec."Document Format")
                {
                    Caption = 'Document Format';
                    Editable = false;
                }
            }
        }
    }
}
