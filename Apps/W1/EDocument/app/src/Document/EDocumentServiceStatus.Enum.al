// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

enum 6106 "E-Document Service Status"
{
    Extensible = true;
    AssignmentCompatibility = true;
    value(0; "Created") { Caption = 'Created'; }
    value(1; "Exported") { Caption = 'Exported'; }
    value(2; "Sending Error") { Caption = 'Sending error'; }
    value(3; "Cancel Error") { Caption = 'Cancel error'; }
    value(4; "Canceled") { Caption = 'Canceled'; }
    value(5; "Imported") { Caption = 'Imported'; }
    value(6; "Imported Document Processing Error") { Caption = 'Imported document processing error'; }
    value(7; "Imported Document Created") { Caption = 'Imported document created'; }
    value(8; "Order Updated") { Caption = 'Order updated'; }
    value(9; "Journal Line Created") { Caption = 'Journal line created'; }
    value(10; "Pending Batch") { Caption = 'Pending batch'; }
    value(11; "Export Error") { Caption = 'Export error'; }
    value(12; "Pending Response") { Caption = 'Pending response'; }
    value(13; "Sent") { Caption = 'Sent'; }
    value(14; "Approved") { Caption = 'Approved'; }
    value(15; "Rejected") { Caption = 'Rejected'; }
    value(16; "Batch Imported") { Caption = 'Batch imported'; }
    value(17; "Order Linked") { Caption = 'Order linked'; }
    value(18; "Pending") { Caption = 'Pending Document Link'; }
    value(19; "Approval Error") { Caption = 'Approval error'; }
}
