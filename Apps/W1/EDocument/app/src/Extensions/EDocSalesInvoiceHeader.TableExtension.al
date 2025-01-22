namespace Microsoft.eServices.EDocument;

using Microsoft.Sales.History;

tableextension 6102 "E-Doc. Sales Invoice Header" extends "Sales Invoice Header"
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
