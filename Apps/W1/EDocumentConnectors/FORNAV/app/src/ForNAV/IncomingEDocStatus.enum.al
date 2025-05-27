namespace Microsoft.EServices.EDocumentConnector.ForNAV;
enum 6410 "ForNAV Incoming E-Doc Status"
{
    Access = Internal;

    value(0; Unknown)
    {
        Caption = 'Unknown';
    }
    value(1; Approved)
    {
        Caption = 'Approved';
    }
    value(2; Rejected)
    {
        Caption = 'Rejected';
    }
    value(3; Received)
    {
        Caption = 'Received';
    }
    value(4; Send)
    {
        Caption = 'Send';
    }
    value(5; Processed)
    {
        Caption = 'Processed';
    }
}