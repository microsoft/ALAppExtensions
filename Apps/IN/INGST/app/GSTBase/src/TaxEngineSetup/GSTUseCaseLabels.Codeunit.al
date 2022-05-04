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

        Handled := false;
    end;
}