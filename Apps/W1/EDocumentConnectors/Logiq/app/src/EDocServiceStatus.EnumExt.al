namespace Microsoft.EServices.EDocumentConnector.Logiq;

using Microsoft.eServices.EDocument;

enumextension 6380 "E-Doc. Service Status" extends "E-Document Service Status"
{

    value(6380; "In Progress Logiq")
    {
        Caption = 'In Progress';
    }
    value(6381; "Failed Logiq")
    {
        Caption = 'Failed';
    }
}
