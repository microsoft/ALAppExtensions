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
    value(2; "Sending Error") { Caption = 'Sending Error'; }
    value(3; "Cancel Error") { Caption = 'Cancel Error'; }
    value(4; "Canceled") { Caption = 'Canceled'; }
    value(5; "Imported") { Caption = 'Imported'; }
    value(6; "Imported Document Processing Error") { Caption = 'Imported Document Processing Error'; }
    value(7; "Imported Document Created") { Caption = 'Imported Document Created'; }
    value(8; "Order Updated") { Caption = 'Order Updated'; }
    value(9; "Journal Line Created") { Caption = 'Journal Line Created'; }
    value(10; "Pending Batch") { Caption = 'Pending Batch'; }
    value(11; "Export Error") { Caption = 'Export Error'; }
    value(12; "Pending Response") { Caption = 'Pending Response'; }
    value(13; "Sent") { Caption = 'Sent'; }
    value(14; "Approved") { Caption = 'Approved'; }
    value(15; "Rejected") { Caption = 'Rejected'; }
    value(16; "Batch Imported") { Caption = 'Batch Imported'; }
}
