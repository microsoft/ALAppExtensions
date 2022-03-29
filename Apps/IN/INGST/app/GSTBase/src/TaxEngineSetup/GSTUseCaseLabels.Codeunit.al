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
        end;

        Handled := false;
    end;
}