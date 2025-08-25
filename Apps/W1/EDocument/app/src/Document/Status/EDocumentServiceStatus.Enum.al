// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

enum 6106 "E-Document Service Status" implements IEDocumentStatus
{
    Extensible = true;
    AssignmentCompatibility = true;
    DefaultImplementation = IEDocumentStatus = "E-Doc In Progress Status";

    value(0; "Created") { Caption = 'Created'; }
    value(1; "Exported")
    {
        Caption = 'Exported';
        Implementation = IEDocumentStatus = "E-Doc Processed Status";
    }
    value(2; "Sending Error")
    {
        Caption = 'Sending error';
        Implementation = IEDocumentStatus = "E-Doc Error Status";
    }
    value(3; "Cancel Error")
    {
        Caption = 'Cancel error';
        Implementation = IEDocumentStatus = "E-Doc Error Status";
    }
    value(4; "Canceled")
    {
        Caption = 'Canceled';
        Implementation = IEDocumentStatus = "E-Doc Processed Status";
    }
    value(5; "Imported") { Caption = 'Imported'; }
    value(6; "Imported Document Processing Error")
    {
        Caption = 'Imported document processing error';
        Implementation = IEDocumentStatus = "E-Doc Error Status";
    }
    value(7; "Imported Document Created")
    {
        Caption = 'Imported document created';
        Implementation = IEDocumentStatus = "E-Doc Processed Status";
    }
    value(8; "Order Updated") { Caption = 'Order updated'; }
    value(9; "Journal Line Created")
    {
        Caption = 'Journal line created';
        Implementation = IEDocumentStatus = "E-Doc Processed Status";
    }
    value(10; "Pending Batch") { Caption = 'Pending batch'; }
    value(11; "Export Error")
    {
        Caption = 'Export error';
        Implementation = IEDocumentStatus = "E-Doc Error Status";
    }
    value(12; "Pending Response") { Caption = 'Pending response'; }
    value(13; "Sent")
    {
        Caption = 'Sent';
        Implementation = IEDocumentStatus = "E-Doc Processed Status";
    }
    value(14; "Approved")
    {
        Caption = 'Approved';
        Implementation = IEDocumentStatus = "E-Doc Processed Status";
    }
    value(15; "Rejected")
    {
        Caption = 'Rejected';
        Implementation = IEDocumentStatus = "E-Doc Processed Status";
    }
    value(16; "Batch Imported") { Caption = 'Batch imported'; }
    value(17; "Order Linked") { Caption = 'Order linked'; }
    value(18; "Pending") { Caption = 'Pending document link'; }
    value(19; "Approval Error")
    {
        Caption = 'Approval error';
        Implementation = IEDocumentStatus = "E-Doc Error Status";
    }

    #region clearance model 30 - 40
    value(30; "Not Cleared")
    {
        Caption = 'Not Cleared';
    }
    value(31; "Cleared")
    {
        Caption = 'Cleared';
        Implementation = IEDocumentStatus = "E-Doc Processed Status";
    }
    #endregion
}
