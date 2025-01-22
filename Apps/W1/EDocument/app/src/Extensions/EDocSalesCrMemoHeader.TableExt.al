namespace Microsoft.EServices.EDocument;

using Microsoft.Sales.History;

tableextension 6103 "E-Doc. Sales Cr. Memo Header" extends "Sales Cr.Memo Header"
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
