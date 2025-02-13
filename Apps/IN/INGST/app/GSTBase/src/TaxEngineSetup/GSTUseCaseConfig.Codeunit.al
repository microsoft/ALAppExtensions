// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.JsonExchange;

using Microsoft.Finance.GST.Base;

codeunit 18000 "GST Use Case Config"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnGetUseCaseConfig', '', false, false)]
    local procedure OnGetUseCaseConfig(CaseID: Guid; var ConfigText: Text; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        ConfigText := GetConfig(CaseID, IsHandled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupUseCases', '', false, false)]
    local procedure OnSetupUseCases()
    var
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
        CaseList: list of [Guid];
        CaseId: Guid;
    begin
        UpdateUseCaseList(CaseList);

        if not GuiAllowed then
            TaxJsonDeserialization.HideDialog(true);

        TaxJsonDeserialization.SkipVersionCheck(true);
        TaxJsonDeserialization.SkipUseCaseIndentation(true);
        foreach CaseId in CaseList do
            TaxJsonDeserialization.ImportUseCases(GetText(CaseId));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade GST Tax Config", 'OnUpgradeGSTUseCases', '', false, false)]
    local procedure OnUpgradeGSTUseCases(CaseID: Guid; var UseCaseConfig: Text; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        UseCaseConfig := GetText(CaseID);
        if UseCaseConfig <> '' then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GST Upgrade Subscribers", 'OnGetUpgradedUseCaseConfig', '', false, false)]
    local procedure OnGetGSTConfig(CaseID: Guid; var IsHandled: Boolean; var Configtext: Text)
    begin
        Configtext := GetConfig(CaseID, IsHandled);
    end;

    local procedure GetText(CaseId: Guid): Text
    var
        IsHandled: Boolean;
    begin
        exit(GetConfig(CaseId, IsHandled))
    end;

    local procedure UpdateUseCaseList(CaseList: list of [Guid])
    begin
        CaseList.Add('{9fe211a9-770a-4396-be84-b9625d975180}');
        CaseList.Add('{04ba2f8d-9562-4551-8a98-c61ce5509b47}');
        CaseList.Add('{fec46768-8566-4c39-ae1d-62b0fd83d5d6}');
        CaseList.Add('{f7997b96-631e-456d-9fa2-028adec745c1}');
        CaseList.Add('{47aa3c60-6575-4f87-8022-29790bb97a11}');
        CaseList.Add('{21a2dffa-df09-4531-be3f-dfc7e50f3d1e}');
        CaseList.Add('{8e9e924f-0be8-4862-bdfe-39cb23848b3c}');
        CaseList.Add('{c9f94259-ea6b-481b-aaf1-8d8f9f025902}');
        CaseList.Add('{b7a4d05e-75c4-47f5-b502-9510b13e2dea}');
        CaseList.Add('{19625bab-02b9-42e1-80ef-fed88d13ff40}');
        CaseList.Add('{56966b10-de93-4980-a9fe-1cbb5de6359b}');
        CaseList.Add('{5e2d969d-2a4b-4288-900b-7d1527f80a8e}');
        CaseList.Add('{2e66dc31-92bb-4928-83e5-6f87fc544a85}');
        CaseList.Add('{b4b3ee78-57ec-4ee8-8f51-e7b868cf34b9}');
        CaseList.Add('{90643bb8-1beb-40c8-81b3-e6a3c5075c45}');
        CaseList.Add('{55bea8b4-15ed-47b2-ad24-157ba39467ee}');
        CaseList.Add('{0c6ee2b8-335f-4420-9b76-aebf773bb40c}');
        CaseList.Add('{10d6a0fe-f802-4235-b438-3a29b7c853ed}');
        CaseList.Add('{7e48e18f-d907-423a-bc62-256d7cfaa089}');
        CaseList.Add('{ccd1bd07-0a33-4dab-9a3e-e66956e0f98b}');
        CaseList.Add('{7642fecb-8bee-4127-9523-47ecb7d29dc4}');
        CaseList.Add('{f1a5130e-021a-40f9-8282-82cbfee3ff07}');
        CaseList.Add('{65746f4e-a835-4278-98ca-b6ab0d0cbf6b}');
        CaseList.Add('{a515d68a-a496-4a81-8f4e-ec21f207d5ff}');
        CaseList.Add('{79a59a19-401f-444f-a3c4-f8cbba06d4b0}');
        CaseList.Add('{8b9b630b-1ac7-49a1-ba60-3a415b97c2bc}');
        CaseList.Add('{7601e944-f060-482e-b620-cf8555d00bb9}');
        CaseList.Add('{040a5713-75a6-4fd3-bca9-7a335d697933}');
        CaseList.Add('{4b185dab-793d-4c0a-a303-417a61ac9b96}');
        CaseList.Add('{4fd977c3-86db-46a1-aeef-a0a176f23be1}');
        CaseList.Add('{bc63870d-585e-4c07-a6a6-44de28f260be}');
        CaseList.Add('{6333f9d2-02b8-4ff1-88ee-386041b7fca4}');
        CaseList.Add('{03d7d334-04d2-4ec5-ae88-a67c1409c8be}');
        CaseList.Add('{9e8f612a-6306-4cd0-aa63-8f443733b9b5}');
        CaseList.Add('{cf89d22f-0cd8-4e3c-a01c-6c159e03e5e6}');
        CaseList.Add('{14fc3d2c-3daf-4c04-aa69-6ae47d0d7552}');
        CaseList.Add('{59157e34-743f-4293-a662-1a9c3d916178}');
        CaseList.Add('{d6d5aacf-3fc9-4e46-ac66-66cb29d5293e}');
        CaseList.Add('{291465b9-0c22-48b5-9eea-4006cc372b1a}');
        CaseList.Add('{c69c8c2b-3445-476c-80ed-776ec67b06d3}');
        CaseList.Add('{08eacbe7-7b68-4b7b-8bce-8d5d4fad80f0}');
        CaseList.Add('{e8acbb6b-eaaf-46c6-a4ea-efb502d8e110}');
        CaseList.Add('{5860dc76-ae27-4a12-808d-667172bef336}');
        CaseList.Add('{a4a8c87f-d458-4dd2-b8e9-8393220fdd2d}');
        CaseList.Add('{d9aa8d5e-8135-47aa-a722-6356873cf5ef}');
        CaseList.Add('{a0d756a0-dc72-49f9-a1f9-b926242c6ad2}');
        CaseList.Add('{bfb628d6-4413-4628-b619-013ef3255ce9}');
        CaseList.Add('{a4b4b64c-1d4c-48ee-88e9-4bbc4f05eae8}');
        CaseList.Add('{8d8429d6-2b1a-4081-900e-9d19c312335e}');
        CaseList.Add('{dc79d469-98cd-45ff-adbb-27dff74d2672}');
        CaseList.Add('{84992760-0362-488c-8d49-0de8065f945c}');
        CaseList.Add('{10ca76a8-8de4-419a-8220-3dd88d8f8747}');
        CaseList.Add('{b8757b78-d36c-4ab7-b532-353006120046}');
        CaseList.Add('{5131a9e4-a281-496f-9af2-e60dc7d88a50}');
        CaseList.Add('{7aff7259-d09b-4c62-8575-34bedee4a72c}');
        CaseList.Add('{e786a7d6-1147-46f6-bb75-1223aac92007}');
        CaseList.Add('{ea505d2c-22a0-4b4b-b20f-18a0e1ae2c02}');
        CaseList.Add('{fbbceafb-3b22-4d36-969e-84ab2cdc7859}');
        CaseList.Add('{c8ba6ca4-7e8c-4053-980d-451fe32d8efa}');
        CaseList.Add('{13827c55-0612-40ef-bed1-62d7605b9d68}');
        CaseList.Add('{92cd1d91-1d76-46d8-b2e1-c62c54e62191}');
        CaseList.Add('{efb5634e-c341-4922-9bc9-1ce76ad61d79}');
        CaseList.Add('{40c0504c-93d7-4ec1-a4b8-7fe82c224be4}');
        CaseList.Add('{3eaea83a-b986-4c1e-9231-edeac919de2f}');
        CaseList.Add('{bb38433a-2ae4-492d-8380-d8b5a6f80135}');
        CaseList.Add('{81345ec6-231d-4274-95d2-302ffe85b903}');
        CaseList.Add('{747b1a95-df79-4286-a38b-a6f98f2d2de1}');
        CaseList.Add('{fc888469-0e29-48ba-b417-07d5943d7c45}');
        CaseList.Add('{31f4991c-5e91-4af3-b911-39f985bf48c1}');
        CaseList.Add('{3397dbb8-098b-4a52-9bfa-e24a12b5f9e7}');
        CaseList.Add('{6c740bb7-2090-4e02-8611-2fd65cc51465}');
        CaseList.Add('{0dd3f665-8d52-487d-a200-9bd69db0a4a2}');
        CaseList.Add('{be591554-5098-41fd-a200-5b5b48c19083}');
        CaseList.Add('{6807fdac-8bcb-4b1a-84ff-882c6a9c15b7}');
        CaseList.Add('{8b4b45ec-5b92-4383-935b-de2e70579ca8}');
        CaseList.Add('{a8b33288-ca54-4dc6-b3e4-a14e3cca4efc}');
        CaseList.Add('{dba2caa4-8ee2-4dd0-b413-383101db034e}');
        CaseList.Add('{8e881e89-87c1-4745-9529-b82a784e83be}');
        CaseList.Add('{1f48109a-8444-4862-b9da-190182b3fbac}');
        CaseList.Add('{3ad6ddbc-a132-4aba-b216-73133b85604a}');
        CaseList.Add('{17da0fc6-fc3f-4ab5-a2c7-34d00b649941}');
        CaseList.Add('{741172e2-8b2d-461d-9081-71145f1316df}');
        CaseList.Add('{29c6fb1d-f01c-426f-ac3e-76e9122fdb69}');
        CaseList.Add('{49fe20a3-c985-4427-98a7-cbc3119c73f7}');
        CaseList.Add('{913aae94-3aef-4f6d-80db-f30ff5e5c067}');
        CaseList.Add('{6cc7879a-5af1-4fd6-8713-7ecf54abc412}');
        CaseList.Add('{858ca47f-fa82-4485-91a5-12b2ebf36d6f}');
        CaseList.Add('{5629ebaa-46b2-4dd7-9511-1d6e697a6b0a}');
        CaseList.Add('{44130b2e-fba8-47de-bf1f-af9145ac13bd}');
        CaseList.Add('{53d88a93-5ce2-427c-81f0-6dcfc36f579f}');
        CaseList.Add('{97120cfc-a3a4-4545-8a71-881473ed33c7}');
        CaseList.Add('{23f3d552-5b8b-47a9-b217-903567666bce}');
        CaseList.Add('{14586eff-720d-4670-b023-ea4fbff96b99}');
        CaseList.Add('{861e4175-2832-49d7-8af3-96e6c19f8e68}');
        CaseList.Add('{220890e5-a6c0-4719-83c5-e2247ef9bec3}');
        CaseList.Add('{4bfa98d3-cef3-4573-b464-9e897eb9d4ae}');
        CaseList.Add('{f0e83015-3886-4263-a0b7-a97ba3b7753c}');
        CaseList.Add('{fd5fd103-5251-4063-92c9-ccfe016b971b}');
        CaseList.Add('{5582b9b9-2c0c-4036-a0e1-ed20495d47af}');
        CaseList.Add('{307349c1-c724-4cb8-8878-7587cc2617ec}');
        CaseList.Add('{c3755aff-81d3-4b1a-85b2-b2c8a60f9eaa}');
        CaseList.Add('{0e655e71-19d9-4a10-8a28-fe4afba2a7c7}');
        CaseList.Add('{f4c6236c-3805-4826-88fd-eac2659389b0}');
        CaseList.Add('{10bbeeb9-e622-4899-b4e0-c000ca753e54}');
        CaseList.Add('{adf93fbf-84bb-4dc9-8b87-eadde08829f0}');
        CaseList.Add('{3c1d2a94-cbae-4190-be50-ad56cf9218d9}');
        CaseList.Add('{103e8a37-530c-4fff-bb01-d298e7df9ffc}');
        CaseList.Add('{02a9b37f-66a8-446a-b5b0-703d594ff934}');
        CaseList.Add('{9654c77e-d850-4aa2-9a47-fb003b1574b2}');
        CaseList.Add('{6924daf8-60f6-4c42-9266-200033c6d3f4}');
        CaseList.Add('{11d160cf-fd98-4c47-928b-9f4125f584a9}');
        CaseList.Add('{b3793372-9ad2-4f36-ba5c-3af13be44f2d}');
        CaseList.Add('{cf0f6dea-a530-45b3-8b1b-cf86879e9eda}');
        CaseList.Add('{0561985a-b2f9-4c9c-be39-7d6ae423104e}');
        CaseList.Add('{51cd0a49-e8df-42a3-9180-84d1a7076a42}');
        CaseList.Add('{da8695b6-d7d7-41e9-be59-c26a19d03c2c}');
        CaseList.Add('{270f6442-0097-437d-9f91-5c15bd9eab4d}');
        CaseList.Add('{abf997c4-d467-4f97-94cd-10afe3a66b3a}');
        CaseList.Add('{902158a0-97d5-4075-943e-3b30b800fb78}');
        CaseList.Add('{4116f9d4-1957-46d1-bced-580bd21c0908}');
        CaseList.Add('{05cee5ad-ff50-479c-922c-1c51fe10f724}');
        CaseList.Add('{f356e0fe-23c7-4d81-a149-3659f2cefbb4}');
        CaseList.Add('{7e2f85f6-ffba-45fe-80b5-39b654365acd}');
        CaseList.Add('{88f1a4b3-dcac-499a-bd7a-a5eba3ef3cb4}');
        CaseList.Add('{1f11a81c-0551-4b07-aa30-23da57e0fe16}');
        CaseList.Add('{ebfdb89b-5f22-4386-87ca-72157cbf122d}');
        CaseList.Add('{321e0f7b-a15d-4ce6-9c11-bf3fd3dee918}');
    end;

    procedure GetConfig(CaseID: Guid; var Handled: Boolean): Text
    var
        "{9fe211a9-770a-4396-be84-b9625d975180}Lbl": Label 'GST Use Cases';
        "{04ba2f8d-9562-4551-8a98-c61ce5509b47}Lbl": Label 'GST Use Cases';
        "{fec46768-8566-4c39-ae1d-62b0fd83d5d6}Lbl": Label 'GST Use Cases';
        "{f7997b96-631e-456d-9fa2-028adec745c1}Lbl": Label 'GST Use Cases';
        "{47aa3c60-6575-4f87-8022-29790bb97a11}Lbl": Label 'GST Use Cases';
        "{21a2dffa-df09-4531-be3f-dfc7e50f3d1e}Lbl": Label 'GST Use Cases';
        "{8e9e924f-0be8-4862-bdfe-39cb23848b3c}Lbl": Label 'GST Use Cases';
        "{c9f94259-ea6b-481b-aaf1-8d8f9f025902}Lbl": Label 'GST Use Cases';
        "{b7a4d05e-75c4-47f5-b502-9510b13e2dea}Lbl": Label 'GST Use Cases';
        "{19625bab-02b9-42e1-80ef-fed88d13ff40}Lbl": Label 'GST Use Cases';
        "{56966b10-de93-4980-a9fe-1cbb5de6359b}Lbl": Label 'GST Use Cases';
        "{5e2d969d-2a4b-4288-900b-7d1527f80a8e}Lbl": Label 'GST Use Cases';
        "{2e66dc31-92bb-4928-83e5-6f87fc544a85}Lbl": Label 'GST Use Cases';
        "{b4b3ee78-57ec-4ee8-8f51-e7b868cf34b9}Lbl": Label 'GST Use Cases';
        "{90643bb8-1beb-40c8-81b3-e6a3c5075c45}Lbl": Label 'GST Use Cases';
        "{55bea8b4-15ed-47b2-ad24-157ba39467ee}Lbl": Label 'GST Use Cases';
        "{0c6ee2b8-335f-4420-9b76-aebf773bb40c}Lbl": Label 'GST Use Cases';
        "{10d6a0fe-f802-4235-b438-3a29b7c853ed}Lbl": Label 'GST Use Cases';
        "{7e48e18f-d907-423a-bc62-256d7cfaa089}Lbl": Label 'GST Use Cases';
        "{ccd1bd07-0a33-4dab-9a3e-e66956e0f98b}Lbl": Label 'GST Use Cases';
        "{7642fecb-8bee-4127-9523-47ecb7d29dc4}Lbl": Label 'GST Use Cases';
        "{f1a5130e-021a-40f9-8282-82cbfee3ff07}Lbl": Label 'GST Use Cases';
        "{65746f4e-a835-4278-98ca-b6ab0d0cbf6b}Lbl": Label 'GST Use Cases';
        "{a515d68a-a496-4a81-8f4e-ec21f207d5ff}Lbl": Label 'GST Use Cases';
        "{79a59a19-401f-444f-a3c4-f8cbba06d4b0}Lbl": Label 'GST Use Cases';
        "{8b9b630b-1ac7-49a1-ba60-3a415b97c2bc}Lbl": Label 'GST Use Cases';
        "{7601e944-f060-482e-b620-cf8555d00bb9}Lbl": Label 'GST Use Cases';
        "{040a5713-75a6-4fd3-bca9-7a335d697933}Lbl": Label 'GST Use Cases';
        "{4b185dab-793d-4c0a-a303-417a61ac9b96}Lbl": Label 'GST Use Cases';
        "{4fd977c3-86db-46a1-aeef-a0a176f23be1}Lbl": Label 'GST Use Cases';
        "{bc63870d-585e-4c07-a6a6-44de28f260be}Lbl": Label 'GST Use Cases';
        "{6333f9d2-02b8-4ff1-88ee-386041b7fca4}Lbl": Label 'GST Use Cases';
        "{03d7d334-04d2-4ec5-ae88-a67c1409c8be}Lbl": Label 'GST Use Cases';
        "{9e8f612a-6306-4cd0-aa63-8f443733b9b5}Lbl": Label 'GST Use Cases';
        "{cf89d22f-0cd8-4e3c-a01c-6c159e03e5e6}Lbl": Label 'GST Use Cases';
        "{14fc3d2c-3daf-4c04-aa69-6ae47d0d7552}Lbl": Label 'GST Use Cases';
        "{59157e34-743f-4293-a662-1a9c3d916178}Lbl": Label 'GST Use Cases';
        "{d6d5aacf-3fc9-4e46-ac66-66cb29d5293e}Lbl": Label 'GST Use Cases';
        "{291465b9-0c22-48b5-9eea-4006cc372b1a}Lbl": Label 'GST Use Cases';
        "{c69c8c2b-3445-476c-80ed-776ec67b06d3}Lbl": Label 'GST Use Cases';
        "{08eacbe7-7b68-4b7b-8bce-8d5d4fad80f0}Lbl": Label 'GST Use Cases';
        "{e8acbb6b-eaaf-46c6-a4ea-efb502d8e110}Lbl": Label 'GST Use Cases';
        "{5860dc76-ae27-4a12-808d-667172bef336}Lbl": Label 'GST Use Cases';
        "{a4a8c87f-d458-4dd2-b8e9-8393220fdd2d}Lbl": Label 'GST Use Cases';
        "{d9aa8d5e-8135-47aa-a722-6356873cf5ef}Lbl": Label 'GST Use Cases';
        "{a0d756a0-dc72-49f9-a1f9-b926242c6ad2}Lbl": Label 'GST Use Cases';
        "{bfb628d6-4413-4628-b619-013ef3255ce9}Lbl": Label 'GST Use Cases';
        "{a4b4b64c-1d4c-48ee-88e9-4bbc4f05eae8}Lbl": Label 'GST Use Cases';
        "{8d8429d6-2b1a-4081-900e-9d19c312335e}Lbl": Label 'GST Use Cases';
        "{dc79d469-98cd-45ff-adbb-27dff74d2672}Lbl": Label 'GST Use Cases';
        "{84992760-0362-488c-8d49-0de8065f945c}Lbl": Label 'GST Use Cases';
        "{10ca76a8-8de4-419a-8220-3dd88d8f8747}Lbl": Label 'GST Use Cases';
        "{b8757b78-d36c-4ab7-b532-353006120046}Lbl": Label 'GST Use Cases';
        "{5131a9e4-a281-496f-9af2-e60dc7d88a50}Lbl": Label 'GST Use Cases';
        "{7aff7259-d09b-4c62-8575-34bedee4a72c}Lbl": Label 'GST Use Cases';
        "{e786a7d6-1147-46f6-bb75-1223aac92007}Lbl": Label 'GST Use Cases';
        "{ea505d2c-22a0-4b4b-b20f-18a0e1ae2c02}Lbl": Label 'GST Use Cases';
        "{fbbceafb-3b22-4d36-969e-84ab2cdc7859}Lbl": Label 'GST Use Cases';
        "{c8ba6ca4-7e8c-4053-980d-451fe32d8efa}Lbl": Label 'GST Use Cases';
        "{13827c55-0612-40ef-bed1-62d7605b9d68}Lbl": Label 'GST Use Cases';
        "{92cd1d91-1d76-46d8-b2e1-c62c54e62191}Lbl": Label 'GST Use Cases';
        "{efb5634e-c341-4922-9bc9-1ce76ad61d79}Lbl": Label 'GST Use Cases';
        "{40c0504c-93d7-4ec1-a4b8-7fe82c224be4}Lbl": Label 'GST Use Cases';
        "{3eaea83a-b986-4c1e-9231-edeac919de2f}Lbl": Label 'GST Use Cases';
        "{bb38433a-2ae4-492d-8380-d8b5a6f80135}Lbl": Label 'GST Use Cases';
        "{81345ec6-231d-4274-95d2-302ffe85b903}Lbl": Label 'GST Use Cases';
        "{747b1a95-df79-4286-a38b-a6f98f2d2de1}Lbl": Label 'GST Use Cases';
        "{fc888469-0e29-48ba-b417-07d5943d7c45}Lbl": Label 'GST Use Cases';
        "{31f4991c-5e91-4af3-b911-39f985bf48c1}Lbl": Label 'GST Use Cases';
        "{3397dbb8-098b-4a52-9bfa-e24a12b5f9e7}Lbl": Label 'GST Use Cases';
        "{6c740bb7-2090-4e02-8611-2fd65cc51465}Lbl": Label 'GST Use Cases';
        "{0dd3f665-8d52-487d-a200-9bd69db0a4a2}Lbl": Label 'GST Use Cases';
        "{be591554-5098-41fd-a200-5b5b48c19083}Lbl": Label 'GST Use Cases';
        "{6807fdac-8bcb-4b1a-84ff-882c6a9c15b7}Lbl": Label 'GST Use Cases';
        "{8b4b45ec-5b92-4383-935b-de2e70579ca8}Lbl": Label 'GST Use Cases';
        "{a8b33288-ca54-4dc6-b3e4-a14e3cca4efc}Lbl": Label 'GST Use Cases';
        "{dba2caa4-8ee2-4dd0-b413-383101db034e}Lbl": Label 'GST Use Cases';
        "{8e881e89-87c1-4745-9529-b82a784e83be}Lbl": Label 'GST Use Cases';
        "{1f48109a-8444-4862-b9da-190182b3fbac}Lbl": Label 'GST Use Cases';
        "{3ad6ddbc-a132-4aba-b216-73133b85604a}Lbl": Label 'GST Use Cases';
        "{17da0fc6-fc3f-4ab5-a2c7-34d00b649941}Lbl": Label 'GST Use Cases';
        "{741172e2-8b2d-461d-9081-71145f1316df}Lbl": Label 'GST Use Cases';
        "{29c6fb1d-f01c-426f-ac3e-76e9122fdb69}Lbl": Label 'GST Use Cases';
        "{49fe20a3-c985-4427-98a7-cbc3119c73f7}Lbl": Label 'GST Use Cases';
        "{913aae94-3aef-4f6d-80db-f30ff5e5c067}Lbl": Label 'GST Use Cases';
        "{6cc7879a-5af1-4fd6-8713-7ecf54abc412}Lbl": Label 'GST Use Cases';
        "{858ca47f-fa82-4485-91a5-12b2ebf36d6f}Lbl": Label 'GST Use Cases';
        "{5629ebaa-46b2-4dd7-9511-1d6e697a6b0a}Lbl": Label 'GST Use Cases';
        "{44130b2e-fba8-47de-bf1f-af9145ac13bd}Lbl": Label 'GST Use Cases';
        "{53d88a93-5ce2-427c-81f0-6dcfc36f579f}Lbl": Label 'GST Use Cases';
        "{97120cfc-a3a4-4545-8a71-881473ed33c7}Lbl": Label 'GST Use Cases';
        "{23f3d552-5b8b-47a9-b217-903567666bce}Lbl": Label 'GST Use Cases';
        "{14586eff-720d-4670-b023-ea4fbff96b99}Lbl": Label 'GST Use Cases';
        "{861e4175-2832-49d7-8af3-96e6c19f8e68}Lbl": Label 'GST Use Cases';
        "{220890e5-a6c0-4719-83c5-e2247ef9bec3}Lbl": Label 'GST Use Cases';
        "{4bfa98d3-cef3-4573-b464-9e897eb9d4ae}Lbl": Label 'GST Use Cases';
        "{f0e83015-3886-4263-a0b7-a97ba3b7753c}Lbl": Label 'GST Use Cases';
        "{fd5fd103-5251-4063-92c9-ccfe016b971b}Lbl": Label 'GST Use Cases';
        "{5582b9b9-2c0c-4036-a0e1-ed20495d47af}Lbl": Label 'GST Use Cases';
        "{307349c1-c724-4cb8-8878-7587cc2617ec}Lbl": Label 'GST Use Cases';
        "{c3755aff-81d3-4b1a-85b2-b2c8a60f9eaa}Lbl": Label 'GST Use Cases';
        "{0e655e71-19d9-4a10-8a28-fe4afba2a7c7}Lbl": Label 'GST Use Cases';
        "{f4c6236c-3805-4826-88fd-eac2659389b0}Lbl": Label 'GST Use Cases';
        "{10bbeeb9-e622-4899-b4e0-c000ca753e54}Lbl": Label 'GST Use Cases';
        "{adf93fbf-84bb-4dc9-8b87-eadde08829f0}Lbl": Label 'GST Use Cases';
        "{3c1d2a94-cbae-4190-be50-ad56cf9218d9}Lbl": Label 'GST Use Cases';
        "{103e8a37-530c-4fff-bb01-d298e7df9ffc}Lbl": Label 'GST Use Cases';
        "{02a9b37f-66a8-446a-b5b0-703d594ff934}Lbl": Label 'GST Use Cases';
        "{9654c77e-d850-4aa2-9a47-fb003b1574b2}Lbl": Label 'GST Use Cases';
        "{6924daf8-60f6-4c42-9266-200033c6d3f4}Lbl": Label 'GST Use Cases';
        "{11d160cf-fd98-4c47-928b-9f4125f584a9}Lbl": Label 'GST Use Cases';
        "{b3793372-9ad2-4f36-ba5c-3af13be44f2d}Lbl": Label 'GST Use Cases';
        "{cf0f6dea-a530-45b3-8b1b-cf86879e9eda}Lbl": Label 'GST Use Cases';
        "{0561985a-b2f9-4c9c-be39-7d6ae423104e}Lbl": Label 'GST Use Cases';
        "{51cd0a49-e8df-42a3-9180-84d1a7076a42}Lbl": Label 'GST Use Cases';
        "{da8695b6-d7d7-41e9-be59-c26a19d03c2c}Lbl": Label 'GST Use Cases';
        "{270f6442-0097-437d-9f91-5c15bd9eab4d}Lbl": Label 'GST Use Cases';
        "{abf997c4-d467-4f97-94cd-10afe3a66b3a}Lbl": Label 'GST Use Cases';
        "{902158a0-97d5-4075-943e-3b30b800fb78}Lbl": Label 'GST Use Cases';
        "{4116f9d4-1957-46d1-bced-580bd21c0908}Lbl": Label 'GST Use Cases';
        "{05cee5ad-ff50-479c-922c-1c51fe10f724}Lbl": Label 'GST Use Cases';
        "{f356e0fe-23c7-4d81-a149-3659f2cefbb4}Lbl": Label 'GST Use Cases';
        "{7e2f85f6-ffba-45fe-80b5-39b654365acd}Lbl": Label 'GST Use Cases';
        "{88f1a4b3-dcac-499a-bd7a-a5eba3ef3cb4}Lbl": Label 'GST Use Cases';
        "{1f11a81c-0551-4b07-aa30-23da57e0fe16}Lbl": Label 'GST Use Cases';
        "{ebfdb89b-5f22-4386-87ca-72157cbf122d}Lbl": Label 'GST Use Cases';
        "{321e0f7b-a15d-4ce6-9c11-bf3fd3dee918}Lbl": Label 'GST Use Cases';
    begin
        Handled := true;

        case CaseID of
            '{9fe211a9-770a-4396-be84-b9625d975180}':
                exit("{9fe211a9-770a-4396-be84-b9625d975180}Lbl");
            '{04ba2f8d-9562-4551-8a98-c61ce5509b47}':
                exit("{04ba2f8d-9562-4551-8a98-c61ce5509b47}Lbl");
            '{fec46768-8566-4c39-ae1d-62b0fd83d5d6}':
                exit("{fec46768-8566-4c39-ae1d-62b0fd83d5d6}Lbl");
            '{f7997b96-631e-456d-9fa2-028adec745c1}':
                exit("{f7997b96-631e-456d-9fa2-028adec745c1}Lbl");
            '{47aa3c60-6575-4f87-8022-29790bb97a11}':
                exit("{47aa3c60-6575-4f87-8022-29790bb97a11}Lbl");
            '{21a2dffa-df09-4531-be3f-dfc7e50f3d1e}':
                exit("{21a2dffa-df09-4531-be3f-dfc7e50f3d1e}Lbl");
            '{8e9e924f-0be8-4862-bdfe-39cb23848b3c}':
                exit("{8e9e924f-0be8-4862-bdfe-39cb23848b3c}Lbl");
            '{c9f94259-ea6b-481b-aaf1-8d8f9f025902}':
                exit("{c9f94259-ea6b-481b-aaf1-8d8f9f025902}Lbl");
            '{b7a4d05e-75c4-47f5-b502-9510b13e2dea}':
                exit("{b7a4d05e-75c4-47f5-b502-9510b13e2dea}Lbl");
            '{19625bab-02b9-42e1-80ef-fed88d13ff40}':
                exit("{19625bab-02b9-42e1-80ef-fed88d13ff40}Lbl");
            '{56966b10-de93-4980-a9fe-1cbb5de6359b}':
                exit("{56966b10-de93-4980-a9fe-1cbb5de6359b}Lbl");
        end;

        case CaseID of
            '{5e2d969d-2a4b-4288-900b-7d1527f80a8e}':
                exit("{5e2d969d-2a4b-4288-900b-7d1527f80a8e}Lbl");
            '{2e66dc31-92bb-4928-83e5-6f87fc544a85}':
                exit("{2e66dc31-92bb-4928-83e5-6f87fc544a85}Lbl");
            '{b4b3ee78-57ec-4ee8-8f51-e7b868cf34b9}':
                exit("{b4b3ee78-57ec-4ee8-8f51-e7b868cf34b9}Lbl");
            '{90643bb8-1beb-40c8-81b3-e6a3c5075c45}':
                exit("{90643bb8-1beb-40c8-81b3-e6a3c5075c45}Lbl");
            '{55bea8b4-15ed-47b2-ad24-157ba39467ee}':
                exit("{55bea8b4-15ed-47b2-ad24-157ba39467ee}Lbl");
            '{0c6ee2b8-335f-4420-9b76-aebf773bb40c}':
                exit("{0c6ee2b8-335f-4420-9b76-aebf773bb40c}Lbl");
            '{10d6a0fe-f802-4235-b438-3a29b7c853ed}':
                exit("{10d6a0fe-f802-4235-b438-3a29b7c853ed}Lbl");
            '{7e48e18f-d907-423a-bc62-256d7cfaa089}':
                exit("{7e48e18f-d907-423a-bc62-256d7cfaa089}Lbl");
            '{ccd1bd07-0a33-4dab-9a3e-e66956e0f98b}':
                exit("{ccd1bd07-0a33-4dab-9a3e-e66956e0f98b}Lbl");
            '{7642fecb-8bee-4127-9523-47ecb7d29dc4}':
                exit("{7642fecb-8bee-4127-9523-47ecb7d29dc4}Lbl");
            '{f1a5130e-021a-40f9-8282-82cbfee3ff07}':
                exit("{f1a5130e-021a-40f9-8282-82cbfee3ff07}Lbl");
        end;

        case CaseID of
            '{65746f4e-a835-4278-98ca-b6ab0d0cbf6b}':
                exit("{65746f4e-a835-4278-98ca-b6ab0d0cbf6b}Lbl");
            '{a515d68a-a496-4a81-8f4e-ec21f207d5ff}':
                exit("{a515d68a-a496-4a81-8f4e-ec21f207d5ff}Lbl");
            '{79a59a19-401f-444f-a3c4-f8cbba06d4b0}':
                exit("{79a59a19-401f-444f-a3c4-f8cbba06d4b0}Lbl");
            '{8b9b630b-1ac7-49a1-ba60-3a415b97c2bc}':
                exit("{8b9b630b-1ac7-49a1-ba60-3a415b97c2bc}Lbl");
            '{7601e944-f060-482e-b620-cf8555d00bb9}':
                exit("{7601e944-f060-482e-b620-cf8555d00bb9}Lbl");
            '{040a5713-75a6-4fd3-bca9-7a335d697933}':
                exit("{040a5713-75a6-4fd3-bca9-7a335d697933}Lbl");
            '{4b185dab-793d-4c0a-a303-417a61ac9b96}':
                exit("{4b185dab-793d-4c0a-a303-417a61ac9b96}Lbl");
            '{4fd977c3-86db-46a1-aeef-a0a176f23be1}':
                exit("{4fd977c3-86db-46a1-aeef-a0a176f23be1}Lbl");
            '{bc63870d-585e-4c07-a6a6-44de28f260be}':
                exit("{bc63870d-585e-4c07-a6a6-44de28f260be}Lbl");
        end;

        case CaseID of
            '{6333f9d2-02b8-4ff1-88ee-386041b7fca4}':
                exit("{6333f9d2-02b8-4ff1-88ee-386041b7fca4}Lbl");
            '{03d7d334-04d2-4ec5-ae88-a67c1409c8be}':
                exit("{03d7d334-04d2-4ec5-ae88-a67c1409c8be}Lbl");
            '{9e8f612a-6306-4cd0-aa63-8f443733b9b5}':
                exit("{9e8f612a-6306-4cd0-aa63-8f443733b9b5}Lbl");
            '{cf89d22f-0cd8-4e3c-a01c-6c159e03e5e6}':
                exit("{cf89d22f-0cd8-4e3c-a01c-6c159e03e5e6}Lbl");
            '{14fc3d2c-3daf-4c04-aa69-6ae47d0d7552}':
                exit("{14fc3d2c-3daf-4c04-aa69-6ae47d0d7552}Lbl");
            '{59157e34-743f-4293-a662-1a9c3d916178}':
                exit("{59157e34-743f-4293-a662-1a9c3d916178}Lbl");
            '{d6d5aacf-3fc9-4e46-ac66-66cb29d5293e}':
                exit("{d6d5aacf-3fc9-4e46-ac66-66cb29d5293e}Lbl");
            '{291465b9-0c22-48b5-9eea-4006cc372b1a}':
                exit("{291465b9-0c22-48b5-9eea-4006cc372b1a}Lbl");
            '{c69c8c2b-3445-476c-80ed-776ec67b06d3}':
                exit("{c69c8c2b-3445-476c-80ed-776ec67b06d3}Lbl");
            '{08eacbe7-7b68-4b7b-8bce-8d5d4fad80f0}':
                exit("{08eacbe7-7b68-4b7b-8bce-8d5d4fad80f0}Lbl");
            '{e8acbb6b-eaaf-46c6-a4ea-efb502d8e110}':
                exit("{e8acbb6b-eaaf-46c6-a4ea-efb502d8e110}Lbl");
            '{5860dc76-ae27-4a12-808d-667172bef336}':
                exit("{5860dc76-ae27-4a12-808d-667172bef336}Lbl");
            '{a4a8c87f-d458-4dd2-b8e9-8393220fdd2d}':
                exit("{a4a8c87f-d458-4dd2-b8e9-8393220fdd2d}Lbl");
            '{d9aa8d5e-8135-47aa-a722-6356873cf5ef}':
                exit("{d9aa8d5e-8135-47aa-a722-6356873cf5ef}Lbl");
            '{a0d756a0-dc72-49f9-a1f9-b926242c6ad2}':
                exit("{a0d756a0-dc72-49f9-a1f9-b926242c6ad2}Lbl");
        end;

        case CaseID of
            '{bfb628d6-4413-4628-b619-013ef3255ce9}':
                exit("{bfb628d6-4413-4628-b619-013ef3255ce9}Lbl");
            '{a4b4b64c-1d4c-48ee-88e9-4bbc4f05eae8}':
                exit("{a4b4b64c-1d4c-48ee-88e9-4bbc4f05eae8}Lbl");
            '{8d8429d6-2b1a-4081-900e-9d19c312335e}':
                exit("{8d8429d6-2b1a-4081-900e-9d19c312335e}Lbl");
            '{dc79d469-98cd-45ff-adbb-27dff74d2672}':
                exit("{dc79d469-98cd-45ff-adbb-27dff74d2672}Lbl");
            '{84992760-0362-488c-8d49-0de8065f945c}':
                exit("{84992760-0362-488c-8d49-0de8065f945c}Lbl");
            '{10ca76a8-8de4-419a-8220-3dd88d8f8747}':
                exit("{10ca76a8-8de4-419a-8220-3dd88d8f8747}Lbl");
            '{b8757b78-d36c-4ab7-b532-353006120046}':
                exit("{b8757b78-d36c-4ab7-b532-353006120046}Lbl");
            '{5131a9e4-a281-496f-9af2-e60dc7d88a50}':
                exit("{5131a9e4-a281-496f-9af2-e60dc7d88a50}Lbl");
            '{7aff7259-d09b-4c62-8575-34bedee4a72c}':
                exit("{7aff7259-d09b-4c62-8575-34bedee4a72c}Lbl");
            '{e786a7d6-1147-46f6-bb75-1223aac92007}':
                exit("{e786a7d6-1147-46f6-bb75-1223aac92007}Lbl");
            '{ea505d2c-22a0-4b4b-b20f-18a0e1ae2c02}':
                exit("{ea505d2c-22a0-4b4b-b20f-18a0e1ae2c02}Lbl");
            '{fbbceafb-3b22-4d36-969e-84ab2cdc7859}':
                exit("{fbbceafb-3b22-4d36-969e-84ab2cdc7859}Lbl");
            '{c8ba6ca4-7e8c-4053-980d-451fe32d8efa}':
                exit("{c8ba6ca4-7e8c-4053-980d-451fe32d8efa}Lbl");
            '{13827c55-0612-40ef-bed1-62d7605b9d68}':
                exit("{13827c55-0612-40ef-bed1-62d7605b9d68}Lbl");
            '{92cd1d91-1d76-46d8-b2e1-c62c54e62191}':
                exit("{92cd1d91-1d76-46d8-b2e1-c62c54e62191}Lbl");
        end;

        case CaseID of
            '{efb5634e-c341-4922-9bc9-1ce76ad61d79}':
                exit("{efb5634e-c341-4922-9bc9-1ce76ad61d79}Lbl");
            '{40c0504c-93d7-4ec1-a4b8-7fe82c224be4}':
                exit("{40c0504c-93d7-4ec1-a4b8-7fe82c224be4}Lbl");
            '{3eaea83a-b986-4c1e-9231-edeac919de2f}':
                exit("{3eaea83a-b986-4c1e-9231-edeac919de2f}Lbl");
            '{bb38433a-2ae4-492d-8380-d8b5a6f80135}':
                exit("{bb38433a-2ae4-492d-8380-d8b5a6f80135}Lbl");
            '{81345ec6-231d-4274-95d2-302ffe85b903}':
                exit("{81345ec6-231d-4274-95d2-302ffe85b903}Lbl");
            '{747b1a95-df79-4286-a38b-a6f98f2d2de1}':
                exit("{747b1a95-df79-4286-a38b-a6f98f2d2de1}Lbl");
            '{fc888469-0e29-48ba-b417-07d5943d7c45}':
                exit("{fc888469-0e29-48ba-b417-07d5943d7c45}Lbl");
            '{31f4991c-5e91-4af3-b911-39f985bf48c1}':
                exit("{31f4991c-5e91-4af3-b911-39f985bf48c1}Lbl");
            '{3397dbb8-098b-4a52-9bfa-e24a12b5f9e7}':
                exit("{3397dbb8-098b-4a52-9bfa-e24a12b5f9e7}Lbl");
            '{6c740bb7-2090-4e02-8611-2fd65cc51465}':
                exit("{6c740bb7-2090-4e02-8611-2fd65cc51465}Lbl");
            '{0dd3f665-8d52-487d-a200-9bd69db0a4a2}':
                exit("{0dd3f665-8d52-487d-a200-9bd69db0a4a2}Lbl");
            '{be591554-5098-41fd-a200-5b5b48c19083}':
                exit("{be591554-5098-41fd-a200-5b5b48c19083}Lbl");
            '{6807fdac-8bcb-4b1a-84ff-882c6a9c15b7}':
                exit("{6807fdac-8bcb-4b1a-84ff-882c6a9c15b7}Lbl");
            '{8b4b45ec-5b92-4383-935b-de2e70579ca8}':
                exit("{8b4b45ec-5b92-4383-935b-de2e70579ca8}Lbl");
            '{a8b33288-ca54-4dc6-b3e4-a14e3cca4efc}':
                exit("{a8b33288-ca54-4dc6-b3e4-a14e3cca4efc}Lbl");
        end;

        case CaseID of
            '{dba2caa4-8ee2-4dd0-b413-383101db034e}':
                exit("{dba2caa4-8ee2-4dd0-b413-383101db034e}Lbl");
            '{8e881e89-87c1-4745-9529-b82a784e83be}':
                exit("{8e881e89-87c1-4745-9529-b82a784e83be}Lbl");
            '{1f48109a-8444-4862-b9da-190182b3fbac}':
                exit("{1f48109a-8444-4862-b9da-190182b3fbac}Lbl");
            '{3ad6ddbc-a132-4aba-b216-73133b85604a}':
                exit("{3ad6ddbc-a132-4aba-b216-73133b85604a}Lbl");
            '{17da0fc6-fc3f-4ab5-a2c7-34d00b649941}':
                exit("{17da0fc6-fc3f-4ab5-a2c7-34d00b649941}Lbl");
            '{741172e2-8b2d-461d-9081-71145f1316df}':
                exit("{741172e2-8b2d-461d-9081-71145f1316df}Lbl");
            '{29c6fb1d-f01c-426f-ac3e-76e9122fdb69}':
                exit("{29c6fb1d-f01c-426f-ac3e-76e9122fdb69}Lbl");
            '{49fe20a3-c985-4427-98a7-cbc3119c73f7}':
                exit("{49fe20a3-c985-4427-98a7-cbc3119c73f7}Lbl");
            '{913aae94-3aef-4f6d-80db-f30ff5e5c067}':
                exit("{913aae94-3aef-4f6d-80db-f30ff5e5c067}Lbl");
            '{6cc7879a-5af1-4fd6-8713-7ecf54abc412}':
                exit("{6cc7879a-5af1-4fd6-8713-7ecf54abc412}Lbl");
            '{858ca47f-fa82-4485-91a5-12b2ebf36d6f}':
                exit("{858ca47f-fa82-4485-91a5-12b2ebf36d6f}Lbl");
            '{5629ebaa-46b2-4dd7-9511-1d6e697a6b0a}':
                exit("{5629ebaa-46b2-4dd7-9511-1d6e697a6b0a}Lbl");
            '{44130b2e-fba8-47de-bf1f-af9145ac13bd}':
                exit("{44130b2e-fba8-47de-bf1f-af9145ac13bd}Lbl");
            '{53d88a93-5ce2-427c-81f0-6dcfc36f579f}':
                exit("{53d88a93-5ce2-427c-81f0-6dcfc36f579f}Lbl");
            '{97120cfc-a3a4-4545-8a71-881473ed33c7}':
                exit("{97120cfc-a3a4-4545-8a71-881473ed33c7}Lbl");
        end;

        case CaseID of
            '{23f3d552-5b8b-47a9-b217-903567666bce}':
                exit("{23f3d552-5b8b-47a9-b217-903567666bce}Lbl");
            '{14586eff-720d-4670-b023-ea4fbff96b99}':
                exit("{14586eff-720d-4670-b023-ea4fbff96b99}Lbl");
            '{861e4175-2832-49d7-8af3-96e6c19f8e68}':
                exit("{861e4175-2832-49d7-8af3-96e6c19f8e68}Lbl");
            '{220890e5-a6c0-4719-83c5-e2247ef9bec3}':
                exit("{220890e5-a6c0-4719-83c5-e2247ef9bec3}Lbl");
            '{4bfa98d3-cef3-4573-b464-9e897eb9d4ae}':
                exit("{4bfa98d3-cef3-4573-b464-9e897eb9d4ae}Lbl");
            '{f0e83015-3886-4263-a0b7-a97ba3b7753c}':
                exit("{f0e83015-3886-4263-a0b7-a97ba3b7753c}Lbl");
            '{fd5fd103-5251-4063-92c9-ccfe016b971b}':
                exit("{fd5fd103-5251-4063-92c9-ccfe016b971b}Lbl");
            '{5582b9b9-2c0c-4036-a0e1-ed20495d47af}':
                exit("{5582b9b9-2c0c-4036-a0e1-ed20495d47af}Lbl");
            '{307349c1-c724-4cb8-8878-7587cc2617ec}':
                exit("{307349c1-c724-4cb8-8878-7587cc2617ec}Lbl");
            '{c3755aff-81d3-4b1a-85b2-b2c8a60f9eaa}':
                exit("{c3755aff-81d3-4b1a-85b2-b2c8a60f9eaa}Lbl");
            '{0e655e71-19d9-4a10-8a28-fe4afba2a7c7}':
                exit("{0e655e71-19d9-4a10-8a28-fe4afba2a7c7}Lbl");
            '{f4c6236c-3805-4826-88fd-eac2659389b0}':
                exit("{f4c6236c-3805-4826-88fd-eac2659389b0}Lbl");
            '{10bbeeb9-e622-4899-b4e0-c000ca753e54}':
                exit("{10bbeeb9-e622-4899-b4e0-c000ca753e54}Lbl");
            '{adf93fbf-84bb-4dc9-8b87-eadde08829f0}':
                exit("{adf93fbf-84bb-4dc9-8b87-eadde08829f0}Lbl");
            '{3c1d2a94-cbae-4190-be50-ad56cf9218d9}':
                exit("{3c1d2a94-cbae-4190-be50-ad56cf9218d9}Lbl");
        end;

        case CaseID of
            '{103e8a37-530c-4fff-bb01-d298e7df9ffc}':
                exit("{103e8a37-530c-4fff-bb01-d298e7df9ffc}Lbl");
            '{02a9b37f-66a8-446a-b5b0-703d594ff934}':
                exit("{02a9b37f-66a8-446a-b5b0-703d594ff934}Lbl");
            '{9654c77e-d850-4aa2-9a47-fb003b1574b2}':
                exit("{9654c77e-d850-4aa2-9a47-fb003b1574b2}Lbl");
            '{6924daf8-60f6-4c42-9266-200033c6d3f4}':
                exit("{6924daf8-60f6-4c42-9266-200033c6d3f4}Lbl");
            '{11d160cf-fd98-4c47-928b-9f4125f584a9}':
                exit("{11d160cf-fd98-4c47-928b-9f4125f584a9}Lbl");
            '{b3793372-9ad2-4f36-ba5c-3af13be44f2d}':
                exit("{b3793372-9ad2-4f36-ba5c-3af13be44f2d}Lbl");
            '{cf0f6dea-a530-45b3-8b1b-cf86879e9eda}':
                exit("{cf0f6dea-a530-45b3-8b1b-cf86879e9eda}Lbl");
            '{0561985a-b2f9-4c9c-be39-7d6ae423104e}':
                exit("{0561985a-b2f9-4c9c-be39-7d6ae423104e}Lbl");
            '{51cd0a49-e8df-42a3-9180-84d1a7076a42}':
                exit("{51cd0a49-e8df-42a3-9180-84d1a7076a42}Lbl");
            '{da8695b6-d7d7-41e9-be59-c26a19d03c2c}':
                exit("{da8695b6-d7d7-41e9-be59-c26a19d03c2c}Lbl");
            '{270f6442-0097-437d-9f91-5c15bd9eab4d}':
                exit("{270f6442-0097-437d-9f91-5c15bd9eab4d}Lbl");
            '{abf997c4-d467-4f97-94cd-10afe3a66b3a}':
                exit("{abf997c4-d467-4f97-94cd-10afe3a66b3a}Lbl");
            '{902158a0-97d5-4075-943e-3b30b800fb78}':
                exit("{902158a0-97d5-4075-943e-3b30b800fb78}Lbl");
            '{4116f9d4-1957-46d1-bced-580bd21c0908}':
                exit("{4116f9d4-1957-46d1-bced-580bd21c0908}Lbl");
            '{05cee5ad-ff50-479c-922c-1c51fe10f724}':
                exit("{05cee5ad-ff50-479c-922c-1c51fe10f724}Lbl");
        end;

        case CaseID of
            '{f356e0fe-23c7-4d81-a149-3659f2cefbb4}':
                exit("{f356e0fe-23c7-4d81-a149-3659f2cefbb4}Lbl");
            '{7e2f85f6-ffba-45fe-80b5-39b654365acd}':
                exit("{7e2f85f6-ffba-45fe-80b5-39b654365acd}Lbl");
            '{88f1a4b3-dcac-499a-bd7a-a5eba3ef3cb4}':
                exit("{88f1a4b3-dcac-499a-bd7a-a5eba3ef3cb4}Lbl");
            '{1f11a81c-0551-4b07-aa30-23da57e0fe16}':
                exit("{1f11a81c-0551-4b07-aa30-23da57e0fe16}Lbl");
            '{ebfdb89b-5f22-4386-87ca-72157cbf122d}':
                exit("{ebfdb89b-5f22-4386-87ca-72157cbf122d}Lbl");
            '{321e0f7b-a15d-4ce6-9c11-bf3fd3dee918}':
                exit("{321e0f7b-a15d-4ce6-9c11-bf3fd3dee918}Lbl");
        end;

        Handled := false;
    end;
}
