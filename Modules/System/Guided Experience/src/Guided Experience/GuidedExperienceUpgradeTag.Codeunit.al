// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1998 "Guided Experience Upgrade Tag"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetGuidedExperienceItemAddSpotlightTourTypeTag());
    end;

    procedure GetGuidedExperienceItemAddSpotlightTourTypeTag(): Code[250]
    begin
        exit('MS-387559-GuidedExperienceItemAddSpotlightTourType-20210810');
    end;

    procedure GetGuidedExperienceTranslationUpdateTag(): Code[250]
    begin
        exit('MS-418689-GuidedExperienceItemTranslationUpdate-20211215');
    end;
}
