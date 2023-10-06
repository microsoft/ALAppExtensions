// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.JsonExchange;

using Microsoft.Finance.GST.Base;

codeunit 18019 "GST Use Case Labels"
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
        CaseList.Add('{5577B8ED-6471-4480-AD5A-63BA31696AB7}');
        CaseList.Add('{A274F11C-332F-4EE3-AC91-2E2D95E9E2B6}');
        CaseList.Add('{F6EB6D82-74A5-413E-BE36-9308F41811A3}');
        CaseList.Add('{7759D07C-F691-4738-8FB8-F682B03DA922}');
        CaseList.Add('{65C755B4-E396-453F-9425-896AFF64D1B3}');
        CaseList.Add('{0D76D452-CCE9-473B-998A-71EDADD459AE}');
        CaseList.Add('{A8B3F6FB-A42D-4767-BD3D-D4C9BB11AEAA}');
        CaseList.Add('{B86AA24C-78CF-4F29-BD88-E17580D6992B}');
        CaseList.Add('{679E7F9F-9AAC-4CC5-A263-904ECC708057}');
        CaseList.Add('{1B2046C2-4264-4272-A998-085B20832B87}');
        CaseList.Add('{998A15E8-B4E6-460E-A89C-239F276E9B3C}');
        CaseList.Add('{FFBADC05-CF47-4787-B31A-EB85F88CACE8}');
        CaseList.Add('{35C8BFED-ED88-46B7-AFE8-9F2C58421857}');
        CaseList.Add('{E0AA74AA-F401-4115-B768-D41BB661B532}');
        CaseList.Add('{51395C06-549D-40B5-98C5-A7F6B73AF427}');
        CaseList.Add('{131AC7D7-6079-4C25-A3A6-CEAC66A6203D}');
        CaseList.Add('{F759EFFB-61F9-4B84-B9CD-01E2616A7B85}');
        CaseList.Add('{F023887D-C599-4FE6-89E7-49C257DC208C}');
        CaseList.Add('{E75A7A67-D332-41BE-B7EA-61C8BF69E9F7}');
        CaseList.Add('{1440B152-A710-4982-86C0-5C27FEF4A7D6}');
        CaseList.Add('{BB48AD27-2942-4C4A-B19C-4A7E76E181DA}');
        CaseList.Add('{d8792403-fbc9-455c-8a3a-c67dafdb6e53}');
        CaseList.Add('{e607f91d-d6e7-459a-801a-cbb9c7f8ce89}');
        CaseList.Add('{aa85ef19-5f94-438e-adc4-a9acf0dcb0c1}');
        CaseList.Add('{4738101c-19e3-418c-a19d-61e67100d199}');
        CaseList.Add('{4e1d5479-c527-4295-a0c1-7d82d94860f6}');
        CaseList.Add('{0628d305-f863-48e9-986e-0570995f7002}');
        CaseList.Add('{f643a772-5ca6-4cc5-913c-9188c52df8e0}');
        CaseList.Add('{0321474a-abd0-45db-8cea-b586a5cb7f49}');
        CaseList.Add('{d22c3484-e0de-473f-9d62-2bb1dd4b10b9}');
        CaseList.Add('{2ff34432-5a9d-4c71-af8b-6dddc92f0a85}');
        CaseList.Add('{fd76eb64-c01a-48c0-9f8e-3ee2e17be515}');
        CaseList.Add('{D500E259-42B6-4346-BA2F-D76ECB9AFEE1}');
        CaseList.Add('{EFF7E856-EF6B-4EC0-9AAE-C2E07B6CB15B}');
        CaseList.Add('{4083d3d9-1f73-48ed-abd1-12c0559d270f}');
        CaseList.Add('{609f72cc-c49f-43f1-ab52-e56ed173368b}');
        CaseList.Add('{7F8B0021-4099-48C9-80BB-D977917CEA9E}');
        CaseList.Add('{882cb936-42d9-4c2d-bfd9-028d5f5d3337}');
        CaseList.Add('{40065229-e7d9-4c0a-a0eb-5de70dd4e9af}');
        CaseList.Add('{57a0b7f8-e6c5-4cc4-89ad-11a14af3c68b}');
        CaseList.Add('{E62B6029-1BFA-456D-8D43-306AB7C78589}');
        CaseList.Add('{4B114178-6589-41CD-907E-8C46CCDFE895}');
        CaseList.Add('{969F9BE2-D2C0-4DB5-BD38-F9DAC8AB8173}');
        CaseList.Add('{e9ed8cb8-e0bd-4e8a-88a5-1aa7348acf20}');
        CaseList.Add('{e28ed0e6-8917-4d81-ad22-29d13fe94091}');
        CaseList.Add('{e65ce6aa-c447-466e-a3fe-154d3f5a76dc}');
        CaseList.Add('{929eb05f-45b5-4f4f-9dd4-61afab36f21b}');
        CaseList.Add('{a2608a05-d116-4475-b690-a6e26170bc2c}');
        CaseList.Add('{c502f69b-f76d-4d72-b7fc-a272a252590b}');
        CaseList.Add('{7be46e73-ef21-4766-b4f2-34558460a2c9}');
        CaseList.Add('{2c82cf3d-40b2-4fcc-8f04-e649dadd1619}');
        CaseList.Add('{1f930cb5-93a8-4be9-b412-b9b44f1fbe2b}');
        CaseList.Add('{71177393-f102-466e-ac36-1a460bc1c3e9}');
        CaseList.Add('{5fb236fb-7619-48a1-92d0-bd12f5c8a5c0}');
        CaseList.Add('{a030c0c9-951c-4818-8a68-c6d5917c31bf}');
        CaseList.Add('{0bd7bb2e-38e6-4254-82cb-713f429d787c}');
        CaseList.Add('{b66179f8-e62e-45f8-9de3-5351c859f85d}');
        CaseList.Add('{2f7b1f64-56f5-48c9-a6b2-a5f7f2bf8a2f}');
        CaseList.Add('{332a3e45-c1c8-423a-9063-b55efa585045}');
        CaseList.Add('{74e6e05f-641d-4857-8f88-c48783b29b3e}');
        CaseList.Add('{8a58255b-97c9-4691-9dbf-1c041d4433db}');
        CaseList.Add('{8ee30985-1662-4a16-b9b1-2c36589f4f94}');
        CaseList.Add('{1dd024d8-c5d0-44dc-bd2e-3b4a395f33fe}');
        CaseList.Add('{478e0789-2184-4644-8165-3b5169084277}');
        CaseList.Add('{afccc11e-97b1-4627-8dfd-4184537e2509}');
        CaseList.Add('{66a099c8-9660-498e-9beb-61296a76cfaf}');
        CaseList.Add('{8b96f1e1-fc2c-48fd-ad1e-62986961ac0d}');
        CaseList.Add('{cce6e98e-5330-48ba-b42e-70e2bde3e45b}');
        CaseList.Add('{718c2339-648b-4fc6-a496-737b12176d01}');
        CaseList.Add('{0abf122d-4ed5-4820-8411-7c39147b2819}');
        CaseList.Add('{fcc8aa84-e16b-4d3f-a139-946089738fb0}');
        CaseList.Add('{e365b9af-953a-462b-a562-9b494d0b84b9}');
        CaseList.Add('{e6b10245-e536-41cf-a9cc-aa043113f6f4}');
        CaseList.Add('{666a5198-99ba-4ec0-a89a-c991109bbc0f}');
        CaseList.Add('{679f358f-4db0-4587-9f0c-ce643b16a152}');
        CaseList.Add('{e246f7fe-de34-4e3c-bd3b-d8943d9b966c}');
        CaseList.Add('{4fa8a9f3-d8c5-4b20-acb0-f52bfe013a01}');
        CaseList.Add('{cd837506-8d55-4e71-8576-fa6b9934a6bb}');
        CaseList.Add('{2a0e0c4e-331f-42b3-96d2-f9cff01e6fc1}');
        CaseList.Add('{c4dd33b4-d4db-4f30-8c86-e2045b473c57}');
        CaseList.Add('{bfb5b4f3-bbc1-4a5b-9b7c-c3572578cd78}');
        CaseList.Add('{38f58d78-84d4-40d9-be77-cd33c02b49af}');
        CaseList.Add('{38583b1e-682c-4b06-bb69-005849014e82}');
        CaseList.Add('{0e9f08c2-7cf2-4ac1-afb4-57ac8383e732}');
        CaseList.Add('{3a542488-e9a7-41e5-bf0b-c73f9c82a8db}');
        CaseList.Add('{c85088e3-672f-4f2e-b1ef-19cbdfa5460b}');
        CaseList.Add('{d2457d2f-2b0e-4f56-bf93-007e245c4ff8}');
        CaseList.Add('{6a0a47a2-4a0f-4ccd-ac63-a70c76e05091}');
        CaseList.Add('{e5053eeb-44d1-4552-8084-67d72a90cecb}');
        CaseList.Add('{1eb264e9-24dd-43ec-a17f-e623bf565203}');
        CaseList.Add('{03418ffd-0af9-48f5-a500-ec48bf9de4e5}');
        CaseList.Add('{da3fc765-67aa-4232-8c30-6ce3e6e6dfdc}');
        CaseList.Add('{714e77d3-c569-418a-a932-dbff272d3b92}');
        CaseList.Add('{d50e350f-963c-4c3c-9e78-08f12ab7d8f0}');
        CaseList.Add('{ffcc9396-d3c4-4a81-bde8-23070bf8976f}');
        CaseList.Add('{21e3248f-92c2-444c-b7e9-b48218ad918a}');
        CaseList.Add('{1988b611-abd4-44c4-9cb5-67bb88e0002c}');
        CaseList.Add('{700cf31e-e4a1-4183-aef6-7c572c34c8ad}');
        CaseList.Add('{13352a4d-eeab-4fea-a778-0bdad73b550c}');
        CaseList.Add('{07ac553c-0e84-41e3-b04a-19b63c3bcf75}');
        CaseList.Add('{2bf5b2fe-2191-416d-b63f-47052716fc1b}');
        CaseList.Add('{df5e22a4-bd3c-4c80-b6d3-9f667c8037dd}');
        CaseList.Add('{8fcf5988-06c7-44e2-a7bd-a5a9b40cdef8}');
        CaseList.Add('{67fecb97-a3fa-4fc9-8a80-e214c3df4ca9}');
        CaseList.Add('{b8a8c947-5ba0-45b4-b8a4-33088f25782f}');
        CaseList.Add('{1A135F44-7A65-49A6-A08A-C87D453E5837}');
        CaseList.Add('{d9172942-78eb-4305-950c-c9dec70f16e6}');
        CaseList.Add('{9d6c4ac2-81d1-47e7-8c7c-494f20f1719f}');
        CaseList.Add('{9cbcec6f-a01b-422b-8aab-4b6bc90ec959}');
        CaseList.Add('{bfcc5c7f-f391-44d5-84f1-1d72dc7a9dec}');
        CaseList.Add('{b95176d6-58ff-487c-a25b-26e433d85356}');
        CaseList.Add('{13e5d66f-422b-4830-992b-39c740d6d560}');
        CaseList.Add('{8e537871-c8f7-4e07-8b32-84411c668443}');
        CaseList.Add('{bc9a772f-dbf9-4f4f-8607-212dc829c005}');
        CaseList.Add('{d7a29410-a685-41b6-a8f9-268d65f062b6}');
        CaseList.Add('{4dc1d2dc-a8f8-4443-a563-348b8e8961c1}');
        CaseList.Add('{85dae7d1-95ac-4fd1-b1e0-5ffd980481bf}');
        CaseList.Add('{0e1a782b-cf1f-4cf0-8797-a1310519b1db}');
        CaseList.Add('{05312e80-be4e-4eb1-9a1e-af55ea4d8e3d}');
        CaseList.Add('{55b6317f-25f3-4c73-8aa5-afa3ec519c88}');
        CaseList.Add('{3e14881b-db97-473e-9a0b-c8a0a2d604c1}');
        CaseList.Add('{0cf4326b-fd68-4ae6-b52a-cd2aa2f2a788}');
        CaseList.Add('{d2c0bc32-d71c-4fec-a3fc-63a0586da3d6}');
        CaseList.Add('{0410bc8a-0231-4947-8ed6-982a68846120}');
        CaseList.Add('{8e20fc81-1137-41b3-a90e-ae86cd66f718}');
        CaseList.Add('{3277542b-b49c-4ccd-b661-f72c71ced698}');
        CaseList.Add('{1bae51d1-ad26-40f8-bfd2-156024a23a7b}');
        CaseList.Add('{364eaba8-df5d-4174-951e-9c9b375830d6}');
        CaseList.Add('{62275f50-6f85-4ea6-aa4f-0bacf20cf65e}');
        CaseList.Add('{ab179237-ef7c-4bb1-9406-46b7b6dd1449}');
        CaseList.Add('{8df66c94-890c-4007-9341-18d0565000fe}');
        CaseList.Add('{DF167294-5878-44C6-9220-01D93BEA09FF}');
        CaseList.Add('{89071509-bf13-4ed5-a45d-8d938dfef265}');
        CaseList.Add('{7bdd3ee0-29ae-4c15-a879-1dbf13ada019}');
        CaseList.Add('{fbedc063-63ea-4fed-a3dd-8b5e175031cd}');
        CaseList.Add('{055aee33-1301-4b59-ba0d-e76d2d542b34}');
        CaseList.Add('{d279be29-1cb8-4f96-ba2c-0348368d0879}');
        CaseList.Add('{f4f11b85-700b-4880-9a73-740ff36c4160}');
        CaseList.Add('{ce65aeff-0248-437e-b8a6-87c60e49efd4}');
        CaseList.Add('{0ebd8b25-3c27-46ae-8cd7-4e870db1315b}');
        CaseList.Add('{97437c0c-3e99-4d15-9378-34ac4b8fd002}');
    end;

    procedure GetConfig(CaseID: Guid; var Handled: Boolean): Text
    var
        "{5577B8ED-6471-4480-AD5A-63BA31696AB7}Lbl": Label 'GST Use Cases';
        "{A274F11C-332F-4EE3-AC91-2E2D95E9E2B6}Lbl": Label 'GST Use Cases';
        "{F6EB6D82-74A5-413E-BE36-9308F41811A3}Lbl": Label 'GST Use Cases';
        "{7759D07C-F691-4738-8FB8-F682B03DA922}Lbl": Label 'GST Use Cases';
        "{65C755B4-E396-453F-9425-896AFF64D1B3}Lbl": Label 'GST Use Cases';
        "{0D76D452-CCE9-473B-998A-71EDADD459AE}Lbl": Label 'GST Use Cases';
        "{A8B3F6FB-A42D-4767-BD3D-D4C9BB11AEAA}Lbl": Label 'GST Use Cases';
        "{B86AA24C-78CF-4F29-BD88-E17580D6992B}Lbl": Label 'GST Use Cases';
        "{679E7F9F-9AAC-4CC5-A263-904ECC708057}Lbl": Label 'GST Use Cases';
        "{1B2046C2-4264-4272-A998-085B20832B87}Lbl": Label 'GST Use Cases';
        "{998A15E8-B4E6-460E-A89C-239F276E9B3C}Lbl": Label 'GST Use Cases';
        "{FFBADC05-CF47-4787-B31A-EB85F88CACE8}Lbl": Label 'GST Use Cases';
        "{35C8BFED-ED88-46B7-AFE8-9F2C58421857}Lbl": Label 'GST Use Cases';
        "{E0AA74AA-F401-4115-B768-D41BB661B532}Lbl": Label 'GST Use Cases';
        "{51395C06-549D-40B5-98C5-A7F6B73AF427}Lbl": Label 'GST Use Cases';
        "{131AC7D7-6079-4C25-A3A6-CEAC66A6203D}Lbl": Label 'GST Use Cases';
        "{F759EFFB-61F9-4B84-B9CD-01E2616A7B85}Lbl": Label 'GST Use Cases';
        "{F023887D-C599-4FE6-89E7-49C257DC208C}Lbl": Label 'GST Use Cases';
        "{E75A7A67-D332-41BE-B7EA-61C8BF69E9F7}Lbl": Label 'GST Use Cases';
        "{1440B152-A710-4982-86C0-5C27FEF4A7D6}Lbl": Label 'GST Use Cases';
        "{BB48AD27-2942-4C4A-B19C-4A7E76E181DA}Lbl": Label 'GST Use Cases';
        "{d8792403-fbc9-455c-8a3a-c67dafdb6e53}Lbl": Label 'GST Use Cases';
        "{e607f91d-d6e7-459a-801a-cbb9c7f8ce89}Lbl": Label 'GST Use Cases';
        "{aa85ef19-5f94-438e-adc4-a9acf0dcb0c1}Lbl": Label 'GST Use Cases';
        "{4738101c-19e3-418c-a19d-61e67100d199}Lbl": Label 'GST Use Cases';
        "{4e1d5479-c527-4295-a0c1-7d82d94860f6}Lbl": Label 'GST Use Cases';
        "{0628d305-f863-48e9-986e-0570995f7002}Lbl": Label 'GST Use Cases';
        "{f643a772-5ca6-4cc5-913c-9188c52df8e0}Lbl": Label 'GST Use Cases';
        "{0321474a-abd0-45db-8cea-b586a5cb7f49}Lbl": Label 'GST Use Cases';
        "{d22c3484-e0de-473f-9d62-2bb1dd4b10b9}Lbl": Label 'GST Use Cases';
        "{2ff34432-5a9d-4c71-af8b-6dddc92f0a85}Lbl": Label 'GST Use Cases';
        "{fd76eb64-c01a-48c0-9f8e-3ee2e17be515}Lbl": Label 'GST Use Cases';
        "{D500E259-42B6-4346-BA2F-D76ECB9AFEE1}Lbl": Label 'GST Use Cases';
        "{EFF7E856-EF6B-4EC0-9AAE-C2E07B6CB15B}Lbl": Label 'GST Use Cases';
        "{4083d3d9-1f73-48ed-abd1-12c0559d270f}Lbl": Label 'GST Use Cases';
        "{609f72cc-c49f-43f1-ab52-e56ed173368b}Lbl": Label 'GST Use Cases';
        "{7F8B0021-4099-48C9-80BB-D977917CEA9E}Lbl": Label 'GST Use Cases';
        "{882cb936-42d9-4c2d-bfd9-028d5f5d3337}Lbl": Label 'GST Use Cases';
        "{40065229-e7d9-4c0a-a0eb-5de70dd4e9af}Lbl": Label 'GST Use Cases';
        "{57a0b7f8-e6c5-4cc4-89ad-11a14af3c68b}Lbl": Label 'GST Use Cases';
        "{E62B6029-1BFA-456D-8D43-306AB7C78589}Lbl": Label 'GST Use Cases';
        "{4B114178-6589-41CD-907E-8C46CCDFE895}Lbl": Label 'GST Use Cases';
        "{969F9BE2-D2C0-4DB5-BD38-F9DAC8AB8173}Lbl": Label 'GST Use Cases';
        "{e9ed8cb8-e0bd-4e8a-88a5-1aa7348acf20}Lbl": Label 'GST Use Cases';
        "{e28ed0e6-8917-4d81-ad22-29d13fe94091}Lbl": Label 'GST Use Cases';
        "{e65ce6aa-c447-466e-a3fe-154d3f5a76dc}Lbl": Label 'GST Use Cases';
        "{929eb05f-45b5-4f4f-9dd4-61afab36f21b}Lbl": Label 'GST Use Cases';
        "{a2608a05-d116-4475-b690-a6e26170bc2c}Lbl": Label 'GST Use Cases';
        "{c502f69b-f76d-4d72-b7fc-a272a252590b}Lbl": Label 'GST Use Cases';
        "{7be46e73-ef21-4766-b4f2-34558460a2c9}Lbl": Label 'GST Use Cases';
        "{2c82cf3d-40b2-4fcc-8f04-e649dadd1619}Lbl": Label 'GST Use Cases';
        "{1f930cb5-93a8-4be9-b412-b9b44f1fbe2b}Lbl": Label 'GST Use Cases';
        "{71177393-f102-466e-ac36-1a460bc1c3e9}Lbl": Label 'GST Use Cases';
        "{5fb236fb-7619-48a1-92d0-bd12f5c8a5c0}Lbl": Label 'GST Use Cases';
        "{a030c0c9-951c-4818-8a68-c6d5917c31bf}Lbl": Label 'GST Use Cases';
        "{0bd7bb2e-38e6-4254-82cb-713f429d787c}Lbl": Label 'GST Use Cases';
        "{b66179f8-e62e-45f8-9de3-5351c859f85d}Lbl": Label 'GST Use Cases';
        "{2f7b1f64-56f5-48c9-a6b2-a5f7f2bf8a2f}Lbl": Label 'GST Use Cases';
        "{332a3e45-c1c8-423a-9063-b55efa585045}Lbl": Label 'GST Use Cases';
        "{74e6e05f-641d-4857-8f88-c48783b29b3e}Lbl": Label 'GST Use Cases';
        "{8a58255b-97c9-4691-9dbf-1c041d4433db}Lbl": Label 'GST Use Cases';
        "{8ee30985-1662-4a16-b9b1-2c36589f4f94}Lbl": Label 'GST Use Cases';
        "{1dd024d8-c5d0-44dc-bd2e-3b4a395f33fe}Lbl": Label 'GST Use Cases';
        "{478e0789-2184-4644-8165-3b5169084277}Lbl": Label 'GST Use Cases';
        "{afccc11e-97b1-4627-8dfd-4184537e2509}Lbl": Label 'GST Use Cases';
        "{66a099c8-9660-498e-9beb-61296a76cfaf}Lbl": Label 'GST Use Cases';
        "{8b96f1e1-fc2c-48fd-ad1e-62986961ac0d}Lbl": Label 'GST Use Cases';
        "{cce6e98e-5330-48ba-b42e-70e2bde3e45b}Lbl": Label 'GST Use Cases';
        "{718c2339-648b-4fc6-a496-737b12176d01}Lbl": Label 'GST Use Cases';
        "{0abf122d-4ed5-4820-8411-7c39147b2819}Lbl": Label 'GST Use Cases';
        "{fcc8aa84-e16b-4d3f-a139-946089738fb0}Lbl": Label 'GST Use Cases';
        "{e365b9af-953a-462b-a562-9b494d0b84b9}Lbl": Label 'GST Use Cases';
        "{e6b10245-e536-41cf-a9cc-aa043113f6f4}Lbl": Label 'GST Use Cases';
        "{666a5198-99ba-4ec0-a89a-c991109bbc0f}Lbl": Label 'GST Use Cases';
        "{679f358f-4db0-4587-9f0c-ce643b16a152}Lbl": Label 'GST Use Cases';
        "{e246f7fe-de34-4e3c-bd3b-d8943d9b966c}Lbl": Label 'GST Use Cases';
        "{4fa8a9f3-d8c5-4b20-acb0-f52bfe013a01}Lbl": Label 'GST Use Cases';
        "{cd837506-8d55-4e71-8576-fa6b9934a6bb}Lbl": Label 'GST Use Cases';
        "{2a0e0c4e-331f-42b3-96d2-f9cff01e6fc1}Lbl": Label 'GST Use Cases';
        "{c4dd33b4-d4db-4f30-8c86-e2045b473c57}Lbl": Label 'GST Use Cases';
        "{bfb5b4f3-bbc1-4a5b-9b7c-c3572578cd78}Lbl": Label 'GST Use Cases';
        "{38f58d78-84d4-40d9-be77-cd33c02b49af}Lbl": Label 'GST Use Cases';
        "{38583b1e-682c-4b06-bb69-005849014e82}Lbl": Label 'GST Use Cases';
        "{0e9f08c2-7cf2-4ac1-afb4-57ac8383e732}Lbl": Label 'GST Use Cases';
        "{3a542488-e9a7-41e5-bf0b-c73f9c82a8db}Lbl": Label 'GST Use Cases';
        "{c85088e3-672f-4f2e-b1ef-19cbdfa5460b}Lbl": Label 'GST Use Cases';
        "{d2457d2f-2b0e-4f56-bf93-007e245c4ff8}Lbl": Label 'GST Use Cases';
        "{6a0a47a2-4a0f-4ccd-ac63-a70c76e05091}Lbl": Label 'GST Use Cases';
        "{e5053eeb-44d1-4552-8084-67d72a90cecb}Lbl": Label 'GST Use Cases';
        "{1eb264e9-24dd-43ec-a17f-e623bf565203}Lbl": Label 'GST Use Cases';
        "{03418ffd-0af9-48f5-a500-ec48bf9de4e5}Lbl": Label 'GST Use Cases';
        "{da3fc765-67aa-4232-8c30-6ce3e6e6dfdc}Lbl": Label 'GST Use Cases';
        "{714e77d3-c569-418a-a932-dbff272d3b92}Lbl": Label 'GST Use Cases';
        "{d50e350f-963c-4c3c-9e78-08f12ab7d8f0}Lbl": Label 'GST Use Cases';
        "{ffcc9396-d3c4-4a81-bde8-23070bf8976f}Lbl": Label 'GST Use Cases';
        "{21e3248f-92c2-444c-b7e9-b48218ad918a}Lbl": Label 'GST Use Cases';
        "{1988b611-abd4-44c4-9cb5-67bb88e0002c}Lbl": Label 'GST Use Cases';
        "{700cf31e-e4a1-4183-aef6-7c572c34c8ad}Lbl": Label 'GST Use Cases';
        "{13352a4d-eeab-4fea-a778-0bdad73b550c}Lbl": Label 'GST Use Cases';
        "{07ac553c-0e84-41e3-b04a-19b63c3bcf75}Lbl": Label 'GST Use Cases';
        "{2bf5b2fe-2191-416d-b63f-47052716fc1b}Lbl": Label 'GST Use Cases';
        "{df5e22a4-bd3c-4c80-b6d3-9f667c8037dd}Lbl": Label 'GST Use Cases';
        "{8fcf5988-06c7-44e2-a7bd-a5a9b40cdef8}Lbl": Label 'GST Use Cases';
        "{67fecb97-a3fa-4fc9-8a80-e214c3df4ca9}Lbl": Label 'GST Use Cases';
        "{b8a8c947-5ba0-45b4-b8a4-33088f25782f}Lbl": Label 'GST Use Cases';
        "{1A135F44-7A65-49A6-A08A-C87D453E5837}Lbl": Label 'GST Use Cases';
        "{d9172942-78eb-4305-950c-c9dec70f16e6}Lbl": Label 'GST Use Cases';
        "{9d6c4ac2-81d1-47e7-8c7c-494f20f1719f}Lbl": Label 'GST Use Cases';
        "{9cbcec6f-a01b-422b-8aab-4b6bc90ec959}Lbl": Label 'GST Use Cases';
        "{bfcc5c7f-f391-44d5-84f1-1d72dc7a9dec}Lbl": Label 'GST Use Cases';
        "{b95176d6-58ff-487c-a25b-26e433d85356}Lbl": Label 'GST Use Cases';
        "{13e5d66f-422b-4830-992b-39c740d6d560}Lbl": Label 'GST Use Cases';
        "{8e537871-c8f7-4e07-8b32-84411c668443}Lbl": Label 'GST Use Cases';
        "{bc9a772f-dbf9-4f4f-8607-212dc829c005}Lbl": Label 'GST Use Cases';
        "{d7a29410-a685-41b6-a8f9-268d65f062b6}Lbl": Label 'GST Use Cases';
        "{4dc1d2dc-a8f8-4443-a563-348b8e8961c1}Lbl": Label 'GST Use Cases';
        "{85dae7d1-95ac-4fd1-b1e0-5ffd980481bf}Lbl": Label 'GST Use Cases';
        "{0e1a782b-cf1f-4cf0-8797-a1310519b1db}Lbl": Label 'GST Use Cases';
        "{05312e80-be4e-4eb1-9a1e-af55ea4d8e3d}Lbl": Label 'GST Use Cases';
        "{55b6317f-25f3-4c73-8aa5-afa3ec519c88}Lbl": Label 'GST Use Cases';
        "{3e14881b-db97-473e-9a0b-c8a0a2d604c1}Lbl": Label 'GST Use Cases';
        "{0cf4326b-fd68-4ae6-b52a-cd2aa2f2a788}Lbl": Label 'GST Use Cases';
        "{d2c0bc32-d71c-4fec-a3fc-63a0586da3d6}Lbl": Label 'GST Use Cases';
        "{0410bc8a-0231-4947-8ed6-982a68846120}Lbl": Label 'GST Use Cases';
        "{8e20fc81-1137-41b3-a90e-ae86cd66f718}Lbl": Label 'GST Use Cases';
        "{3277542b-b49c-4ccd-b661-f72c71ced698}Lbl": Label 'GST Use Cases';
        "{1bae51d1-ad26-40f8-bfd2-156024a23a7b}Lbl": Label 'GST Use Cases';
        "{364eaba8-df5d-4174-951e-9c9b375830d6}Lbl": Label 'GST Use Cases';
        "{62275f50-6f85-4ea6-aa4f-0bacf20cf65e}Lbl": Label 'GST Use Cases';
        "{ab179237-ef7c-4bb1-9406-46b7b6dd1449}Lbl": Label 'GST Use Cases';
        "{8df66c94-890c-4007-9341-18d0565000fe}Lbl": Label 'GST Use Cases';
        "{DF167294-5878-44C6-9220-01D93BEA09FF}Lbl": Label 'GST Use Cases';
        "{89071509-bf13-4ed5-a45d-8d938dfef265}Lbl": Label 'GST Use Cases';
        "{7bdd3ee0-29ae-4c15-a879-1dbf13ada019}Lbl": Label 'GST Use Cases';
        "{fbedc063-63ea-4fed-a3dd-8b5e175031cd}Lbl": Label 'GST Use Cases';
        "{055aee33-1301-4b59-ba0d-e76d2d542b34}Lbl": Label 'GST Use Cases';
        "{d279be29-1cb8-4f96-ba2c-0348368d0879}Lbl": Label 'GST Use Cases';
        "{f4f11b85-700b-4880-9a73-740ff36c4160}Lbl": Label 'GST Use Cases';
        "{ce65aeff-0248-437e-b8a6-87c60e49efd4}Lbl": Label 'GST Use Cases';
        "{0ebd8b25-3c27-46ae-8cd7-4e870db1315b}Lbl": Label 'GST Use Cases';
        "{97437c0c-3e99-4d15-9378-34ac4b8fd002}Lbl": Label 'GST Use Cases';
    begin
        Handled := true;

        case CaseID of
            '{5577B8ED-6471-4480-AD5A-63BA31696AB7}':
                exit("{5577B8ED-6471-4480-AD5A-63BA31696AB7}Lbl");
            '{A274F11C-332F-4EE3-AC91-2E2D95E9E2B6}':
                exit("{A274F11C-332F-4EE3-AC91-2E2D95E9E2B6}Lbl");
            '{F6EB6D82-74A5-413E-BE36-9308F41811A3}':
                exit("{F6EB6D82-74A5-413E-BE36-9308F41811A3}Lbl");
            '{7759D07C-F691-4738-8FB8-F682B03DA922}':
                exit("{7759D07C-F691-4738-8FB8-F682B03DA922}Lbl");
            '{65C755B4-E396-453F-9425-896AFF64D1B3}':
                exit("{65C755B4-E396-453F-9425-896AFF64D1B3}Lbl");
            '{0D76D452-CCE9-473B-998A-71EDADD459AE}':
                exit("{0D76D452-CCE9-473B-998A-71EDADD459AE}Lbl");
            '{A8B3F6FB-A42D-4767-BD3D-D4C9BB11AEAA}':
                exit("{A8B3F6FB-A42D-4767-BD3D-D4C9BB11AEAA}Lbl");
            '{B86AA24C-78CF-4F29-BD88-E17580D6992B}':
                exit("{B86AA24C-78CF-4F29-BD88-E17580D6992B}Lbl");
            '{679E7F9F-9AAC-4CC5-A263-904ECC708057}':
                exit("{679E7F9F-9AAC-4CC5-A263-904ECC708057}Lbl");
            '{1B2046C2-4264-4272-A998-085B20832B87}':
                exit("{1B2046C2-4264-4272-A998-085B20832B87}Lbl");
            '{998A15E8-B4E6-460E-A89C-239F276E9B3C}':
                exit("{998A15E8-B4E6-460E-A89C-239F276E9B3C}Lbl");
        end;
        case CaseID of
            '{FFBADC05-CF47-4787-B31A-EB85F88CACE8}':
                exit("{FFBADC05-CF47-4787-B31A-EB85F88CACE8}Lbl");
            '{35C8BFED-ED88-46B7-AFE8-9F2C58421857}':
                exit("{35C8BFED-ED88-46B7-AFE8-9F2C58421857}Lbl");
            '{E0AA74AA-F401-4115-B768-D41BB661B532}':
                exit("{E0AA74AA-F401-4115-B768-D41BB661B532}Lbl");
            '{51395C06-549D-40B5-98C5-A7F6B73AF427}':
                exit("{51395C06-549D-40B5-98C5-A7F6B73AF427}Lbl");
            '{131AC7D7-6079-4C25-A3A6-CEAC66A6203D}':
                exit("{131AC7D7-6079-4C25-A3A6-CEAC66A6203D}Lbl");
            '{F759EFFB-61F9-4B84-B9CD-01E2616A7B85}':
                exit("{F759EFFB-61F9-4B84-B9CD-01E2616A7B85}Lbl");
            '{F023887D-C599-4FE6-89E7-49C257DC208C}':
                exit("{F023887D-C599-4FE6-89E7-49C257DC208C}Lbl");
            '{E75A7A67-D332-41BE-B7EA-61C8BF69E9F7}':
                exit("{E75A7A67-D332-41BE-B7EA-61C8BF69E9F7}Lbl");
            '{1440B152-A710-4982-86C0-5C27FEF4A7D6}':
                exit("{1440B152-A710-4982-86C0-5C27FEF4A7D6}Lbl");
            '{BB48AD27-2942-4C4A-B19C-4A7E76E181DA}':
                exit("{BB48AD27-2942-4C4A-B19C-4A7E76E181DA}Lbl");
            '{d8792403-fbc9-455c-8a3a-c67dafdb6e53}':
                exit("{d8792403-fbc9-455c-8a3a-c67dafdb6e53}Lbl");
            '{e607f91d-d6e7-459a-801a-cbb9c7f8ce89}':
                exit("{e607f91d-d6e7-459a-801a-cbb9c7f8ce89}Lbl");
            '{aa85ef19-5f94-438e-adc4-a9acf0dcb0c1}':
                exit("{aa85ef19-5f94-438e-adc4-a9acf0dcb0c1}Lbl");
            '{4738101c-19e3-418c-a19d-61e67100d199}':
                exit("{4738101c-19e3-418c-a19d-61e67100d199}Lbl");
            '{4e1d5479-c527-4295-a0c1-7d82d94860f6}':
                exit("{4e1d5479-c527-4295-a0c1-7d82d94860f6}Lbl");
        end;
        case CaseID of
            '{0628d305-f863-48e9-986e-0570995f7002}':
                exit("{0628d305-f863-48e9-986e-0570995f7002}Lbl");
            '{f643a772-5ca6-4cc5-913c-9188c52df8e0}':
                exit("{f643a772-5ca6-4cc5-913c-9188c52df8e0}Lbl");
            '{0321474a-abd0-45db-8cea-b586a5cb7f49}':
                exit("{0321474a-abd0-45db-8cea-b586a5cb7f49}Lbl");
            '{d22c3484-e0de-473f-9d62-2bb1dd4b10b9}':
                exit("{d22c3484-e0de-473f-9d62-2bb1dd4b10b9}Lbl");
            '{2ff34432-5a9d-4c71-af8b-6dddc92f0a85}':
                exit("{2ff34432-5a9d-4c71-af8b-6dddc92f0a85}Lbl");
            '{fd76eb64-c01a-48c0-9f8e-3ee2e17be515}':
                exit("{fd76eb64-c01a-48c0-9f8e-3ee2e17be515}Lbl");
            '{D500E259-42B6-4346-BA2F-D76ECB9AFEE1}':
                exit("{D500E259-42B6-4346-BA2F-D76ECB9AFEE1}Lbl");
            '{EFF7E856-EF6B-4EC0-9AAE-C2E07B6CB15B}':
                exit("{EFF7E856-EF6B-4EC0-9AAE-C2E07B6CB15B}Lbl");
            '{4083d3d9-1f73-48ed-abd1-12c0559d270f}':
                exit("{4083d3d9-1f73-48ed-abd1-12c0559d270f}Lbl");
            '{609f72cc-c49f-43f1-ab52-e56ed173368b}':
                exit("{609f72cc-c49f-43f1-ab52-e56ed173368b}Lbl");
            '{7F8B0021-4099-48C9-80BB-D977917CEA9E}':
                exit("{7F8B0021-4099-48C9-80BB-D977917CEA9E}Lbl");
        end;
        case CaseID of
            '{882cb936-42d9-4c2d-bfd9-028d5f5d3337}':
                exit("{882cb936-42d9-4c2d-bfd9-028d5f5d3337}Lbl");
            '{40065229-e7d9-4c0a-a0eb-5de70dd4e9af}':
                exit("{40065229-e7d9-4c0a-a0eb-5de70dd4e9af}Lbl");
            '{57a0b7f8-e6c5-4cc4-89ad-11a14af3c68b}':
                exit("{57a0b7f8-e6c5-4cc4-89ad-11a14af3c68b}Lbl");
            '{E62B6029-1BFA-456D-8D43-306AB7C78589}':
                exit("{E62B6029-1BFA-456D-8D43-306AB7C78589}Lbl");
            '{4B114178-6589-41CD-907E-8C46CCDFE895}':
                exit("{4B114178-6589-41CD-907E-8C46CCDFE895}Lbl");
            '{969F9BE2-D2C0-4DB5-BD38-F9DAC8AB8173}':
                exit("{969F9BE2-D2C0-4DB5-BD38-F9DAC8AB8173}Lbl");
            '{e9ed8cb8-e0bd-4e8a-88a5-1aa7348acf20}':
                exit("{e9ed8cb8-e0bd-4e8a-88a5-1aa7348acf20}Lbl");
            '{e28ed0e6-8917-4d81-ad22-29d13fe94091}':
                exit("{e28ed0e6-8917-4d81-ad22-29d13fe94091}Lbl");
            '{e65ce6aa-c447-466e-a3fe-154d3f5a76dc}':
                exit("{e65ce6aa-c447-466e-a3fe-154d3f5a76dc}Lbl");
            '{929eb05f-45b5-4f4f-9dd4-61afab36f21b}':
                exit("{929eb05f-45b5-4f4f-9dd4-61afab36f21b}Lbl");
            '{a2608a05-d116-4475-b690-a6e26170bc2c}':
                exit("{a2608a05-d116-4475-b690-a6e26170bc2c}Lbl");
            '{c502f69b-f76d-4d72-b7fc-a272a252590b}':
                exit("{c502f69b-f76d-4d72-b7fc-a272a252590b}Lbl");
            '{7be46e73-ef21-4766-b4f2-34558460a2c9}':
                exit("{7be46e73-ef21-4766-b4f2-34558460a2c9}Lbl");
        end;

        case CaseID of
            '{2c82cf3d-40b2-4fcc-8f04-e649dadd1619}':
                exit("{2c82cf3d-40b2-4fcc-8f04-e649dadd1619}Lbl");
            '{1f930cb5-93a8-4be9-b412-b9b44f1fbe2b}':
                exit("{1f930cb5-93a8-4be9-b412-b9b44f1fbe2b}Lbl");
            '{71177393-f102-466e-ac36-1a460bc1c3e9}':
                exit("{71177393-f102-466e-ac36-1a460bc1c3e9}Lbl");
            '{5fb236fb-7619-48a1-92d0-bd12f5c8a5c0}':
                exit("{5fb236fb-7619-48a1-92d0-bd12f5c8a5c0}Lbl");
            '{a030c0c9-951c-4818-8a68-c6d5917c31bf}':
                exit("{a030c0c9-951c-4818-8a68-c6d5917c31bf}Lbl");
            '{0bd7bb2e-38e6-4254-82cb-713f429d787c}':
                exit("{0bd7bb2e-38e6-4254-82cb-713f429d787c}Lbl");
            '{b66179f8-e62e-45f8-9de3-5351c859f85d}':
                exit("{b66179f8-e62e-45f8-9de3-5351c859f85d}Lbl");
            '{2f7b1f64-56f5-48c9-a6b2-a5f7f2bf8a2f}':
                exit("{2f7b1f64-56f5-48c9-a6b2-a5f7f2bf8a2f}Lbl");
            '{332a3e45-c1c8-423a-9063-b55efa585045}':
                exit("{332a3e45-c1c8-423a-9063-b55efa585045}Lbl");
            '{74e6e05f-641d-4857-8f88-c48783b29b3e}':
                exit("{74e6e05f-641d-4857-8f88-c48783b29b3e}Lbl");
        end;

        case CaseID of
            '{8a58255b-97c9-4691-9dbf-1c041d4433db}':
                exit("{8a58255b-97c9-4691-9dbf-1c041d4433db}Lbl");
            '{8ee30985-1662-4a16-b9b1-2c36589f4f94}':
                exit("{8ee30985-1662-4a16-b9b1-2c36589f4f94}Lbl");
            '{1dd024d8-c5d0-44dc-bd2e-3b4a395f33fe}':
                exit("{1dd024d8-c5d0-44dc-bd2e-3b4a395f33fe}Lbl");
            '{478e0789-2184-4644-8165-3b5169084277}':
                exit("{478e0789-2184-4644-8165-3b5169084277}Lbl");
            '{afccc11e-97b1-4627-8dfd-4184537e2509}':
                exit("{afccc11e-97b1-4627-8dfd-4184537e2509}Lbl");
            '{66a099c8-9660-498e-9beb-61296a76cfaf}':
                exit("{66a099c8-9660-498e-9beb-61296a76cfaf}Lbl");
            '{8b96f1e1-fc2c-48fd-ad1e-62986961ac0d}':
                exit("{8b96f1e1-fc2c-48fd-ad1e-62986961ac0d}Lbl");
            '{cce6e98e-5330-48ba-b42e-70e2bde3e45b}':
                exit("{cce6e98e-5330-48ba-b42e-70e2bde3e45b}Lbl");
            '{718c2339-648b-4fc6-a496-737b12176d01}':
                exit("{718c2339-648b-4fc6-a496-737b12176d01}Lbl");
            '{0abf122d-4ed5-4820-8411-7c39147b2819}':
                exit("{0abf122d-4ed5-4820-8411-7c39147b2819}Lbl");
        end;

        case CaseID of
            '{fcc8aa84-e16b-4d3f-a139-946089738fb0}':
                exit("{fcc8aa84-e16b-4d3f-a139-946089738fb0}Lbl");
            '{e365b9af-953a-462b-a562-9b494d0b84b9}':
                exit("{e365b9af-953a-462b-a562-9b494d0b84b9}Lbl");
            '{e6b10245-e536-41cf-a9cc-aa043113f6f4}':
                exit("{e6b10245-e536-41cf-a9cc-aa043113f6f4}Lbl");
            '{666a5198-99ba-4ec0-a89a-c991109bbc0f}':
                exit("{666a5198-99ba-4ec0-a89a-c991109bbc0f}Lbl");
            '{679f358f-4db0-4587-9f0c-ce643b16a152}':
                exit("{679f358f-4db0-4587-9f0c-ce643b16a152}Lbl");
            '{e246f7fe-de34-4e3c-bd3b-d8943d9b966c}':
                exit("{e246f7fe-de34-4e3c-bd3b-d8943d9b966c}Lbl");
            '{4fa8a9f3-d8c5-4b20-acb0-f52bfe013a01}':
                exit("{4fa8a9f3-d8c5-4b20-acb0-f52bfe013a01}Lbl");
            '{cd837506-8d55-4e71-8576-fa6b9934a6bb}':
                exit("{cd837506-8d55-4e71-8576-fa6b9934a6bb}Lbl");
            '{2a0e0c4e-331f-42b3-96d2-f9cff01e6fc1}':
                exit("{2a0e0c4e-331f-42b3-96d2-f9cff01e6fc1}Lbl");
            '{c4dd33b4-d4db-4f30-8c86-e2045b473c57}':
                exit("{c4dd33b4-d4db-4f30-8c86-e2045b473c57}Lbl");
        end;

        case CaseID of
            '{bfb5b4f3-bbc1-4a5b-9b7c-c3572578cd78}':
                exit("{bfb5b4f3-bbc1-4a5b-9b7c-c3572578cd78}Lbl");
            '{38f58d78-84d4-40d9-be77-cd33c02b49af}':
                exit("{38f58d78-84d4-40d9-be77-cd33c02b49af}Lbl");
            '{38583b1e-682c-4b06-bb69-005849014e82}':
                exit("{38583b1e-682c-4b06-bb69-005849014e82}Lbl");
            '{0e9f08c2-7cf2-4ac1-afb4-57ac8383e732}':
                exit("{0e9f08c2-7cf2-4ac1-afb4-57ac8383e732}Lbl");
            '{3a542488-e9a7-41e5-bf0b-c73f9c82a8db}':
                exit("{3a542488-e9a7-41e5-bf0b-c73f9c82a8db}Lbl");
            '{c85088e3-672f-4f2e-b1ef-19cbdfa5460b}':
                exit("{c85088e3-672f-4f2e-b1ef-19cbdfa5460b}Lbl");
            '{d2457d2f-2b0e-4f56-bf93-007e245c4ff8}':
                exit("{d2457d2f-2b0e-4f56-bf93-007e245c4ff8}Lbl");
            '{6a0a47a2-4a0f-4ccd-ac63-a70c76e05091}':
                exit("{6a0a47a2-4a0f-4ccd-ac63-a70c76e05091}Lbl");
            '{e5053eeb-44d1-4552-8084-67d72a90cecb}':
                exit("{e5053eeb-44d1-4552-8084-67d72a90cecb}Lbl");
            '{1eb264e9-24dd-43ec-a17f-e623bf565203}':
                exit("{1eb264e9-24dd-43ec-a17f-e623bf565203}Lbl");
        end;

        case CaseID of
            '{03418ffd-0af9-48f5-a500-ec48bf9de4e5}':
                exit("{03418ffd-0af9-48f5-a500-ec48bf9de4e5}Lbl");
            '{da3fc765-67aa-4232-8c30-6ce3e6e6dfdc}':
                exit("{da3fc765-67aa-4232-8c30-6ce3e6e6dfdc}Lbl");
            '{714e77d3-c569-418a-a932-dbff272d3b92}':
                exit("{714e77d3-c569-418a-a932-dbff272d3b92}Lbl");
            '{d50e350f-963c-4c3c-9e78-08f12ab7d8f0}':
                exit("{d50e350f-963c-4c3c-9e78-08f12ab7d8f0}Lbl");
            '{ffcc9396-d3c4-4a81-bde8-23070bf8976f}':
                exit("{ffcc9396-d3c4-4a81-bde8-23070bf8976f}Lbl");
            '{21e3248f-92c2-444c-b7e9-b48218ad918a}':
                exit("{21e3248f-92c2-444c-b7e9-b48218ad918a}Lbl");
            '{1988b611-abd4-44c4-9cb5-67bb88e0002c}':
                exit("{1988b611-abd4-44c4-9cb5-67bb88e0002c}Lbl");
            '{700cf31e-e4a1-4183-aef6-7c572c34c8ad}':
                exit("{700cf31e-e4a1-4183-aef6-7c572c34c8ad}Lbl");
            '{13352a4d-eeab-4fea-a778-0bdad73b550c}':
                exit("{13352a4d-eeab-4fea-a778-0bdad73b550c}Lbl");
            '{07ac553c-0e84-41e3-b04a-19b63c3bcf75}':
                exit("{07ac553c-0e84-41e3-b04a-19b63c3bcf75}Lbl");
            '{2bf5b2fe-2191-416d-b63f-47052716fc1b}':
                exit("{2bf5b2fe-2191-416d-b63f-47052716fc1b}Lbl");
            '{df5e22a4-bd3c-4c80-b6d3-9f667c8037dd}':
                exit("{df5e22a4-bd3c-4c80-b6d3-9f667c8037dd}Lbl");
            '{8fcf5988-06c7-44e2-a7bd-a5a9b40cdef8}':
                exit("{8fcf5988-06c7-44e2-a7bd-a5a9b40cdef8}Lbl");
            '{67fecb97-a3fa-4fc9-8a80-e214c3df4ca9}':
                exit("{67fecb97-a3fa-4fc9-8a80-e214c3df4ca9}Lbl");
        end;

        case CaseID of
            '{b8a8c947-5ba0-45b4-b8a4-33088f25782f}':
                exit("{b8a8c947-5ba0-45b4-b8a4-33088f25782f}Lbl");
            '{1A135F44-7A65-49A6-A08A-C87D453E5837}':
                exit("{1A135F44-7A65-49A6-A08A-C87D453E5837}Lbl");
            '{d9172942-78eb-4305-950c-c9dec70f16e6}':
                exit("{d9172942-78eb-4305-950c-c9dec70f16e6}Lbl");
            '{9d6c4ac2-81d1-47e7-8c7c-494f20f1719f}':
                exit("{9d6c4ac2-81d1-47e7-8c7c-494f20f1719f}Lbl");
            '{9cbcec6f-a01b-422b-8aab-4b6bc90ec959}':
                exit("{9cbcec6f-a01b-422b-8aab-4b6bc90ec959}Lbl");
            '{bfcc5c7f-f391-44d5-84f1-1d72dc7a9dec}':
                exit("{bfcc5c7f-f391-44d5-84f1-1d72dc7a9dec}Lbl");
            '{b95176d6-58ff-487c-a25b-26e433d85356}':
                exit("{b95176d6-58ff-487c-a25b-26e433d85356}Lbl");
            '{13e5d66f-422b-4830-992b-39c740d6d560}':
                exit("{13e5d66f-422b-4830-992b-39c740d6d560}Lbl");
            '{8e537871-c8f7-4e07-8b32-84411c668443}':
                exit("{8e537871-c8f7-4e07-8b32-84411c668443}Lbl");
            '{bc9a772f-dbf9-4f4f-8607-212dc829c005}':
                exit("{bc9a772f-dbf9-4f4f-8607-212dc829c005}Lbl");
        end;

        case CaseID of
            '{d7a29410-a685-41b6-a8f9-268d65f062b6}':
                exit("{d7a29410-a685-41b6-a8f9-268d65f062b6}Lbl");
            '{4dc1d2dc-a8f8-4443-a563-348b8e8961c1}':
                exit("{4dc1d2dc-a8f8-4443-a563-348b8e8961c1}Lbl");
            '{85dae7d1-95ac-4fd1-b1e0-5ffd980481bf}':
                exit("{85dae7d1-95ac-4fd1-b1e0-5ffd980481bf}Lbl");
            '{0e1a782b-cf1f-4cf0-8797-a1310519b1db}':
                exit("{0e1a782b-cf1f-4cf0-8797-a1310519b1db}Lbl");
            '{05312e80-be4e-4eb1-9a1e-af55ea4d8e3d}':
                exit("{05312e80-be4e-4eb1-9a1e-af55ea4d8e3d}Lbl");
            '{55b6317f-25f3-4c73-8aa5-afa3ec519c88}':
                exit("{55b6317f-25f3-4c73-8aa5-afa3ec519c88}Lbl");
            '{3e14881b-db97-473e-9a0b-c8a0a2d604c1}':
                exit("{3e14881b-db97-473e-9a0b-c8a0a2d604c1}Lbl");
            '{0cf4326b-fd68-4ae6-b52a-cd2aa2f2a788}':
                exit("{0cf4326b-fd68-4ae6-b52a-cd2aa2f2a788}Lbl");
            '{d2c0bc32-d71c-4fec-a3fc-63a0586da3d6}':
                exit("{d2c0bc32-d71c-4fec-a3fc-63a0586da3d6}Lbl");
            '{0410bc8a-0231-4947-8ed6-982a68846120}':
                exit("{0410bc8a-0231-4947-8ed6-982a68846120}Lbl");
            '{8e20fc81-1137-41b3-a90e-ae86cd66f718}':
                exit("{8e20fc81-1137-41b3-a90e-ae86cd66f718}Lbl");
            '{3277542b-b49c-4ccd-b661-f72c71ced698}':
                exit("{3277542b-b49c-4ccd-b661-f72c71ced698}Lbl");
        end;

        case CaseID of
            '{1bae51d1-ad26-40f8-bfd2-156024a23a7b}':
                exit("{1bae51d1-ad26-40f8-bfd2-156024a23a7b}Lbl");
            '{364eaba8-df5d-4174-951e-9c9b375830d6}':
                exit("{364eaba8-df5d-4174-951e-9c9b375830d6}Lbl");
            '{62275f50-6f85-4ea6-aa4f-0bacf20cf65e}':
                exit("{62275f50-6f85-4ea6-aa4f-0bacf20cf65e}Lbl");
            '{ab179237-ef7c-4bb1-9406-46b7b6dd1449}':
                exit("{ab179237-ef7c-4bb1-9406-46b7b6dd1449}Lbl");
            '{8df66c94-890c-4007-9341-18d0565000fe}':
                exit("{8df66c94-890c-4007-9341-18d0565000fe}Lbl");
            '{DF167294-5878-44C6-9220-01D93BEA09FF}':
                exit("{DF167294-5878-44C6-9220-01D93BEA09FF}Lbl");
            '{89071509-bf13-4ed5-a45d-8d938dfef265}':
                exit("{89071509-bf13-4ed5-a45d-8d938dfef265}Lbl");
            '{7bdd3ee0-29ae-4c15-a879-1dbf13ada019}':
                exit("{7bdd3ee0-29ae-4c15-a879-1dbf13ada019}Lbl");
            '{fbedc063-63ea-4fed-a3dd-8b5e175031cd}':
                exit("{fbedc063-63ea-4fed-a3dd-8b5e175031cd}Lbl");
            '{055aee33-1301-4b59-ba0d-e76d2d542b34}':
                exit("{055aee33-1301-4b59-ba0d-e76d2d542b34}Lbl");
            '{d279be29-1cb8-4f96-ba2c-0348368d0879}':
                exit("{d279be29-1cb8-4f96-ba2c-0348368d0879}Lbl");
            '{f4f11b85-700b-4880-9a73-740ff36c4160}':
                exit("{f4f11b85-700b-4880-9a73-740ff36c4160}Lbl");
            '{ce65aeff-0248-437e-b8a6-87c60e49efd4}':
                exit("{ce65aeff-0248-437e-b8a6-87c60e49efd4}Lbl");
            '{0ebd8b25-3c27-46ae-8cd7-4e870db1315b}':
                exit("{0ebd8b25-3c27-46ae-8cd7-4e870db1315b}Lbl");
            '{97437c0c-3e99-4d15-9378-34ac4b8fd002}':
                exit("{97437c0c-3e99-4d15-9378-34ac4b8fd002}Lbl");
        end;

        Handled := false;
    end;
}
