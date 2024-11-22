namespace Microsoft.EServices.EDocumentConnector.Logiq;

using Microsoft.eServices.EDocument;
tableextension 6380 "E-Document" extends "E-Document"
{
    fields
    {
        field(6380; "Logiq External Id"; Text[50])
        {
            Caption = 'Logiq External Id';
            DataClassification = CustomerContent;
        }
    }
}
