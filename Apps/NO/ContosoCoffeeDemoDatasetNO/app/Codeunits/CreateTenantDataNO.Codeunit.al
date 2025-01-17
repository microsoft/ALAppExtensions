codeunit 10693 "Create Tenant Data NO"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Contoso Tenant Data", 'OnAfterCreateTenantData', '', false, false)]
    local procedure CreateTenantData()
    var
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        ContosoUtilities.InsertBLOBFromFile(SAFTMediaFolderLbl, 'General_Ledger_Standard_Accounts_2_character.xml');
        ContosoUtilities.InsertBLOBFromFile(SAFTMediaFolderLbl, 'General_Ledger_Standard_Accounts_4_character.xml');
        ContosoUtilities.InsertBLOBFromFile(SAFTMediaFolderLbl, 'KA_Grouping_Category_Code.xml');
        ContosoUtilities.InsertBLOBFromFile(SAFTMediaFolderLbl, 'RF-1167_Grouping_Category_Code.xml');
        ContosoUtilities.InsertBLOBFromFile(SAFTMediaFolderLbl, 'RF-1175_Grouping_Category_Code.xml');
        ContosoUtilities.InsertBLOBFromFile(SAFTMediaFolderLbl, 'RF-1323_Grouping_Category_Code.xml');
        ContosoUtilities.InsertBLOBFromFile(SAFTMediaFolderLbl, 'Standard_Tax_Codes.xml');
    end;

    var
        SAFTMediaFolderLbl: Label 'SAFTMedia/', Locked = true;
}