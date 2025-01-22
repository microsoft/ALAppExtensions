namespace Microsoft.eServices.EDocument;

using Microsoft.Sales.Document;

tableextension 6101 "E-Doc. Sales Header" extends "Sales Header"
{
    fields
    {
        field(6100; "Send E-Document via Email"; Boolean)
        {
            Caption = 'Send E-Document via Email';
            DataClassification = SystemMetadata;
        }
    }
}
