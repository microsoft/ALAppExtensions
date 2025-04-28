#pragma warning disable AA0247
codeunit 31188 "Create FA Ext. Post. Group CZF"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoFixedAssetCZF: Codeunit "Contoso Fixed Asset CZF";
        CreateFAPostingGroup: Codeunit "Create FA Posting Group";
        CreateFAPostingGroupCZ: Codeunit "Create FA Posting Group CZ";
        CreateReasonCodeCZ: Codeunit "Create Reason Code CZ";
        CreateFAMaintenance: Codeunit "Create FA Maintenance";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateGLAccountCZ: Codeunit "Create G/L Account CZ";
    begin
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroup.Property(), "FA Extended Posting Type CZF"::Disposal, CreateReasonCodeCZ.Liquid(),
            CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), '', '', '');
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroup.Property(), "FA Extended Posting Type CZF"::Disposal, CreateReasonCodeCZ.Sale(),
            CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(),
            CreateGLAccountCZ.SalesFixedAssets(), CreateGLAccountCZ.SalesFixedAssets(), '');
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroup.Property(), "FA Extended Posting Type CZF"::Maintenance, CreateFAMaintenance.Service(),
            '', '', '', '', CreateGLAccount.RepairsandMaintenance());
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroup.Property(), "FA Extended Posting Type CZF"::Maintenance, CreateFAMaintenance.SpareParts(),
            '', '', '', '', CreateGLAccountCZ.ConsumptionOfMaterial());

        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroup.Goodwill(), "FA Extended Posting Type CZF"::Disposal, CreateReasonCodeCZ.Liquid(),
            CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), '', '', '');
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroup.Goodwill(), "FA Extended Posting Type CZF"::Disposal, CreateReasonCodeCZ.Sale(),
            CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(),
            CreateGLAccountCZ.SalesFixedAssets(), CreateGLAccountCZ.SalesFixedAssets(), '');
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroup.Goodwill(), "FA Extended Posting Type CZF"::Maintenance, CreateFAMaintenance.Service(),
            '', '', '', '', CreateGLAccount.RepairsandMaintenance());
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroup.Goodwill(), "FA Extended Posting Type CZF"::Maintenance, CreateFAMaintenance.SpareParts(),
            '', '', '', '', CreateGLAccountCZ.ConsumptionOfMaterial());

        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroup.Vehicles(), "FA Extended Posting Type CZF"::Disposal, CreateReasonCodeCZ.Liquid(),
            CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), '', '', '');
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroup.Vehicles(), "FA Extended Posting Type CZF"::Disposal, CreateReasonCodeCZ.Sale(),
            CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(),
            CreateGLAccountCZ.SalesFixedAssets(), CreateGLAccountCZ.SalesFixedAssets(), '');
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroup.Vehicles(), "FA Extended Posting Type CZF"::Maintenance, CreateFAMaintenance.Service(),
            '', '', '', '', CreateGLAccount.RepairsandMaintenance());
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroup.Vehicles(), "FA Extended Posting Type CZF"::Maintenance, CreateFAMaintenance.SpareParts(),
            '', '', '', '', CreateGLAccountCZ.ConsumptionOfMaterial());

        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroup.Equipment(), "FA Extended Posting Type CZF"::Disposal, CreateReasonCodeCZ.Liquid(),
            CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), '', '', '');
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroup.Equipment(), "FA Extended Posting Type CZF"::Disposal, CreateReasonCodeCZ.Sale(),
            CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(),
            CreateGLAccountCZ.SalesFixedAssets(), CreateGLAccountCZ.SalesFixedAssets(), '');
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroup.Equipment(), "FA Extended Posting Type CZF"::Maintenance, CreateFAMaintenance.Service(),
            '', '', '', '', CreateGLAccount.RepairsandMaintenance());
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroup.Equipment(), "FA Extended Posting Type CZF"::Maintenance, CreateFAMaintenance.SpareParts(),
            '', '', '', '', CreateGLAccountCZ.ConsumptionOfMaterial());

        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroup.Plant(), "FA Extended Posting Type CZF"::Disposal, CreateReasonCodeCZ.Liquid(),
            CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), '', '', '');
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroup.Plant(), "FA Extended Posting Type CZF"::Disposal, CreateReasonCodeCZ.Sale(),
            CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(),
            CreateGLAccountCZ.SalesFixedAssets(), CreateGLAccountCZ.SalesFixedAssets(), '');
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroup.Plant(), "FA Extended Posting Type CZF"::Maintenance, CreateFAMaintenance.Service(),
            '', '', '', '', CreateGLAccount.RepairsandMaintenance());
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroup.Plant(), "FA Extended Posting Type CZF"::Maintenance, CreateFAMaintenance.SpareParts(),
            '', '', '', '', CreateGLAccountCZ.ConsumptionOfMaterial());

        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroupCZ.Furniture(), "FA Extended Posting Type CZF"::Disposal, CreateReasonCodeCZ.Liquid(),
            CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), '', '', '');
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroupCZ.Furniture(), "FA Extended Posting Type CZF"::Disposal, CreateReasonCodeCZ.Sale(),
            CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(),
            CreateGLAccountCZ.SalesFixedAssets(), CreateGLAccountCZ.SalesFixedAssets(), '');
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroupCZ.Furniture(), "FA Extended Posting Type CZF"::Maintenance, CreateFAMaintenance.Service(),
            '', '', '', '', CreateGLAccount.RepairsandMaintenance());
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroupCZ.Furniture(), "FA Extended Posting Type CZF"::Maintenance, CreateFAMaintenance.SpareParts(),
            '', '', '', '', CreateGLAccountCZ.ConsumptionOfMaterial());

        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroupCZ.Patents(), "FA Extended Posting Type CZF"::Disposal, CreateReasonCodeCZ.Liquid(),
            CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), '', '', '');
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroupCZ.Patents(), "FA Extended Posting Type CZF"::Disposal, CreateReasonCodeCZ.Sale(),
            CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(),
            CreateGLAccountCZ.SalesFixedAssets(), CreateGLAccountCZ.SalesFixedAssets(), '');
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroupCZ.Patents(), "FA Extended Posting Type CZF"::Maintenance, CreateFAMaintenance.Service(),
            '', '', '', '', CreateGLAccount.RepairsandMaintenance());
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroupCZ.Patents(), "FA Extended Posting Type CZF"::Maintenance, CreateFAMaintenance.SpareParts(),
            '', '', '', '', CreateGLAccountCZ.ConsumptionOfMaterial());

        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroupCZ.Software(), "FA Extended Posting Type CZF"::Disposal, CreateReasonCodeCZ.Liquid(),
            CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), '', '', '');
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroupCZ.Software(), "FA Extended Posting Type CZF"::Disposal, CreateReasonCodeCZ.Sale(),
            CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(),
            CreateGLAccountCZ.SalesFixedAssets(), CreateGLAccountCZ.SalesFixedAssets(), '');
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroupCZ.Software(), "FA Extended Posting Type CZF"::Maintenance, CreateFAMaintenance.Service(),
            '', '', '', '', CreateGLAccount.RepairsandMaintenance());
        ContosoFixedAssetCZF.InsertFAExtendedPostingGroup(
            CreateFAPostingGroupCZ.Software(), "FA Extended Posting Type CZF"::Maintenance, CreateFAMaintenance.SpareParts(),
            '', '', '', '', CreateGLAccountCZ.ConsumptionOfMaterial());
    end;
}
