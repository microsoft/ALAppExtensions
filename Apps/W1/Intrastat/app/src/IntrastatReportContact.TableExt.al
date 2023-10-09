// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.CRM.Contact;

tableextension 4812 "Intrastat Report Contact" extends Contact
{
    trigger OnAfterDelete()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        IntrastatReportSetup.CheckDeleteIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Contact, "No.");
    end;
}