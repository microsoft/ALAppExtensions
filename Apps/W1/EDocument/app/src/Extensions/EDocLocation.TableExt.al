namespace Microsoft.Inventory.Location;

using Microsoft.Foundation.Reporting;

tableextension 6102 "E-Doc. Location" extends Location
{
    fields
    {
        field(6100; "Tranfer Doc. Sending Profile"; Code[10])
        {
            Caption = 'Transfer Doc. Sending Profile';
            DataClassification = CustomerContent;
            TableRelation = "Document Sending Profile";
            ToolTip = 'Specifies the document sending profile that is used for transfer shipment documents.';
        }
    }
}
