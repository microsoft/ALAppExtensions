codeunit 31213 "Fixed Asset Module CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure LocalizationFA(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
        CreateFAPostingGroup: Codeunit "Create FA Posting Group";
        FAGLAccount: Codeunit "Create FA GL Account";
        CreateFixedAsset: Codeunit "Create Fixed Asset";
        ContosoUtilities: Codeunit "Contoso Utilities";
        CreateFADepreciationBook: Codeunit "Create FA Depreciation Book";
        FAExtendedPostigType: Enum "FA Extended Posting Type CZF";
    begin
        if Module = Enum::"Contoso Demo Data Module"::"Fixed Asset Module" then begin
            if ContosoDemoDataLevel = Enum::"Contoso Demo Data Level"::"Setup Data" then begin
                ContosoFixedAsset.SetOverwriteData(true);

                InsertFAPostingGroup(CreateFAPostingGroup.Property(), AcquisitionCostBuildings(), FAGLAccount.AccumDepreciationBuildings(), WriteDownBuildings(), Custom2Buildings(), AcqCostonDisposalBuildings(), AccumDepronDisposalBuildings(), WriteDownonDisposalBuildings(), Custom2onDisposalBuildings(), GainsonDisposalBuildings(), LossesonDisposalBuildings(), BookValonDispGainBuildings(), BookValonDispLossBuildings(), SalesonDispGainBuildings(), SalesonDispLossBuildings(), MaintenanceExpenseBuildings(),
                                     DepreciationExpenseBuildings(), AcquisitionCostBalBuildings(), AcqusitionCostBalonDisposalBuildings(), ApprecBalonDispBuildings(), AppreciationonDisposalBuildings(), AppreciationBuildings(), AppreciationBalBuildings(), SalesBalBuildings(), BookValueBalonDisposalBuildings());

                InsertFAPostingGroup(CreateFAPostingGroup.Goodwill(), AcquisitionCostGoodwill(), AccumDepreciationGoodwill(), WriteDownGoodwill(), Custom2Goodwill(), AcqCostonDisposalGoodwill(), AccumDepronDisposalGoodwill(), WriteDownonDisposalGoodwill(), Custom2onDisposalGoodwill(), GainsonDisposalGoodwill(), LossesonDisposalGoodwill(), BookValonDispGainGoodwill(), BookValonDispLossGoodwill(), SalesonDispGainGoodwill(), SalesonDispLossGoodwill(), MaintenanceExpenseGoodwill(),
                                     DepreciationExpenseGoodwill(), AcquisitionCostBalGoodwill(), AcqusitionCostBalonDisposalGoodwill(), ApprecBalonDispGoodwill(), AppreciationonDisposalGoodwill(), AppreciationGoodwill(), AppreciationBalGoodwill(), SalesBalGoodwill(), BookValueBalonDisposalGoodwill());

                InsertFAPostingGroup(CreateFAPostingGroup.Vehicles(), AcquisitionCostVehicles(), AccumDepreciationVehicles(), WriteDownVehicles(), Custom2Vehicles(), AcqCostonDisposalVehicles(), AccumDepronDisposalVehicles(), WriteDownonDisposalVehicles(), Custom2onDisposalVehicles(), GainsonDisposalVehicles(), LossesonDisposalVehicles(), BookValonDispGainVehicles(), BookValonDispLossVehicles(), SalesonDispGainVehicles(), SalesonDispLossVehicles(), MaintenanceExpenseVehicles(),
                                     DepreciationExpenseVehicles(), AcquisitionCostBalVehicles(), AcqusitionCostBalonDisposalVehicles(), ApprecBalonDispVehicles(), AppreciationonDisposalVehicles(), AppreciationVehicles(), AppreciationBalVehicles(), SalesBalVehicles(), BookValueBalonDisposalVehicles());

                InsertFAPostingGroup(CreateFAPostingGroup.Equipment(), AcquisitionCostEquipment(), AccumDepreciationEquipment(), WriteDownEquipment(), Custom2Equipment(), AcqCostonDisposalEquipment(), AccumDepronDisposalEquipment(), WriteDownonDisposalEquipment(), Custom2onDisposalEquipment(), GainsonDisposalEquipment(), LossesonDisposalEquipment(), BookValonDispGainEquipment(), BookValonDispLossEquipment(), SalesonDispGainEquipment(), SalesonDispLossEquipment(), MaintenanceExpenseEquipment(),
                                     DepreciationExpenseEquipment(), AcquisitionCostBalEquipment(), AcqusitionCostBalonDisposalEquipment(), ApprecBalonDispEquipment(), AppreciationonDisposalEquipment(), AppreciationEquipment(), AppreciationBalEquipment(), SalesBalEquipment(), BookValueBalonDisposalEquipment());

                InsertFAPostingGroup(CreateFAPostingGroup.Plant(), AcquisitionCostBuildings(), FAGLAccount.AccumDepreciationBuildings(), WriteDownBuildings(), Custom2Buildings(), AcqCostonDisposalBuildings(), AccumDepronDisposalBuildings(), WriteDownonDisposalBuildings(), Custom2onDisposalBuildings(), GainsonDisposalBuildings(), LossesonDisposalBuildings(), BookValonDispGainBuildings(), BookValonDispLossBuildings(), SalesonDispGainBuildings(), SalesonDispLossBuildings(), MaintenanceExpenseBuildings(),
                                    DepreciationExpenseBuildings(), AcquisitionCostBalBuildings(), AcqusitionCostBalonDisposalBuildings(), ApprecBalonDispBuildings(), AppreciationonDisposalBuildings(), AppreciationBuildings(), AppreciationBalBuildings(), SalesBalBuildings(), BookValueBalonDisposalBuildings());

                InsertFAPostingGroup(Furniture(), AcquisitionCostEquipment(), AccumDepreciationEquipment(), WriteDownEquipment(), Custom2Equipment(), AcqCostonDisposalEquipment(), AccumDepronDisposalEquipment(), WriteDownonDisposalEquipment(), Custom2onDisposalEquipment(), GainsonDisposalEquipment(), LossesonDisposalEquipment(), BookValonDispGainEquipment(), BookValonDispLossEquipment(), SalesonDispGainEquipment(), SalesonDispLossEquipment(), MaintenanceExpenseEquipment(),
                                     DepreciationExpenseEquipment(), AcquisitionCostBalEquipment(), AcqusitionCostBalonDisposalEquipment(), ApprecBalonDispEquipment(), AppreciationonDisposalEquipment(), AppreciationEquipment(), AppreciationBalEquipment(), SalesBalEquipment(), BookValueBalonDisposalEquipment());

                InsertFAPostingGroup(Patents(), AcquisitionCostPatents(), AccumDepreciationPatents(), WriteDownPatents(), Custom2Patents(), AcqCostonDisposalPatents(), AccumDepronDisposalPatents(), WriteDownonDisposalPatents(), Custom2onDisposalPatents(), GainsonDisposalPatents(), LossesonDisposalPatents(), BookValonDispGainPatents(), BookValonDispLossPatents(), SalesonDispGainPatents(), SalesonDispLossPatents(), MaintenanceExpensePatents(),
                                     DepreciationExpensePatents(), AcquisitionCostBalPatents(), AcqusitionCostBalonDisposalPatents(), ApprecBalonDispPatents(), AppreciationonDisposalPatents(), AppreciationPatents(), AppreciationBalPatents(), SalesBalPatents(), BookValueBalonDisposalPatents());

                InsertFAPostingGroup(Software(), AcquisitionCostSoftware(), AccumDepreciationSoftware(), WriteDownSoftware(), Custom2Software(), AcqCostonDisposalSoftware(), AccumDepronDisposalSoftware(), WriteDownonDisposalSoftware(), Custom2onDisposalSoftware(), GainsonDisposalSoftware(), LossesonDisposalSoftware(), BookValonDispGainSoftware(), BookValonDispLossSoftware(), SalesonDispGainSoftware(), SalesonDispLossSoftware(), MaintenanceExpenseSoftware(),
                                     DepreciationExpenseSoftware(), AcquisitionCostBalSoftware(), AcqusitionCostBalonDisposalSoftware(), ApprecBalonDispSoftware(), AppreciationonDisposalSoftware(), AppreciationSoftware(), AppreciationBalSoftware(), SalesBalSoftware(), BookValueBalonDisposalSoftware());

                InsertReasonCode(LIQUID(), LIQUIDDescriptionLbl);
                InsertReasonCode(SALE(), SALEDescriptionLbl);
                ContosoFixedAsset.InsertMaintenance(SERVICE(), SERVICEDescriptionLbl);
                ContosoFixedAsset.InsertMaintenance(SPAREPARTS(), SPAREPARTSDescriptionLbl);

                InsertFAExtendedPostingGroup(CreateFAPostingGroup.Property(), FAExtendedPostigType::Disposal, Liquid(), GainsonDisposalBuildings(), LossesonDisposalBuildings(), '', '', '');
                InsertFAExtendedPostingGroup(CreateFAPostingGroup.Property(), FAExtendedPostigType::Disposal, Sale(), BookValonDispGainBuildings(), BookValonDispLossBuildings(), SalesFixedAssets(), SalesFixedAssets(), '');
                InsertFAExtendedPostingGroup(CreateFAPostingGroup.Property(), FAExtendedPostigType::Maintenance, Service(), '', '', '', '', MaintenanceExpenseBuildings());
                InsertFAExtendedPostingGroup(CreateFAPostingGroup.Property(), FAExtendedPostigType::Maintenance, SpareParts(), '', '', '', '', ConsumableMaterials());

                InsertFAExtendedPostingGroup(CreateFAPostingGroup.Goodwill(), FAExtendedPostigType::Disposal, Liquid(), GainsonDisposalGoodwill(), LossesonDisposalGoodwill(), '', '', '');
                InsertFAExtendedPostingGroup(CreateFAPostingGroup.Goodwill(), FAExtendedPostigType::Disposal, Sale(), BookValonDispGainGoodwill(), BookValonDispLossGoodwill(), SalesFixedAssets(), SalesFixedAssets(), '');
                InsertFAExtendedPostingGroup(CreateFAPostingGroup.Goodwill(), FAExtendedPostigType::Maintenance, Service(), '', '', '', '', MaintenanceExpenseGoodwill());
                InsertFAExtendedPostingGroup(CreateFAPostingGroup.Goodwill(), FAExtendedPostigType::Maintenance, SpareParts(), '', '', '', '', ConsumableMaterials());

                InsertFAExtendedPostingGroup(CreateFAPostingGroup.Vehicles(), FAExtendedPostigType::Disposal, Liquid(), GainsonDisposalVehicles(), LossesonDisposalVehicles(), '', '', '');
                InsertFAExtendedPostingGroup(CreateFAPostingGroup.Vehicles(), FAExtendedPostigType::Disposal, Sale(), BookValonDispGainVehicles(), BookValonDispLossVehicles(), SalesFixedAssets(), SalesFixedAssets(), '');
                InsertFAExtendedPostingGroup(CreateFAPostingGroup.Vehicles(), FAExtendedPostigType::Maintenance, Service(), '', '', '', '', MaintenanceExpenseVehicles());
                InsertFAExtendedPostingGroup(CreateFAPostingGroup.Vehicles(), FAExtendedPostigType::Maintenance, SpareParts(), '', '', '', '', ConsumableMaterials());

                InsertFAExtendedPostingGroup(CreateFAPostingGroup.Equipment(), FAExtendedPostigType::Disposal, Liquid(), GainsonDisposalEquipment(), LossesonDisposalEquipment(), '', '', '');
                InsertFAExtendedPostingGroup(CreateFAPostingGroup.Equipment(), FAExtendedPostigType::Disposal, Sale(), BookValonDispGainEquipment(), BookValonDispLossEquipment(), SalesFixedAssets(), SalesFixedAssets(), '');
                InsertFAExtendedPostingGroup(CreateFAPostingGroup.Equipment(), FAExtendedPostigType::Maintenance, Service(), '', '', '', '', MaintenanceExpenseEquipment());
                InsertFAExtendedPostingGroup(CreateFAPostingGroup.Equipment(), FAExtendedPostigType::Maintenance, SpareParts(), '', '', '', '', ConsumableMaterials());

                InsertFAExtendedPostingGroup(CreateFAPostingGroup.Plant(), FAExtendedPostigType::Disposal, Liquid(), GainsonDisposalBuildings(), LossesonDisposalBuildings(), '', '', '');
                InsertFAExtendedPostingGroup(CreateFAPostingGroup.Plant(), FAExtendedPostigType::Disposal, Sale(), BookValonDispGainBuildings(), BookValonDispLossBuildings(), SalesFixedAssets(), SalesFixedAssets(), '');
                InsertFAExtendedPostingGroup(CreateFAPostingGroup.Plant(), FAExtendedPostigType::Maintenance, Service(), '', '', '', '', MaintenanceExpenseBuildings());
                InsertFAExtendedPostingGroup(CreateFAPostingGroup.Plant(), FAExtendedPostigType::Maintenance, SpareParts(), '', '', '', '', ConsumableMaterials());

                InsertFAExtendedPostingGroup(Furniture(), FAExtendedPostigType::Disposal, Liquid(), GainsonDisposalEquipment(), LossesonDisposalEquipment(), '', '', '');
                InsertFAExtendedPostingGroup(Furniture(), FAExtendedPostigType::Disposal, Sale(), BookValonDispGainEquipment(), BookValonDispLossEquipment(), SalesFixedAssets(), SalesFixedAssets(), '');
                InsertFAExtendedPostingGroup(Furniture(), FAExtendedPostigType::Maintenance, Service(), '', '', '', '', MaintenanceExpenseEquipment());
                InsertFAExtendedPostingGroup(Furniture(), FAExtendedPostigType::Maintenance, SpareParts(), '', '', '', '', ConsumableMaterials());

                InsertFAExtendedPostingGroup(Patents(), FAExtendedPostigType::Disposal, Liquid(), GainsonDisposalPatents(), LossesonDisposalPatents(), '', '', '');
                InsertFAExtendedPostingGroup(Patents(), FAExtendedPostigType::Disposal, Sale(), BookValonDispGainPatents(), BookValonDispLossPatents(), SalesFixedAssets(), SalesFixedAssets(), '');
                InsertFAExtendedPostingGroup(Patents(), FAExtendedPostigType::Maintenance, Service(), '', '', '', '', MaintenanceExpensePatents());
                InsertFAExtendedPostingGroup(Patents(), FAExtendedPostigType::Maintenance, SpareParts(), '', '', '', '', ConsumableMaterials());

                InsertFAExtendedPostingGroup(Software(), FAExtendedPostigType::Disposal, Liquid(), GainsonDisposalSoftware(), LossesonDisposalSoftware(), '', '', '');
                InsertFAExtendedPostingGroup(Software(), FAExtendedPostigType::Disposal, Sale(), BookValonDispGainSoftware(), BookValonDispLossSoftware(), SalesFixedAssets(), SalesFixedAssets(), '');
                InsertFAExtendedPostingGroup(Software(), FAExtendedPostigType::Maintenance, Service(), '', '', '', '', MaintenanceExpenseSoftware());
                InsertFAExtendedPostingGroup(Software(), FAExtendedPostigType::Maintenance, SpareParts(), '', '', '', '', ConsumableMaterials());

                ContosoFixedAsset.SetOverwriteData(false);
            end;

            if ContosoDemoDataLevel = Enum::"Contoso Demo Data Level"::"Master Data" then begin
                ContosoFixedAsset.SetOverwriteData(true);

                ContosoFixedAsset.InsertDepreciationBook("1Account"(), AccountBookLbl, true, true, true, true, true, true, true, true, true, 10);
                ContosoFixedAsset.InsertDepreciationBook("2Tax"(), TaxBookLbl, true, true, true, true, true, true, true, true, true, 10);

                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000010(), "1Account"(), ContosoUtilities.AdjustDate(19020101D), 5);
                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000010(), "2Tax"(), ContosoUtilities.AdjustDate(19020101D), 5);
                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000010(), CreateFADepreciationBook.Company(), ContosoUtilities.AdjustDate(19020101D), 0);
                ClearFADepreciationBook(CreateFixedAsset.FA000010(), CreateFADepreciationBook.Company());

                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000020(), "1Account"(), ContosoUtilities.AdjustDate(19020501D), 5);
                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000020(), "2Tax"(), ContosoUtilities.AdjustDate(19020501D), 5);
                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000020(), CreateFADepreciationBook.Company(), ContosoUtilities.AdjustDate(19020501D), 0);
                ClearFADepreciationBook(CreateFixedAsset.FA000020(), CreateFADepreciationBook.Company());

                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000030(), "1Account"(), ContosoUtilities.AdjustDate(19020601D), 5);
                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000030(), "2Tax"(), ContosoUtilities.AdjustDate(19020601D), 5);
                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000030(), CreateFADepreciationBook.Company(), ContosoUtilities.AdjustDate(19020601D), 0);
                ClearFADepreciationBook(CreateFixedAsset.FA000030(), CreateFADepreciationBook.Company());

                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000040(), "1Account"(), ContosoUtilities.AdjustDate(19020101D), 0);
                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000040(), "2Tax"(), ContosoUtilities.AdjustDate(19020101D), 0);
                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000040(), CreateFADepreciationBook.Company(), ContosoUtilities.AdjustDate(19020101D), 0);
                ClearFADepreciationBook(CreateFixedAsset.FA000040(), CreateFADepreciationBook.Company());

                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000050(), "1Account"(), ContosoUtilities.AdjustDate(19020101D), 10);
                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000050(), "2Tax"(), ContosoUtilities.AdjustDate(19020101D), 10);
                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000050(), CreateFADepreciationBook.Company(), ContosoUtilities.AdjustDate(19020101D), 0);
                ClearFADepreciationBook(CreateFixedAsset.FA000050(), CreateFADepreciationBook.Company());

                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000060(), "1Account"(), ContosoUtilities.AdjustDate(19020201D), 8);
                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000060(), "2Tax"(), ContosoUtilities.AdjustDate(19020201D), 8);
                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000060(), CreateFADepreciationBook.Company(), ContosoUtilities.AdjustDate(19020201D), 0);
                ClearFADepreciationBook(CreateFixedAsset.FA000060(), CreateFADepreciationBook.Company());

                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000070(), "1Account"(), ContosoUtilities.AdjustDate(19020301D), 4);
                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000070(), "2Tax"(), ContosoUtilities.AdjustDate(19020301D), 4);
                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000070(), CreateFADepreciationBook.Company(), ContosoUtilities.AdjustDate(19020301D), 0);
                ClearFADepreciationBook(CreateFixedAsset.FA000070(), CreateFADepreciationBook.Company());

                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000080(), "1Account"(), ContosoUtilities.AdjustDate(19020401D), 8);
                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000080(), "2Tax"(), ContosoUtilities.AdjustDate(19020401D), 8);
                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000080(), CreateFADepreciationBook.Company(), ContosoUtilities.AdjustDate(19020401D), 0);
                ClearFADepreciationBook(CreateFixedAsset.FA000080(), CreateFADepreciationBook.Company());

                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000090(), "1Account"(), ContosoUtilities.AdjustDate(19020201D), 7);
                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000090(), "2Tax"(), ContosoUtilities.AdjustDate(19020201D), 7);
                ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000090(), CreateFADepreciationBook.Company(), ContosoUtilities.AdjustDate(19020201D), 0);
                ClearFADepreciationBook(CreateFixedAsset.FA000090(), CreateFADepreciationBook.Company());

                ContosoFixedAsset.SetOverwriteData(false);
            end;
        end;
    end;

    procedure InsertFAPostingGroup(GroupCode: Code[20]; AcquisitionCostAccount: Code[20]; AccumDepreciationAccount: Code[20]; WriteDownAccount: Code[20]; Custom2Account: Code[20]; AcqCostAccOnDisposal: Code[20]; AccumDeprAccOnDisposal: Code[20]; WriteDownAccOnDisposal: Code[20]; Custom2AccountOnDisposal: Code[20]; GainsAccOnDisposal: Code[20]; LossesAccOnDisposal: Code[20]; BookValAccOnDispGain: Code[20]; BookValAccOnDispLoss: Code[20];
                                   SalesAccOnDispGain: Code[20]; SalesAccOnDispLoss: Code[20]; MaintenanceExpenseAccount: Code[20]; DepreciationExpenseAcc: Code[20]; AcquisitionCostBalAcc: Code[20]; AcqCostBalAccDispCZF: Code[20]; ApprecBalAccOnDisp: Code[20]; AppreciationAccOnDisposal: Code[20]; AppreciationAccount: Code[20]; AppreciationBalAccount: Code[20]; SalesBalAcc: Code[20]; BookValueBalAccOnDisposal: Code[20])
    var
        FAPostingGroup: Record "FA Posting Group";
        Exists: Boolean;
    begin
        if FAPostingGroup.Get(GroupCode) then
            Exists := true;

        FAPostingGroup.Validate(Code, GroupCode);
        FAPostingGroup.Validate("Acquisition Cost Account", AcquisitionCostAccount);
        FAPostingGroup.Validate("Accum. Depreciation Account", AccumDepreciationAccount);
        FAPostingGroup.Validate("Write-Down Account", WriteDownAccount);
        FAPostingGroup.Validate("Custom 2 Account", Custom2Account);
        FAPostingGroup.Validate("Acq. Cost Acc. on Disposal", AcqCostAccOnDisposal);
        FAPostingGroup.Validate("Accum. Depr. Acc. on Disposal", AccumDeprAccOnDisposal);
        FAPostingGroup.Validate("Write-Down Acc. on Disposal", WriteDownAccOnDisposal);
        FAPostingGroup.Validate("Custom 2 Account on Disposal", Custom2AccountOnDisposal);
        FAPostingGroup.Validate("Gains Acc. on Disposal", GainsAccOnDisposal);
        FAPostingGroup.Validate("Losses Acc. on Disposal", LossesAccOnDisposal);
        FAPostingGroup.Validate("Book Val. Acc. on Disp. (Gain)", BookValAccOnDispGain);
        FAPostingGroup.Validate("Book Val. Acc. on Disp. (Loss)", BookValAccOnDispLoss);
        FAPostingGroup.Validate("Sales Acc. on Disp. (Gain)", SalesAccOnDispGain);
        FAPostingGroup.Validate("Sales Acc. on Disp. (Loss)", SalesAccOnDispLoss);
        FAPostingGroup.Validate("Maintenance Expense Account", MaintenanceExpenseAccount);
        FAPostingGroup.Validate("Depreciation Expense Acc.", DepreciationExpenseAcc);
        FAPostingGroup.Validate("Acquisition Cost Bal. Acc.", AcquisitionCostBalAcc);
        FAPostingGroup.Validate("Acq. Cost Bal. Acc. Disp. CZF", AcqCostBalAccDispCZF);
        FAPostingGroup.Validate("Apprec. Bal. Acc. on Disp.", ApprecBalAccOnDisp);
        FAPostingGroup.Validate("Appreciation Acc. on Disposal", AppreciationAccOnDisposal);
        FAPostingGroup.Validate("Appreciation Account", AppreciationAccount);
        FAPostingGroup.Validate("Appreciation Bal. Account", AppreciationBalAccount);
        FAPostingGroup.Validate("Sales Bal. Acc.", SalesBalAcc);
        FAPostingGroup.Validate("Book Value Bal. Acc. Disp. CZF", BookValueBalAccOnDisposal);

        if Exists then
            FAPostingGroup.Modify(true)
        else
            FAPostingGroup.Insert(true);
    end;

    local procedure InsertReasonCode(Code: Code[20]; Description: Text[100])
    var
        ReasonCode: Record "Reason Code";
        Exists: Boolean;
    begin
        if ReasonCode.Get(Code) then
            Exists := true;

        ReasonCode.Validate(Code, Code);
        ReasonCode.Validate("Description", Description);

        if Exists then
            ReasonCode.Modify(true)
        else
            ReasonCode.Insert(true);
    end;


    local procedure InsertFAExtendedPostingGroup(GroupCode: Code[20]; FAExtendedPostigType: Enum "FA Extended Posting Type CZF"; Code: Code[20]; BookValAccOnDispGain: Code[20]; BookValAccOnDispLoss: Code[20]; SalesAccOnDispGain: Code[20]; SalesAccOnDispLoss: Code[20]; MaintenanceExpenseAccount: Code[20])
    var
        FAExtendedPosingGroupCZF: Record "FA Extended Posting Group CZF";
        Exists: Boolean;
    begin
        if FAExtendedPosingGroupCZF.Get(Code, FAExtendedPostigType, GroupCode) then
            Exists := true;

        FAExtendedPosingGroupCZF.Validate("FA Posting Group Code", GroupCode);
        FAExtendedPosingGroupCZF.Validate("FA Posting Type", FAExtendedPostigType);
        FAExtendedPosingGroupCZF.Validate(Code, Code);
        FAExtendedPosingGroupCZF.Validate("Book Val. Acc. on Disp. (Gain)", BookValAccOnDispGain);
        FAExtendedPosingGroupCZF.Validate("Book Val. Acc. on Disp. (Loss)", BookValAccOnDispLoss);
        FAExtendedPosingGroupCZF.Validate("Sales Acc. on Disp. (Gain)", SalesAccOnDispGain);
        FAExtendedPosingGroupCZF.Validate("Sales Acc. on Disp. (Loss)", SalesAccOnDispLoss);
        FAExtendedPosingGroupCZF.Validate("Maintenance Expense Account", MaintenanceExpenseAccount);

        if Exists then
            FAExtendedPosingGroupCZF.Modify(true)
        else
            FAExtendedPosingGroupCZF.Insert(true);
    end;

    local procedure ClearFADepreciationBook(FixedAssetNo: Code[20]; DepreciationBookCode: Code[10])
    var
        FADepreciationBook: Record "FA Depreciation Book";
    begin
        FADepreciationBook.Get(FixedAssetNo, DepreciationBookCode);
        FADepreciationBook.Validate("Depreciation Starting Date", 0D);
        FADepreciationBook.Modify(true);
    end;

    procedure Furniture(): Code[20]
    begin
        exit(FurnitureLbl);
    end;

    procedure Patents(): Code[20]
    begin
        exit(PatentsLbl);
    end;

    procedure Software(): Code[20]
    begin
        exit(SoftwareLbl);
    end;

    procedure AcquisitionCostBuildingsName(): Text[100]
    begin
        exit(BuildingsLbl);
    end;

    procedure AcquisitionCostBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionCostBuildingsName()));
    end;

    procedure WriteDownBuildingsName(): Text[100]
    begin
        exit(BuildingsLbl);
    end;

    procedure WriteDownBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WriteDownBuildingsName()));
    end;

    procedure Custom2BuildingsName(): Text[100]
    begin
        exit(AcquisitionofbuildingsLbl);
    end;

    procedure Custom2Buildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Custom2BuildingsName()));
    end;

    procedure AcqCostonDisposalBuildingsName(): Text[100]
    begin
        exit(BuildingsLbl);
    end;

    procedure AcqCostonDisposalBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcqCostonDisposalBuildingsName()));
    end;

    procedure AccumDepronDisposalBuildingsName(): Text[100]
    begin
        exit(AccumulateddepreciationofbuildingsLbl);
    end;

    procedure AccumDepronDisposalBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumDepronDisposalBuildingsName()));
    end;

    procedure WriteDownonDisposalBuildingsName(): Text[100]
    begin
        exit(BuildingsLbl);
    end;

    procedure WriteDownonDisposalBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WriteDownonDisposalBuildingsName()));
    end;

    procedure Custom2onDisposalBuildingsName(): Text[100]
    begin
        exit(AcquisitionofbuildingsLbl);
    end;

    procedure Custom2onDisposalBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Custom2onDisposalBuildingsName()));
    end;

    procedure GainsonDisposalBuildingsName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetsdisposedLbl);
    end;

    procedure GainsonDisposalBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GainsonDisposalBuildingsName()));
    end;

    procedure LossesonDisposalBuildingsName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetsdisposedLbl);
    end;

    procedure LossesonDisposalBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LossesonDisposalBuildingsName()));
    end;

    procedure BookValonDispGainBuildingsName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetssoldLbl);
    end;

    procedure BookValonDispGainBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BookValonDispGainBuildingsName()));
    end;

    procedure BookValonDispLossBuildingsName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetssoldLbl);
    end;

    procedure BookValonDispLossBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BookValonDispLossBuildingsName()));
    end;

    procedure SalesonDispGainBuildingsName(): Text[100]
    begin
        exit(AccumulateddepreciationofbuildingsLbl);
    end;

    procedure SalesonDispGainBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesonDispGainBuildingsName()));
    end;

    procedure SalesonDispLossBuildingsName(): Text[100]
    begin
        exit(AccumulateddepreciationofbuildingsLbl);
    end;

    procedure SalesonDispLossBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesonDispLossBuildingsName()));
    end;

    procedure MaintenanceExpenseBuildingsName(): Text[100]
    begin
        exit(RepairsandMaintenanceLbl);
    end;

    procedure MaintenanceExpenseBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaintenanceExpenseBuildingsName()));
    end;

    procedure AcquisitionCostBalBuildingsName(): Text[100]
    begin
        exit(AcquisitionofbuildingsLbl);
    end;

    procedure AcquisitionCostBalBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionCostBalBuildingsName()));
    end;

    procedure DepreciationExpenseBuildingsName(): Text[100]
    begin
        exit(RepairsandMaintenanceLbl);
    end;

    procedure DepreciationExpenseBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationExpenseBuildingsName()));
    end;

    procedure AcqusitionCostBalonDisposalBuildingsName(): Text[100]
    begin
        exit(AccumulateddepreciationofbuildingsLbl);
    end;

    procedure AcqusitionCostBalonDisposalBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcqusitionCostBalonDisposalBuildingsName()));
    end;

    procedure ApprecBalonDispBuildingsName(): Text[100]
    begin
        exit(AccumulateddepreciationofbuildingsLbl);
    end;

    procedure ApprecBalonDispBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ApprecBalonDispBuildingsName()));
    end;

    procedure AppreciationonDisposalBuildingsName(): Text[100]
    begin
        exit(BuildingsLbl);
    end;

    procedure AppreciationonDisposalBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AppreciationonDisposalBuildingsName()));
    end;

    procedure AppreciationBuildingsName(): Text[100]
    begin
        exit(BuildingsLbl);
    end;

    procedure AppreciationBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AppreciationBuildingsName()));
    end;

    procedure AppreciationBalBuildingsName(): Text[100]
    begin
        exit(AcquisitionofbuildingsLbl);
    end;

    procedure AppreciationBalBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AppreciationBalBuildingsName()));
    end;

    procedure SalesBalBuildingsName(): Text[100]
    begin
        exit(InternalsettlementLbl);
    end;

    procedure SalesBalBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesBalBuildingsName()));
    end;

    procedure BookValueBalonDisposalBuildingsName(): Text[100]
    begin
        exit(AccumulateddepreciationofbuildingsLbl);
    end;

    procedure BookValueBalonDisposalBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BookValueBalonDisposalBuildingsName()));
    end;

    procedure AcquisitionCostGoodwillName(): Text[100]
    begin
        exit(GoodwillLbl);
    end;

    procedure AcquisitionCostGoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionCostGoodwillName()));
    end;

    procedure WriteDownGoodwillName(): Text[100]
    begin
        exit(GoodwillLbl);
    end;

    procedure WriteDownGoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WriteDownGoodwillName()));
    end;

    procedure AccumDepreciationGoodwillName(): Text[100]
    begin
        exit(CorrectionstogoodwillLbl);
    end;

    procedure AccumDepreciationGoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumDepreciationGoodwillName()));
    end;

    procedure Custom2GoodwillName(): Text[100]
    begin
        exit(AcquisitionofintangiblefixedassetsLbl);
    end;

    procedure Custom2Goodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Custom2GoodwillName()));
    end;

    procedure AcqCostonDisposalGoodwillName(): Text[100]
    begin
        exit(GoodwillLbl);
    end;

    procedure AcqCostonDisposalGoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcqCostonDisposalGoodwillName()));
    end;

    procedure AccumDepronDisposalGoodwillName(): Text[100]
    begin
        exit(CorrectionstogoodwillLbl);
    end;

    procedure AccumDepronDisposalGoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumDepronDisposalGoodwillName()));
    end;

    procedure WriteDownonDisposalGoodwillName(): Text[100]
    begin
        exit(GoodwillLbl);
    end;

    procedure WriteDownonDisposalGoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WriteDownonDisposalGoodwillName()));
    end;

    procedure Custom2onDisposalGoodwillName(): Text[100]
    begin
        exit(AcquisitionofintangiblefixedassetsLbl);
    end;

    procedure Custom2onDisposalGoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Custom2onDisposalGoodwillName()));
    end;

    procedure GainsonDisposalGoodwillName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetsdisposedLbl);
    end;

    procedure GainsonDisposalGoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GainsonDisposalGoodwillName()));
    end;

    procedure LossesonDisposalGoodwillName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetsdisposedLbl);
    end;

    procedure LossesonDisposalGoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LossesonDisposalGoodwillName()));
    end;

    procedure BookValonDispGainGoodwillName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetssoldLbl);
    end;

    procedure BookValonDispGainGoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BookValonDispGainGoodwillName()));
    end;

    procedure BookValonDispLossGoodwillName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetssoldLbl);
    end;

    procedure BookValonDispLossGoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BookValonDispLossGoodwillName()));
    end;

    procedure SalesonDispGainGoodwillName(): Text[100]
    begin
        exit(CorrectionstogoodwillLbl);
    end;

    procedure SalesonDispGainGoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesonDispGainGoodwillName()));
    end;

    procedure SalesonDispLossGoodwillName(): Text[100]
    begin
        exit(CorrectionstogoodwillLbl);
    end;

    procedure SalesonDispLossGoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesonDispLossGoodwillName()));
    end;

    procedure MaintenanceExpenseGoodwillName(): Text[100]
    begin
        exit(RepairsandMaintenanceLbl);
    end;

    procedure MaintenanceExpenseGoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaintenanceExpenseGoodwillName()));
    end;

    procedure AcquisitionCostBalGoodwillName(): Text[100]
    begin
        exit(AcquisitionofintangiblefixedassetsLbl);
    end;

    procedure AcquisitionCostBalGoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionCostBalGoodwillName()));
    end;

    procedure DepreciationExpenseGoodwillName(): Text[100]
    begin
        exit(DeprecationofotherintangiblefixedassetsLbl);
    end;

    procedure DepreciationExpenseGoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationExpenseGoodwillName()));
    end;

    procedure AcqusitionCostBalonDisposalGoodwillName(): Text[100]
    begin
        exit(CorrectionstogoodwillLbl);
    end;

    procedure AcqusitionCostBalonDisposalGoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcqusitionCostBalonDisposalGoodwillName()));
    end;

    procedure ApprecBalonDispGoodwillName(): Text[100]
    begin
        exit(CorrectionstogoodwillLbl);
    end;

    procedure ApprecBalonDispGoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ApprecBalonDispGoodwillName()));
    end;

    procedure AppreciationonDisposalGoodwillName(): Text[100]
    begin
        exit(GoodwillLbl);
    end;

    procedure AppreciationonDisposalGoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AppreciationonDisposalGoodwillName()));
    end;

    procedure AppreciationGoodwillName(): Text[100]
    begin
        exit(GoodwillLbl);
    end;

    procedure AppreciationGoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AppreciationGoodwillName()));
    end;

    procedure AppreciationBalGoodwillName(): Text[100]
    begin
        exit(AcquisitionofintangiblefixedassetsLbl);
    end;

    procedure AppreciationBalGoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AppreciationBalGoodwillName()));
    end;

    procedure SalesBalGoodwillName(): Text[100]
    begin
        exit(InternalsettlementLbl);
    end;

    procedure SalesBalGoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesBalGoodwillName()));
    end;

    procedure BookValueBalonDisposalGoodwillName(): Text[100]
    begin
        exit(CorrectionstogoodwillLbl);
    end;

    procedure BookValueBalonDisposalGoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BookValueBalonDisposalGoodwillName()));
    end;

    procedure AcquisitionCostVehiclesName(): Text[100]
    begin
        exit(VehiclesLbl);
    end;

    procedure AcquisitionCostVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionCostVehiclesName()));
    end;

    procedure AccumDepreciationVehiclesName(): Text[100]
    begin
        exit(AccumulateddepreciationofvehiclesLbl);
    end;

    procedure AccumDepreciationVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumDepreciationVehiclesName()));
    end;


    procedure WriteDownVehiclesName(): Text[100]
    begin
        exit(VehiclesLbl);
    end;

    procedure WriteDownVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WriteDownVehiclesName()));
    end;

    procedure Custom2VehiclesName(): Text[100]
    begin
        exit(AcquisitionofvehiclesLbl);
    end;

    procedure Custom2Vehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Custom2VehiclesName()));
    end;

    procedure AcqCostonDisposalVehiclesName(): Text[100]
    begin
        exit(VehiclesLbl);
    end;

    procedure AcqCostonDisposalVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcqCostonDisposalVehiclesName()));
    end;

    procedure AccumDepronDisposalVehiclesName(): Text[100]
    begin
        exit(AccumulateddepreciationofvehiclesLbl);
    end;

    procedure AccumDepronDisposalVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumDepronDisposalVehiclesName()));
    end;

    procedure WriteDownonDisposalVehiclesName(): Text[100]
    begin
        exit(VehiclesLbl);
    end;

    procedure WriteDownonDisposalVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WriteDownonDisposalVehiclesName()));
    end;

    procedure Custom2onDisposalVehiclesName(): Text[100]
    begin
        exit(AcquisitionofintangiblefixedassetsLbl);
    end;

    procedure Custom2onDisposalVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Custom2onDisposalVehiclesName()));
    end;

    procedure GainsonDisposalVehiclesName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetsdisposedLbl);
    end;

    procedure GainsonDisposalVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GainsonDisposalVehiclesName()));
    end;

    procedure LossesonDisposalVehiclesName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetsdisposedLbl);
    end;

    procedure LossesonDisposalVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LossesonDisposalVehiclesName()));
    end;

    procedure BookValonDispGainVehiclesName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetssoldLbl);
    end;

    procedure BookValonDispGainVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BookValonDispGainVehiclesName()));
    end;

    procedure BookValonDispLossVehiclesName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetssoldLbl);
    end;

    procedure BookValonDispLossVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BookValonDispLossVehiclesName()));
    end;

    procedure SalesonDispGainVehiclesName(): Text[100]
    begin
        exit(AccumulateddepreciationofvehiclesLbl);
    end;

    procedure SalesonDispGainVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesonDispGainVehiclesName()));
    end;

    procedure SalesonDispLossVehiclesName(): Text[100]
    begin
        exit(AccumulateddepreciationofvehiclesLbl);
    end;

    procedure SalesonDispLossVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesonDispLossVehiclesName()));
    end;

    procedure MaintenanceExpenseVehiclesName(): Text[100]
    begin
        exit(RepairsandMaintenanceLbl);
    end;

    procedure MaintenanceExpenseVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaintenanceExpenseVehiclesName()));
    end;

    procedure AcquisitionCostBalVehiclesName(): Text[100]
    begin
        exit(AcquisitionofvehiclesLbl);
    end;

    procedure AcquisitionCostBalVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionCostBalVehiclesName()));
    end;

    procedure DepreciationExpenseVehiclesName(): Text[100]
    begin
        exit(DepreciationofvehiclesLbl);
    end;

    procedure DepreciationExpenseVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationExpenseVehiclesName()));
    end;

    procedure AcqusitionCostBalonDisposalVehiclesName(): Text[100]
    begin
        exit(AccumulateddepreciationofvehiclesLbl);
    end;

    procedure AcqusitionCostBalonDisposalVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcqusitionCostBalonDisposalVehiclesName()));
    end;

    procedure ApprecBalonDispVehiclesName(): Text[100]
    begin
        exit(AccumulateddepreciationofvehiclesLbl);
    end;

    procedure ApprecBalonDispVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ApprecBalonDispVehiclesName()));
    end;

    procedure AppreciationonDisposalVehiclesName(): Text[100]
    begin
        exit(VehiclesLbl);
    end;

    procedure AppreciationonDisposalVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AppreciationonDisposalVehiclesName()));
    end;

    procedure AppreciationVehiclesName(): Text[100]
    begin
        exit(VehiclesLbl);
    end;

    procedure AppreciationVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AppreciationVehiclesName()));
    end;

    procedure AppreciationBalVehiclesName(): Text[100]
    begin
        exit(AcquisitionofvehiclesLbl);
    end;

    procedure AppreciationBalVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AppreciationBalVehiclesName()));
    end;

    procedure SalesBalVehiclesName(): Text[100]
    begin
        exit(InternalsettlementLbl);
    end;

    procedure SalesBalVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesBalVehiclesName()));
    end;

    procedure BookValueBalonDisposalVehiclesName(): Text[100]
    begin
        exit(AccumulateddepreciationofvehiclesLbl);
    end;

    procedure BookValueBalonDisposalVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BookValueBalonDisposalVehiclesName()));
    end;

    procedure AcquisitionCostEquipmentName(): Text[100]
    begin
        exit(MachinestoolsequipmentLbl);
    end;

    procedure AcquisitionCostEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionCostEquipmentName()));
    end;

    procedure WriteDownEquipmentName(): Text[100]
    begin
        exit(MachinestoolsequipmentLbl);
    end;

    procedure WriteDownEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WriteDownEquipmentName()));
    end;

    procedure AccumDepreciationEquipmentName(): Text[100]
    begin
        exit(AccumulateddepreciationofmachineryLbl);
    end;

    procedure AccumDepreciationEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumDepreciationEquipmentName()));
    end;

    procedure Custom2EquipmentName(): Text[100]
    begin
        exit(AcquisitionofmachineryLbl);
    end;

    procedure Custom2Equipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Custom2EquipmentName()));
    end;

    procedure AcqCostonDisposalEquipmentName(): Text[100]
    begin
        exit(MachinestoolsequipmentLbl);
    end;

    procedure AcqCostonDisposalEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcqCostonDisposalEquipmentName()));
    end;

    procedure AccumDepronDisposalEquipmentName(): Text[100]
    begin
        exit(AccumulateddepreciationofmachineryLbl);
    end;

    procedure AccumDepronDisposalEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumDepronDisposalEquipmentName()));
    end;

    procedure WriteDownonDisposalEquipmentName(): Text[100]
    begin
        exit(MachinestoolsequipmentLbl);
    end;

    procedure WriteDownonDisposalEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WriteDownonDisposalEquipmentName()));
    end;

    procedure Custom2onDisposalEquipmentName(): Text[100]
    begin
        exit(AcquisitionofmachineryLbl);
    end;

    procedure Custom2onDisposalEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Custom2onDisposalEquipmentName()));
    end;

    procedure GainsonDisposalEquipmentName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetsdisposedLbl);
    end;

    procedure GainsonDisposalEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GainsonDisposalEquipmentName()));
    end;

    procedure LossesonDisposalEquipmentName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetsdisposedLbl);
    end;

    procedure LossesonDisposalEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LossesonDisposalEquipmentName()));
    end;

    procedure BookValonDispGainEquipmentName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetssoldLbl);
    end;

    procedure BookValonDispGainEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BookValonDispGainEquipmentName()));
    end;

    procedure BookValonDispLossEquipmentName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetssoldLbl);
    end;

    procedure BookValonDispLossEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BookValonDispLossEquipmentName()));
    end;

    procedure SalesonDispGainEquipmentName(): Text[100]
    begin
        exit(AccumulateddepreciationofmachineryLbl);
    end;

    procedure SalesonDispGainEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesonDispGainEquipmentName()));
    end;

    procedure SalesonDispLossEquipmentName(): Text[100]
    begin
        exit(AccumulateddepreciationofmachineryLbl);
    end;

    procedure SalesonDispLossEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesonDispLossEquipmentName()));
    end;

    procedure MaintenanceExpenseEquipmentName(): Text[100]
    begin
        exit(RepairsandMaintenanceLbl);
    end;

    procedure MaintenanceExpenseEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaintenanceExpenseEquipmentName()));
    end;

    procedure AcquisitionCostBalEquipmentName(): Text[100]
    begin
        exit(AcquisitionofmachineryLbl);
    end;

    procedure AcquisitionCostBalEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionCostBalEquipmentName()));
    end;

    procedure DepreciationExpenseEquipmentName(): Text[100]
    begin
        exit(DepreciationofmachinesandtoolsLbl);
    end;

    procedure DepreciationExpenseEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationExpenseEquipmentName()));
    end;

    procedure AcqusitionCostBalonDisposalEquipmentName(): Text[100]
    begin
        exit(AccumulateddepreciationofmachineryLbl);
    end;

    procedure AcqusitionCostBalonDisposalEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcqusitionCostBalonDisposalEquipmentName()));
    end;

    procedure ApprecBalonDispEquipmentName(): Text[100]
    begin
        exit(AccumulateddepreciationofmachineryLbl);
    end;

    procedure ApprecBalonDispEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ApprecBalonDispEquipmentName()));
    end;

    procedure AppreciationonDisposalEquipmentName(): Text[100]
    begin
        exit(MachinestoolsequipmentLbl);
    end;

    procedure AppreciationonDisposalEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AppreciationonDisposalEquipmentName()));
    end;

    procedure AppreciationEquipmentName(): Text[100]
    begin
        exit(MachinestoolsequipmentLbl);
    end;

    procedure AppreciationEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AppreciationEquipmentName()));
    end;

    procedure AppreciationBalEquipmentName(): Text[100]
    begin
        exit(AcquisitionofmachineryLbl);
    end;

    procedure AppreciationBalEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AppreciationBalEquipmentName()));
    end;

    procedure SalesBalEquipmentName(): Text[100]
    begin
        exit(InternalsettlementLbl);
    end;

    procedure SalesBalEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesBalEquipmentName()));
    end;

    procedure BookValueBalonDisposalEquipmentName(): Text[100]
    begin
        exit(AccumulateddepreciationofmachineryLbl);
    end;

    procedure BookValueBalonDisposalEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BookValueBalonDisposalEquipmentName()));
    end;

    procedure AcquisitionCostPatentsName(): Text[100]
    begin
        exit(IntangibleresultsofresearchanddevelopmentLbl);
    end;

    procedure AcquisitionCostPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionCostPatentsName()));
    end;

    procedure WriteDownPatentsName(): Text[100]
    begin
        exit(IntangibleresultsofresearchanddevelopmentLbl);
    end;

    procedure WriteDownPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WriteDownPatentsName()));
    end;

    procedure AccumDepreciationPatentsName(): Text[100]
    begin
        exit(CorrectionstointangibleresultsofresearchanddevelopmentLbl);
    end;

    procedure AccumDepreciationPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumDepreciationPatentsName()));
    end;

    procedure Custom2PatentsName(): Text[100]
    begin
        exit(AcquisitionofintangiblefixedassetsLbl);
    end;

    procedure Custom2Patents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Custom2PatentsName()));
    end;

    procedure AcqCostonDisposalPatentsName(): Text[100]
    begin
        exit(IntangibleresultsofresearchanddevelopmentLbl);
    end;

    procedure AcqCostonDisposalPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcqCostonDisposalPatentsName()));
    end;

    procedure AccumDepronDisposalPatentsName(): Text[100]
    begin
        exit(CorrectionstointangibleresultsofresearchanddevelopmentLbl);
    end;

    procedure AccumDepronDisposalPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumDepronDisposalPatentsName()));
    end;

    procedure WriteDownonDisposalPatentsName(): Text[100]
    begin
        exit(IntangibleresultsofresearchanddevelopmentLbl);
    end;

    procedure WriteDownonDisposalPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WriteDownonDisposalPatentsName()));
    end;

    procedure Custom2onDisposalPatentsName(): Text[100]
    begin
        exit(AcquisitionofintangiblefixedassetsLbl);
    end;

    procedure Custom2onDisposalPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Custom2onDisposalPatentsName()));
    end;

    procedure GainsonDisposalPatentsName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetsdisposedLbl);
    end;

    procedure GainsonDisposalPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GainsonDisposalPatentsName()));
    end;

    procedure LossesonDisposalPatentsName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetsdisposedLbl);
    end;

    procedure LossesonDisposalPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LossesonDisposalPatentsName()));
    end;

    procedure BookValonDispGainPatentsName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetssoldLbl);
    end;

    procedure BookValonDispGainPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BookValonDispGainPatentsName()));
    end;

    procedure BookValonDispLossPatentsName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetssoldLbl);
    end;

    procedure BookValonDispLossPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BookValonDispLossPatentsName()));
    end;

    procedure SalesonDispGainPatentsName(): Text[100]
    begin
        exit(CorrectionstointangibleresultsofresearchanddevelopmentLbl);
    end;

    procedure SalesonDispGainPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesonDispGainPatentsName()));
    end;

    procedure SalesonDispLossPatentsName(): Text[100]
    begin
        exit(CorrectionstointangibleresultsofresearchanddevelopmentLbl);
    end;

    procedure SalesonDispLossPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesonDispLossPatentsName()));
    end;

    procedure MaintenanceExpensePatentsName(): Text[100]
    begin
        exit(RepairsandMaintenanceLbl);
    end;

    procedure MaintenanceExpensePatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaintenanceExpensePatentsName()));
    end;

    procedure AcquisitionCostBalPatentsName(): Text[100]
    begin
        exit(AcquisitionofintangiblefixedassetsLbl);
    end;

    procedure AcquisitionCostBalPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionCostBalPatentsName()));
    end;

    procedure DepreciationExpensePatentsName(): Text[100]
    begin
        exit(DeprecationofpatentsLbl);
    end;

    procedure DepreciationExpensePatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationExpensePatentsName()));
    end;

    procedure AcqusitionCostBalonDisposalPatentsName(): Text[100]
    begin
        exit(CorrectionstointangibleresultsofresearchanddevelopmentLbl);
    end;

    procedure AcqusitionCostBalonDisposalPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcqusitionCostBalonDisposalPatentsName()));
    end;

    procedure ApprecBalonDispPatentsName(): Text[100]
    begin
        exit(CorrectionstointangibleresultsofresearchanddevelopmentLbl);
    end;

    procedure ApprecBalonDispPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ApprecBalonDispPatentsName()));
    end;

    procedure AppreciationonDisposalPatentsName(): Text[100]
    begin
        exit(IntangibleresultsofresearchanddevelopmentLbl);
    end;

    procedure AppreciationonDisposalPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AppreciationonDisposalPatentsName()));
    end;

    procedure AppreciationPatentsName(): Text[100]
    begin
        exit(IntangibleresultsofresearchanddevelopmentLbl);
    end;

    procedure AppreciationPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AppreciationPatentsName()));
    end;

    procedure AppreciationBalPatentsName(): Text[100]
    begin
        exit(AcquisitionofintangiblefixedassetsLbl);
    end;

    procedure AppreciationBalPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AppreciationBalPatentsName()));
    end;

    procedure SalesBalPatentsName(): Text[100]
    begin
        exit(InternalsettlementLbl);
    end;

    procedure SalesBalPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesBalPatentsName()));
    end;

    procedure BookValueBalonDisposalPatentsName(): Text[100]
    begin
        exit(CorrectionstointangibleresultsofresearchanddevelopmentLbl);
    end;

    procedure BookValueBalonDisposalPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BookValueBalonDisposalPatentsName()));
    end;

    procedure AcquisitionCostSoftwareName(): Text[100]
    begin
        exit(SoftwareAccountLbl);
    end;

    procedure AcquisitionCostSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionCostSoftwareName()));
    end;

    procedure WriteDownSoftwareName(): Text[100]
    begin
        exit(SoftwareAccountLbl);
    end;

    procedure WriteDownSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WriteDownSoftwareName()));
    end;

    procedure AccumDepreciationSoftwareName(): Text[100]
    begin
        exit(CorrectionstoSoftwareLbl);
    end;

    procedure AccumDepreciationSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumDepreciationSoftwareName()));
    end;

    procedure Custom2SoftwareName(): Text[100]
    begin
        exit(AcquisitionofintangiblefixedassetsLbl);
    end;

    procedure Custom2Software(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Custom2SoftwareName()));
    end;

    procedure AcqCostonDisposalSoftwareName(): Text[100]
    begin
        exit(SoftwareAccountLbl);
    end;

    procedure AcqCostonDisposalSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcqCostonDisposalSoftwareName()));
    end;

    procedure AccumDepronDisposalSoftwareName(): Text[100]
    begin
        exit(CorrectionstoSoftwareLbl);
    end;

    procedure AccumDepronDisposalSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumDepronDisposalSoftwareName()));
    end;

    procedure WriteDownonDisposalSoftwareName(): Text[100]
    begin
        exit(SoftwareAccountLbl);
    end;

    procedure WriteDownonDisposalSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WriteDownonDisposalSoftwareName()));
    end;

    procedure Custom2onDisposalSoftwareName(): Text[100]
    begin
        exit(AcquisitionofintangiblefixedassetsLbl);
    end;

    procedure Custom2onDisposalSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(Custom2onDisposalSoftwareName()));
    end;

    procedure GainsonDisposalSoftwareName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetsdisposedLbl);
    end;

    procedure GainsonDisposalSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GainsonDisposalSoftwareName()));
    end;

    procedure LossesonDisposalSoftwareName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetsdisposedLbl);
    end;

    procedure LossesonDisposalSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LossesonDisposalSoftwareName()));
    end;

    procedure BookValonDispGainSoftwareName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetssoldLbl);
    end;

    procedure BookValonDispGainSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BookValonDispGainSoftwareName()));
    end;

    procedure BookValonDispLossSoftwareName(): Text[100]
    begin
        exit(NetbookvalueoffixedassetssoldLbl);
    end;

    procedure BookValonDispLossSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BookValonDispLossSoftwareName()));
    end;

    procedure SalesonDispGainSoftwareName(): Text[100]
    begin
        exit(CorrectionstoSoftwareLbl);
    end;

    procedure SalesonDispGainSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesonDispGainSoftwareName()));
    end;

    procedure SalesonDispLossSoftwareName(): Text[100]
    begin
        exit(CorrectionstoSoftwareLbl);
    end;

    procedure SalesonDispLossSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesonDispLossSoftwareName()));
    end;

    procedure MaintenanceExpenseSoftwareName(): Text[100]
    begin
        exit(RepairsandMaintenanceLbl);
    end;

    procedure MaintenanceExpenseSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaintenanceExpenseSoftwareName()));
    end;

    procedure AcquisitionCostBalSoftwareName(): Text[100]
    begin
        exit(AcquisitionofintangiblefixedassetsLbl);
    end;

    procedure AcquisitionCostBalSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitionCostBalSoftwareName()));
    end;

    procedure DepreciationExpenseSoftwareName(): Text[100]
    begin
        exit(DeprecationofsoftwareLbl);
    end;

    procedure DepreciationExpenseSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationExpenseSoftwareName()));
    end;

    procedure AcqusitionCostBalonDisposalSoftwareName(): Text[100]
    begin
        exit(CorrectionstoSoftwareLbl);
    end;

    procedure AcqusitionCostBalonDisposalSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcqusitionCostBalonDisposalSoftwareName()));
    end;

    procedure ApprecBalonDispSoftwareName(): Text[100]
    begin
        exit(CorrectionstoSoftwareLbl);
    end;

    procedure ApprecBalonDispSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ApprecBalonDispSoftwareName()));
    end;

    procedure AppreciationonDisposalSoftwareName(): Text[100]
    begin
        exit(SoftwareAccountLbl);
    end;

    procedure AppreciationonDisposalSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AppreciationonDisposalSoftwareName()));
    end;

    procedure AppreciationSoftwareName(): Text[100]
    begin
        exit(SoftwareAccountLbl);
    end;

    procedure AppreciationSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AppreciationSoftwareName()));
    end;

    procedure AppreciationBalSoftwareName(): Text[100]
    begin
        exit(AcquisitionofintangiblefixedassetsLbl);
    end;

    procedure AppreciationBalSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AppreciationBalSoftwareName()));
    end;

    procedure SalesBalSoftwareName(): Text[100]
    begin
        exit(InternalsettlementLbl);
    end;

    procedure SalesBalSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesBalSoftwareName()));
    end;

    procedure BookValueBalonDisposalSoftwareName(): Text[100]
    begin
        exit(CorrectionstoSoftwareLbl);
    end;

    procedure BookValueBalonDisposalSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BookValueBalonDisposalSoftwareName()));
    end;

    procedure SalesFixedAssetsName(): Text[100]
    begin
        exit(SalesFixedAssetsLbl);
    end;

    procedure SalesFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesFixedAssetsName()));
    end;

    procedure ConsumableMaterialsName(): Text[100]
    begin
        exit(ConsumableMaterialsLbl);
    end;

    procedure ConsumableMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsumableMaterialsName()));
    end;

    procedure "1Account"(): Code[10]
    begin
        exit("1AccountLbl");
    end;

    procedure "2Tax"(): Code[10]
    begin
        exit("2TaxLbl");
    end;

    procedure Liquid(): Code[10]
    begin
        exit(LIQUIDLbl);
    end;

    procedure Sale(): Code[10]
    begin
        exit(SALELbl);
    end;

    procedure SpareParts(): Code[10]
    begin
        exit(SPAREPARTSLbl);
    end;

    procedure Service(): Code[10]
    begin
        exit(SERVICELbl);
    end;

    procedure Car(): Code[10]
    begin
        exit(CARLbl);
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        BuildingsLbl: Label 'Buildings', MaxLength = 100;
        AcquisitionofbuildingsLbl: Label 'Acquisition of buildings', MaxLength = 100;
        AccumulateddepreciationofbuildingsLbl: Label 'Accumulated depreciation of buildings', MaxLength = 100;
        NetbookvalueoffixedassetsdisposedLbl: Label 'Net book value of fixed assets disposed', MaxLength = 100;
        NetbookvalueoffixedassetssoldLbl: Label 'Net book value of fixed assets sold', MaxLength = 100;
        RepairsandMaintenanceLbl: Label 'Repairs and Maintenance', MaxLength = 100;
        InternalsettlementLbl: Label 'Internal settlement', MaxLength = 100;
        GoodwillLbl: Label 'Goodwill', MaxLength = 100;
        CorrectionstogoodwillLbl: Label 'Corrections to goodwill', MaxLength = 100;
        AcquisitionofintangiblefixedassetsLbl: Label 'Acquisition of intangible fixed assets', MaxLength = 100;
        DeprecationofotherintangiblefixedassetsLbl: Label 'Deprecation of other intangible fixed assets', MaxLength = 100;
        VehiclesLbl: Label 'Vehicles', MaxLength = 100;
        AccumulateddepreciationofvehiclesLbl: Label 'Accumulated depreciation of vehicles', MaxLength = 100;
        AcquisitionofvehiclesLbl: Label 'Acquisition of vehicles', MaxLength = 100;
        DepreciationofvehiclesLbl: Label 'Depreciation of vehicles', MaxLength = 100;
        MachinestoolsequipmentLbl: Label 'Machines, tools, equipment', MaxLength = 100;
        AccumulateddepreciationofmachineryLbl: Label 'Accumulated depreciation of machinery', MaxLength = 100;
        AcquisitionofmachineryLbl: Label 'Acquisition of machinery', MaxLength = 100;
        DepreciationofmachinesandtoolsLbl: Label 'Depreciation of machines and tools', MaxLength = 100;
        IntangibleresultsofresearchanddevelopmentLbl: Label 'Intangible results of research and development', MaxLength = 100;
        CorrectionstointangibleresultsofresearchanddevelopmentLbl: Label 'Corrections to intangible results of research and development', MaxLength = 100;
        DeprecationofpatentsLbl: Label 'Deprecation of patents', MaxLength = 100;
        CorrectionstosoftwareLbl: Label 'Corrections to software', MaxLength = 100;
        DeprecationofsoftwareLbl: Label 'Deprecation of software', MaxLength = 100;
        SoftwareAccountLbl: Label 'Software', MaxLength = 100;
        SalesFixedAssetsLbl: Label 'Sales of fixed assets', MaxLength = 100;
        ConsumableMaterialsLbl: Label 'Consumable materials', MaxLength = 100;
        FurnitureLbl: Label 'FURNITURE', MaxLength = 20;
        PatentsLbl: Label 'PATENTS', MaxLength = 20;
        SoftwareLbl: Label 'SOFTWARE', MaxLength = 20;
        "1AccountLbl": Label '1-ACCOUNT', MaxLength = 10;
        "2TaxLbl": Label '2-TAX', MaxLength = 10;
        AccountBookLbl: Label 'Account book', MaxLength = 100;
        TaxBookLbl: Label 'Tax book', MaxLength = 100;
        LIQUIDLbl: Label 'LIQUID', MaxLength = 10;
        SALELbl: Label 'SALE', MaxLength = 10;
        SPAREPARTSLbl: Label 'SPAREPARTS', MaxLength = 10;
        SERVICELbl: Label 'SERVICE', MaxLength = 10;
        LiquidDescriptionLbl: Label 'Liquidation', MaxLength = 100;
        SaleDescriptionLbl: Label 'Sale', MaxLength = 100;
        SparePartsDescriptionLbl: Label 'Spare Parts', MaxLength = 100;
        ServiceDescriptionLbl: Label 'Service', MaxLength = 100;
        CARLbl: Label 'CAR', MaxLength = 10;
}
