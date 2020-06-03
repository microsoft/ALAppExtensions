// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9994 "Upgrade Tag Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;
    Permissions = TableData "Upgrade Tags" = rimd, TableData Company = r;

    trigger OnCheckPreconditionsPerCompany()
    var
        UpgradeTags: Record "Upgrade Tags";
        UpgradeTagTags: Codeunit "Upgrade Tag - Tags";
    begin
        UpgradeTags.SetRange(Tag, UpgradeTagTags.GetUpgradeTagInitializedTag());
        if UpgradeTags.IsEmpty() then
            exit;

        UpgradeTagTags.VerifyAllCompaniesInitialized();

        // Verify per database tag
        UpgradeTagTags.VerifyCompanyInitialized('');
    end;
}