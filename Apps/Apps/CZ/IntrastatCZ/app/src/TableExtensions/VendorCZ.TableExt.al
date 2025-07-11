// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Purchases.Vendor;

tableextension 31352 "Vendor CZ" extends Vendor
{
    procedure GetDefaultTransactionTypeCZ(IsPhysicalTransfer: Boolean; IsCreditDocType: Boolean): Code[10]
    begin
        if (IsCreditDocType and IsPhysicalTransfer) or
           (not IsCreditDocType and not IsPhysicalTransfer)
        then
            exit("Default Trans. Type - Return");
        exit("Default Trans. Type");
    end;
}