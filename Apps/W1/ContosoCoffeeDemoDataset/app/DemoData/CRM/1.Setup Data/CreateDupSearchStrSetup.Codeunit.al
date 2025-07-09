// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.CRM;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Duplicates;
using Microsoft.DemoTool.Helpers;

codeunit 5351 "Create Dup. Search Str. Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        Contact: Record Contact;
        DuplicateSearchStringSetup: Record "Duplicate Search String Setup";
        ContosoCRM: Codeunit "Contoso CRM";
    begin
        ContosoCRM.InsertDuplicateSearchStringSetup(Contact.FieldNo(Name), DuplicateSearchStringSetup."Part of Field"::First, 5);
        ContosoCRM.InsertDuplicateSearchStringSetup(Contact.FieldNo(Name), DuplicateSearchStringSetup."Part of Field"::Last, 5);
        ContosoCRM.InsertDuplicateSearchStringSetup(Contact.FieldNo(Address), DuplicateSearchStringSetup."Part of Field"::First, 5);
        ContosoCRM.InsertDuplicateSearchStringSetup(Contact.FieldNo(Address), DuplicateSearchStringSetup."Part of Field"::Last, 5);
        ContosoCRM.InsertDuplicateSearchStringSetup(Contact.FieldNo(City), DuplicateSearchStringSetup."Part of Field"::First, 5);
        ContosoCRM.InsertDuplicateSearchStringSetup(Contact.FieldNo(City), DuplicateSearchStringSetup."Part of Field"::Last, 5);
        ContosoCRM.InsertDuplicateSearchStringSetup(Contact.FieldNo("Phone No."), DuplicateSearchStringSetup."Part of Field"::First, 5);
        ContosoCRM.InsertDuplicateSearchStringSetup(Contact.FieldNo("Phone No."), DuplicateSearchStringSetup."Part of Field"::Last, 5);
        ContosoCRM.InsertDuplicateSearchStringSetup(Contact.FieldNo("VAT Registration No."), DuplicateSearchStringSetup."Part of Field"::First, 5);
        ContosoCRM.InsertDuplicateSearchStringSetup(Contact.FieldNo("VAT Registration No."), DuplicateSearchStringSetup."Part of Field"::Last, 5);
        ContosoCRM.InsertDuplicateSearchStringSetup(Contact.FieldNo("Post Code"), DuplicateSearchStringSetup."Part of Field"::First, 5);
        ContosoCRM.InsertDuplicateSearchStringSetup(Contact.FieldNo("Post Code"), DuplicateSearchStringSetup."Part of Field"::Last, 5);
        ContosoCRM.InsertDuplicateSearchStringSetup(Contact.FieldNo("E-Mail"), DuplicateSearchStringSetup."Part of Field"::First, 5);
        ContosoCRM.InsertDuplicateSearchStringSetup(Contact.FieldNo("E-Mail"), DuplicateSearchStringSetup."Part of Field"::Last, 5);
        ContosoCRM.InsertDuplicateSearchStringSetup(Contact.FieldNo("Mobile Phone No."), DuplicateSearchStringSetup."Part of Field"::First, 5);
        ContosoCRM.InsertDuplicateSearchStringSetup(Contact.FieldNo("Mobile Phone No."), DuplicateSearchStringSetup."Part of Field"::Last, 5);
    end;
}
