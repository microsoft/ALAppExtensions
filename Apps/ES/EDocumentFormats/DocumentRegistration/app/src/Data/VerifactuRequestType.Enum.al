// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Verifactu;

enum 10777 "Verifactu Request Type"
{
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; "DocumentRegistration") { Caption = 'Document Registration'; }
    value(1; "DocumentCancelation") { Caption = 'Document Cancelation'; }
    value(2; "QRCodeValidation") { Caption = 'QR Code Validation'; }
}
