// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using System.Utilities;

interface "Digital Voucher Check"
{
    /// <summary>
    /// Checks if the voucher is attached to the document.
    /// </summary>
    /// <param name="ErrorMessageMgt">An instance of the Error Message Mgt. codeunit to add error if voucher is not attached.</param>
    /// <param name="DigitalVoucherEntryType">A type entry associated with the document.</param>
    /// <param name="RecRef">A record reference of the document.</param>
    procedure CheckVoucherIsAttachedToDocument(var ErrorMessageMgt: Codeunit "Error Message Management"; DigitalVoucherEntryType: Enum "Digital Voucher Entry Type"; RecRef: RecordRef)
    /// <summary>
    /// Generate voucher and attach to the posted document.
    /// </summary>
    /// <param name="DigitalVoucherEntryType">A type entry associated with the document.</param>
    /// <param name="RecRef">A record reference of the posted document.</param>
    procedure GenerateDigitalVoucherForPostedDocument(DigitalVoucherEntryType: Enum "Digital Voucher Entry Type"; RecRef: RecordRef)
}
