namespace JLogiqEDocumentsConnector.JLogiqEDocumentsConnector;

using Microsoft.eServices.EDocument;

tableextension 6380 "Logiq E-Document" extends "E-Document"
{
    fields
    {
        field(50100; "Logiq External Id"; Text[50])
        {
            Caption = 'Logiq External Id';
            DataClassification = ToBeClassified;
        }
    }
}
